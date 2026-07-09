# 验证日志

本文件是只追加证据流水账。

它只记录每轮变更的目的、文件范围、边界确认和验证结果。

它不是协议事实源，不替代 `README.md`、`ROADMAP.md`、PR 正文或 Linear 证据。

Agent / Graphify 默认读取 `docs/validation/latest-verification-summary.md`。

完整历史只在审计、追溯或 debug 时读取。

历史记录不压缩、不拆分、不重写。

## GH-1309 v0.22.0 Live Canary Transport Contract

日期：2026-07-05

执行者：Codex

- Anchors: `GH-1309-VERIFY-V0220-LIVE-CANARY-TRANSPORT-CONTRACT` / `TVM-RELEASE-V0220-LIVE-CANARY-TRANSPORT-CONTRACT` / `V0220-001-V0211-PREFLIGHT-GATE` / `V0220-001-BINANCE-SPOT-LIVE-CANARY-TRANSPORT` / `V0220-001-OPERATOR-APPROVAL-REQUIRED` / `V0220-001-ONE-SHOT-RUN-LOCK` / `V0220-001-RISK-KILL-NO-TRADE-OMS-RECONCILIATION` / `V0220-001-QUEUE-ORDER` / `V0220-001-NO-PRODUCTION-CUTOVER`.
- Command: `bash checks/verify-v0.22.0-live-canary-transport-contract.sh`.
- Scope: GH-1309 defines the Binance Spot one-shot live canary transport completion contract only.
- Boundary: no secret read, no endpoint connection, no submit / status / cancel implementation, no tag / GitHub Release publication and no production cutover authorization.

## GH-1310 v0.22.0 Operator Approval Run Lock

日期：2026-07-05

执行者：Codex

- Anchors: `GH-1310-VERIFY-V0220-OPERATOR-APPROVAL-RUN-LOCK` / `TVM-RELEASE-V0220-OPERATOR-APPROVAL-RUN-LOCK` / `V0220-002-BLOCKED-BY-GH1309` / `V0220-002-OPERATOR-APPROVAL-SESSION` / `V0220-002-SCOPE-BOUND-APPROVAL` / `V0220-002-APPROVAL-REUSE-FAILS-CLOSED` / `V0220-002-MISSING-STALE-MISMATCHED-FAILS-CLOSED` / `V0220-002-ONE-SHOT-RUN-LOCK` / `V0220-002-NO-SECRET-ENDPOINT-ORDER` / `V0220-002-NO-PRODUCTION-CUTOVER`.
- Command: `bash checks/verify-v0.22.0-operator-approval-run-lock.sh`.
- Scope: GH-1310 defines the operator approval session and one-shot run lock required after GH-1309.
- Boundary: approval cannot be reused, missing / stale / mismatched approval fails closed, concurrent live canary submit attempts are blocked, and GH-1310 does not read secrets, connect endpoints, submit orders, publish a release, or authorize production cutover.

## GH-1311 v0.22.0 Credential Secret Material Read Redaction

日期：2026-07-05

执行者：Codex

- Anchors: `GH-1311-VERIFY-V0220-CREDENTIAL-SECRET-MATERIAL-READ-REDACTION` / `TVM-RELEASE-V0220-CREDENTIAL-SECRET-MATERIAL-READ-REDACTION` / `V0220-003-BLOCKED-BY-GH1310` / `V0220-003-APPROVAL-BOUND-SECRET-READ` / `V0220-003-EPHEMERAL-SECRET-MATERIAL-ONLY` / `V0220-003-REDACTED-AUDIT-EVIDENCE` / `V0220-003-RAW-SECRET-NEVER-PERSISTED` / `V0220-003-MISSING-APPROVAL-FAILS-CLOSED` / `V0220-003-NO-ENDPOINT-ORDER` / `V0220-003-NO-PRODUCTION-CUTOVER`.
- Command: `bash checks/verify-v0.22.0-credential-secret-material-read-redaction.sh`.
- Scope: GH-1311 defines the approval-bound ephemeral credential secret material read path required after GH-1310.
- Boundary: raw secret / signature / listenKey never persist or log, missing / consumed / mismatched approval or missing secret material fails closed, and GH-1311 does not connect endpoints, sign requests, submit orders, publish a release, or authorize production cutover.

## GH-1312 v0.22.0 Signed Account Runtime Preflight

日期：2026-07-05

执行者：Codex

- Anchors: `GH-1312-VERIFY-V0220-SIGNED-ACCOUNT-RUNTIME-PREFLIGHT` / `TVM-RELEASE-V0220-SIGNED-ACCOUNT-RUNTIME-PREFLIGHT` / `V0220-004-BLOCKED-BY-GH1311` / `V0220-004-APPROVED-CANARY-SESSION-ONLY` / `V0220-004-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT` / `V0220-004-REDACTED-FRESHNESS-STATUS-EVIDENCE` / `V0220-004-RAW-ACCOUNT-PAYLOAD-NEVER-PERSISTED` / `V0220-004-ENDPOINT-AUTH-TIMESTAMP-PERMISSION-STALE-FAIL-CLOSED` / `V0220-004-FAILED-PREFLIGHT-BLOCKS-SUBMIT` / `V0220-004-NO-FUTURES-OKX` / `V0220-004-NO-ORDER-CUTOVER`.
- Command: `bash checks/verify-v0.22.0-signed-account-runtime-preflight.sh`.
- Scope: GH-1312 defines approved-session Binance Spot signed account read-only preflight evidence after GH-1311 credential secret material read evidence is held.
- Boundary: only redacted freshness/status evidence persists; endpoint / auth / timestamp / permission / stale response failures fail closed and block submit path; GH-1312 does not persist raw account payload or signature, enable Futures / OKX, submit orders, publish a release, or authorize production cutover.

## GH-1313 v0.22.0 Live Order Submit Transport

日期：2026-07-05

执行者：Codex

- Anchors: `GH-1313-VERIFY-V0220-LIVE-ORDER-SUBMIT-TRANSPORT` / `TVM-RELEASE-V0220-LIVE-ORDER-SUBMIT-TRANSPORT` / `V0220-005-BLOCKED-BY-GH1312` / `V0220-005-BINANCE-SPOT-ONE-SHOT-SUBMIT` / `V0220-005-ALLOWLISTED-SYMBOL-NOTIONAL-SIDE-TIF` / `V0220-005-COMMAND-RISK-KILL-NOTRADE-EXECUTION-OMS-GATES` / `V0220-005-REDACTED-EXCHANGE-ACK-EVIDENCE` / `V0220-005-SINGLE-APPROVED-ORDER-PER-RUN` / `V0220-005-FAIL-CLOSED-LIMIT-RISK-KILL-NOTRADE-TRANSPORT` / `V0220-005-NO-FUTURES-OKX` / `V0220-005-NO-DASHBOARD-TRADING-CONTROLS` / `V0220-005-NO-PRODUCTION-CUTOVER`.
- Command: `bash checks/verify-v0.22.0-live-order-submit-transport.sh`.
- Scope: GH-1313 defines one allowlisted Binance Spot canary submit transport evidence path after GH-1312 signed account preflight is ready.
- Boundary: CommandGateway, RiskEngine, kill switch, no-trade, ExecutionEngine and OMS gates are required; only redacted request / exchange ack evidence persists; limit / risk / kill switch / no-trade / duplicate / transport failure cases fail closed; GH-1313 does not enable Futures / OKX, Dashboard trading controls, release publication, or production cutover.

## GH-1314 v0.22.0 Live Order Status / Cancel Transport

日期：2026-07-05

执行者：Codex

- Anchors: `GH-1314-VERIFY-V0220-LIVE-ORDER-STATUS-CANCEL-TRANSPORT` / `TVM-RELEASE-V0220-LIVE-ORDER-STATUS-CANCEL-TRANSPORT` / `V0220-006-BLOCKED-BY-GH1313` / `V0220-006-STATUS-QUERY-BY-EXCHANGE-AND-CLIENT-ID` / `V0220-006-CANCEL-APPROVED-CANARY-ORDER-ONLY` / `V0220-006-IDEMPOTENCY-KEY-RETRY-CLASSIFICATION` / `V0220-006-REDACTED-STATUS-CANCEL-EVIDENCE` / `V0220-006-AMBIGUOUS-STATE-REQUIRES-RECONCILIATION` / `V0220-006-UNKNOWN-STATE-FAILS-CLOSED` / `V0220-006-NO-FUTURES-OKX` / `V0220-006-NO-DASHBOARD-TRADING-CONTROLS` / `V0220-006-NO-PRODUCTION-CUTOVER`.
- Command: `bash checks/verify-v0.22.0-status-cancel-transport.sh`.
- Scope: GH-1314 defines approved Binance Spot canary order status / cancel transport evidence after GH-1313 one-shot submit transport is ready.
- Boundary: status query is scoped to approved exchange/client order identifiers; cancel can target only the approved canary run/order; duplicate retry must be idempotent; ambiguous / unknown exchange state fails closed and requires reconciliation; GH-1314 persists only redacted status / cancel evidence and does not enable Futures / OKX, Dashboard trading controls, release publication, or production cutover.

## GH-1315 v0.22.0 OMS Event Log

日期：2026-07-05

执行者：Codex

- Anchors: `GH-1315-VERIFY-V0220-OMS-EVIDENCE-LOG` / `TVM-RELEASE-V0220-OMS-EVIDENCE-LOG` / `V0220-007-BLOCKED-BY-GH1313-GH1314` / `V0220-007-APPEND-ONLY-OMS-EVENT-LOG` / `V0220-007-SUBMIT-ACK-STATUS-CANCEL-TERMINAL-EVENTS` / `V0220-007-CORRELATION-CAUSATION-IDS` / `V0220-007-REDACTED-REPLAYABLE-EVIDENCE` / `V0220-007-REJECTS-MISSING-OUT-OF-ORDER-LIFECYCLE` / `V0220-007-NO-FUTURES-OKX` / `V0220-007-NO-DASHBOARD-TRADING-CONTROLS` / `V0220-007-NO-PRODUCTION-CUTOVER`.
- Command: `bash checks/verify-v0.22.0-oms-evidence-log.sh`.
- Scope: GH-1315 defines append-only OMS event log evidence after GH-1313 submit transport and GH-1314 status / cancel transport are ready.
- Boundary: submit ack, status observation, cancel request, cancel ack, terminal state, and ambiguous state share one run/order correlation and causation chain; missing status, missing cancel outcome, out-of-order lifecycle, correlation mismatch, or raw payload evidence fails closed; GH-1315 persists only redacted replayable OMS evidence and does not enable Futures / OKX, Dashboard trading controls, release publication, or production cutover.

## GH-1316 v0.22.0 Reconciliation Evidence

日期：2026-07-05

执行者：Codex

- Anchors: `GH-1316-VERIFY-V0220-RECONCILIATION-EVIDENCE` / `TVM-RELEASE-V0220-RECONCILIATION-EVIDENCE` / `V0220-008-BLOCKED-BY-GH1312-GH1315` / `V0220-008-OMS-EXCHANGE-STATUS-ACCOUNT-RECONCILIATION` / `V0220-008-MATCHED-PENDING-AMBIGUOUS-REJECTED-CANCELLED-FILL-LIKE` / `V0220-008-REDACTED-RECONCILIATION-ARTIFACT` / `V0220-008-MISSING-EXCHANGE-EVIDENCE-FAILS-CLOSED` / `V0220-008-AMBIGUOUS-STATE-FAILS-CLOSED` / `V0220-008-NEXT-OPERATOR-ACTION` / `V0220-008-NO-FUTURES-OKX` / `V0220-008-NO-DASHBOARD-TRADING-CONTROLS` / `V0220-008-NO-PRODUCTION-CUTOVER`.
- Command: `bash checks/verify-v0.22.0-reconciliation-evidence.sh`.
- Scope: GH-1316 defines redacted reconciliation artifact evidence after GH-1312 signed account preflight and GH-1315 OMS event log are ready.
- Boundary: matched / pending / ambiguous / rejected / cancelled / fill-like observations must be classified with next operator action; missing exchange evidence, ambiguous exchange state, missing OMS log evidence, or local-only assumptions fail closed; GH-1316 persists only redacted reconciliation evidence and does not enable Futures / OKX, Dashboard trading controls, release publication, or production cutover.

## GH-1317 v0.22.0 Failure Rollback Drill

日期：2026-07-05

执行者：Codex

- Anchors: `GH-1317-VERIFY-V0220-FAILURE-ROLLBACK-DRILL` / `TVM-RELEASE-V0220-FAILURE-ROLLBACK-DRILL` / `V0220-009-BLOCKED-BY-GH1315-GH1316` / `V0220-009-FAILURE-CLASSIFICATION` / `V0220-009-AUTH-ENDPOINT-RISK-KILL-NOTRADE-SUBMIT-CANCEL-STATUS-RECONCILIATION-ARTIFACT` / `V0220-009-DETERMINISTIC-NEXT-ACTION` / `V0220-009-KILL-SWITCH-BLOCKS-SUBMIT-CANCEL` / `V0220-009-NO-TRADE-BLOCKS-SUBMIT-CANCEL` / `V0220-009-ROLLBACK-DRILL-EVIDENCE` / `V0220-009-NO-UNINTENDED-ORDERS` / `V0220-009-NO-FUTURES-OKX` / `V0220-009-NO-DASHBOARD-TRADING-CONTROLS` / `V0220-009-NO-PRODUCTION-CUTOVER`.
- Command: `bash checks/verify-v0.22.0-failure-rollback-drill.sh`.
- Scope: GH-1317 defines failure classification and rollback drill evidence after GH-1315 OMS event log and GH-1316 reconciliation evidence are ready.
- Boundary: auth / endpoint / risk / kill switch / no-trade / submit / cancel / status / reconciliation / artifact failures must fail closed with deterministic next action; kill switch and no-trade block submit / cancel; rollback drill records no unintended orders and does not enable Futures / OKX, Dashboard trading controls, release publication, or production cutover.

## GH-1318 v0.22.0 Dashboard / CLI Live Canary Evidence Surface

日期：2026-07-06

执行者：Codex

- Anchors: `GH-1318-VERIFY-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE` / `TVM-RELEASE-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE` / `V0220-010-BLOCKED-BY-GH1317` / `V0220-010-LIVE-CANARY-EVIDENCE-CHAIN` / `V0220-010-APPROVAL-PREFLIGHT-SUBMIT-STATUS-CANCEL-OMS-RECONCILIATION` / `V0220-010-FAILURE-CLASS-NEXT-ACTION` / `V0220-010-READ-ONLY-DASHBOARD-CLI` / `V0220-010-REDACTION-FAILURE-STATES-VISIBLE` / `V0220-010-NO-TRADING-COMMANDS` / `V0220-010-NO-FUTURES-OKX` / `V0220-010-NO-PRODUCTION-CUTOVER`.
- Command: `bash checks/verify-v0.22.0-dashboard-cli-live-canary-evidence-surface.sh`.
- Scope: GH-1318 projects the live canary evidence chain after GH-1317 failure rollback drill into Dashboard and CLI read-only state surfaces.
- Boundary: approval, signed preflight, submit, status/cancel, OMS, reconciliation, failure class, next action, rollback and redaction evidence are visible only as redacted read-only rows; no trading button, order form, live command, raw order id, raw broker payload, submit / cancel / replace command, Futures / OKX, release publication or production cutover.

## GH-1307 v0.21.1 Canary Evidence Wording Guard

日期：2026-07-04

执行者：Codex

目的：

- 使用 `GH-1307-VERIFY-V0211-CANARY-EVIDENCE-WORDING`、`TVM-RELEASE-V0211-CANARY-EVIDENCE-WORDING`、`V0211-003-CONTROLLED-CANARY-EVIDENCE-WORDING`、`V0211-003-NOT-LIVE-NETWORK-EXECUTION`、`V0211-003-LIVE-SPOT-CANARY-TRANSPORT-FUTURE` 和 `V0211-003-NO-PRODUCTION-CUTOVER` 明确 v0.21.0 是 controlled canary evidence, not live network execution。
- 保留 `networkSubmitAttempted=false` / `networkCancelAttempted=false` 作为当前事实，并把 live Spot canary transport is future work 归入 v0.22.0 后续队列。

文件范围：

- `checks/verify-v0.21.1-v0210-canary-evidence-wording.sh`
- `checks/run.sh`
- `checks/automation-readiness.sh`
- `README.md`
- `GOAL.md`
- `BLUEPRINT.md`
- `docs/roadmap.md`
- `docs/automation/automation-readiness.md`
- `docs/validation/latest-verification-summary.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/release/release-publication-policy.md`
- `docs/release/mtpro-release-v0.21.0-binance-spot-controlled-production-canary-notes.md`
- `docs/audit/mtpro-release-v0.21.0-binance-spot-controlled-production-canary-stage-code-audit.md`
- `Tests/TargetGraphTests/TargetGraphTests.swift`

边界确认：

- 不创建 v0.21.1 tag / GitHub Release。

## GH-1308 v0.21.1 Patch Audit / Release Notes Closeout

日期：2026-07-05

执行者：Codex

目的：

- 使用 `GH-1308-VERIFY-V0211-PATCH-AUDIT-RELEASE-NOTES`、`TVM-RELEASE-V0211-PATCH-AUDIT-RELEASE-NOTES`、`V0211-004-AGGREGATE-GUARD`、`V0211-004-PATCH-AUDIT`、`V0211-004-RELEASE-NOTES`、`V0211-004-VALIDATION-MATRIX`、`V0211-004-NO-CAPABILITY-CHANGE`、`V0211-004-V0220-DOWNSTREAM-LIVE-TRANSPORT-HANDOFF`、`V0211-004-NO-PRODUCTION-CUTOVER` 和 `V0211-004-NO-TAG-OR-RELEASE-PUBLICATION` 收口 #1305..#1308 patch audit / release notes / validation matrix。
- 确认 #1305 / PR #1321、#1306 / PR #1322、#1307 / PR #1323 的 merge evidence 和 `checks` SUCCESS 已进入 v0.21.1 patch closeout 证据链。
- 确认 v0.21.0 stable GitHub Release fact remains `https://github.com/atxinbao/MTPRO/releases/tag/v0.21.0` / `bca492ed48324a8057c5dc7223d740426a54c3b1` / `2026-07-04T10:08:42Z`。
- 确认 v0.21.0 remains controlled canary evidence, not live network execution。
- 确认 live Spot canary transport is future work for v0.22.0。
- 确认 production cutover not authorized。

文件范围：

- `checks/verify-v0.21.1.sh`
- `checks/run.sh`
- `checks/automation-readiness.sh`
- `docs/audit/mtpro-release-v0.21.1-publication-fact-and-canary-semantics-patch-stage-code-audit.md`
- `docs/release/mtpro-release-v0.21.1-publication-fact-and-canary-semantics-patch-notes.md`
- `README.md`
- `GOAL.md`
- `BLUEPRINT.md`
- `docs/roadmap.md`
- `docs/automation/automation-readiness.md`
- `docs/validation/latest-verification-summary.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/release/release-publication-policy.md`
- `Tests/TargetGraphTests/TargetGraphTests.swift`

验证：

- `swift test --filter TargetGraphTests/testGH1308ReleaseV0211PatchAuditReleaseNotesCloseout`
- `bash checks/verify-v0.21.1.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

边界确认：

- 未创建 `v0.21.1` tag / GitHub Release。
- 未移动或覆盖 `v0.21.0` tag / GitHub Release。
- 未启动 v0.22.0。
- 未读取 production secret。
- 未连接 production endpoint / broker endpoint。
- 未发送 submit / cancel / replace。
- 未授权 production cutover。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不发送 submit / cancel / replace。
- production cutover not authorized。

## GH-1306 v0.21.1 v0.21.0 Stale Wording Guard

日期：2026-07-04

执行者：Codex

目的：

- 使用 `GH-1306-VERIFY-V0211-V0210-STALE-WORDING-GUARD`、`V0211-002-V0210-STALE-WORDING-GUARD`、`V0211-002-HISTORICAL-CONSTRUCTION-CLOSEOUT-ALLOWLIST`、`TVM-RELEASE-V0211-V0210-STALE-WORDING-GUARD`、`V0211-002-CURRENT-FACING-STALE-WORDING-REJECTION` 和 `V0211-002-NO-PRODUCTION-CUTOVER` 增加 v0.21.0 已发布事实的 stale wording guard。
- 拒绝 current-facing stale v0.21.0 publication wording；只允许带 release facts 的 #1286 historical construction closeout evidence。

Release 事实：

- Release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.21.0`
- Tag peeled commit：`bca492ed48324a8057c5dc7223d740426a54c3b1`
- Publication timestamp：`2026-07-04T10:08:42Z`

文件范围：

- `checks/verify-v0.21.1-v0210-stale-wording-guard.sh`
- `checks/run.sh`
- `checks/automation-readiness.sh`
- `README.md`
- `GOAL.md`
- `BLUEPRINT.md`
- `docs/roadmap.md`
- `docs/automation/automation-readiness.md`
- `docs/validation/latest-verification-summary.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/release/release-publication-policy.md`
- `docs/release/mtpro-release-v0.21.0-binance-spot-controlled-production-canary-notes.md`
- `docs/audit/mtpro-release-v0.21.0-binance-spot-controlled-production-canary-stage-code-audit.md`
- `Tests/TargetGraphTests/TargetGraphTests.swift`

边界确认：

- 不移动或重写 `v0.21.0` tag。
- 不创建 `v0.21.1` tag / GitHub Release。
- 不新增交易能力。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不发送 submit / cancel / replace。
- 不授权 production cutover。
- production cutover not authorized。

验证：

- `swift test --filter TargetGraphTests/testGH1306ReleaseV0211V0210StaleWordingGuardRejectsCurrentFacingDrift`
- `bash checks/verify-v0.21.1-v0210-stale-wording-guard.sh`
- `bash checks/verify-v0.21.0.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## GH-1305 v0.21.0 Release Publication Fact Sync

日期：2026-07-04

执行者：Codex

目的：

- 将已发布的 `v0.21.0` GitHub Release 事实同步到 root / release / audit / validation-facing 文档。
- 将 #1286 的 no-tag / no-release wording 明确标记为 historical construction closeout evidence，而不是当前发布事实。
- 固定 release URL、tag peeled commit 和 publication timestamp，避免后续文档漂移。

Release 事实：

- Release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.21.0`
- Tag peeled commit：`bca492ed48324a8057c5dc7223d740426a54c3b1`
- Publication timestamp：`2026-07-04T10:08:42Z`
- Release state：stable，`isDraft=false`，`isPrerelease=false`

文件范围：

- `README.md`
- `GOAL.md`
- `BLUEPRINT.md`
- `docs/roadmap.md`
- `docs/audit/mtpro-release-v0.21.0-binance-spot-controlled-production-canary-stage-code-audit.md`
- `docs/release/mtpro-release-v0.21.0-binance-spot-controlled-production-canary-notes.md`
- `docs/release/release-publication-policy.md`
- `docs/validation/latest-verification-summary.md`
- `checks/verify-v0.21.0-stage-audit-release-docs.sh`
- `Tests/TargetGraphTests/TargetGraphTests.swift`

边界确认：

- 不移动或重写 `v0.21.0` tag。
- 不创建新的 GitHub Release。
- 不新增交易能力。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不授权 production cutover。

验证：

- `swift test --filter TargetGraphTests/testGH1286ReleaseV0210StageAuditReleaseDocsCloseout`
- `bash checks/verify-v0.21.0-stage-audit-release-docs.sh`
- `bash checks/verify-v0.21.0.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## MTPRO Release v0.21.0 Stage Audit / Release Docs Closeout

日期：2026-07-04

执行者：Codex

目的：

- 使用 `GH-1286-VERIFY-V0210-STAGE-AUDIT-RELEASE-DOCS`、`TVM-RELEASE-V0210-STAGE-AUDIT-RELEASE-DOCS`、`V0210-014-STAGE-CODE-AUDIT`、`V0210-014-RELEASE-NOTES`、`V0210-014-VALIDATION-MATRIX`、`V0210-014-ROOT-DOCS-REFRESH`、`V0210-014-STALE-WORDING-GUARD`、`V0210-014-RELEASE-PUBLICATION-GATE-HANDOFF`、`V0210-014-NO-PRODUCTION-CUTOVER` 和 `V0210-014-NO-TAG-OR-RELEASE-PUBLICATION` 收口 v0.21.0 Stage Code Audit / release docs。
- 固定 `docs/audit/mtpro-release-v0.21.0-binance-spot-controlled-production-canary-stage-code-audit.md` 与 `docs/release/mtpro-release-v0.21.0-binance-spot-controlled-production-canary-notes.md` 为 #1273..#1286 closeout evidence。
- 记录 PR #1291..#1303 merged、required check `checks` SUCCESS、#1286 release publication gate handoff 和 production cutover boundary。

文件范围：

- `docs/audit/mtpro-release-v0.21.0-binance-spot-controlled-production-canary-stage-code-audit.md`
- `docs/release/mtpro-release-v0.21.0-binance-spot-controlled-production-canary-notes.md`
- `checks/verify-v0.21.0-stage-audit-release-docs.sh`
- `checks/run.sh`
- `checks/automation-readiness.sh`
- `README.md`
- `GOAL.md`
- `BLUEPRINT.md`
- `docs/roadmap.md`
- `docs/automation/automation-readiness.md`
- `docs/validation/latest-verification-summary.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/release/release-publication-policy.md`
- `Tests/TargetGraphTests/TargetGraphTests.swift`

边界确认：

- 不创建 tag / GitHub Release。
- 不创建下一 Project / Issue。
- 不推进 v0.22.0。
- 不读取 production secret value。
- 不连接 production endpoint / broker endpoint。
- 不授权 production cutover。
- production cutover not authorized。

验证：

- `bash checks/verify-v0.21.0-stage-audit-release-docs.sh`
- `git diff --check`
- `bash checks/verify-v0.21.0.sh`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## MTPRO Release v0.21.0 Aggregate Validation Suite

日期：2026-07-03

执行者：Codex

目的：

- 使用 `GH-1285-VERIFY-V0210-AGGREGATE-VALIDATION`、`TVM-RELEASE-V0210-AGGREGATE-VALIDATION`、`V0210-013-AGGREGATE-VALIDATION-SUITE`、`V0210-013-CANARY-READINESS-CHAIN`、`V0210-013-FOCUSED-GUARDS-COVERED`、`V0210-013-RUN-AUTOMATION-WIRING`、`V0210-013-NO-PRODUCTION-CUTOVER` 和 `V0210-013-NO-TAG-OR-RELEASE-PUBLICATION` 定义 v0.21.0 aggregate validation suite。
- 固定 `bash checks/verify-v0.21.0.sh` 为 v0.21.0 single aggregate verifier，按 GH-1273..GH-1284 顺序运行 12 个 focused verifier。
- 证明 approval、credential redaction、read-only preflight、snapshot redaction、hard limits、risk / kill / no-trade、submit evidence、cancel rollback、OMS / reconciliation、Dashboard / CLI read-only surface 和 operator runbook wiring 均由聚合入口覆盖。

文件范围：

- `checks/verify-v0.21.0.sh`
- `checks/run.sh`
- `checks/automation-readiness.sh`
- `README.md`
- `GOAL.md`
- `BLUEPRINT.md`
- `docs/roadmap.md`
- `docs/automation/automation-readiness.md`
- `docs/validation/latest-verification-summary.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `verification.md`

边界确认：

- 不新增 runtime capability。
- 不读取 production secret value。
- 不连接 production endpoint / broker endpoint。
- 不创建 tag / GitHub Release。
- 不授权 production cutover。
- 不新增 trading button、order form、live command 或新的 submit / cancel / replace runtime。

验证：

- `bash checks/verify-v0.21.0.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## MTPRO Release v0.21.0 Canary Operator Runbook

日期：2026-07-03

执行者：Codex

目的：

- 使用 `GH-1284-VERIFY-V0210-CANARY-OPERATOR-RUNBOOK`、`TVM-RELEASE-V0210-CANARY-OPERATOR-RUNBOOK`、`V0210-012-CANARY-OPERATOR-RUNBOOK`、`V0210-012-START-OBSERVE-CANCEL-ROLLBACK`、`V0210-012-INCIDENT-STOP-CONDITIONS`、`V0210-012-EVIDENCE-COLLECTION`、`V0210-012-NO-PRODUCTION-CUTOVER` 和 `V0210-012-NO-TAG-OR-RELEASE-PUBLICATION` 定义 Binance Spot controlled canary operator runbook。
- 固定 GH-1284 依赖 GH-1283，输出给 GH-1285，并保持 queue range `GH-1273..GH-1286`。

文件范围：

- `docs/operators/release-v0.21.0-binance-spot-controlled-canary-runbook.md`
- `checks/verify-v0.21.0-canary-operator-runbook.sh`
- `checks/run.sh`
- `checks/automation-readiness.sh`
- `README.md`
- `GOAL.md`
- `BLUEPRINT.md`
- `docs/roadmap.md`
- `docs/automation/automation-readiness.md`
- `docs/validation/latest-verification-summary.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `verification.md`

边界确认：

- 不新增 runtime capability。
- 不读取 production secret value。
- 不连接 production endpoint / broker endpoint。
- 不创建 tag / GitHub Release。
- 不授权 production cutover。
- 不新增 trading button、order form、live command 或 submit / cancel / replace runtime。

验证：

- `bash checks/verify-v0.21.0-canary-operator-runbook.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## MTPRO Release v0.21.0 Dashboard / CLI canary status surface

日期：2026-07-02

执行者：Codex

目的：

- 使用 `GH-1283-VERIFY-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE`、`TVM-RELEASE-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE`、`V0210-011-DASHBOARD-CLI-CANARY-STATUS`、`V0210-011-CANARY-STATE-GATES`、`V0210-011-RISK-ORDER-CANCEL-RECONCILIATION`、`V0210-011-READ-ONLY-NO-COMMANDS` 和 `V0210-011-NO-PRODUCTION-CUTOVER` 定义 GH-1282 后的 Dashboard / CLI 只读 canary status surface。
- 固定 GH-1283 依赖 GH-1280、GH-1281 和 GH-1282，输出给 GH-1284，并保持 queue range `GH-1273..GH-1286`。
- 明确 Dashboard 和 `mtpro canary-status` 只能展示 canary state、gate stack、risk decision、order lifecycle、cancel / rollback、reconciliation 和 redaction boundary。

边界确认：

- 未显示 trading button、order form 或 live command。
- 未执行 submit / cancel / replace。
- 未显示 raw order id 或 raw broker payload。
- 未保存 credential secret value。
- 未连接 production endpoint / broker endpoint。
- 未创建 tag / GitHub Release。
- 未授权 production cutover；production cutover not authorized。

验证命令：

- `swift test --filter AppTests/testGH1283DashboardCLIReadOnlyCanaryStatusSurfaceShowsCanaryEvidenceWithoutCommands`
- `swift test --filter TargetGraphTests/testGH1283ReleaseV0210DashboardCLIReadOnlyCanaryStatusSurface`
- `bash checks/verify-v0.21.0-dashboard-cli-canary-status-surface.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## MTPRO Release v0.21.0 canary OMS event log reconciliation

日期：2026-07-02

执行者：Codex

目的：

- 使用 `GH-1282-VERIFY-V0210-CANARY-OMS-EVENT-LOG-RECONCILIATION`、`TVM-RELEASE-V0210-CANARY-OMS-EVENT-LOG-RECONCILIATION`、`V0210-010-OMS-EVENT-LOG`、`V0210-010-CANARY-LIFECYCLE-EVENTS`、`V0210-010-STATUS-RESPONSES`、`V0210-010-CANCEL-OUTCOMES`、`V0210-010-RECONCILIATION-EVIDENCE`、`V0210-010-REDACTED-EVIDENCE`、`V0210-010-NO-BROAD-OMS-ROLLOUT` 和 `V0210-010-NO-PRODUCTION-CUTOVER` 定义 GH-1280 submit evidence 与 GH-1281 cancel / rollback evidence 后的本地 OMS event log / reconciliation evidence。
- 固定 GH-1282 依赖 GH-1280 和 GH-1281，输出给 GH-1283，并保持 queue range `GH-1273..GH-1286`。
- 明确 canary lifecycle 必须可由 redacted event log、status response、cancel outcome 和 reconciliation evidence 重构；任一证据缺失都 fail closed。

边界确认：

- 未保存 credential secret value。
- 未记录 API key / secret key / listenKey。
- 未保存 raw order id、raw status payload、raw cancel payload 或 raw broker payload。
- 未启用 broad production OMS rollout、Futures reconciliation 或 OKX reconciliation。
- 未执行 submit / cancel / replace。
- 未创建 tag / GitHub Release。
- 未授权 production cutover；production cutover not authorized。

验证命令：

- `swift test --filter TargetGraphTests/testGH1282ReleaseV0210CanaryOMSEventLogReconciliationEvidence`
- `bash checks/verify-v0.21.0-canary-oms-event-log-reconciliation.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## MTPRO Release v0.21.0 controlled canary cancel rollback guard

日期：2026-07-02

执行者：Codex

目的：

- 使用 `GH-1281-VERIFY-V0210-CONTROLLED-CANARY-CANCEL-ROLLBACK`、`TVM-RELEASE-V0210-CONTROLLED-CANARY-CANCEL-ROLLBACK`、`V0210-009-CONTROLLED-CANARY-CANCEL`、`V0210-009-STATUS-ROLLBACK-GUARD`、`V0210-009-AUDIT-EVIDENCE`、`V0210-009-REDACTED-CANCEL-EVIDENCE`、`V0210-009-SINGLE-CANARY-ORDER`、`V0210-009-NO-BULK-CANCEL`、`V0210-009-NO-FUTURES-CANCEL` 和 `V0210-009-NO-PRODUCTION-CUTOVER` 定义 v0.21.0 Binance Spot canary controlled cancel request evidence 和 status rollback guard。
- 固定 GH-1281 依赖 GH-1280 authorized submit evidence，输出给 GH-1282，并保持 queue range `GH-1273..GH-1286`。
- 明确 explicit cancel approval、redacted canary order reference、audit event、redacted cancel request evidence、status rollback guard 和 single canary order scope 任一缺失都 fail closed。

边界确认：

- 未保存 credential secret value。
- 未记录 API key / secret key / listenKey。
- 未保存 raw order id 或 raw cancel payload。
- 未执行 network cancel。
- 未启用 bulk cancel、Futures cancel 或 Dashboard default trading button。
- 未创建 tag / GitHub Release。
- 未授权 production cutover；production cutover not authorized。

验证命令：

- `swift test --filter TargetGraphTests/testGH1281ReleaseV0210ControlledCanaryCancelRollbackGuard`
- `bash checks/verify-v0.21.0-controlled-canary-cancel-rollback.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## MTPRO Release v0.21.0 controlled Spot canary submit path

日期：2026-07-02

执行者：Codex

目的：

- 使用 `GH-1280-VERIFY-V0210-CONTROLLED-SPOT-CANARY-SUBMIT`、`TVM-RELEASE-V0210-CONTROLLED-SPOT-CANARY-SUBMIT`、`V0210-008-CONTROLLED-SPOT-CANARY-SUBMIT`、`V0210-008-IDEMPOTENCY-KEY`、`V0210-008-AUDIT-EVENT`、`V0210-008-REDACTED-REQUEST-EVIDENCE`、`V0210-008-STRICT-SYMBOL-SIZE-SCOPE`、`V0210-008-SINGLE-APPROVED-ORDER`、`V0210-008-NO-REPEATED-AUTOMATION-LOOP` 和 `V0210-008-NO-PRODUCTION-CUTOVER` 定义 v0.21.0 Binance Spot canary controlled submit request evidence。
- 固定 GH-1280 依赖 GH-1279 accepted pre-trade evidence，输出给 GH-1281，并保持 queue range `GH-1273..GH-1286`。
- 明确 explicit submit approval、idempotency key、audit event、redacted request evidence 和 strict symbol / size scope 任一缺失都 fail closed。

边界确认：

- 未保存 credential secret value。
- 未记录 API key / secret key / listenKey。
- 未保存 raw request payload。
- 未执行 network submit。
- 未启用 repeated automation loop。
- 未启用 Dashboard default trading button、Futures / OKX scope 或 cancel / replace。
- 未创建 tag / GitHub Release。
- 未授权 production cutover；production cutover not authorized。

验证命令：

- `swift test --filter TargetGraphTests/testGH1280ReleaseV0210ControlledSpotCanarySubmitPath`
- `bash checks/verify-v0.21.0-controlled-spot-canary-submit.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## MTPRO Release v0.21.0 pre-trade risk / kill switch / no-trade gate

日期：2026-07-02

执行者：Codex

目的：

- 使用 `GH-1279-VERIFY-V0210-PRETRADE-RISK-KILL-NOTRADE`、`TVM-RELEASE-V0210-PRETRADE-RISK-KILL-NOTRADE`、`V0210-007-RISKENGINE-PRETRADE-GATE`、`V0210-007-GLOBAL-KILL-SWITCH-GATE`、`V0210-007-NO-TRADE-GATE`、`V0210-007-APPROVAL-GATE`、`V0210-007-HARD-LIMIT-GATE`、`V0210-007-AUDIT-EVIDENCE-NO-BYPASS` 和 `V0210-007-NO-PRODUCTION-CUTOVER` 定义 v0.21.0 Binance Spot canary submit-intent 前置组合 gate。
- 固定 GH-1279 依赖 GH-1278，输出给 GH-1280，并保持 queue range `GH-1273..GH-1286`。
- 明确 RiskEngine、global kill switch、no-trade、operator approval 和 hard-limit 任一失败都阻断 submit intent，并输出 audit evidence。

边界确认：

- 未保存 credential secret value。
- 未记录 API key / secret key / listenKey。
- 未保存 raw order payload。
- 未触达 order endpoint。
- 未尝试 network submit。
- 未提供 bypass path 或 Dashboard command shortcut。
- 未发送 submit / cancel / replace。
- 未创建 tag / GitHub Release。
- 未授权 production cutover；production cutover not authorized。

验证命令：

| Command | Result | Notes |
| --- | --- | --- |
| `swift test --filter TargetGraphTests/testGH1279ReleaseV0210PreTradeRiskKillNoTradeGate` | passed | 1 selected test / 0 failures |
| `bash checks/verify-v0.21.0-pretrade-risk-kill-notrade.sh` | passed | #1279 focused verifier passed |
| `git diff --check` | passed | whitespace check passed |
| `bash checks/automation-readiness.sh` | passed | automation readiness passed |
| `bash checks/run.sh` | passed | `788 tests / 0 failures`; `MTPRO checks passed.` |

## MTPRO Release v0.21.0 canary hard limits

日期：2026-07-02

执行者：Codex

目的：

- 使用 `GH-1278-VERIFY-V0210-CANARY-HARD-LIMITS`、`TVM-RELEASE-V0210-CANARY-HARD-LIMITS`、`V0210-006-CANARY-SYMBOL-ALLOWLIST`、`V0210-006-NOTIONAL-QUANTITY-CAPS`、`V0210-006-ORDER-TYPE-COUNT-WINDOW-LIMITS`、`V0210-006-PRE-TRADE-FAIL-CLOSED`、`V0210-006-NO-SUBMIT-CANCEL-REPLACE` 和 `V0210-006-NO-PRODUCTION-CUTOVER` 定义 v0.21.0 Binance Spot canary hard-limit pre-trade gate。
- 固定 GH-1278 依赖 GH-1276 和 GH-1277，输出给 GH-1279，并保持 queue range `GH-1273..GH-1286`。
- 明确 gate 只消费 GH-1277 redacted snapshot evidence，并在 canary order creation 前强制 symbol allowlist、notional cap、quantity cap、order type allowlist、order count cap 和 time-window limit。

边界确认：

- 未保存 credential secret value。
- 未记录 API key / secret key / listenKey。
- 未保存 raw order payload。
- 未触达 order endpoint。
- 未发送 submit / cancel / replace。
- 未创建 tag / GitHub Release。
- 未授权 production cutover；production cutover not authorized。

验证命令：

| Command | Result | Notes |
| --- | --- | --- |
| `swift test --filter TargetGraphTests/testGH1278ReleaseV0210CanaryHardLimitPreTradeGate` | passed | 1 selected test / 0 failures |
| `bash checks/verify-v0.21.0-canary-hard-limits.sh` | passed | #1278 focused verifier passed |
| `git diff --check` | passed | whitespace check passed |
| `bash checks/automation-readiness.sh` | passed | automation readiness passed |
| `bash checks/run.sh` | passed | `787 tests / 0 failures`; `MTPRO checks passed.` |

## MTPRO Release v0.21.0 live account snapshot redaction

日期：2026-07-02

执行者：Codex

目的：

- 使用 `GH-1277-VERIFY-V0210-LIVE-ACCOUNT-SNAPSHOT-REDACTION`、`TVM-RELEASE-V0210-LIVE-ACCOUNT-SNAPSHOT-REDACTION`、`V0210-005-LIVE-ACCOUNT-SNAPSHOT-REDACTION`、`V0210-005-CONSUMES-SIGNED-ACCOUNT-PREFLIGHT`、`V0210-005-ALLOWED-READINESS-FIELDS`、`V0210-005-FRESHNESS-STALE-FAIL-CLOSED`、`V0210-005-NO-RAW-BALANCE-ACCOUNT-ID` 和 `V0210-005-NO-PRODUCTION-CUTOVER` 定义 v0.21.0 Binance Spot redacted live account snapshot artifact 和 freshness evidence。
- 固定 GH-1277 依赖 GH-1276，输出给 GH-1278，并保持 queue range `GH-1273..GH-1286`。
- 明确 artifact 只保存 readiness / freshness 脱敏字段，stale 或 malformed snapshot fail closed，不保存 raw balance、account id 或 raw account payload。

边界确认：

- 未保存 credential secret value。
- 未记录 API key / secret key / listenKey。
- 未保存 raw balance、account id 或 raw account payload。
- 未触达 order endpoint。
- 未发送 submit / cancel / replace。
- 未创建 tag / GitHub Release。
- 未授权 production cutover；production cutover not authorized。

验证命令：

| Command | Result | Notes |
| --- | --- | --- |
| `swift test --filter TargetGraphTests/testGH1277ReleaseV0210LiveAccountSnapshotRedactionArtifact` | passed | 1 selected test / 0 failures |
| `bash checks/verify-v0.21.0-live-account-snapshot-redaction.sh` | passed | #1277 focused verifier passed |
| `git diff --check` | passed | whitespace check passed |
| `bash checks/automation-readiness.sh` | passed | automation readiness passed |
| `bash checks/run.sh` | passed | full local validation passed: 786 tests / 0 failures |

## MTPRO Release v0.21.0 signed account read-only preflight

日期：2026-07-02

执行者：Codex

目的：

- 使用 `GH-1276-VERIFY-V0210-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT`、`TVM-RELEASE-V0210-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT`、`V0210-004-SIGNED-ACCOUNT-READ-ONLY-PREFLIGHT`、`V0210-004-CONSUMES-CREDENTIAL-APPROVAL`、`V0210-004-REDACTED-ACCOUNT-STATUS-EVIDENCE`、`V0210-004-NO-RAW-ACCOUNT-PAYLOAD`、`V0210-004-NO-ORDER-ENDPOINT` 和 `V0210-004-NO-PRODUCTION-CUTOVER` 定义 v0.21.0 Binance Spot signed account read-only runtime preflight。
- 固定 GH-1276 依赖 GH-1275，输出给 GH-1277，并保持 queue range `GH-1273..GH-1286`。
- 明确 preflight 只消费 GH-1275 approval evidence，输出 redacted account status evidence，不保存 raw account payload。

边界确认：

- 未保存 credential secret value。
- 未记录 API key / secret key / listenKey。
- 未保存 raw account payload。
- 未触达 order endpoint。
- 未发送 submit / cancel / replace。
- 未创建 tag / GitHub Release。
- 未授权 production cutover；production cutover not authorized。

验证命令：

| Command | Result | Notes |
| --- | --- | --- |
| `swift test --filter TargetGraphTests/testGH1276ReleaseV0210SignedAccountReadOnlyRuntimePreflight` | passed | 1 selected test / 0 failures |
| `bash checks/verify-v0.21.0-signed-account-readonly-preflight.sh` | passed | #1276 focused verifier passed |
| `git diff --check` | passed | whitespace check passed |
| `bash checks/automation-readiness.sh` | passed | automation readiness passed |
| `bash checks/run.sh` | passed | 785 tests / 0 failures；MTPRO checks passed |

## MTPRO Release v0.21.0 credential secret-read approval

日期：2026-07-02

执行者：Codex

目的：

- 使用 `GH-1275-VERIFY-V0210-CREDENTIAL-SECRET-READ-APPROVAL`、`TVM-RELEASE-V0210-CREDENTIAL-SECRET-READ-APPROVAL`、`V0210-003-CREDENTIAL-SECRET-READ-APPROVAL`、`V0210-003-EXPLICIT-OPERATOR-APPROVAL`、`V0210-003-REDACTED-AUDIT-EVIDENCE`、`V0210-003-NO-AUTOMATIC-SECRET-DISCOVERY`、`V0210-003-NO-SECRET-LOGGING` 和 `V0210-003-NO-ENDPOINT-ORDER-CUTOVER` 定义 v0.21.0 Binance Spot canary credential secret-read approval path。
- 固定 GH-1275 依赖 GH-1274，输出给 GH-1276，并保持 queue range `GH-1273..GH-1286`。
- 明确 approval path 只记录 explicit Human operator approval、redacted credential reference 和 append-only audit evidence；授权后续 gate 消费审批事实，但本 issue 不读取 secret value。

边界确认：

- 未读取 secret value。
- 未自动发现 fallback secret。
- 未记录 credential value。
- 未连接 production endpoint / broker endpoint。
- 未实现 signed account endpoint runtime。
- 未发送 submit / cancel / replace。
- 未创建 tag / GitHub Release。
- 未授权 production cutover；production cutover not authorized。

验证命令：

| Command | Result | Notes |
| --- | --- | --- |
| `swift test --filter TargetGraphTests/testGH1275ReleaseV0210CredentialSecretReadApprovalPath` | pending | #1275 focused TargetGraph test，随 PR 验证执行 |
| `bash checks/verify-v0.21.0-credential-secret-read-approval.sh` | pending | #1275 focused verifier，随 PR 验证执行 |
| `git diff --check` | pending | 随 PR 验证执行 |
| `bash checks/automation-readiness.sh` | pending | 随 PR 验证执行 |
| `bash checks/run.sh` | pending | 随 PR 验证执行 |

## MTPRO Release v0.21.0 spot canary environment profile

日期：2026-07-01

执行者：Codex

目的：

- 使用 `GH-1274-VERIFY-V0210-SPOT-CANARY-ENVIRONMENT-PROFILE`、`TVM-RELEASE-V0210-SPOT-CANARY-ENVIRONMENT-PROFILE`、`V0210-002-BINANCE-SPOT-CANARY-PROFILE`、`V0210-002-DEFAULT-OFF-FAIL-CLOSED`、`V0210-002-OPERATOR-OPT-IN-EVIDENCE`、`V0210-002-NO-SECRET-ENDPOINT-ORDER` 和 `V0210-002-NO-PRODUCTION-CUTOVER` 定义 v0.21.0 Binance Spot canary environment profile。
- 固定 GH-1274 依赖 GH-1273，输出给 GH-1275，并保持 queue range `GH-1273..GH-1286`。
- 明确 profile 只表达 productionLive identity、default-off fail-closed policy 和显式 Human operator opt-in evidence 需求，不实现 secret read、endpoint connection、signed account runtime 或 submit / cancel / replace。

边界确认：

- 未读取 production secret。
- 未连接 production endpoint / broker endpoint。
- 未实现 signed account endpoint runtime。
- 未发送 submit / cancel / replace。
- 未创建 tag / GitHub Release。
- 未授权 production cutover；production cutover not authorized。

验证结果：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter TargetGraphTests/testGH1274ReleaseV0210SpotCanaryEnvironmentProfile` | pending | #1274 focused profile test，随 PR 验证执行 |
| `bash checks/verify-v0.21.0-spot-canary-environment-profile.sh` | pending | #1274 focused verifier，随 PR 验证执行 |
| `git diff --check` | pending | whitespace 检查待执行 |
| `bash checks/automation-readiness.sh` | pending | automation readiness guard 待执行 |
| `bash checks/run.sh` | pending | 全量本地验证待执行 |

## MTPRO Release v0.21.0 controlled canary contract

日期：2026-07-01

执行者：Codex

目的：

- 使用 `GH-1273-VERIFY-V0210-CONTROLLED-CANARY-CONTRACT`、`TVM-RELEASE-V0210-CONTROLLED-CANARY-CONTRACT`、`V0210-001-V0201-PREFLIGHT-GATE`、`V0210-001-BINANCE-SPOT-CONTROLLED-CANARY`、`V0210-001-HUMAN-APPROVAL-REQUIRED`、`V0210-001-SYMBOL-ALLOWLIST-SIZE-CAPS`、`V0210-001-RISK-KILL-NO-TRADE-GATES`、`V0210-001-QUEUE-ORDER` 和 `V0210-001-NO-PRODUCTION-CUTOVER` 定义 v0.21.0 Binance Spot controlled production canary 首个合同。
- 固定 GH-1273..GH-1286 queue order、GH-1272 preflight、Human operator approval、symbol allowlist、notional / exposure size caps、RiskEngine / kill switch / no-trade gates 和 auditable evidence 要求。
- 明确 GH-1273 是 contract-only，不实现 secret read、endpoint connection、signed account runtime 或 submit / cancel / replace。

边界确认：

- 未读取 production secret。
- 未连接 production endpoint / broker endpoint。
- 未实现 signed account endpoint runtime。
- 未发送 submit / cancel / replace。
- 未创建 tag / GitHub Release。
- 未授权 production cutover；production cutover not authorized。

验证结果：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter TargetGraphTests/testGH1273ReleaseV0210SpotControlledProductionCanaryContract` | pending | #1273 focused contract test，随 PR 验证执行 |
| `bash checks/verify-v0.21.0-controlled-canary-contract.sh` | pending | #1273 focused verifier，随 PR 验证执行 |
| `git diff --check` | pending | whitespace 检查待执行 |
| `bash checks/automation-readiness.sh` | pending | automation readiness guard 待执行 |
| `bash checks/run.sh` | pending | 全量本地验证待执行 |

## MTPRO Release v0.20.1 patch audit / release notes closeout

日期：2026-07-01

执行者：Codex

目的：

- 使用 `GH-1272-VERIFY-V0201-PATCH-AUDIT-RELEASE-NOTES`、`TVM-RELEASE-V0201-PATCH-AUDIT-RELEASE-NOTES`、`V0201-004-AGGREGATE-GUARD`、`V0201-004-PATCH-AUDIT`、`V0201-004-RELEASE-NOTES`、`V0201-004-VALIDATION-MATRIX`、`V0201-004-NO-CAPABILITY-CHANGE`、`V0201-004-V0210-DOWNSTREAM-CANARY-HANDOFF`、`V0201-004-NO-PRODUCTION-CUTOVER` 和 `V0201-004-NO-TAG-OR-RELEASE-PUBLICATION` 收口 #1269..#1272 patch audit / release notes / validation matrix。
- 确认 #1269 / PR #1287、#1270 / PR #1288、#1271 / PR #1289 的 merge evidence 和 `checks` SUCCESS 已进入 v0.20.1 patch closeout 证据链。
- 记录 v0.20.0 stable GitHub Release 事实：`https://github.com/atxinbao/MTPRO/releases/tag/v0.20.0` / `7f84999e8e4071fb71fdc802f895de81303bbcfd` / `2026-06-30T16:55:24Z`。
- 明确 GH-1243 public-market probe 是 classification evidence，不是 live transport proof；GH-1244 signed-account readiness 是 intent evidence，不是 account access proof 或 account payload retrieval。
- 明确 v0.21.0 Spot canary is downstream only。

边界确认：

- 未创建 `v0.20.1` tag / GitHub Release。
- 未移动 `v0.20.0` tag，未覆盖 GitHub Release。
- 未读取 production secret。
- 未连接 production endpoint / broker endpoint。
- 未进行 account payload retrieval。
- 未发送 submit / cancel / replace。
- 未授权 production cutover；production cutover not authorized。

验证结果：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter TargetGraphTests/testGH1272ReleaseV0201PatchAuditReleaseNotesCloseout` | pass | #1272 focused patch audit / release notes closeout test，1 test / 0 failures |
| `bash checks/verify-v0.20.1.sh` | pass | #1272 aggregate verifier passed |
| `git diff --check` | pass | whitespace 检查通过 |
| `bash checks/automation-readiness.sh` | pass | automation readiness guard passed |
| `bash checks/run.sh` | pass | 全量本地验证通过，781 tests / 0 failures；`MTPRO checks passed.` |

## MTPRO Release v0.20.1 public probe classification evidence

日期：2026-07-01

执行者：Codex

目的：

- 使用 `GH-1271-VERIFY-V0201-PUBLIC-PROBE-CLASSIFICATION-EVIDENCE`、`TVM-RELEASE-V0201-PUBLIC-PROBE-CLASSIFICATION-EVIDENCE`、`V0201-003-PUBLIC-MARKET-PROBE-CLASSIFICATION-EVIDENCE`、`V0201-003-SIGNED-ACCOUNT-READINESS-INTENT-EVIDENCE`、`V0201-003-NOT-LIVE-TRANSPORT-PROOF`、`V0201-003-NO-ACCOUNT-PAYLOAD-RETRIEVAL`、`V0201-003-NO-ENDPOINT-CONNECTION` 和 `V0201-003-NO-PRODUCTION-CUTOVER` 固定 v0.20.0 public-market probe / signed-account readiness 的证据语义。
- GH-1243 public-market probe 是 classification evidence，不是 live transport proof。
- GH-1244 signed-account readiness 是 intent evidence，不是 account access proof 或 account payload retrieval。

边界确认：

- 未读取 production secret。
- 未连接 production endpoint / broker endpoint。
- 未进行 account payload retrieval。
- 未发送 submit / cancel / replace。
- 未移动 `v0.20.0` tag，未覆盖 GitHub Release。
- 未创建 `v0.20.1` tag / GitHub Release。
- 未授权 production cutover；production cutover not authorized。

验证结果：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter TargetGraphTests/testGH1271ReleaseV0201PublicProbeClassificationEvidenceGuard` | pass | #1271 focused classification evidence test，1 test / 0 failures |
| `bash checks/verify-v0.20.1-v0200-probe-classification-evidence.sh` | pass | #1271 focused verifier passed |
| `git diff --check` | pass | whitespace 检查通过 |
| `bash checks/automation-readiness.sh` | pass | automation readiness guard passed |
| `bash checks/run.sh` | pass | 全量本地验证通过，780 tests / 0 failures |

## MTPRO Release v0.20.1 v0.20.0 stale wording guard

日期：2026-07-01

执行者：Codex

目的：

- 使用 `GH-1270-VERIFY-V0201-V0200-STALE-WORDING-GUARD`、`V0201-002-V0200-STALE-WORDING-GUARD`、`V0201-002-HISTORICAL-CONSTRUCTION-CLOSEOUT-ALLOWLIST`、`TVM-RELEASE-V0201-V0200-STALE-WORDING-GUARD`、`V0201-002-CURRENT-FACING-STALE-WORDING-REJECTION` 和 `V0201-002-NO-PRODUCTION-CUTOVER` 增加 v0.20.0 已发布事实的 stale wording guard。
- 拒绝 current-facing stale v0.20.0 publication wording；允许带 release facts 的 #1250 historical construction closeout evidence。
- Release fact remains `https://github.com/atxinbao/MTPRO/releases/tag/v0.20.0` / `7f84999e8e4071fb71fdc802f895de81303bbcfd` / `2026-06-30T16:55:24Z`。

边界确认：

- 未移动 `v0.20.0` tag。
- 未覆盖 GitHub Release。
- 未创建 `v0.20.1` tag / GitHub Release。
- 未读取 production secret。
- 未连接 production endpoint / broker endpoint。
- 未发送 submit / cancel / replace。
- 未授权 production cutover；production cutover not authorized。

验证结果：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter TargetGraphTests/testGH1270ReleaseV0201V0200StaleWordingGuardRejectsCurrentFacingDrift` | pass | focused stale wording guard；1 test / 0 failures |
| `bash checks/verify-v0.20.1-v0200-stale-wording-guard.sh` | pass | #1270 focused verifier |
| `git diff --check` | pass | whitespace 检查 |
| `bash checks/automation-readiness.sh` | pass | automation readiness guard |
| `bash checks/run.sh` | pass | 全量本地验证；779 tests / 0 failures；`MTPRO checks passed` |

## MTPRO Release v0.18.0 stage audit / release docs closeout

日期：2026-06-28

执行者：Codex

目的：

- 使用 `GH-1185-VERIFY-V0180-STAGE-AUDIT-RELEASE-DOCS`、`TVM-RELEASE-V0180-STAGE-AUDIT-RELEASE-DOCS`、`V0180-010-STAGE-CODE-AUDIT`、`V0180-010-RELEASE-NOTES`、`V0180-010-VALIDATION-MATRIX`、`V0180-010-ROOT-DOCS-REFRESH`、`V0180-010-STALE-WORDING-GUARD`、`V0180-010-NO-PRODUCTION-CUTOVER` 和 `V0180-010-NO-TAG-OR-RELEASE-PUBLICATION` 收口 v0.18.0 construction queue。
- 记录 `#1176..#1185` issue completion、PR #1190..#1198 merge evidence、required `checks` success、Stage Code Audit、release notes、validation matrix 和 root docs refresh。
- 明确 #1185 不创建 `v0.18.0` tag，不创建 GitHub Release，不创建下一 Project / Issue，不推进下一 Todo，不授权 production cutover；production cutover not authorized。

边界确认：

- 未创建 tag / GitHub Release。
- 未创建下一 Project / Issue。
- 未推进下一 Todo。
- 未启动 Linear / Symphony / Graphify / code-index / Figma。
- 未读取 production secret。
- 未连接 production endpoint / broker endpoint。
- 未发送 testnet 或 production submit / cancel / replace。
- 未授权 production cutover。

验证结果：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter TargetGraphTests/testGH1185ReleaseV0180StageAuditReleaseDocsCloseout` | pass | focused root docs / closeout guard；1 个 XCTest / 0 failures |
| `bash checks/verify-v0.18.0-stage-audit-release-docs.sh` | pass | #1185 aggregate verifier |
| `git diff --check` | pass | whitespace 检查 |
| exact pasted testnet key scan | pass | 未在 `Sources`、`Tests`、`checks`、`docs`、root docs 或 `verification.md` 中发现用户粘贴的 testnet key / secret |
| `bash checks/automation-readiness.sh` | pass | automation readiness guard |
| `bash checks/run.sh` | pass | 全量本地验证，743 XCTest / 0 failures，最终输出 `MTPRO checks passed.` |

## MTPRO Release v0.10.0 final audit / docs / runbook closure

日期：2026-06-18

执行者：Codex

PR：#905 `Close v0.10.0 final audit docs runbook` 已 merged

提交：`7b0e1f8bb6a671cd3b96f7e7b020b803f8cea4b4`

目的：

- 记录 `MTPRO Release v0.10.0 Production Cutover Readiness Gate` 的 final Stage Code Audit、release notes、operator runbook、root docs refresh 和 aggregate verifier final guard。
- 将最新完成范围从 v0.9.0 提升到 v0.10.0 completed readiness facts。
- 保持 production trading disabled by default，不授权 production cutover；v0.10.0 已在后续独立 publication gate 发布 stable GitHub Release。
- v0.10.0 GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.10.0`；tag target commit：`7b0e1f8bb6a671cd3b96f7e7b020b803f8cea4b4`；publication timestamp：`2026-06-18T05:19:46Z`。

文件范围：

- 新增：
  - `docs/audit/mtpro-release-v0.10.0-production-cutover-readiness-gate-stage-code-audit.md`
  - `docs/release/mtpro-release-v0.10.0-production-cutover-readiness-gate-notes.md`
  - `docs/operators/release-v0.10.0-production-cutover-readiness-gate-runbook.md`
  - `checks/verify-v0.10.0.sh`
- 更新：
  - `README.md`
  - `GOAL.md`
  - `BLUEPRINT.md`
  - `docs/roadmap.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/automation/automation-readiness.md`
  - `checks/automation-readiness.sh`
  - `checks/run.sh`
  - `verification.md`

边界确认：

- 未创建下一 Project / Issue。
- 未推进下一 Todo。
- 未启动 Linear。
- 未启动 Symphony / `symphony-issue`。
- 未运行 Graphify / code-index。
- 未修改 Figma。
- 未实现新业务 runtime。
- #891 construction closeout PR 本身未创建 release tag。
- #891 construction closeout PR 本身未创建 GitHub Release。
- v0.10.0 已在后续独立 publication gate 发布 stable GitHub Release；该 publication 不授权 production cutover。
- 未授权 production trading。
- 未读取 production secret。
- 未连接 production endpoint / broker endpoint。
- 未发送 testnet 或 production order。
- 未授权 production cutover。
- 未提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

验证计划：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/verify-v0.10.0.sh` | pass | 聚合 v0.10.0 focused verifiers 和 root docs guards |
| `git diff --check` | pass | whitespace 检查 |
| `bash checks/automation-readiness.sh` | pass | automation readiness guard |
| `bash checks/run.sh` | pass | 全量本地验证，591 tests / 0 failures |

## GH-906 v0.10.0 release publication docs alignment

日期：2026-06-18

执行者：Codex

目的：

- 同步 v0.10.0 stable GitHub Release 已发布事实。
- 替换 root docs、release docs、runbook、latest summary 和验证流水账中的 release pending / no tag / no GitHub Release 旧口径。
- 保持 production cutover 未授权、production trading 默认关闭。

文件范围：

- `README.md`
- `docs/roadmap.md`
- `docs/release/release-publication-policy.md`
- `docs/release/mtpro-release-v0.10.0-production-cutover-readiness-gate-notes.md`
- `docs/operators/release-v0.10.0-production-cutover-readiness-gate-runbook.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

边界确认：

- 未修改业务代码。
- 未修改 `Package.swift`。
- 未创建或移动 tag。
- 未创建或覆盖 GitHub Release。
- 未授权 production cutover。
- 未读取 production secret。
- 未连接 production endpoint / broker endpoint。
- 未提交 testnet 或 production order。

## GH-907 v0.10.1 release fact sync stale wording guard

日期：2026-06-18

执行者：Codex

目的：

- 新增 release fact sync / stale wording guard，确保 v0.10.0 stable GitHub Release 已发布事实持续同步。
- 固定四段 release fact flow：construction closeout gate、release publication gate、release fact sync gate、stale wording guard gate。
- 将 v0.10.0 release URL `https://github.com/atxinbao/MTPRO/releases/tag/v0.10.0` 和 target commit `7b0e1f8bb6a671cd3b96f7e7b020b803f8cea4b4` 纳入 guard。
- 保持 production cutover 独立且未授权，production trading 默认关闭。

文件范围：

- 新增：
  - `checks/verify-v0.10.1-release-fact-sync.sh`
- 更新：
  - `checks/verify-v0.10.0.sh`
  - `checks/run.sh`
  - `checks/automation-readiness.sh`
  - `docs/release/release-publication-policy.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/automation/automation-readiness.md`
  - `docs/validation/latest-verification-summary.md`
  - `Tests/TargetGraphTests/TargetGraphTests.swift`
  - `verification.md`

边界确认：

- 未移动既有 release tag。
- 未重写 GitHub Release。
- 未创建下一 Project / Issue。
- 未推进下一 Todo。
- 未启动 Linear。
- 未启动 Symphony / `symphony-issue`。
- 未运行 Graphify / code-index。
- 未修改 Figma。
- 未实现 runtime / OMS / broker gateway / Live PRO Console command。
- 未授权 production cutover / production trading。
- 未读取 production secret。
- 未连接 production endpoint / broker endpoint。
- 未提交 testnet 或 production order。
- 未提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

验证计划：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/verify-v0.10.1-release-fact-sync.sh` | pass | focused stale wording / release fact sync guard |
| `swift test --filter TargetGraphTests/testGH907ReleaseFactSyncGuardRejectsV0100StalePublicationWording` | pass | 1 test / 0 failures |
| `git diff --check` | pass | whitespace 检查 |
| `bash checks/automation-readiness.sh` | pass | automation readiness guard |
| `bash checks/verify-v0.10.0.sh` | pass | v0.10.0 aggregate verifier 已调用 v0.10.1 release fact sync guard |
| `bash checks/run.sh` | pass | 全量本地验证，592 tests / 0 failures |

## GH-908 v0.10.1 Dashboard macOS v0.10 focused guard

日期：2026-06-18

执行者：Codex

目的：

- 新增 v0.10 Dashboard macOS focused guard，确保 required `dashboard-macos` job 在 Dashboard build / smoke 前执行 v0.10 Production Readiness Center guard。
- 复用 `checks/verify-v0.10.0-dashboard-production-readiness-center.sh`，并在 macOS 本地执行 `DASHBOARD_SMOKE=1 swift run Dashboard`。
- 固定 Dashboard 仍为 read-model-only / readiness-only surface，不开放 production command surface。
- 保持 production cutover 未授权、production trading 默认关闭。

文件范围：

- 新增：
  - `checks/verify-v0.10.1-dashboard-macos-v0100-guards.sh`
- 更新：
  - `.github/workflows/checks.yml`
  - `checks/verify-v0.10.0.sh`
  - `checks/run.sh`
  - `checks/automation-readiness.sh`
  - `docs/automation/automation-readiness.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/latest-verification-summary.md`
  - `Tests/TargetGraphTests/TargetGraphTests.swift`
  - `verification.md`

边界确认：

- 未修改 runtime / OMS / broker gateway / Live PRO Console command。
- 未移动既有 release tag。
- 未重写 GitHub Release。
- 未创建下一 Project / Issue。
- 未推进下一 Todo。
- 未启动 Linear。
- 未启动 Symphony / `symphony-issue`。
- 未运行 Graphify / code-index。
- 未修改 Figma。
- 未授权 production cutover / production trading。
- 未读取 production secret。
- 未连接 production endpoint / broker endpoint。
- 未提交 testnet 或 production order。
- 未显示 trading button、order form、live command、submit / cancel / replace。
- 未提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

验证计划：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/verify-v0.10.1-dashboard-macos-v0100-guards.sh` | pass | focused Dashboard macOS v0.10 guard，包含 readiness center verifier 与 Dashboard smoke |
| `swift test --filter TargetGraphTests/testGH908DashboardMacOSV0100GuardRunsReadinessCenterBeforeBuildAndSmoke` | pass | 1 test / 0 failures |
| `git diff --check` | pass | whitespace 检查 |
| `bash checks/automation-readiness.sh` | pass | automation readiness guard |
| `bash checks/verify-v0.10.0.sh` | pass | v0.10.0 aggregate verifier 已调用 v0.10.1 Dashboard macOS v0.10 focused guard |
| `bash checks/run.sh` | pass | 全量本地验证，593 tests / 0 failures |

## GH-909 v0.10.1 CLI verify v0.10.0 wording guard

日期：2026-06-18

执行者：Codex

目的：

- 修正 `mtpro verify` 当前输出口径，将 v0.10.0 明确为 `Production Readiness Contract / Reference Evidence Model`。
- 防止 `mtpro verify v0.10.0` 被误读为 operational production readiness、production cutover readiness、production endpoint readiness 或 live order authorization。
- 保留 v0.9.0 historical verification evidence，并将当前 release verification 指向 v0.10.0 readiness contract / reference evidence。
- 保持 production cutover 未授权、production trading 默认关闭。

文件范围：

- 新增：
  - `checks/verify-v0.10.1-cli-verify-v0100-wording.sh`
- 更新：
  - `Sources/MTPROCLI/main.swift`
  - `checks/verify-v0.10.0.sh`
  - `checks/run.sh`
  - `checks/automation-readiness.sh`
  - `checks/verify-v0.5.0-cli.sh`
  - `checks/verify-v0.7.0-cli.sh`
  - `checks/verify-v0.8.1-cli-verify-v080-wording.sh`
  - `checks/verify-v0.9.1-cli-verify-v090-wording.sh`
  - `docs/automation/automation-readiness.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `Tests/TargetGraphTests/TargetGraphTests.swift`
  - `verification.md`

边界确认：

- 未修改 runtime / OMS / broker gateway / Live PRO Console command。
- 未移动既有 release tag。
- 未重写 GitHub Release。
- 未创建下一 Project / Issue。
- 未推进下一 Todo。
- 未启动 Linear。
- 未启动 Symphony / `symphony-issue`。
- 未运行 Graphify / code-index。
- 未修改 Figma。
- 未授权 production cutover / production trading。
- 未读取 production secret。
- 未连接 production endpoint / broker endpoint。
- 未提交 testnet 或 production order。
- 未显示 trading button、order form、live command、submit / cancel / replace。
- 未提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

验证计划：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/verify-v0.10.1-cli-verify-v0100-wording.sh` | pass | focused CLI verify v0.10.0 wording guard，拒绝 operational readiness / cutover / endpoint / live order 授权误读 |
| `swift test --filter TargetGraphTests/testGH909CLIVerifyV0100WordingUsesReadinessContractReferenceEvidence` | pass | 1 test / 0 failures |
| `git diff --check` | pass | whitespace 检查 |
| `bash checks/automation-readiness.sh` | pass | automation readiness guard |
| `bash checks/verify-v0.10.0.sh` | pass | v0.10.0 aggregate verifier 已调用 v0.10.1 CLI verify v0.10.0 wording guard |
| `bash checks/run.sh` | pass | 全量本地验证，594 tests / 0 failures |

## GH-910 v0.10.1 readiness CLI help placeholder guard

日期：2026-06-18

执行者：Codex

目的：

- 为 planned readiness runtime 增加只读 CLI help / no-op placeholder surface：`readiness help`、`readiness build`、`readiness status`、`readiness validate`、`readiness export`、`readiness approval-status`。
- 明确 readiness artifact runtime 仍属于 v0.11.0 future runtime，不在本轮实现。
- 确认所有 readiness CLI placeholder 均为非变更路径：不写 artifact、不写 readiness bundle、不实现 `ProductionReadinessArtifactStore`。
- 同步历史 CLI command list guard，保证新增 `readiness` command 不破坏 v0.5 strict parser、v0.9 Dashboard / CLI operator UX 和 v0.10 aggregate guard。
- 保持 production cutover 未授权、production trading 默认关闭。

文件范围：

- 新增：
  - `checks/verify-v0.10.1-readiness-cli-help.sh`
- 更新：
  - `Sources/MTPROCLI/main.swift`
  - `checks/verify-v0.10.0.sh`
  - `checks/run.sh`
  - `checks/automation-readiness.sh`
  - `checks/verify-v0.5.0-cli.sh`
  - `checks/verify-v0.9.0-dashboard-cli-operator-ux.sh`
  - `docs/automation/automation-readiness.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `Tests/TargetGraphTests/TargetGraphTests.swift`
  - `verification.md`

边界确认：

- 未实现 readiness artifact runtime。
- 未实现 `ProductionReadinessArtifactStore`。
- 未写入 readiness artifact / readiness bundle。
- 未修改 runtime / OMS / broker gateway / Live PRO Console command。
- 未移动既有 release tag。
- 未重写 GitHub Release。
- 未创建下一 Project / Issue。
- 未推进下一 Todo。
- 未启动 Linear。
- 未启动 Symphony / `symphony-issue`。
- 未运行 Graphify / code-index。
- 未修改 Figma。
- 未授权 production cutover / production trading。
- 未读取 production secret。
- 未连接 production endpoint / broker endpoint。
- 未提交 testnet 或 production order。
- 未显示 trading button、order form、live command、submit / cancel / replace。
- 未提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

验证计划：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/verify-v0.10.1-readiness-cli-help.sh` | pass | focused readiness CLI help placeholder guard，确认 no-op / no artifact write / production disabled |
| `swift test --filter TargetGraphTests/testGH910ReadinessCLIHelpPlaceholderIsNonMutatingAndFailsClosed` | pass | 1 test / 0 failures |
| `bash checks/verify-v0.5.0-cli.sh` | pass | historical strict CLI command list 已同步 `readiness` |
| `bash checks/verify-v0.9.0-dashboard-cli-operator-ux.sh` | pass | historical v0.9 Dashboard / CLI operator UX command list 已同步 `readiness` |
| `swift test --filter TargetGraphTests/testGH855DashboardCLIOperatorUXIsAnchoredInV090Guards` | pass | historical v0.9 guard 同步验证，1 test / 0 failures |
| `git diff --check` | pass | whitespace 检查 |
| `bash checks/automation-readiness.sh` | pass | automation readiness guard |
| `bash checks/verify-v0.10.0.sh` | pass | v0.10.0 aggregate verifier 已调用 v0.10.1 readiness CLI help placeholder guard |
| `bash checks/run.sh` | pass | 全量本地验证，595 tests / 0 failures |

## GH-911 v0.10.0 GitHub Release notes stale wording refresh

日期：2026-06-18

执行者：Codex

目的：

- 只读检查 `v0.10.0` GitHub Release body 后，确认其仍包含 construction closeout 阶段遗留的未发布旧口径。
- 仅更新 `v0.10.0` GitHub Release body 文本，改为 stable GitHub Release 已发布事实。
- 确认 `v0.10.0` tag target commit 未变：`7b0e1f8bb6a671cd3b96f7e7b020b803f8cea4b4`。
- 明确 release publication、release fact sync 和 production cutover 仍是独立 gate；v0.10.0 publication 不授权 production cutover。

文件范围：

- GitHub Release body 外部更新：
  - `https://github.com/atxinbao/MTPRO/releases/tag/v0.10.0`
- 仓库证据更新：
  - `verification.md`

边界确认：

- 未移动、删除、重建、覆盖或 retarget `v0.10.0` tag。
- 未移动、删除或重建 GitHub Release。
- 未修改业务代码。
- 未实现 readiness artifact runtime。
- 未实现 `ProductionReadinessArtifactStore`。
- 未创建下一 Project / Issue。
- 未推进下一 Todo。
- 未启动 Linear。
- 未启动 Symphony / `symphony-issue`。
- 未运行 Graphify / code-index。
- 未修改 Figma。
- 未授权 production cutover / production trading。
- 未读取 production secret。
- 未连接 production endpoint / broker endpoint。
- 未提交 testnet 或 production order。
- 未显示 trading button、order form、live command、submit / cancel / replace。
- 未提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

验证计划：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `stale publication wording scan over v0.10.0 release body` | pass | checked stale publication phrases; scan 无命中 |
| `git rev-list -n 1 v0.10.0` | pass | tag target commit 仍为 `7b0e1f8bb6a671cd3b96f7e7b020b803f8cea4b4` |
| `gh release view v0.10.0 --json tagName,isDraft,isPrerelease,url,targetCommitish` | pass | stable release，非 draft，非 prerelease，URL 可读 |
| `git diff --check` | pass | whitespace 检查 |
| `bash checks/automation-readiness.sh` | pass | automation readiness guard |
| `bash checks/verify-v0.10.0.sh` | pass | v0.10.0 aggregate verifier；本 PR 仅追加 external release body refresh evidence，未改代码 |

## MTPRO Release v0.7.0 final audit / docs / runbook closure

日期：2026-06-15

执行者：Codex

PR：#792 closure PR 待创建

提交：待创建

目的：

- 记录 `MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity` 的 final Stage Code Audit、release notes、operator runbook、root docs refresh 和 aggregate verifier final guard。
- 将最新完成范围从 v0.6.0 提升到 v0.7.0 completed facts。
- 保持 production trading disabled by default，不授权 production cutover。

文件范围：

- 新增：
  - `docs/audit/mtpro-release-v0.7.0-operator-runtime-session-testnet-read-only-connectivity-stage-code-audit.md`
  - `docs/release/mtpro-release-v0.7.0-operator-runtime-session-testnet-read-only-connectivity-notes.md`
  - `docs/operators/release-v0.7.0-operator-runtime-session-testnet-readonly-connectivity-runbook.md`
- 更新：
  - `README.md`
  - `GOAL.md`
  - `BLUEPRINT.md`
  - `docs/roadmap.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/automation/automation-readiness.md`
  - `checks/automation-readiness.sh`
  - `checks/verify-v0.7.0.sh`
  - `verification.md`

边界确认：

- 未创建下一 Project / Issue。
- 未推进下一 Todo。
- 未启动 Linear。
- 未启动 Symphony / `symphony-issue`。
- 未运行 Graphify / code-index。
- 未修改 Figma。
- 未实现新业务 runtime。
- 未授权 production trading。
- 未读取 production secret。
- 未连接 production endpoint / broker endpoint。
- 未发送真实 order。
- 未提交 `.codex/*` 或 `graphify-out/*`。

验证计划：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/verify-v0.7.0.sh` | 待执行 | 聚合 v0.7.0 focused verifiers 和 root docs guards |
| `git diff --check` | 待执行 | whitespace 检查 |
| `bash checks/automation-readiness.sh` | 待执行 | automation readiness guard |
| `bash checks/run.sh` | 待执行 | 全量本地验证 |

## MTPRO Release v0.6.0 final audit / root docs closure

日期：2026-06-15

执行者：Codex

PR：#766 closure PR 待创建

提交：待创建

目的：

- 记录 `MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening` 的 final Stage Code Audit、release notes、operator runbook、root docs refresh 和 aggregate verifier。
- 将最新完成范围从 v0.5.0 提升到 v0.6.0 completed facts。
- 保持 production trading disabled by default，不授权 production cutover。

文件范围：

- 新增：
  - `docs/audit/mtpro-release-v0.6.0-local-operational-runtime-testnet-read-only-probe-hardening-stage-code-audit.md`
  - `docs/release/mtpro-release-v0.6.0-local-operational-runtime-testnet-read-only-probe-hardening-notes.md`
  - `docs/operators/release-v0.6.0-operator-local-operational-runtime-testnet-readonly-probe-runbook.md`
  - `checks/verify-v0.6.0.sh`
- 更新：
  - `README.md`
  - `GOAL.md`
  - `BLUEPRINT.md`
  - `docs/roadmap.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/automation/automation-readiness.md`
  - `checks/automation-readiness.sh`
  - `checks/run.sh`
  - `verification.md`

边界确认：

- 未创建下一 Project / Issue。
- 未推进下一 Todo。
- 未启动 Linear。
- 未启动 Symphony / `symphony-issue`。
- 未运行 Graphify / code-index。
- 未修改 Figma。
- 未实现新业务 runtime。
- 未授权 production trading。
- 未读取 production secret。
- 未连接 production endpoint / broker endpoint。
- 未发送真实 order。
- 未提交 `.codex/*` 或 `graphify-out/*`。

验证计划：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/verify-v0.6.0.sh` | 待执行 | 聚合 v0.6.0 focused verifiers 和 root docs guards |
| `git diff --check` | 待执行 | whitespace 检查 |
| `bash checks/automation-readiness.sh` | 待执行 | automation readiness guard |
| `bash checks/run.sh` | 待执行 | 全量本地验证 |

## MTPRO 引导骨架

日期：2026-05-14

执行者：Codex

PR：未创建

提交：未创建

目的：

- 从 0 创建 MTPRO 项目定义和 SwiftPM 骨架。
- 固化当前用户确认的项目定义、契约优先边界和本地验证入口。

文件范围：

- 新增：
  - `README.md`
  - `GOAL.md`
  - `ENVIRONMENT.md`
  - `AGENTS.md`
  - `ARCHITECTURE.md`
  - `ROADMAP.md`
  - `Package.swift`
  - `Sources/`
  - `Tests/`
  - `docs/product/product-surface-map.md`
  - `docs/architecture/module-boundary.md`
  - `docs/contracts/`
  - `docs/validation/validation-plan.md`
  - `examples/README.md`
- 更新：
  - 无
- 删除：
  - 无

边界确认：

- 未实现业务功能。
- 未实现前端页面。
- 未实现 Binance 适配器。
- 未实现回测引擎。
- 未实现 Paper 执行。
- 未实现数据库适配器。
- 未创建 Linear 项目或事项。
- 未修改 Linear 状态。
- 未运行 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 已通过 |
| `swift test` | 通过 | 4 个 XCTest 通过 |

## MTPRO Linear 草案

日期：2026-05-14

执行者：Codex

PR：未创建

提交：未创建

目的：

- 按 AI Engineering Protocol 将 MTPRO `ROADMAP.md` 转换为只供审查的 Linear 草案。
- 保留 9 个里程碑：引导基线、核心模型与事件日志、Binance 只读行情、内核与缓存、EMA 回测与 Paper 一致性、订单簿策略、SQLite / DuckDB 投影、工作台看板、验证与自动化就绪。
- 明确第一个未来可执行事项草案为“核心领域模型与事件日志契约”。

文件范围：

- 新增：
  - `docs/planning/linear-draft-plan.md`
- 更新：
  - `verification.md`
- 删除：
  - 无

边界确认：

- 未调用 Linear API。
- 未创建 Linear 项目、里程碑或事项。
- 未修改 Linear 状态。
- 未启动 Symphony。
- 未运行 Graphify 更新、范围更新或全量重建。
- 未提交 `graphify-out/*`。
- 未实现 Binance 适配器。
- 未实现回测引擎。
- 未实现 Paper 执行。
- 未实现 UI。
- 未实现数据库适配器。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 已通过 |
| `swift test` | 通过 | 4 个 XCTest 通过 |

## MTPRO Linear 草案人工确认

日期：2026-05-14

执行者：Codex

PR：未创建

提交：未创建

目的：

- 记录用户对 MTPRO Linear 草案的人工确认。
- 将草案状态从等待审查更新为已确认。
- 标记 Linear 写入授权为“是”；当时仍需补齐 Linear 团队名称、团队标识、团队 ID，后续已由“Linear 团队信息修正”记录补齐。

文件范围：

- 新增：
  - 无
- 更新：
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- 删除：
  - 无

边界确认：

- 未调用 Linear API。
- 未创建 Linear 项目、里程碑或事项。
- 未修改 Linear 状态。
- 未启动 Symphony。
- 未运行 Graphify 更新、范围更新或全量重建。
- 未提交 `graphify-out/*`。
- 未进入开发执行。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 已通过 |
| `swift test` | 通过 | 4 个 XCTest 通过 |

## MTPRO Linear 团队信息修正

日期：2026-05-14

执行者：Codex

PR：未创建

提交：未创建

目的：

- 按用户最新确认修正 Linear 团队信息。
- 以团队名称 `NautilusTrade Pro`、团队 ID `MTP` 为准。
- 将 Linear 草案中的团队名称、团队标识、团队 ID 更新为 `NautilusTrade Pro / MTP`。

文件范围：

- 新增：
  - 无
- 更新：
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- 删除：
  - 无

边界确认：

- 未调用 Linear API。
- 未创建 Linear 项目、里程碑或事项。
- 未修改 Linear 状态。
- 未启动 Symphony。
- 未运行 Graphify 更新、范围更新或全量重建。
- 未进入开发执行。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 已通过 |
| `swift test` | 通过 | 4 个 XCTest 通过 |

## MTPRO Linear Setup

日期：2026-05-14

执行者：Codex

PR：未创建

提交：未创建

目的：

- 按已确认 Linear 草案执行 Linear Setup。
- 在团队 `MTP` 下创建 Project `MTPRO 引导`。
- 创建 9 个里程碑。
- 创建 `MTP-7` 到 `MTP-15`。
- 保持 `MTP-8` 为唯一 `Todo`，其余开发事项为 `Backlog`。

Linear 结果：

- Project：`MTPRO 引导`
- Project ID：`3a8e07ff-0c15-47cf-b9d2-9a077dfa037e`
- Project URL：`https://linear.app/atxinbao/project/mtpro-引导-f3792087e333`
- 团队标识：`MTP`
- Linear 返回团队显示名称：Macostrader Pro

事项状态：

| Linear 事项 | 标题 | 状态 |
| --- | --- | --- |
| `MTP-7` | 记录引导基线 | `Done` |
| `MTP-8` | 核心领域模型与事件日志契约 | `Todo` |
| `MTP-9` | Binance 公开只读行情适配器契约 | `Backlog` |
| `MTP-10` | 交易内核、数据引擎与缓存边界 | `Backlog` |
| `MTP-11` | EMA 回测与 Paper 一致性契约 | `Backlog` |
| `MTP-12` | 订单簿失衡策略研究链路 | `Backlog` |
| `MTP-13` | SQLite / DuckDB 投影与重放边界 | `Backlog` |
| `MTP-14` | Trader Workstation 看板 ViewModel 契约 | `Backlog` |
| `MTP-15` | 验证加固与自动化就绪 | `Backlog` |

文件范围：

- 新增：
  - 无
- 更新：
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- 删除：
  - 无

边界确认：

- 已调用 Linear API 创建 Project、里程碑和事项。
- 已设置新建事项初始状态。
- 未修改既有 Linear 事项状态。
- 未启动 Symphony。
- 未运行 Graphify 更新、范围更新或全量重建。
- 未提交 `graphify-out/*`。
- 未进入开发执行。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| Linear Project 查询 | 通过 | `MTPRO 引导` 已创建 |
| Linear Todo 查询 | 通过 | 仅 `MTP-8` 为 `Todo` |
| Linear 里程碑查询 | 通过 | 9 个里程碑已创建 |
| `git diff --check` | 通过 | 已通过 |
| `swift test` | 通过 | 4 个 XCTest 通过 |

## MTPRO Automation Readiness

日期：2026-05-14

执行者：Codex

PR：未创建

提交：未创建

目的：

- 检查 GitHub + Linear 关联前提、PR 模板、WIP=1、Authorized Merge 分离和 Graphify 只读边界。
- 补齐本地中文 PR 模板。
- 记录自动化就绪状态和阻塞项。

文件范围：

- 新增：
  - `.github/pull_request_template.md`
  - `docs/automation/automation-readiness.md`
- 更新：
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- 删除：
  - 无

检查结果：

| 项目 | 结果 | 说明 |
| --- | --- | --- |
| Git remote | 阻塞 | `git remote -v` 无输出 |
| GitHub + Linear 关联 | 待验证 | 需要先配置 GitHub remote 并创建或关联 PR |
| PR 模板 | 通过 | 已新增 `.github/pull_request_template.md` |
| Linear Project | 通过 | Project ID：`3a8e07ff-0c15-47cf-b9d2-9a077dfa037e`；名称：`MTPRO 引导` |
| Linear WIP=1 | 通过 | 仅 `MTP-8` 为 `Todo` |
| Authorized Merge 分离 | 通过 | PR 模板已固化分离门槛 |
| Graphify 只读边界 | 通过 | 未运行 Graphify update、scoped update 或 full rebuild |

边界确认：

- 未创建 GitHub PR。
- 未推送远程分支。
- 未修改 Linear 状态。
- 未启动 Symphony。
- 未运行 Graphify 更新、范围更新或全量重建。
- 未提交 `graphify-out/*`。
- 未进入 `MTP-8` 开发执行。
- 未实现 Binance 适配器。
- 未实现回测引擎。
- 未实现 Paper 执行。
- 未实现 UI。
- 未实现数据库适配器。
- 未实现 `LiveExecutionAdapter`。
- 未调用 Binance signed endpoint。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git remote -v` | 阻塞项确认 | 当前无 Git remote |
| `gh repo view --json nameWithOwner,url` | 阻塞项确认 | 返回 `no git remotes found` |
| Linear Project ID 查询 | 通过 | Project `MTPRO 引导` 可查询 |
| Linear Todo 查询 | 通过 | 仅 `MTP-8` 为 `Todo` |
| `git diff --check` | 通过 | 已通过 |
| `swift test` | 通过 | 4 个 XCTest 通过 |

## MTPRO Bootstrap PR

日期：2026-05-14

执行者：Codex

PR：`https://github.com/atxinbao/MTPRO/pull/1`

提交：待合并

目的：

- 创建 GitHub private 仓库。
- 配置 `origin`。
- 发布 Bootstrap Draft PR。
- 验证 GitHub + Linear 关联。
- 保持正式开发未开始。

GitHub 结果：

- Repository：`https://github.com/atxinbao/MTPRO`
- Visibility：private
- Remote：`origin https://github.com/atxinbao/MTPRO.git`
- Base branch：`main`
- PR branch：`codex/bootstrap-readiness`
- Draft PR：`https://github.com/atxinbao/MTPRO/pull/1`

降级说明：

- 本地 `git push` 连续两次因 GitHub 443 连接超时失败。
- 已改用 GitHub API 导入远端 Git objects。
- 远端 commit SHA 与本地 commit SHA 不同，但 GitHub compare 已确认文件范围。

证据链：

| 项目 | 值 |
| --- | --- |
| 本地 baseline commit | `a141648 Bootstrap MTPRO skeleton` |
| 远端 `main` import commit | `d4d172b7e51b43fc65cfbd2d5791d3b0aab0f4d0` |
| 本地证据 commit | `24abb12 Document Linear setup and automation readiness` |
| 远端 PR branch import commit | `58e488b928a9076bada4ca8854389a3e7b572e72` |

Linear 结果：

- `MTP-7` 已追加 Bootstrap PR attachment。
- `MTP-8` 仍是唯一 `Todo`。
- `MTP-9` 到 `MTP-15` 仍保持 `Backlog`。
- 未修改 Linear 状态。

文件范围：

- 新增：
  - 无
- 更新：
  - `docs/automation/automation-readiness.md`
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- 删除：
  - 无

边界确认：

- 已创建 GitHub private 仓库。
- 已创建 Bootstrap Draft PR。
- 已将 PR 关联到 Linear `MTP-7`。
- 未修改 Linear 状态。
- 未启动 Symphony。
- 未运行 Graphify 更新、范围更新或全量重建。
- 未提交 `graphify-out/*`。
- 未进入 `MTP-8` 开发执行。
- 未实现 Binance 适配器。
- 未实现回测引擎。
- 未实现 Paper 执行。
- 未实现 UI。
- 未实现数据库适配器。
- 未实现 `LiveExecutionAdapter`。
- 未调用 Binance signed endpoint。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `gh repo view atxinbao/MTPRO --json nameWithOwner,url,isPrivate,defaultBranchRef` | 通过 | private 仓库存在，默认分支为 `main` |
| GitHub compare `main...codex/bootstrap-readiness` | 通过 | ahead 1，变更文件为 PR 模板、自动化就绪、Linear 草案和验证日志 |
| Linear `MTP-7` attachment 查询 | 通过 | 已关联 Bootstrap Draft PR |
| Linear Todo 查询 | 通过 | 仅 `MTP-8` 为 `Todo` |
| `git diff --check` | 通过 | 已通过 |
| `swift test` | 通过 | 4 个 XCTest 通过 |

## MTPRO Onboarding Test Removal

日期：2026-05-16
执行者：Codex
PR：本轮 PR
Commit：本轮提交

目的：

- 将 MTPRO 项目路径调整为不创建单独的 test-mode onboarding Project / Issues。
- 明确第一个真实 `MTP-8` PR 同时验证 GitHub PR Automation 链路。
- 将旧 Authorized Merge / Bootstrap 阶段状态更新为 GitHub PR Automation 语义。

文件范围：

- Created：无
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `ROADMAP.md`
  - `docs/automation/automation-readiness.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/contracts/binance-market-data-contract.md`
  - `verification.md`
- Deleted：无

边界确认：

- 未创建单独 test Project。
- 未创建单独 test Issues。
- 未修改 Linear。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未实现业务功能。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，4 个 XCTest 通过 |

## MTPRO AEP v2 Flow Alignment

日期：2026-05-16
执行者：Codex
PR：本轮 PR
Commit：本轮提交

目的：

- 按 AEP v2 正式流程重新梳理 MTPRO 当前状态。
- 明确 `1. Human Project Planning` 到 `5. Next Human Project Planning` 的项目级映射。
- 明确当前唯一 configured executable issue 是 `MTP-8`。
- 明确 Symphony Issue Automation 尚未启动，GitHub PR Automation 已配置。

文件范围：

- Created：无
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `ROADMAP.md`
  - `docs/automation/automation-readiness.md`
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- Deleted：无

边界确认：

- 未修改 Linear。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未实现业务功能。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，4 个 XCTest 通过 |

## MTPRO Graphify Resource Graph Initialization

日期：2026-05-16
执行者：Codex
PR：本轮 PR
Commit：本轮提交

目的：
- 初始化 MTPRO 本地 Graphify resource relationship graph，让后续 Agent 可读取项目资源关系上下文。
- 明确 Graphify 默认不是 source code graph，源码目录、测试目录和 `graphify-out/*` 不进入 PR。

文件范围：
- Created：
  - `.graphifyignore`
  - `docs/automation/graphify-resource-graph-scope.md`
- Updated：
  - `docs/automation/automation-readiness.md`
  - `verification.md`
- Deleted：无

边界确认：
- 未修改 Linear。
- 未启动 Symphony。
- 未修改业务代码。
- 未纳入完整源码目录。
- 未纳入测试目录。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `graphify update .` | 通过 | 本地生成 176 nodes / 156 edges / 24 communities |
| Graphify source / test directory exclusion check | 通过 | 确认 `Sources/` 和 `Tests/` 未作为 graph source files |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，4 个 XCTest 通过 |

## MTPRO symphony-issue Handoff Alignment

日期：2026-05-16
执行者：Codex
PR：本轮 PR
Commit：本轮提交

目的：
- 将 MTPRO PR 模板补齐 `symphony-issue` handoff evidence。
- 将 Linear `MTP-8` 至 `MTP-15` 描述统一对齐为 AEP v2 `symphony-issue` / GitHub PR Automation / Graphify scoped update 语义。
- 移除 future issues 中的旧 Authorized Merge / Graphify no-update 表述，并保留 Backlog 执行锁定。

文件范围：
- Created：无
- Updated：
  - `.github/pull_request_template.md`
  - `verification.md`
- Deleted：无

边界确认：
- 未修改业务代码。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未创建 Linear Project / Issue。
- 仅更新 Linear `MTP-8` 至 `MTP-15` 描述，不修改 Linear status。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | `swift test` 通过 |
| Linear issue description consistency check | 通过 | `MTP-8` 至 `MTP-15` 无旧 Authorized Merge / Graphify no-update 语义，并包含 handoff marker、Graphify scoped update 和 GitHub auto-merge handoff 要求 |

## MTPRO Agent Boundary Alignment for symphony-issue

日期：2026-05-16
执行者：Codex
PR：本轮 PR
Commit：本轮提交

目的：
- 修正 `AGENTS.md` 中仍保留的旧边界，明确 symphony-issue 已作为授权本地自动化负责唯一 `Todo` issue 调度。
- 明确 Codex Execution Agent 执行后需要运行 Graphify scoped resource relationship graph update，或记录环境不可用 / issue 禁止原因。

文件范围：
- Created：无
- Updated：
  - `AGENTS.md`
  - `verification.md`
- Deleted：无

边界确认：
- 未修改业务代码。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/run.sh` | 通过 | `swift test` 通过，4 个 XCTest 通过 |
| `git diff --check` | 通过 | 无 whitespace 问题 |

## MTP-8 核心领域模型与事件日志契约

日期：2026-05-16

执行者：Codex

PR：未创建（当前 sandbox / GitHub token 阻塞，需 host-side handoff fallback）

Commit：未创建（当前 sandbox 拒绝写入 `.git/index.lock`）

目的：

- 实现 `MTPROCore` 核心 symbol、timeframe、market event、domain event、command、query、event envelope 契约。
- 定义只追加事件日志契约和 replay 契约。
- 为后续 backtest / paper 一致性保留统一事件语义。
- 增加核心单元测试，覆盖正常路径、边界值、价格 / 数量约束、Codable 反序列化约束、只追加序列和拒绝 Live action 的约束。

文件范围：

- Created：无
- Updated：
  - `Sources/MTPROCore/MTPROCore.swift`
  - `Tests/MTPROCoreTests/MTPROCoreTests.swift`
  - `verification.md`
- Deleted：无

边界确认：

- 未修改 `MTPROAdapters`。
- 未修改 `MTPROPersistence`。
- 未修改 `MTPROApp`。
- 未接 Binance 网络。
- 未实现真实持久化 adapter。
- 未实现内核运行时。
- 未实现策略。
- 未实现 UI。
- 未实现 `LiveExecutionAdapter`。
- 未调用 signed endpoint。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

Graphify 状态：

- 执行前 `graphify-out/*` 在当前 worktree 中不存在，无法读取既有 Graphify 输出上下文。
- 已读取 `.graphifyignore` 和 `docs/automation/graphify-resource-graph-scope.md` 确认 Graphify 资源关系图边界。
- 执行后已尝试 `graphify update .`。
- Graphify update 未完成：当前 Graphify CLI 返回 `Re-extracting code files in . (no LLM needed)...` 后失败，错误为 `[Errno 1] Operation not permitted`。
- 本轮未生成或提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/run.sh` | 阻塞 | SwiftPM 在当前 sandbox 中尝试写入 `/Users/mac/.cache/clang/ModuleCache`，随后内部 `sandbox-exec` 返回 `Operation not permitted`，未进入源码编译 |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `CLANG_MODULE_CACHE_PATH="$PWD/.build/clang-module-cache" swift test --disable-sandbox --cache-path "$PWD/.build/swiftpm-cache" --config-path "$PWD/.build/swiftpm-config" --security-path "$PWD/.build/swiftpm-security" --scratch-path "$PWD/.build"` | 通过 | 12 个 XCTest 通过；其中 `MTPROCoreTests` 9 个测试通过 |
| `graphify update .` | 阻塞 | Graphify CLI 在当前 sandbox 中返回 `[Errno 1] Operation not permitted`，未生成可提交输出 |

Pre-PR Codex Code Review：

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| Diff scope | 通过 | 仅修改 `Sources/MTPROCore/MTPROCore.swift`、`Tests/MTPROCoreTests/MTPROCoreTests.swift`、`verification.md` |
| Issue scope | 通过 | 变更只覆盖核心领域模型、事件、命令 / 查询、事件信封、只追加日志和 replay 契约 |
| Forbidden paths | 通过 | 未修改 `MTPROAdapters`、`MTPROPersistence`、`MTPROApp` 或其他非当前 issue scope 文件 |
| Live / signed endpoint boundary | 通过 | 未新增 `LiveExecutionAdapter`、网络调用、signed endpoint、account endpoint 或真实订单动作 |
| Validation credibility | 需说明 | 默认 `bash checks/run.sh` 被本地 sandbox 阻塞；等价 `git diff --check` 与 sandbox-compatible `swift test --disable-sandbox` 已通过 |
| Graphify boundary | 需说明 | 已尝试 scoped update，但 Graphify CLI 在当前 sandbox 中失败；未提交 `graphify-out/*` |

## MTPRO symphony-issue Automation Write Profile

日期：2026-05-16
执行者：Codex
PR：本轮 PR
Commit：本轮提交

目的：
- 将 MTPRO 本地自动化边界对齐到 `symphony-issue` automation write profile。
- 明确 child Codex 可在当前 issue workspace 内完成 git commit / push、ready-for-review PR、GitHub auto-merge handoff 和本地 handoff marker。
- 明确 child Codex 被 sandbox、GitHub token、网络或 MCP elicitation 阻塞时，可由 host-side fallback 接管 handoff。

文件范围：
- Created：无
- Updated：
  - `.github/pull_request_template.md`
  - `AGENTS.md`
  - `docs/automation/automation-readiness.md`
  - `verification.md`
- Deleted：无

本地运行配置：
- `/Users/mac/code/symphony-workflows/mtpro-aep-v2.md`
- `/Users/mac/code/symphony-workflows/runtime/mtpro-aep-v2-local-seed.md`

边界确认：
- 未修改业务代码。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- host-side fallback 不扩大 issue scope，不替代 Linear 状态推进。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无 whitespace 问题。 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，4 个 XCTest 通过。 |

## MTPRO symphony-issue Host Handoff Fallback Alignment

日期：2026-05-16
执行者：Codex
PR：本轮 PR
Commit：本轮提交

目的：
- 将 MTPRO 本地自动化边界从默认 `dangerFullAccess` 收回到 `workspaceWrite` issue workspace 写入模型。
- 明确 child Codex 可处理 git / PR / marker，若被 sandbox、GitHub token、网络或 MCP elicitation 阻塞，则由 symphony-issue host-side handoff fallback 接管。
- 同步 workflow 运行配置，避免下一轮 MTP issue 自动化继续依赖 child Codex 直接写 `.git` 或 `.codex`。

文件范围：
- Created：无
- Updated：
  - `AGENTS.md`
  - `docs/automation/automation-readiness.md`
  - `verification.md`
- Deleted：无

本地运行配置：
- `/Users/mac/code/symphony-workflows/mtpro-aep-v2.md`
- `/Users/mac/code/symphony-workflows/runtime/mtpro-aep-v2-local-seed.md`

边界确认：
- 未修改业务代码。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无 whitespace 问题。 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，4 个 XCTest 通过。 |
| `mix test core + workspace/config` | 通过 | Symphony 相关 90 个测试通过。 |

## MTP-9 Binance 公开只读行情适配器契约

日期：2026-05-16

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 实现 `MTPROAdapters` 的 Binance public market data read-only endpoint contract。
- 固化 `exchangeInfo`、`klines`、recent trades、best bid / ask、有限深度快照和深度增量的 contract。
- 将 Binance public fixture payload 解码为 `MTPROCore` market event model。
- 用测试覆盖 configured universe、`1m` / `5m` timeframe、record limit、fixture decoding、unsupported symbol、invalid numeric payload 和 forbidden capability boundary。

文件范围：

- Created：
  - 无
- Updated：
  - `Sources/MTPROAdapters/MTPROAdapters.swift`
  - `Tests/MTPROAdaptersTests/MTPROAdaptersTests.swift`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`
- Deleted：
  - 无

Linear / scope 确认：

- Linear 查询显示 `MTP-9` 为当前唯一 `In Progress` issue。
- Linear 查询显示 `MTP-8` 已 `Done`。
- Linear 查询显示 `MTP-10` 至 `MTP-15` 仍为 `Backlog`。
- 根文档中仍有 `MTP-8` current issue 的历史文字；本轮执行授权以 Linear 当前状态和用户提供的 `symphony-issue` workflow 为准。

边界确认：

- 未接真实 Binance 网络。
- 未实现 URLSession client。
- 未实现 WebSocket 生命周期管理。
- 未使用 API key。
- 未调用 signed endpoint。
- 未调用 account endpoint。
- 未提交、取消或替换订单。
- 未实现 `LiveExecutionAdapter`。
- 未实现策略。
- 未实现 TradingKernel / DataEngine / Cache。
- 未实现 persistence adapter。
- 未实现 SwiftUI 页面。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

Graphify 状态：

- 执行前 `graphify-out/*` 在当前 worktree 中不存在，无法读取既有 Graphify 输出上下文。
- 已读取 `docs/automation/graphify-resource-graph-scope.md`，确认 Graphify 资源关系图边界和 `graphify-out/*` 不进入 PR。
- 执行后已尝试 `graphify update .`。
- Graphify update 未完成：当前 Graphify CLI 返回 `Re-extracting code files in . (no LLM needed)...` 后失败，错误为 `[Errno 1] Operation not permitted`。
- 本轮未生成或提交 `graphify-out/*`。

本地 `.codex` evidence 状态：

- 已创建仓库根目录 `.codex/`，但当前 sandbox 拒绝向 `.codex/*` 写入文件。
- `apply_patch` 写入 `.codex/*` 返回 `writing outside of the project`。
- `touch .codex/foo` 返回 `Operation not permitted`。
- 因此 `.codex/structured-request.json`、`.codex/context-scan.json`、`.codex/operations-log.md`、`.codex/testing.md` 和 `.codex/review-report.md` 未能写入。
- 后续 `.codex/symphony-issue-handoff.json` 很可能需要 host-side handoff fallback 接管写入。

Git / PR handoff 状态：

- 已尝试 `git add` 精确暂存本轮 5 个 tracked 文件。
- `git add` 被当前 sandbox 阻塞，错误为 `Unable to create '.git/index.lock': Operation not permitted`。
- 未产生半写入的 `.git/index.lock`。
- `git diff --cached --name-only` 为空，未产生 partial staging。
- `gh auth status` 显示当前 GitHub CLI token invalid。
- 因此 commit / push / ready-for-review PR / auto-merge handoff / `.codex/symphony-issue-handoff.json` 需要 host-side handoff fallback 接管。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | 通过 | 19 个 XCTest 通过，其中 `MTPROAdaptersTests` 8 个测试通过 |
| `bash checks/run.sh` | 阻塞 | SwiftPM 在当前 sandbox 中尝试写入 `/Users/mac/.cache/clang/ModuleCache`，随后返回 `Operation not permitted`，未进入源码编译 |
| `CLANG_MODULE_CACHE_PATH="$PWD/.build/clang-module-cache" swift test --disable-sandbox --cache-path "$PWD/.build/swiftpm-cache" --config-path "$PWD/.build/swiftpm-config" --security-path "$PWD/.build/swiftpm-security" --scratch-path "$PWD/.build"` | 通过 | 19 个 XCTest 通过，其中 `MTPROAdaptersTests` 8 个测试通过 |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `graphify update .` | 阻塞 | Graphify CLI 返回 `[Errno 1] Operation not permitted`，未生成可提交输出 |
| `git add ... && git commit ...` | 阻塞 | 当前 sandbox 拒绝创建 `.git/index.lock`，未完成 commit |
| `gh auth status` | 阻塞 | GitHub CLI token invalid，无法由 child Codex 创建 PR |

Pre-PR Codex Code Review：

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| Diff scope | 通过 | 变更集中在 adapter contract、adapter tests、Binance contract 文档、validation 文档和验证日志 |
| Issue scope | 通过 | 覆盖 MTP-9 要求的 public read-only market data adapter contract、fixture decoding 和 forbidden capability tests |
| Forbidden paths | 通过 | 未修改 `MTPROCore`、`MTPROPersistence`、`MTPROApp`、`Package.swift` 或非当前 issue 业务模块 |
| Live / signed endpoint boundary | 通过 | 未新增 API key、signature、account endpoint、listenKey、真实订单动作或 Live adapter |
| Validation credibility | 需说明 | 默认 `bash checks/run.sh` 被本地 sandbox 阻塞；等价 `git diff --check` 与 sandbox-compatible `swift test --disable-sandbox` 已通过 |
| Graphify boundary | 需说明 | 已尝试 update，但 sandbox 阻塞；未提交 `graphify-out/*` |
| Handoff marker | 需 fallback | 当前 sandbox 拒绝写入 `.codex/*`，本地 marker 预计需要 host-side fallback |
| GitHub handoff | 需 fallback | 当前 sandbox 拒绝写 `.git`，且 `gh` token invalid；commit / push / PR / auto-merge 预计需要 host-side fallback |

Host-side handoff fallback：

- child Codex 已完成当前 issue scope 的实现、测试、Graphify update 尝试和 Pre-PR Code Review。
- child Codex sandbox 拒绝写入 `.codex/*`，因此本地 handoff marker 由 host-side fallback 在 PR 创建后写入。
- child Codex sandbox 的 `bash checks/run.sh` 失败原因是 SwiftPM cache 写入权限，不是源码或测试失败。
- host-side fallback 在同一 issue workspace 中补跑 `git diff --check`，结果通过。
- host-side fallback 在同一 issue workspace 中补跑 `bash checks/run.sh`，结果通过，19 个 XCTest 全部通过。
- host-side fallback 只接管 commit / push / PR / auto-merge handoff / 本地 marker，不扩大 diff scope，不修改 Linear status。

Host-side validation：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | host 环境无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | host 环境 `swift test` 通过，19 个 XCTest 通过 |

## MTPRO current issue stale wording cleanup

日期：2026-05-16

执行者：Codex

目的：

- 清理 active docs 中把 `MTP-8` 写死为当前唯一 configured executable issue 的旧表述。
- 明确当前执行事项必须从 Linear / symphony-project 运行时状态读取。
- 明确 `MTP-8` 和 `MTP-9` 已完成，`MTP-10` 仍为 `Backlog`，本轮暂不接 symphony-project continuation。

文件范围：

- Created：
  - 无
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `ROADMAP.md`
  - `docs/automation/automation-readiness.md`
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未接入 symphony-project continuation。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 已在 host 环境运行 Graphify update，确认不经 child sandbox 可完成；输出仍位于忽略路径 `graphify-out/*`。
- 未提交 `graphify-out/*`。
- 未提交 `.codex/*`。
- 未修改业务代码。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `rg active stale MTP-8 current issue wording` | 通过 | active docs 未再把 `MTP-8` 写死为 current issue |
| `graphify update .` | 通过 | host 环境更新 `graphify-out/*`，未纳入 git |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，19 个 XCTest 通过 |

## MTPRO symphony-issue execution profile and Graphify refresh alignment

日期：2026-05-16

执行者：Codex

目的：

- 将 MTPRO 文档对齐到本地 symphony-issue 的 `dangerFullAccess` issue automation profile。
- 明确 child Codex 可在 issue workspace 内完成 git / PR / handoff marker；GitHub token、网络或 MCP elicitation 阻塞时再由 host-side handoff fallback 接管。
- 明确 Graphify update 不再依赖 child sandbox，PR merge / Linear bot Done 后由 symphony-issue host-side `before_remove` 刷新 `/Users/mac/Documents/MTPRO` 的 resource relationship graph。

文件范围：

- Created：
  - 无
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `docs/automation/automation-readiness.md`
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未接入 symphony-project continuation。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify full rebuild。
- 未提交 `graphify-out/*`。
- 未提交 `.codex/*`。
- 未修改业务代码。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，19 个 XCTest 通过 |

## MTP-10 交易内核、数据引擎与缓存边界

日期：2026-05-16

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 建立 `MTPROCore` 的最小 `MTPROTradingKernel` actor 边界。
- 建立 `MTPROMessageBus`、`MTPRODataEngine` 和 `MTPROMarketDataCache` 的可测试契约。
- 将只读 `MTPROMarketEvent` 同步写入 cache 和 append-only event stream。
- 通过 replay envelope 确认 cache projection 可确定性重建。

文件范围：

- Created：
  - 无
- Updated：
  - `Sources/MTPROCore/MTPROCore.swift`
  - `Tests/MTPROCoreTests/MTPROCoreTests.swift`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`
- Deleted：
  - 无

Linear / scope 确认：

- Linear 查询显示 `MTP-10` 为当前唯一 active issue，状态为 `In Progress`。
- Linear 查询显示 `MTP-9` 已 `Done`。
- Linear 查询显示 `MTP-11` 至 `MTP-15` 仍为 `Backlog`。
- 本轮只执行 MTP-10 scope，不解锁后续 issue。

边界确认：

- 未实现 Live 执行。
- 未提交订单。
- 未实现数据库适配器。
- 未实现 SwiftUI 页面。
- 未实现 Binance 网络客户端。
- 未调用 Binance signed endpoint。
- 未调用 Binance account endpoint。
- 未实现策略、backtest engine 或 paper execution engine。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

Graphify 状态：

- 当前 issue workspace 未发现 `graphify-out/*` 可读取上下文。
- 已读取 `docs/automation/graphify-resource-graph-scope.md` 和 `docs/automation/automation-readiness.md`。
- 按本轮 workflow，Graphify post-merge resource graph refresh 由 symphony-issue host-side `before_remove` 在持久仓库 `/Users/mac/Documents/MTPRO` 执行；child Codex 本轮未运行 Graphify full rebuild。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | 通过 | 24 个 XCTest 通过，`MTPROCoreTests` 14 个测试通过 |
| `bash checks/run.sh` | 通过 | `git diff --check` 和 `swift test` 通过，输出 `MTPRO checks passed.` |

新增测试：

- MessageBus monotonic sequence 和 stream replay 测试。
- DataEngine read-only market event ingest 测试。
- Cache deterministic replay projection 测试。
- TradingKernel actor 并发 ingest 隔离测试。
- TradingKernel replay cache rebuild 测试。

Pre-PR Codex Code Review：

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| Diff scope | 通过 | 变更集中在 `MTPROCore`、核心测试、backend contract、validation plan 和验证日志 |
| Issue scope | 通过 | 覆盖 MTP-10 要求的 actor kernel、MessageBus、DataEngine、Cache 和 deterministic replay |
| Forbidden paths | 通过 | 未修改 `MTPROAdapters`、`MTPROPersistence`、`MTPROApp`、`Package.swift` 或非当前 issue 业务模块 |
| Live / signed endpoint boundary | 通过 | 未新增 API key、signature、account endpoint、listenKey、真实订单动作或 Live adapter |
| Validation credibility | 通过 | 默认项目级 `bash checks/run.sh` 已通过 |
| Graphify boundary | 通过 | 未运行 full rebuild，未提交 `graphify-out/*`，post-merge refresh 交由 host-side workflow |

## Post-Issue Ledger / 施工后记账流程收口

日期：2026-05-16

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将 MTP-10 真实自动化跑通后暴露出的 `before_remove` 语义收口为 Post-Issue Ledger / 施工后记账。
- 明确施工后记账只同步最新 `main`、刷新 Graphify resource relationship graph、承接只读下一步观察提示。
- 明确下一步观察提示不授权下一个 issue、不创建 Linear issue、不修改 `ROADMAP.md`。

文件范围：

- Created：
  - `docs/automation/post-issue-ledger.md`
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `.github/pull_request_template.md`
  - `docs/automation/automation-readiness.md`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未修改业务代码。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未把下一步观察提示写成执行授权。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，24 个 XCTest 通过 |

## Structured Post-Issue Ledger Summary

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将 Post-Issue Ledger / 施工后记账从纯 hook 命令说明升级为结构化本地摘要。
- 明确摘要路径为 `.codex/post-issue-ledger/latest.json`，只供父 Codex / Human 读取。
- 明确摘要不授权下一 issue，不进入 PR。

文件范围：

- Created：
  - 无
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `.github/pull_request_template.md`
  - `docs/automation/automation-readiness.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/automation/post-issue-ledger.md`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未修改业务代码。
- 未创建 Linear Project / Issue。
- 未自动推进 Linear issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未把 ledger summary 写成执行授权。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，24 个 XCTest 通过 |

## Parent Codex Automation Supervision Flow

日期：2026-05-16

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将父 Codex 明确为当前 Project 级自动化监督角色，替代未接入的独立 `symphony-project` continuation。
- 明确父 Codex 负责 queue preview、child Codex 监控、代码审查、host-side fallback 和流程迭代建议。
- 明确父 Codex 只有在 Human 明确授权后，才可将 eligible `Backlog` 推进为唯一 `Todo`。

文件范围：

- Created：
  - `docs/automation/parent-codex-supervision.md`
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `.github/pull_request_template.md`
  - `docs/automation/automation-readiness.md`
  - `docs/automation/post-issue-ledger.md`
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未修改业务代码。
- 未创建 Linear Project / Issue。
- 未自动推进 Linear issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未把父 Codex 写成业务实现 Agent 或 PR merge Agent。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，24 个 XCTest 通过 |

## MTP-11 EMA 回测与 Paper 一致性契约

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 实现 EMA cross 策略配置、EMA 信号样本和确定性 signal timeline。
- 实现 Backtest requested / signalGenerated / completed 事件流。
- 实现 Paper sessionRequested / signalGenerated / sessionCompleted 事件流。
- 建立 Backtest / Paper signal timeline parity 验证。

文件范围：

- Created：
  - 无
- Updated：
  - `Sources/MTPROCore/MTPROCore.swift`
  - `Tests/MTPROCoreTests/MTPROCoreTests.swift`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未实现 Live trading。
- 未连接 broker。
- 未提交真实订单。
- 未调用 Binance signed endpoint。
- 未实现订单簿失衡策略。
- 未实现完整 Dashboard 页面。
- 未实现数据库 adapter。
- 未修改 Linear status。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/run.sh` | 执行前通过 | 基线 24 个 XCTest 通过 |
| `swift package clean` | 通过 | 清理 SwiftPM 增量缓存 |
| `swift test` | 通过 | 28 个 XCTest 通过，新增 EMA fixture、回测事件流、Paper 事件流和 parity 测试 |
| `bash checks/run.sh` | 通过 | `git diff --check` 通过；`swift test` 28 个 XCTest 通过；输出 `MTPRO checks passed.` |

## MTP-12 订单簿失衡策略研究链路

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 定义订单簿读模型输入，复用只读 snapshot / delta market events。
- 实现订单簿 top depth notional imbalance 信号契约。
- 新增订单簿失衡研究 command / result / event flow，并可发布到 strategy stream。
- 用测试夹具验证 delta 应用、信号稳定性、边界拒绝和研究链路事件流。

文件范围：

- Created：
  - 无
- Updated：
  - `Sources/MTPROCore/MTPROCore.swift`
  - `Tests/MTPROCoreTests/MTPROCoreTests.swift`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`
- Deleted：
  - 无

Linear / scope 确认：

- Linear 查询显示 `MTP-12` 为当前唯一 active issue，状态为 `In Progress`。
- Linear 查询显示 `MTP-11` 已 `Done`。
- Linear 查询显示 `MTP-13` 至 `MTP-15` 仍为 `Backlog`。
- 本轮只执行 MTP-12 scope，不解锁后续 issue。

边界确认：

- 未接 signed endpoint。
- 未接 account endpoint。
- 未做 futures leverage / margin action。
- 未提交、取消或替换真实订单。
- 未实现 `LiveExecutionAdapter`。
- 未扩展 configured symbol universe。
- 未实现 persistence adapter。
- 未实现 SwiftUI 页面。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

Graphify 状态：

- 当前 issue workspace 未发现 `graphify-out/*` 可读取上下文。
- 已读取 `docs/automation/graphify-resource-graph-scope.md` 和 `docs/automation/post-issue-ledger.md`。
- 按本轮 workflow，Graphify post-merge resource graph refresh 由 symphony-issue host-side `before_remove` 在持久仓库 `/Users/mac/Documents/MTPRO` 执行；child Codex 本轮未运行 Graphify full rebuild。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | 通过 | 32 个 XCTest 通过，新增订单簿读模型、失衡信号和研究事件流测试 |
| `bash checks/run.sh` | 通过 | `git diff --check` 和 `swift test` 通过，32 个 XCTest 通过，输出 `MTPRO checks passed.` |

新增测试：

- Order book read model snapshot / delta deterministic application 测试。
- Order book imbalance stable signal fixture 测试。
- Order book imbalance invalid configuration / input rejection 测试。
- Order book imbalance research event flow strategy stream 测试。

Pre-PR Codex Code Review：

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| Diff scope | 通过 | 变更集中在 `MTPROCore`、核心测试、contract 文档、validation plan 和验证日志 |
| Issue scope | 通过 | 覆盖 MTP-12 要求的订单簿读模型输入、失衡信号、研究链路和测试夹具 |
| Forbidden paths | 通过 | 未修改 `MTPROAdapters`、`MTPROPersistence`、`MTPROApp`、`Package.swift` 或非当前 issue 业务模块 |
| Live / signed endpoint boundary | 通过 | 未新增 API key、signature、account endpoint、listenKey、真实订单动作、futures / margin action 或 Live adapter |
| Validation credibility | 通过 | 默认项目级 `bash checks/run.sh` 已通过 |
| Graphify boundary | 通过 | 未运行 full rebuild，未提交 `graphify-out/*`，post-merge refresh 交由 host-side workflow |

## MTP-13 SQLite / DuckDB 投影与重放边界

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 实现 persistence replay boundary，复用 `AppendOnlyEventLog` 与 `EventReplayCommand`。
- 建立 SQLite runtime projection contract，投影 paper session、risk rejection 和 portfolio runtime read model。
- 建立 DuckDB analytical projection contract，投影 market data、backtest、订单簿研究和 analytical signal timeline。
- 确认 database table、ORM model 和 runtime object 不作为 UI contract。

文件范围：

- Created：
  - 无
- Updated：
  - `Sources/MTPROPersistence/MTPROPersistence.swift`
  - `Tests/MTPROPersistenceTests/MTPROPersistenceTests.swift`
  - `docs/contracts/persistence-boundary.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`
- Deleted：
  - 无

Linear / scope 确认：

- Linear 查询显示 `MTP-13` 为当前唯一 active issue，状态为 `In Progress`。
- Linear 查询显示 `MTP-12` 已 `Done`。
- Linear 查询显示 `MTP-14` 和 `MTP-15` 仍为 `Backlog`。
- 本轮只执行 MTP-13 scope，不解锁后续 issue。

边界确认：

- 未让 UI 直接读取数据库表。
- 未暴露 ORM model。
- 未把 runtime object 持久化为 UI contract。
- 未做破坏性数据库迁移。
- 未引入真实 SQLite / DuckDB driver。
- 未实现 Live execution persistence。
- 未连接 broker。
- 未调用 Binance signed endpoint。
- 未提交、取消或替换真实订单。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

Graphify 状态：

- 当前 issue workspace 未发现 `graphify-out/*` 可读取上下文。
- 已读取 `docs/automation/graphify-resource-graph-scope.md`。
- 按本轮 workflow，Graphify post-merge resource graph refresh 由 symphony-issue host-side `before_remove` 在持久仓库 `/Users/mac/Documents/MTPRO` 执行；child Codex 本轮未运行 Graphify full rebuild。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/run.sh` | 执行前通过 | 基线 `git diff --check` 和 `swift test` 通过，32 个 XCTest 通过 |
| `swift test` | 通过 | 36 个 XCTest 通过，新增 replay、临时 SQLite、临时 DuckDB 和投影隔离测试 |
| `bash checks/run.sh` | 通过 | `git diff --check` 和 `swift test` 通过，36 个 XCTest 通过，输出 `MTPRO checks passed.` |

新增测试：

- Persistence replay boundary selected event range rebuild 测试。
- Temporary SQLite runtime projection rebuild 测试。
- Temporary DuckDB analytical projection rebuild 测试。
- Runtime / analytical projection isolation 测试。

Pre-PR Codex Code Review：

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| Diff scope | 通过 | 变更集中在 `MTPROPersistence`、持久化测试、contract 文档、validation plan 和验证日志 |
| Issue scope | 通过 | 覆盖 MTP-13 要求的事件日志重放、SQLite 运行投影、DuckDB 分析投影和隔离验证 |
| Forbidden paths | 通过 | 未修改 `MTPROApp`、`MTPROCore`、`MTPROAdapters`、`Package.swift` 或后续 issue scope |
| Live / signed endpoint boundary | 通过 | 未新增 API key、signature、account endpoint、listenKey、真实订单动作或 Live adapter |
| Validation credibility | 通过 | 默认项目级 `bash checks/run.sh` 已通过 |
| Graphify boundary | 通过 | 未运行 full rebuild，未提交 `graphify-out/*`，post-merge refresh 交由 host-side workflow |
| Handoff marker | 待 PR 后完成 | ready-for-review PR 和 auto-merge handoff 后写入 `.codex/symphony-issue-handoff.json` |

## MTP-14 Trader Workstation 看板 ViewModel 契约

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 实现 Market / Strategy / Backtest / Paper / Risk / Portfolio / Events 的 App 层 ViewModel contract。
- 建立 Dashboard read model 聚合，输入只来自 SQLite runtime projection、DuckDB analytical projection 和 append-only event timeline。
- 移除 `MTPROApp` target 对 `MTPROAdapters` 的直接依赖，强化 UI 不直接调用 Binance adapter 的边界。
- 新增 ViewModel source contract、读模型映射测试和状态快照测试。

文件范围：

- Created：
  - 无
- Updated：
  - `Package.swift`
  - `Sources/MTPROApp/MTPROApp.swift`
  - `Tests/MTPROAppTests/MTPROAppTests.swift`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`
- Deleted：
  - 无

Linear / scope 确认：

- Linear 查询显示 `MTP-14` 为当前唯一 active issue，状态为 `In Progress`。
- Linear 查询显示 `MTP-13` 已 `Done`。
- Linear 查询显示 `MTP-15` 仍为 `Backlog`。
- 本轮只执行 MTP-14 scope，不解锁后续 issue。

边界确认：

- 未实现 SwiftUI 页面。
- 未让 UI 直接读取数据库表。
- 未暴露 ORM model。
- 未暴露 runtime object。
- 未调用 Binance adapter。
- 未提供 live order button。
- 未连接 broker。
- 未调用 Binance signed endpoint。
- 未提交、取消或替换真实订单。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

Graphify 状态：

- 当前 issue workspace 未发现 `graphify-out/*` 可读取上下文。
- 已读取 `docs/automation/graphify-resource-graph-scope.md`。
- 按本轮 workflow，Graphify post-merge resource graph refresh 由 symphony-issue host-side `before_remove` 在持久仓库 `/Users/mac/Documents/MTPRO` 执行；child Codex 本轮未运行 Graphify full rebuild。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | 通过 | 39 个 XCTest 通过，新增 Dashboard ViewModel source contract、读模型映射和状态快照测试 |
| `bash checks/run.sh` | 通过 | `git diff --check` 和 `swift test` 通过，39 个 XCTest 通过，输出 `MTPRO checks passed.` |

新增测试：

- Dashboard ViewModel stable read model source contract 测试。
- Read model projection maps all dashboard sections 测试。
- Dashboard ViewModel Codable deterministic state snapshot 测试。

Pre-PR Codex Code Review：

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| Diff scope | 通过 | 变更集中在 `MTPROApp`、App tests、contract 文档、validation plan 和验证日志；`Package.swift` 仅移除 App 对 adapter 直接依赖并补测试依赖 |
| Issue scope | 通过 | 覆盖 MTP-14 要求的 ViewModel 契约、读模型映射和状态契约测试 |
| Forbidden paths | 通过 | `.codex/*` 被 `.gitignore` 忽略，`graphify-out/*` 不存在且未进入 PR |
| Live / signed endpoint boundary | 通过 | 未新增 API key、signature、account endpoint、listenKey、真实订单动作或 Live adapter |
| Validation credibility | 通过 | 默认项目级 `bash checks/run.sh` 已通过 |
| Graphify boundary | 通过 | 未运行 full rebuild，未提交 `graphify-out/*`，post-merge refresh 交由 host-side workflow |
| Handoff marker | 待 PR 后完成 | ready-for-review PR 和 auto-merge handoff 后写入 `.codex/symphony-issue-handoff.json` |

## MTP-15 验证加固与自动化就绪

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 完成 MTP-15 验证矩阵。
- 将 PR evidence template、GitHub PR Automation Gate、WIP=1、symphony-issue handoff marker 和 Graphify / Post-Issue Ledger 边界固化为本地可重复检查。
- 更新自动化就绪文档，记录 MTP-15 当前 Linear queue snapshot。

文件范围：

- Created：
  - `checks/automation-readiness.sh`
- Updated：
  - `.github/pull_request_template.md`
  - `checks/run.sh`
  - `docs/automation/automation-readiness.md`
  - `docs/automation/graphify-resource-graph-scope.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`
- Deleted：
  - 无

Linear / scope 确认：

- Linear 查询显示 `MTP-15` 为当前唯一 active issue，状态为 `In Progress`。
- Linear 查询显示 `MTP-14` 已 `Done`。
- 本轮只执行 MTP-15 scope，不解锁后续 issue。

边界确认：

- 未实现新的业务功能。
- 未修改 `Sources/` 或 `Tests/`。
- 未修改 `ROADMAP.md`。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未实现 `LiveExecutionAdapter`。
- 未调用 Binance signed endpoint。

Graphify 状态：

- 当前 issue workspace 未发现 `graphify-out/*` 可读取上下文。
- 已读取并更新 `docs/automation/graphify-resource-graph-scope.md` 的 MTP-15 child Codex 执行边界。
- 按本轮 workflow，Graphify post-merge resource graph refresh 由 symphony-issue host-side `before_remove` 在持久仓库 `/Users/mac/Documents/MTPRO` 执行；child Codex 本轮未运行 Graphify full rebuild。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | 通过 | 检查 workflow、PR 模板、WIP=1、handoff marker、Graphify 边界、ignore 边界和验证文档，输出 `MTPRO automation readiness checks passed.` |
| `bash -n checks/automation-readiness.sh checks/run.sh` | 通过 | shell 脚本语法检查通过 |
| `git diff --check` | 通过 | 无空白或补丁格式问题 |
| `bash checks/run.sh` | 通过 | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

新增验证：

- Automation readiness shell gate。
- PR template evidence gate。
- GitHub workflow required check gate。
- WIP=1 evidence gate。
- symphony-issue handoff marker gate。
- Graphify / Post-Issue Ledger boundary gate。
- `.codex/*` 与 `graphify-out/*` local output isolation gate。

Pre-PR Codex Code Review：

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| Diff scope | 通过 | 变更集中在验证脚本、PR 模板、automation docs、validation plan 和验证日志 |
| Issue scope | 通过 | 覆盖 MTP-15 要求的验证矩阵、PR 证据、WIP=1、handoff marker、GitHub PR Automation 和 Graphify 边界 |
| Forbidden paths | 通过 | 未修改业务源码、测试源码或 `ROADMAP.md`；`.codex/*` 被 `.gitignore` 忽略，`graphify-out/*` 不存在且未进入 PR |
| Live / signed endpoint boundary | 通过 | 未新增 API key、signature、account endpoint、listenKey、真实订单动作或 Live adapter |
| Validation credibility | 通过 | 默认项目级 `bash checks/run.sh` 已通过，并包含新增 automation readiness gate |
| Graphify boundary | 通过 | 未运行 full rebuild，未提交 `graphify-out/*`，post-merge refresh 交由 host-side workflow |
| Handoff marker | 待 PR 后完成 | ready-for-review PR 和 auto-merge handoff 后写入 `.codex/symphony-issue-handoff.json` |

## MTPRO Linear Issue Execution Contract Alignment

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将 MTPRO 的 Codex Execution Agent 执行前语义对齐为“Linear issue 内容就是执行合同”。
- 移除“执行前二次确认 issue scope / boundary / validation”的流程含义。
- 明确子 Codex 读取 Linear issue 中已填写的 Scope / Non-goals / Codex Instructions / Validation / Boundary / PR Requirements 后直接执行。

文件范围：

- Created：
  - 无
- Updated：
  - `AGENTS.md`
  - `checks/automation-readiness.sh`
  - `docs/automation/automation-readiness.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未修改业务源码。
- 未修改测试源码。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未实现 `LiveExecutionAdapter`。
- 未调用 Binance signed endpoint。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无空白或补丁格式问题。 |
| `bash checks/run.sh` | 通过 | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## MTPRO Project Role Map

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 补充 MTPRO 项目能力角色地图，明确系统架构、前端设计、后端开发、数据 / 持久化、质量验证、部署与运营等职责覆盖。
- 将角色地图定位为 Human Project Planning 和阶段复盘辅助文档，不授权执行，不替代 Linear Project / Issue。

文件范围：

- Created：
  - `docs/planning/project-role-map.md`
- Updated：
  - `AGENTS.md`
  - `checks/automation-readiness.sh`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未修改业务源码。
- 未修改测试源码。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未实现 `LiveExecutionAdapter`。
- 未调用 Binance signed endpoint。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | Project Role Map 文档和检查脚本更新无空白问题。 |
| `bash checks/run.sh` | 通过 | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Linear Team Name Correction

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 修正 `docs/planning/linear-draft-plan.md` 中的目标 Linear 团队名称。
- 将团队名称统一为 `Macostrader Pro`，团队标识和团队 ID 仍为 `MTP`。

文件范围：

- Created：
  - 无
- Updated：
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未修改业务源码。
- 未修改测试源码。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | Linear team name 修正文档无空白问题。 |
| `bash checks/run.sh` | 通过 | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Swift Module MTPRO Prefix Removal

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 移除 `Sources/`、`Tests/`、SwiftPM target / product 和 Swift 类型命名中的 `MTPRO` 前缀。
- 保留项目名 `MTPRO`，但代码模块使用通用名称 `Core`、`Adapters`、`Persistence`、`App`。
- 同步更新当前合同文档和 README 中的代码模块引用。

文件范围：

- Created / Renamed：
  - `Sources/Core/Core.swift`
  - `Sources/Adapters/Adapters.swift`
  - `Sources/Persistence/Persistence.swift`
  - `Sources/App/App.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/AdaptersTests/AdaptersTests.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `Tests/AppTests/AppTests.swift`
- Updated：
  - `Package.swift`
  - `README.md`
  - `ARCHITECTURE.md`
  - `ROADMAP.md`
  - `AGENTS.md`
  - `checks/automation-readiness.sh`
  - `docs/architecture/module-boundary.md`
  - `docs/audit/mtpro-guidance-stage-code-audit.md`
  - `docs/contracts/*.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`
- Deleted / Renamed from：
  - `Sources/MTPROCore/MTPROCore.swift`
  - `Sources/MTPROAdapters/MTPROAdapters.swift`
  - `Sources/MTPROPersistence/MTPROPersistence.swift`
  - `Sources/MTPROApp/MTPROApp.swift`
  - `Tests/MTPROCoreTests/MTPROCoreTests.swift`
  - `Tests/MTPROAdaptersTests/MTPROAdaptersTests.swift`
  - `Tests/MTPROPersistenceTests/MTPROPersistenceTests.swift`
  - `Tests/MTPROAppTests/MTPROAppTests.swift`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未实现 `LiveExecutionAdapter`。
- 未调用 Binance signed endpoint。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Swift module rename 无空白问题。 |
| `swift test` | pass | 39 个 XCTest 通过；module 名称已变为 `Core`、`Adapters`、`Persistence`、`App`。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；输出 `MTPRO checks passed.` |

## Project Supervision And Examples Cleanup

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 删除 MTPRO 项目中的 `examples/` 目录。
- 移除 active docs 中把独立 Project 级自动 continuation 程序作为未完成项的表述。
- 明确 MTPRO 当前 Project 级监督由 Parent Codex Automation Supervision 承接。

文件范围：

- Updated：
  - `README.md`
  - `ROADMAP.md`
  - `docs/automation/automation-readiness.md`
  - `docs/automation/graphify-resource-graph-scope.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- Deleted：
  - `examples/README.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未修改业务代码。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Project supervision / examples cleanup 无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Codex Use Cases Alignment

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将 OpenAI Codex use cases 映射到 MTPRO 当前工程流程。
- 补齐 codebase onboarding、Codex code review、verified operations、macOS build / run loop、eval strategy 和 docs sync 的本地规则。
- 明确当前不引入独立 eval 框架，并记录未来允许引入的条件。
- 新增代码详细中文注释规则。

文件范围：

- Created：
  - `docs/automation/codex-use-cases-alignment.md`
  - `docs/automation/verified-operations.md`
  - `docs/validation/eval-strategy.md`
  - `docs/validation/macos-build-run-loop.md`
- Updated：
  - `AGENTS.md`
  - `README.md`
  - `.github/pull_request_template.md`
  - `checks/automation-readiness.sh`
  - `docs/automation/automation-readiness.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未修改业务代码。
- 未引入独立 eval 框架。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Codex use-cases alignment 文档和检查更新无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Team Role Map Alignment

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 按 Codex use cases 的 Team 视角完善 MTPRO 项目角色图。
- 补齐 Product / Design / Engineering / Finance / Operations / QA 的职责映射。
- 新增 Finance / Trading Domain Analyst、Product Designer、Frontend / App Designer 和 Automation / Runtime Operations Engineer 边界。
- 将交易语义验证、fees / slippage、Backtest / Paper parity 和 runtime readiness 纳入角色和验证规则。

文件范围：

- Updated：
  - `README.md`
  - `AGENTS.md`
  - `docs/planning/project-role-map.md`
  - `docs/validation/validation-plan.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未修改业务代码。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Team role map alignment 无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Active Documentation Closeout

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 从 `README.md` 开始梳理 MTPRO active documentation。
- 移除 active docs 中写死 current issue / stale Linear 状态的表述。
- 压缩 README、ROADMAP、ENVIRONMENT、ARCHITECTURE、automation readiness、Graphify scope、validation plan 和 Linear draft plan。
- 明确 `MTPRO 引导` Project 已完成，当前下一步是 Human 基于阶段审计报告规划新的 Linear Project。

文件范围：

- Updated：
  - `README.md`
  - `ENVIRONMENT.md`
  - `GOAL.md`
  - `AGENTS.md`
  - `ARCHITECTURE.md`
  - `ROADMAP.md`
  - `checks/automation-readiness.sh`
  - `docs/automation/automation-readiness.md`
  - `docs/automation/graphify-resource-graph-scope.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改业务代码。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未压缩历史 verification 记录。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Active docs closeout 无空白问题。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.` |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## 最近验证摘要

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 新增最近验证摘要，降低 Agent / Graphify 日常读取完整 `verification.md` 的上下文成本。
- 保持 `verification.md` 为 append-only 完整证据流水账。

文件范围：

- Created：
  - `docs/validation/latest-verification-summary.md`
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `docs/automation/graphify-resource-graph-scope.md`
  - `checks/automation-readiness.sh`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未修改业务代码。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未压缩、拆分或重写历史 verification 记录。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 最近验证摘要无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Runtime Research Workbench Linear Planning

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将 Human 确认的 `MTPRO Runtime Research Workbench v1` 写入 Linear。
- 创建 `MTP-16` 到 `MTP-23`，全部保持 `Backlog` / non-executable。
- 统一 Linear Project / Issue 正文为 Codex Execution Agent 执行合同格式。
- 在仓库中只记录摘要、issue 顺序、依赖和格式规则，不复制 8 个 issue 全文。

Linear 写入摘要：

- Project：`MTPRO Runtime Research Workbench v1`
- Project status：`Planned`
- Issue range：`MTP-16` 到 `MTP-23`
- Current Todo：none
- First executable candidate：`MTP-16`
- WIP=1：当前满足，未推进任何 issue 到 `Todo`

Linear issue 顺序：

| 顺序 | Linear issue | 目标 |
| --- | --- | --- |
| 1 | `MTP-16` | 按领域边界拆分 `Core.swift`，不改变行为 |
| 2 | `MTP-17` | 新增追加式事件日志文件持久化和重放冒烟测试 |
| 3 | `MTP-18` | 新增 SQLite 运行时投影适配器最小闭环 |
| 4 | `MTP-19` | 新增 DuckDB 分析投影适配器最小闭环 |
| 5 | `MTP-20` | 新增 Binance 公开只读行情客户端边界 |
| 6 | `MTP-21` | 串联行情 ingest -> event log -> replay -> projection snapshots |
| 7 | `MTP-22` | 新增绑定视图模型快照的 macOS 看板壳 |
| 8 | `MTP-23` | 新增“研究 -> 回测 -> 报告”最小路径和阶段证据就绪 |

Linear blocker 依赖：

- `MTP-17` blocked by `MTP-16`。
- `MTP-18` blocked by `MTP-17`。
- `MTP-19` blocked by `MTP-17`。
- `MTP-20` blocked by `MTP-16`。
- `MTP-21` blocked by `MTP-17`, `MTP-18`, `MTP-19`, `MTP-20`。
- `MTP-22` blocked by `MTP-18`, `MTP-19`, `MTP-21`。
- `MTP-23` blocked by `MTP-21`, `MTP-22`。

仓库文件范围：

- Updated：
  - `AGENTS.md`
  - `ROADMAP.md`
  - `checks/automation-readiness.sh`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未写业务代码。
- 未推进任何 Linear issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 仓库文档只记录摘要和格式规则，不复制 8 个 issue 全文。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Project Planning / Parent / Child Role Boundaries

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 固化 MTPRO 当前流程中的 Project Planning Facilitator、Parent Codex Automation Supervision 和 Child Codex Execution Agent 三角色职责边界。
- 明确 Project Planning Facilitator 只负责阶段规划、Linear Project / Issue 草案和写入准备，不操作 `Backlog` -> `Todo`。
- 明确第一个 issue 和后续 issue 的 `Backlog` -> `Todo` 都只能由 Parent Codex 在 Human 明确授权后执行。

文件范围：

- Updated：
  - `AGENTS.md`
  - `docs/automation/automation-readiness.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/planning/project-role-map.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未写业务代码。
- 未创建 Linear Project / Issue。
- 未推进任何 Linear issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 三角色职责边界文档变更通过 whitespace 检查。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## symphony-issue Active Project Pointer

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将 MTPRO 本地 `symphony-issue` workflow 定位为稳定执行规则 + active Project pointer。
- 将当前 active Project pointer 切到 `MTPRO Runtime Research Workbench v1`。
- 明确 Parent Codex 负责 Project 切换时更新 pointer，并在更新后先做 queue preview。

文件范围：

- Created：
  - `docs/automation/symphony-issue-workflow-template.md`
- Updated：
  - `AGENTS.md`
  - `docs/automation/automation-readiness.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`
- Local-only runtime updated：
  - `/Users/mac/code/symphony-workflows/mtpro-aep-v2.md`
  - `/Users/mac/code/symphony-workflows/runtime/mtpro-aep-v2-local-seed.md`
  - `/Users/mac/code/symphony-workflows/README.md`

边界确认：

- 未写业务代码。
- 未创建 Linear Project / Issue。
- 未推进任何 Linear issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 本地 workflow pointer 更新不授权执行。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | `symphony-issue` active Project pointer 文档变更通过 whitespace 检查。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## MTP-16 Core Domain File Split

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 按 Linear issue `MTP-16` 将 `Sources/Core/Core.swift` 按领域边界拆分为多个文件。
- 保持 `Core` module public API、行为和现有测试语义不变。
- 补齐触达 production code 的中文边界注释，明确 read-only market data、append-only event log、Paper-only 和禁止 Live trading / signed endpoint / broker action。

文件范围：

- Deleted：
  - `Sources/Core/Core.swift`
- Created：
  - `Sources/Core/CoreError.swift`
  - `Sources/Core/MarketPrimitives.swift`
  - `Sources/Core/MarketDataModels.swift`
  - `Sources/Core/OrderBookReadModel.swift`
  - `Sources/Core/StrategySignals.swift`
  - `Sources/Core/OrderBookImbalance.swift`
  - `Sources/Core/EMACross.swift`
  - `Sources/Core/CommandsAndQueries.swift`
  - `Sources/Core/ResearchResults.swift`
  - `Sources/Core/DomainEvents.swift`
  - `Sources/Core/ResearchEventFlows.swift`
  - `Sources/Core/EventLog.swift`
  - `Sources/Core/MarketDataCache.swift`
  - `Sources/Core/TradingKernel.swift`
  - `Sources/Core/CoreBaseline.swift`

边界确认：

- 未新增业务功能。
- 未修改策略逻辑。
- 未修改 persistence、adapter、App 行为。
- 未引入数据库、网络或 UI。
- 未触碰 Live trading、signed endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

行为保持检查：

- public 顶层类型数量：拆分前 66，拆分后 66。
- public 顶层类型缺失：无。
- public 顶层类型新增：无。
- `StrategyMarketDataValidation` 仍为 `ResearchEventFlows.swift` 文件内 private helper。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 修复一次机械切分遗漏括号后，39 个 XCTest 通过。 |
| `git diff --check` | pass | Core 文件拆分无 whitespace error。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Parent Codex Auto Project Scheduling

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将 MTPRO 中 Parent Codex Automation Supervision 调整为 Project 级自动调度角色。
- 明确 Human 授权停留在 Project / Issue plan review 和 Linear 写入层；`MTPRO Runtime Research Workbench v1` 内后续 eligible issue 由父 Codex 按 queue preflight 自动推进。

文件范围：

- Updated：
  - `README.md`
  - `AGENTS.md`
  - `.github/pull_request_template.md`
  - `docs/automation/automation-readiness.md`
  - `docs/automation/codex-use-cases-alignment.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/automation/post-issue-ledger.md`
  - `docs/automation/symphony-issue-workflow-template.md`
  - `docs/automation/verified-operations.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/planning/project-role-map.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未写业务代码。
- 未创建 Linear Project / Issue。
- 未推进任何 Linear issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 父 Codex 自动调度仍必须通过 WIP=1、依赖、previous issue Done 和 execution contract Gate。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Parent Codex 自动 Project 调度文档变更通过 whitespace 检查。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## MTP-17 File-backed Append-only Event Log

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 按 Linear issue `MTP-17` 新增追加式事件日志文件持久化边界。
- 支持写入 Core `EventEnvelope`，并按 `EventReplayCommand` 从文件事实源 replay。
- 验证 append-only sequence 不变量和 replay smoke path，为后续 SQLite / DuckDB adapter 提供稳定事实源。
- 保持文件格式对 UI、数据库 schema 和外部 API 不可见。

文件范围：

- Updated：
  - `Sources/Persistence/Persistence.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/persistence-boundary.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未实现 SQLite adapter。
- 未实现 DuckDB adapter。
- 未做 schema migration。
- 未接 Binance 网络。
- 未做 UI。
- 未触碰 Live trading、signed endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 42 个 XCTest 通过；新增文件事件日志 append、append-only 拒绝跳号、file replay projection smoke 测试。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；42 个 XCTest 通过，输出 `MTPRO checks passed.` |

## MTP-18 SQLite Runtime Projection Adapter

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 按 Linear issue `MTP-18` 新增 SQLite runtime projection adapter 最小闭环。
- 基于 MTP-17 event log / replay envelope 重建 paper session、risk rejection、portfolio projection。
- 提供 query snapshot，把 SQLite 私有投影存储重新读回稳定 `SQLiteRuntimeProjectionSnapshot`。
- 保持 SQLite schema、SQL statement 和 payload 编码不暴露给 UI、API 或 ViewModel contract。

文件范围：

- Updated：
  - `Package.swift`
  - `Sources/Persistence/Persistence.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/persistence-boundary.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- Event Log / replay envelope 仍是事实源。
- SQLite 只作为运行时投影 adapter，不保存真实 broker 状态。
- 未做完整 schema 设计。
- 未做 migration framework。
- 未引入 ORM。
- 未实现 DuckDB adapter。
- 未接 Binance 网络。
- 未做 UI。
- 未触碰 Live trading、signed endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 45 个 XCTest 通过；新增 SQLite runtime projection adapter rebuild / query snapshot / replacement / empty snapshot 测试。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；45 个 XCTest 通过，输出 `MTPRO checks passed.` |

## MTP-19 DuckDB Analytical Projection Adapter

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 按 Linear issue `MTP-19` 新增 DuckDB analytical projection adapter 最小闭环。
- 基于 MTP-17 event log / replay envelope 重建 market data、backtest run、order book research run 和 signal timeline。
- 在 macOS runtime target 使用官方 SwiftPM 包 `duckdb/duckdb-swift`，提供 query snapshot，把 DuckDB 私有分析投影存储重新读回稳定 `DuckDBAnalyticalProjectionSnapshot`。
- 保持 DuckDB schema、SQL statement 和 payload 编码不暴露给 UI、API 或 ViewModel contract。

文件范围：

- Added：
  - `Package.resolved`
  - `Sources/Persistence/DuckDBAnalyticalProjectionAdapter.swift`
- Updated：
  - `Package.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/persistence-boundary.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- Event Log / replay envelope 仍是事实源。
- DuckDB 只作为分析投影 adapter，不保存 runtime object 或真实 broker 状态。
- 未做完整 schema 设计。
- 未做 migration framework。
- 未引入 ORM。
- 未扩展 SQLite runtime adapter。
- 未接 Binance 网络。
- 未做 UI。
- 未触碰 Live trading、signed endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- GitHub Ubuntu runner 不构建官方 DuckDB Swift wrapper；真实 DuckDB adapter 由 macOS 本地验证覆盖，Linux CI 只编译公共 API。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter PersistenceTests/testDuckDBAnalyticalProjectionAdapter` | pass | 3 个 DuckDB adapter focused tests 通过；覆盖 rebuild / query snapshot、重复 rebuild 替换旧投影、空 snapshot。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；48 个 XCTest 通过，输出 `MTPRO checks passed.` |

## MTP-20 Binance Public Read-only Client Boundary

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 按 Linear issue `MTP-20` 新增 Binance public read-only market data client boundary。
- 在现有 endpoint contract 和 fixture decoder 基础上增加 client configuration、transport request、transport protocol、URLSession transport 和 client facade。
- 通过 mock transport required validation 覆盖 REST public endpoint、public depth stream path、fixture parity 和 forbidden capability 断言。
- 保持 required validation 不依赖真实 Binance 网络；真实网络 smoke test 仍仅可作为可选人工证据。

文件范围：

- Updated：
  - `Sources/Adapters/Adapters.swift`
  - `Tests/AdaptersTests/AdaptersTests.swift`
  - `docs/architecture/module-boundary.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- Binance client 只读取 public market data。
- request 发给 transport 前校验 `isReadOnly == true` 和 `requiresAPIKey == false`。
- request 发给 transport 前校验 path 属于 Binance public market data allowlist。
- transport request 不携带 API key、signature、listenKey、account、order、SAPI、FAPI 或 DAPI 片段。
- 未做 MTP-21 ingest 串联。
- 未写 Event Log。
- 未接 DataEngine / TradingKernel。
- 未做 SwiftUI 页面。
- 未把真实 Binance 网络 smoke test 作为 required validation。
- 未触碰 Live trading、signed endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AdaptersTests` | pass | 12 个 AdaptersTests 通过；新增 mock transport、REST fixture parity、public depth stream path 和 mutable/API-key contract transport 前拒绝测试。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；52 个 XCTest 通过，输出 `MTPRO checks passed.` |

## MTP-21 Runtime Market Data Ingest Replay Projection

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 按 Linear issue `MTP-21` 串联 Binance public read-only market data ingest -> Core event log -> replay -> SQLite / DuckDB projection snapshots。
- 新增薄 `Runtime` target，依赖 `Adapters`、`Core` 和 `Persistence` 做跨模块编排，避免 `App` 直接调用 Binance adapter。
- required validation 使用 mock transport / fixture parity，不依赖真实 Binance 网络。
- 验证 market event sequence 单调、replay deterministic、DuckDB analytical snapshot 来自 replay，SQLite runtime snapshot 在 market-only ingest 下保持稳定空 snapshot。

文件范围：

- Added：
  - `Sources/Runtime/Runtime.swift`
  - `Tests/RuntimeTests/RuntimeTests.swift`
- Updated：
  - `Package.swift`
  - `README.md`
  - `ARCHITECTURE.md`
  - `docs/architecture/module-boundary.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/contracts/persistence-boundary.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- Runtime 只消费 Binance public read-only client 输出。
- 自动验证只使用 mock transport 和 fixture payload。
- request 不携带 API key、signature、listenKey、account、order、SAPI、FAPI 或 DAPI 片段。
- Event Log / replay envelope 仍是事实源。
- Projection snapshots 来自 replay，不暴露 SQLite / DuckDB schema。
- Market-only ingest 不伪造 Paper / Risk / Portfolio runtime facts。
- 未新增 UI。
- 未新增完整报表路径。
- 未把真实 Binance 网络 smoke test 作为 required validation。
- 未触碰 Live trading、signed endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 55 个 XCTest 通过；新增 3 个 RuntimeTests 覆盖端到端 ingest / event log / replay / projection snapshot、非空 file event log 拒绝和 SQLite adapter replay query。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；55 个 XCTest 通过，输出 `MTPRO checks passed.` |

## MTP-22 macOS Dashboard Shell

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 按 Linear issue `MTP-22` 新增绑定 `DashboardViewModel` snapshot 的 macOS 只读看板 shell。
- 新增 `MTPRODashboard` SwiftPM executable，提供可构建、可 smoke-run 的 macOS app shell 入口。
- 展示 Market / Strategy / Backtest / Paper / Risk / Portfolio / Events 七个只读区域。
- 验证 shell 只消费 App 层 ViewModel / Read Model，不导入 Runtime / Adapters，不直连 database schema 或行情 adapter。

文件范围：

- Added：
  - `Sources/App/DashboardShell.swift`
  - `Sources/MTPRODashboard/MTPRODashboardApplication.swift`
- Updated：
  - `Package.swift`
  - `Sources/App/App.swift`
  - `Tests/AppTests/AppTests.swift`
  - `checks/run.sh`
  - `README.md`
  - `ARCHITECTURE.md`
  - `ENVIRONMENT.md`
  - `docs/product/product-surface-map.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/macos-build-run-loop.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- SwiftUI shell 唯一输入是 `DashboardViewModel` / `DashboardShellSnapshot`。
- 默认 app launch snapshot 是空 read model projection，不伪造 market、paper、risk、portfolio 或 event facts。
- `MTPRODashboard` executable 只依赖 `App` target。
- `Sources/App/DashboardShell.swift` 和 `Sources/MTPRODashboard/MTPRODashboardApplication.swift` 不导入 Runtime / Adapters。
- shell source 不直接引用 database implementation 名或 public market data client 类型。
- 未提供 live order button。
- 未连接真实 broker / exchange。
- 未读取 secret。
- 未触碰 signed endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift build --product MTPRODashboard` | pass | macOS dashboard executable 构建通过。 |
| `MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` | pass | 输出 `MTPRO Dashboard smoke: sections=7; readModelOnly=true; sections=Market,Strategy,Backtest,Paper,Risk,Portfolio,Events`。 |
| `swift test` | pass | 58 个 XCTest 通过；新增 AppTests 覆盖 shell snapshot binding、空 read model 初始快照和 forbidden integration source boundary。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、`swift build --product MTPRODashboard`、`MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` 和 `swift test` 通过；58 个 XCTest 通过，输出 `MTPRO checks passed.` |

CI 修复记录：

- GitHub Actions 初次运行失败：Linux runner 编译 `App` target 时不提供 SwiftUI，错误为 `no such module 'SwiftUI'`。
- 修复方式：`DashboardShell.swift` 保留跨平台 shell snapshot contract；真实 SwiftUI view 只在 `canImport(SwiftUI) && os(macOS)` 分支构建，非 macOS 使用 snapshot-only fallback 供 XCTest 和 CI 验证。
- 二次修复：SwiftPM Linux `swift test` 仍会编译 executable target，因此 `MTPRODashboardApplication` 也新增非 macOS command-line fallback，避免 unconditional `Darwin` / `SwiftUI` import。
- `checks/run.sh` 修复为只在 Darwin runner 执行 `swift build --product MTPRODashboard` 和 dashboard smoke run；Linux CI 跳过 macOS-only shell build / smoke 后继续运行 `swift test`。

## MTP-23 Research -> Backtest -> Report 最小路径

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 按 Linear issue `MTP-23` 新增 Research -> Backtest -> Report 最小路径。
- 新增 `ReportReadModel`、`ResearchBacktestReportArtifact`、`ReportViewModel` 和 Dashboard Report 快照。
- 复用既有 strategy / backtest / paper parity / projection snapshots，不新增 Runtime / Adapter 依赖。
- 准备阶段证据材料 `docs/validation/mtp-23-stage-evidence.md`。
- 明确 Stage Code Audit Report 不属于本 issue，必须在 Project 全部 Done 后由父 Codex 单独输出。

文件范围：

- Updated：
  - `Sources/App/App.swift`
  - `Sources/App/DashboardShell.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/product/product-surface-map.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`
- Added：
  - `docs/validation/mtp-23-stage-evidence.md`

边界确认：

- Report 输入只来自 `DuckDBAnalyticalProjectionSnapshot`、`SQLiteRuntimeProjectionSnapshot` 和 append-only event timeline 派生的 read model。
- Report 只表达 projection-level Backtest / Paper evidence，不替代 Core 层完整 signal timeline parity。
- Dashboard shell 只展示 Report ViewModel 快照，不导入 Runtime / Adapters，不调用行情 adapter。
- Report artifact 的 execution authorization 固定为 research output only。
- 未输出 Stage Code Audit Report。
- 未做完整报表系统。
- 未扩展完整 Paper execution 工作流。
- 未连接真实 broker / exchange。
- 未读取 secret。
- 未触碰 Live trading、signed endpoint、account endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 59 个 XCTest 通过；新增 AppTests 覆盖 Report read model、Dashboard Report 快照、projection-level parity evidence 和 missing Paper projection 禁区断言。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、`swift build --product MTPRODashboard`、`MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` 和 `swift test` 通过；smoke 输出 `sections=8`；59 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Runtime Research Workbench Stage Code Audit 落仓

日期：2026-05-18

执行者：Parent Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将本会话已输出的 `MTPRO Runtime Research Workbench v1` Stage Code Audit Report 固化为 canonical 仓库文档。
- 新增 `docs/audit/mtpro-runtime-research-workbench-v1-stage-code-audit.md`，作为后续 Next Human Project Planning 的固定读取入口。
- 更新 `docs/validation/latest-verification-summary.md`，指向新的 Stage Code Audit Report。
- 补充 Known CI Boundary，记录 `MTP-18` / `MTP-19` / `MTP-22` 的临时 CI 平台边界、修复方式和最终通过 run。

边界确认：

- 未修改 Linear Project / Issue。
- 未修改 Linear status。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未修改业务代码。
- 未创建下一阶段 Project / Issue。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 文档变更无空白错误。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、`swift build --product MTPRODashboard`、`MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` 和 `swift test` 通过；59 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Stage Code Audit Report Repository Gate

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 固化 MTPRO Stage Code Audit Report 落仓规则。
- 明确命名规则为 `docs/audit/<linear-project-slug>-stage-code-audit.md`。
- 明确 Stage Code Audit Report 必须覆盖完整 Linear Project，不得只覆盖单个 issue。
- 明确 Next Human Project Planning 必须读取落仓的 Project 级审计报告。

文件范围：

- Updated：
  - `README.md`
  - `AGENTS.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/audit/mtpro-runtime-research-workbench-v1-stage-code-audit.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未修改 Linear Project / Issue。
- 未修改 Linear status。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未修改业务代码。
- 未创建下一阶段 Project / Issue。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Stage Code Audit Report 落仓规则文档变更无空白错误。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build / smoke 和 `swift test` 通过；59 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Role Alias Number Rule

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 固化 MTPRO 三位数字编号和三字母角色代号规则。
- 明确 `@001 = PLN`，并固定 `001` 到 `007` 的核心角色映射。
- 明确角色编号只用于沟通压缩，不改变职责边界，不授权执行。

文件范围：

- Updated：
  - `AGENTS.md`
  - `docs/planning/project-role-map.md`
  - `docs/automation/parent-codex-supervision.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未修改 Linear Project / Issue。
- 未修改 Linear status。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未修改业务代码。
- 未创建下一阶段 Project / Issue。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Role Alias Rule 文档变更无空白错误。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build / smoke 和 `swift test` 通过；59 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Trading Validation Project Planning Record

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 新增 `MTPRO Trading Validation and Parity Hardening` 写入 Linear 前的 Project Planning Record。
- 在 `docs/planning/linear-draft-plan.md` 中链接当前 planning record。
- 明确仓库只保存 Project 级计划摘要和格式门槛。
- 明确完整 issue execution contract 以 Linear issue body 为准。

文件范围：

- Created：
  - `docs/planning/mtpro-trading-validation-and-parity-hardening-plan.md`
- Updated：
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 Todo。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未写业务代码。
- 未复制 7 个 issue 的完整正文到仓库。
- 未把 planning record 当作执行授权。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Trading Validation planning record 文档变更无空白错误。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build / smoke 和 `swift test` 通过；输出 `MTPRO checks passed.` |

## Project Planning Record Structure Normalization

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将历史 Project planning 内容迁移到 `docs/planning/projects/`。
- 固化 Project Planning Record 的 canonical 命名规则和内容规则。
- 将 `docs/planning/linear-draft-plan.md` 收敛为入口索引和边界规则文档。
- 明确完整 issue execution contract 归属 Linear issue body。

文件范围：

- Created：
  - `docs/planning/projects/mtpro-guidance-plan.md`
  - `docs/planning/projects/mtpro-runtime-research-workbench-v1-plan.md`
  - `docs/planning/projects/mtpro-trading-validation-and-parity-hardening-plan.md`
- Deleted：
  - `docs/planning/mtpro-trading-validation-and-parity-hardening-plan.md`
- Updated：
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 Todo。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未写业务代码。
- 未复制完整 issue body 到仓库。
- 未把 planning record 当作执行授权。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Project Planning Record 结构迁移文档变更无空白错误。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build / smoke 和 `swift test` 通过；输出 `MTPRO checks passed.` |

## Parent Codex Startup Runbook

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 固化 `@002 / PAR` 接管已写入 Linear Project 时的启动 runbook。
- 明确执行前检查、active Project pointer 更新、pointer 后二次 queue preview 和唯一 eligible issue 推进必须作为连续动作处理。

文件范围：

- Updated：
  - `AGENTS.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/automation/symphony-issue-workflow-template.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 Todo。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Parent Codex startup runbook 文档变更无空白错误。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build / smoke 和 `swift test` 通过；输出 `MTPRO checks passed.` |

## MTP-24 Trading Validation Matrix

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 新增 `docs/validation/trading-validation-matrix.md`，作为 Trading Validation Matrix 和验收证据边界入口。
- 记录 EMA parity、order book imbalance parity、fees / slippage、risk blocker、portfolio exposure 和 report evidence 的现有 coverage、证据边界和后续回填责任。
- 在 `checks/automation-readiness.sh` 中检查 matrix 文件和 required `TVM-*` anchors，防止矩阵入口丢失。
- 在 `docs/validation/validation-plan.md` 中链接 matrix，并记录 MTP-24 的 required validation。
- 更新最近验证摘要，保留 MTP-24 本轮验证结果和当前 Project 边界。

文件范围：

- Created：
  - `docs/validation/trading-validation-matrix.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 production Swift code。
- 未实现策略逻辑。
- 未实现 fees / slippage 计算。
- 未实现 risk engine。
- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未接 Live trading、signed endpoint、account endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；已检查 `docs/validation/trading-validation-matrix.md` 和 `TVM-EMA-PARITY`、`TVM-ORDER-BOOK-IMBALANCE-PARITY`、`TVM-FEES-SLIPPAGE`、`TVM-RISK-BLOCKER`、`TVM-PORTFOLIO-EXPOSURE`、`TVM-REPORT-EVIDENCE`、`TVM-FUTURE-ISSUE-BACKFILL`。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 通过；59 个 XCTest 通过；输出 `MTPRO checks passed.` |

## 2026-05-18 — MTP-25 EMA Backtest / Paper parity hardening

执行者：Codex

关联 Linear issue：`MTP-25` — 加固 EMA Backtest / Paper signal timeline parity。

本轮变更：

- `BacktestEventFlow` / `PaperSessionEventFlow` 在 EMA 计算前校验 bars 是否被 `MarketDataQuery.range` 完整覆盖。
- 新增 deterministic Core tests，覆盖 strategy config、symbol、timeframe、warm-up、signal direction、timestamp、完整 signal timeline 和 query range too narrow 错误边界。
- 回填 `docs/validation/trading-validation-matrix.md` 的 `TVM-EMA-PARITY`。
- 更新 `docs/contracts/backend-use-case-contract.md`、`docs/contracts/api-contract.md` 和 `docs/validation/validation-plan.md` 的 MTP-25 契约 / 验证说明。

验证命令：

```bash
swift test --filter CoreTests/testEMA
bash checks/run.sh
```

验证结果：

- `swift test --filter CoreTests/testEMA` 通过：4 个 EMA XCTest，0 failure。
- 更新 latest summary 后的两次中间验证失败均来自 automation readiness 固定锚点缺失：先缺少 `临时 CI 平台边界`，再缺少 `覆盖完整 Linear Project`；两个锚点已恢复。
- `bash checks/run.sh` 通过：`git diff --check`、`bash checks/automation-readiness.sh`、`swift build --product MTPRODashboard`、`MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard`、`swift test` 均通过。
- `swift test` 全量结果：61 个 XCTest，0 failure。
- Dashboard smoke 输出：`MTPRO Dashboard smoke: sections=8; readModelOnly=true; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。
- 最终输出：`MTPRO checks passed.`。

边界确认：

- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint、account endpoint、broker action 或真实订单行为。
- 未修改 Linear status。
- 未运行 Graphify full rebuild。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

---

## 2026-06-01 — MTPRO Target Module Physical Layout / Source Migration Planning Record

执行者：Codex

目的：

- 将 Human 确认的 `MTPRO Target Module Physical Layout / Source Migration v1` planning draft 落仓为 docs-only Project Planning Record。
- 记录 target module physical layout / source migration 的 Project goal、target maturity、target engines / modules、scope、non-goals、8 个 milestones、suggested issue order、dependencies、validation requirements、evidence requirements、first executable issue candidate、WIP=1、Linear write boundary 和 repository record boundary。
- 明确该 planning record 只作为 Linear 写入前的 Project 级计划摘要，不授权 source move、`Package.swift` target graph change、business code、L4 implementation 或任何 live / broker / signed / OMS / command 能力。

更新内容：

- 新增 `docs/planning/projects/mtpro-target-module-physical-layout-source-migration-v1-plan.md`。
- 更新 `docs/planning/linear-draft-plan.md`，把 `MTPRO Engine Module Boundary Consolidation v1` 标记为已完成，并将当前 planning record 指向 `MTPRO Target Module Physical Layout / Source Migration v1`。
- 更新 `docs/validation/latest-verification-summary.md`，记录该 Project-level planning record 已落仓但不是 Project closure，不更新 `Final Product Goal Progress`，不更新旧 `Engine Maturity Roadmap Progress`，后续执行必须经 Linear 写入和 Parent Codex queue preflight。
- 更新 `BLUEPRINT.md`，只增加 planning record 引用，不复制完整 issue body，不更新进度条，不授权 execution。
- 更新 `docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，增加 target module physical layout / source migration planning record 的 mechanical readiness anchor，确保后续 root docs refresh 不会丢失该 non-executable planning record。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 本 docs-only PR 终稿验证通过。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build / smoke 和 Swift test；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不修改业务代码。
- 不移动 `Sources` 文件。
- 不修改 `Package.swift` target graph。
- 不修改 Figma。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation 或 OMS implementation。
- 不实现 signed endpoint、account endpoint / listenKey、private WebSocket runtime、broker / exchange execution adapter、`LiveExecutionAdapter`、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、real PnL、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

## Root Docs Refresh Gate

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 固化 Project Done 后的 Root Docs Refresh Gate。
- 明确 Stage Code Audit Report 必须包含 Root Docs Delta。
- 明确 `@002 / PAR` 只同步 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md`、`ROADMAP.md` 中已发生的事实；方向性变化交给 Human + `@001 / PLN`。

文件范围：

- Updated：
  - `AGENTS.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 Todo。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Root Docs Refresh Gate 文档变更无空白错误。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build / smoke 和 `swift test` 通过；61 个 XCTest 通过；输出 `MTPRO checks passed.` |

## MTP-26 Order Book Imbalance parity / bias evidence

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 为 `OrderBookImbalanceSignalSample` 增加 `inputSource`，让订单簿失衡信号 evidence 可追溯到原始 snapshot 或 delta 应用后的本地读模型。
- 新增 `OrderBookImbalanceResearchParity` 与 `OrderBookImbalanceResearchParityResult`，比较直接策略 contract 和 research event flow 的 signal samples。
- 明确 ask dominance 只作为 research bias，signal direction 仍为 `.flat`，不映射为 short、margin、futures leverage 或真实订单动作。
- 在 DuckDB analytical signal timeline projection 中保留 `orderBookInputSource`，供 read model / report evidence 使用，不暴露数据库 schema。
- 回填 `TVM-ORDER-BOOK-IMBALANCE-PARITY`，并在 validation plan / contract docs 记录 MTP-26 验收边界。

文件范围：

- Updated：
  - `Sources/Core/OrderBookImbalance.swift`
  - `Sources/Core/ResearchEventFlows.swift`
  - `Sources/Persistence/Persistence.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未运行 Graphify full rebuild。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未实现 futures leverage / margin action。
- 未实现 Paper 或 Live execution 推进。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests/testOrderBookImbalance` | pass | 4 个 CoreTests 通过；覆盖订单簿失衡 invalid input、research stream、parity / bias evidence 和 deterministic fixture。 |
| `swift test --filter PersistenceTests/testTemporaryDuckDBProjectionRebuildsAnalyticalState` | pass | 1 个 PersistenceTests 通过；验证 DuckDB analytical signal timeline 保存 order book input source。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 通过；62 个 XCTest 通过；输出 `MTPRO checks passed.` |

## MTP-27 Fees / slippage assumptions and minimum cost evidence

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 新增 Core-only `ExecutionCostAssumptions`，定义 deterministic fixture：maker fee `2 bps`、taker fee `5 bps`、fixed slippage `1.5 bps` 和 `8` 位小数 rounding scale。
- 新增 `ExecutionCostEstimateRequest` / `ExecutionCostEstimate` / `ExecutionCostCalculator`，输出 gross notional、fee amount、slippage amount 和 total cost amount。
- 新增 `ExecutionCostParity` / `ExecutionCostParityResult`，比较 Backtest 与 Paper 使用同一固定假设和同一输入时的 cost evidence 是否一致。
- 回填 `TVM-FEES-SLIPPAGE`，并在 validation plan / contract docs 记录 MTP-27 验收边界。

文件范围：

- Added：
  - `Sources/Core/ExecutionCosts.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未运行 Graphify full rebuild。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未实现 exchange fee table。
- 未实现 dynamic slippage model。
- 未实现 execution cost optimizer。
- 未实现 Paper 或 Live execution 推进。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests/testExecutionCost` | pass | 3 个 CoreTests 通过；覆盖 maker / taker fee、fixed slippage、gross notional、total cost、rounding scale、Backtest / Paper cost parity 和 invalid assumptions。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 通过；65 个 XCTest 通过；输出 `MTPRO checks passed.` |

## MTP-28 Risk blocker evidence and portfolio exposure read model

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 新增 `RiskBlockerEvidence` / `RiskBlockerReason`，记录 proposed Paper action context、risk profile、blocker reason 和 generatedAt。
- 新增 `PortfolioExposureSnapshot` / `PortfolioExposureSource`，记录 paper-only portfolio exposure、reference price、gross exposure notional 和 source。
- 扩展 SQLite runtime projection，保存 risk blocker evidence、portfolio exposure、source sequence 和 projected timestamp。
- 扩展 App / Dashboard Risk / Portfolio 只读 ViewModel，展示 blocker reason、exposure count 和 gross exposure notional。
- 回填 `TVM-RISK-BLOCKER`、`TVM-PORTFOLIO-EXPOSURE`，并在 validation plan / contract docs 记录 MTP-28 验收边界。

文件范围：

- Updated：
  - `Sources/Core/CoreError.swift`
  - `Sources/Core/CommandsAndQueries.swift`
  - `Sources/Core/DomainEvents.swift`
  - `Sources/Persistence/Persistence.swift`
  - `Sources/App/App.swift`
  - `Sources/App/DashboardShell.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/persistence-boundary.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未运行 Graphify full rebuild。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未实现完整风险引擎。
- 未实现实时风控。
- 未实现仓位管理、保证金、杠杆。
- 未实现真实账户余额、broker balance 或 Live execution。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests/testRiskBlockerEvidenceAndPortfolioExposureRemainPaperOnlyReadModels` | pass | 1 个 CoreTests 通过；覆盖 proposed Paper action context、risk profile、blocker reason、paper-only execution mode、portfolio exposure source 和 gross exposure notional。 |
| `swift test --filter <MTP-28 targeted Persistence/App tests>` | pass | 4 个 targeted XCTest 通过；覆盖 SQLite runtime projection、Risk / Portfolio ViewModel 和 Dashboard shell snapshot。 |
| `swift test` | pass | 66 个 XCTest 通过；新增 MTP-28 risk blocker / portfolio exposure evidence coverage。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 通过；66 个 XCTest 通过；输出 `MTPRO checks passed.` |

## MTP-29 Report / Dashboard trading validation evidence summary

日期：2026-05-19

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 新增 `ReportExecutionCostEvidence`，把 MTP-27 deterministic fees / slippage fixture 和 paper-only portfolio exposure projection 映射为 Report 层只读成本证据。
- 新增 `TradingValidationEvidenceSummary`，聚合 projection-level parity、Backtest / Paper cost parity、risk blocker evidence 和 portfolio exposure evidence。
- 扩展 `ResearchBacktestReportArtifact`、`ReportArtifactViewModel` 和 `ReportViewModel`，展示 cost assumption IDs、cost evidence count、cost parity consistency、risk blocker evidence IDs、portfolio exposure symbols 和 gross exposure notional。
- 扩展 Dashboard Report shell snapshot，展示 cost evidence、risk blockers、exposure evidence、cost parity、risk blocker evidence、exposure symbols 和 gross exposure。
- 回填 `TVM-REPORT-EVIDENCE`、validation plan、read model / frontend contract 和 product surface map。

文件范围：

- Updated：
  - `Sources/App/App.swift`
  - `Sources/App/DashboardShell.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未运行 Graphify full rebuild。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未实现完整报表系统。
- 未实现交易所费率表、动态滑点模型或执行成本优化。
- 未实现完整风险引擎、实时风控、仓位管理、保证金、杠杆或真实账户余额。
- 未实现 Paper 或 Live execution 推进。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 8 个 AppTests 通过；覆盖 Report / Dashboard trading validation evidence summary、Codable deterministic snapshot、schema leakage 禁区和 research-only execution authorization。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 通过；66 个 XCTest 通过；输出 `MTPRO checks passed.` |

## MTP-30 Validation summary, automation evidence, and Stage Code Audit input

日期：2026-05-19

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 更新最近验证摘要，记录 `MTPRO Trading Validation and Parity Hardening` 中 `MTP-24` 至 `MTP-29` 的 Done evidence 和 MTP-30 当前收口目标。
- 回填 `docs/validation/trading-validation-matrix.md` 的 MTP-30 阶段收口说明。
- 新增 `docs/validation/mtp-30-stage-audit-input.md`，汇总 Issue / PR evidence、merge commit、required check、matrix evidence chain、known boundaries、automation readiness evidence、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- 更新 `docs/validation/validation-plan.md` 和 `checks/automation-readiness.sh`，使 MTP-30 输入材料和关键锚点进入本地机械检查。

文件范围：

- Added：
  - `docs/validation/mtp-30-stage-audit-input.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未输出最终 Stage Code Audit Report。
- 未修改 active Project pointer。
- 未运行 Graphify full rebuild。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未实现完整报表系统。
- 未实现交易所费率表、动态滑点模型或执行成本优化。
- 未实现完整风险引擎、实时风控、仓位管理、保证金、杠杆或真实账户余额。
- 未实现 Paper 或 Live execution 推进。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；MTP-30 Stage Code Audit input、Trading Validation Matrix 和 automation anchors 完整。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 通过；66 个 XCTest 通过；输出 `MTPRO checks passed.` |

## MTPRO Trading Validation and Parity Hardening Stage Code Audit Report

日期：2026-05-19

执行者：Parent Codex Automation Supervision（@002 / PAR）

目的：

- 将 `MTPRO Trading Validation and Parity Hardening` 的 Project 级 Stage Code Audit Report 落仓到 canonical audit path。
- 同步最新验证摘要，记录 `MTP-24` 到 `MTP-30` 全部 Done、PR evidence、final validation、Known CI Boundary、Boundary Audit 和 Next Human Project Planning handoff。
- 通过 Root Docs Refresh Gate 更新 `README.md` 与 `ROADMAP.md` 中已发生的 Project 完成事实。

文件范围：

- Added：
  - `docs/audit/mtpro-trading-validation-and-parity-hardening-stage-code-audit.md`
- Updated：
  - `README.md`
  - `ROADMAP.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未推进任何 issue 到 `Todo`。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未写业务代码。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未实现 Live execution。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 本轮 Stage Code Audit Report 和文档更新无空白问题。 |
| `bash checks/run.sh` | failed first attempt | 首次本地增量构建在 `swift test` 链接阶段引用旧的 `SQLiteRuntimeProjectionSnapshot` 符号并失败；本轮仅改文档，判断为 SwiftPM 本地缓存边界。 |
| `swift package clean && bash checks/run.sh` | pass | 清理 SwiftPM build cache 后，同一验证入口通过；`git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 通过；66 个 XCTest 通过；输出 `MTPRO checks passed.` |

## MTPRO Paper Session Runtime v1 Project Planning Record

日期：2026-05-19

执行者：Codex（@001 / PLN）

目的：

- 将 Human 确认的 `MTPRO Paper Session Runtime v1` 修正版 Project / Issue 草案落仓为 Project-level planning record。
- 新增 `docs/planning/projects/mtpro-paper-session-runtime-v1-plan.md`，只保存 Project 级计划摘要和格式门槛。
- 更新 `docs/planning/linear-draft-plan.md` 索引，指向当前下一阶段 planning record。
- 更新 `docs/validation/latest-verification-summary.md`，记录该 planning record 已落仓但尚未写入 Linear。
- 更新 `checks/automation-readiness.sh`，将新 planning record 的命名、边界、不授权执行、Parent Codex queue preflight 规则纳入机械检查。

文件范围：

- Added：
  - `docs/planning/projects/mtpro-paper-session-runtime-v1-plan.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进 Todo。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未复制完整 Linear issue body 到仓库。
- 未把 planning record 当作执行授权。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Paper Session Runtime planning record 和文档更新无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 通过；输出 `MTPRO checks passed.` |

## MTP-31 Paper Session Lifecycle and Event Boundary

日期：2026-05-19

执行者：Codex

目的：

- 定义 Paper Session lifecycle 状态和 started / updated / closed paper-only events。
- 明确 Paper lifecycle facts 的 append-only event log 写入边界。
- 增加 deterministic lifecycle fixture / tests，并回填 validation docs / trading validation matrix。

文件范围：

- Added：
  - `Sources/Core/PaperSessionLifecycle.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Sources/Core/DomainEvents.swift`
  - `Sources/Core/ResearchEventFlows.swift`
  - `Sources/Persistence/Persistence.swift`
  - `Sources/App/App.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未解锁下一 issue。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未实现 action proposal。
- 未实现 portfolio projection update。
- 未实现完整 Paper execution engine。
- 未实现 Live execution。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 68 个 XCTest 通过；新增 Paper lifecycle deterministic facts、`.paper` stream event log boundary 和 decode validation coverage。 |
| `bash checks/run.sh` | failed first attempt after rebase | rebase 到 PR #61 后，automation readiness 仍机械要求最近验证摘要包含 `尚未写入 Linear`；已在 latest summary 中保留该历史 planning 状态说明，并明确当前 MTP-31 执行授权来自 Linear live-read issue contract。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build、dashboard smoke 和 `swift test` 全部通过；输出 `MTPRO checks passed.` |

## MTP-32 Paper Action Proposal Minimal Model and Fixture

日期：2026-05-19

执行者：Codex

目的：

- 定义 Paper action proposal 最小模型，把 strategy signal 转换为 paper-only action intent。
- 映射 strategy signal、symbol、timeframe、side、quantity / notional assumption。
- 复用 MTP-27 deterministic execution cost evidence。
- 增加 deterministic long / flat proposal fixture 和 validation tests。
- 回填 contracts、validation plan、Trading Validation Matrix 和 latest verification summary。

文件范围：

- Added：
  - `Sources/Core/PaperActionProposal.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未解锁下一 issue。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未新增 order command。
- 未新增 Paper action event log 写入。
- 未串联 risk blocker。
- 未实现 portfolio projection update。
- 未实现完整 Paper execution engine。
- 未实现 Live execution。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 70 个 XCTest 通过；新增 `testPaperActionProposalMapsStrategySignalToPaperOnlyIntentDeterministically` 和 `testPaperActionProposalDecodingRejectsNonPaperOrMismatchedIntent`，覆盖 long / flat 映射、notional、MTP-27 fixed cost evidence、paper-only authorization 和 Codable 不变量。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build、dashboard smoke 和 `swift test` 全部通过；70 个 XCTest 0 failures，输出 `MTPRO checks passed.` |

## MTP-33 Paper Action Proposal -> Risk Blocker Link

日期：2026-05-19

执行者：Codex

目的：

- 串联 strategy signal -> paper action proposal -> risk blocker 的本地 Core evidence 链路。
- 将 MTP-32 proposal 转换为 `RiskEvaluationQuery`。
- 在 deterministic policy 阻断时复用 `RiskBlockerEvidence`，记录 blocker reason、source sequence 和 paper-only context。
- 覆盖 allowed / blocked proposal evidence。
- 回填 contracts、validation plan、Trading Validation Matrix 和 latest verification summary。

文件范围：

- Added：
  - `Sources/Core/PaperActionRiskLink.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未解锁下一 issue。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未新增 order command。
- 未新增 Paper action event log 写入。
- 未实现 broker rejection fallback。
- 未实现完整风险引擎。
- 未实现 portfolio projection update。
- 未实现完整 Paper execution workflow。
- 未实现 Live execution。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 73 个 XCTest 通过；新增 `testPaperActionRiskLinkAllowsPaperProposalWithTraceableContext`、`testPaperActionRiskLinkBlocksOversizedPaperProposalWithEvidence`、`testPaperActionRiskDecisionDecodingRejectsMismatchedEvidence`，覆盖 allowed / blocked deterministic evidence、source sequence、paper-only context、无 broker / Live fallback 和 Codable 不变量。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build、dashboard smoke 和 `swift test` 全部通过；73 个 XCTest 0 failures，输出 `MTPRO checks passed.` |

## MTP-34 Paper-only Portfolio Projection Update Path

日期：2026-05-19

执行者：Codex

目的：

- 基于 MTP-33 allowed paper risk decision 更新 paper-only portfolio exposure projection。
- 定义 `PaperPortfolioProjectionUpdate` 和 `PortfolioEvent.paperProjectionUpdated`。
- 通过 replay / SQLite runtime projection 更新 `SQLitePortfolioProjection.exposures`。
- 保持 Portfolio ViewModel 只消费 read model projection，不直连 database schema、runtime object、adapter、broker 或交易动作。
- 回填 contracts、validation plan、Trading Validation Matrix 和 latest verification summary。

文件范围：

- Added：
  - `Sources/Core/PaperPortfolioProjectionUpdate.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Sources/Core/DomainEvents.swift`
  - `Sources/Persistence/Persistence.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/persistence-boundary.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未解锁下一 issue。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未新增 order command。
- 未新增 Paper action event log 写入。
- 未读取真实账户余额。
- 未做 margin / leverage。
- 未做 broker position sync。
- 未实现完整 portfolio management。
- 未实现完整 Paper execution workflow。
- 未实现 Live execution。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 77 个 XCTest 通过；新增 `testPaperPortfolioProjectionUpdateEmitsPaperOnlyPortfolioEventFromAllowedDecision`、`testPaperPortfolioProjectionUpdateRejectsBlockedDecisionAndCapabilityBypass`、`testSQLiteRuntimeProjectionAppliesPaperPortfolioProjectionUpdateFromReplay`、`testPortfolioViewModelConsumesPaperPortfolioUpdateProjectionReadOnly`，覆盖 allowed risk decision -> portfolio update、blocked decision 拒绝、Codable 禁区、SQLite replay projection 和 ViewModel read-model-only 边界。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build、dashboard smoke 和 `swift test` 全部通过；77 个 XCTest 0 failures，输出 `MTPRO checks passed.` |

## MTP-35 Paper Session Replay and Deterministic Evidence

日期：2026-05-19

执行者：Codex

目的：

- 建立 Paper Session replay path。
- 用 `PaperEvent.actionProposed` 将 proposal 纳入 `.paper` stream replay fact。
- 从 append-only event log replay 汇总 session lifecycle、proposal、risk blocker 和 portfolio projection event。
- 输出 `PaperSessionReplayEvidenceSummary` deterministic evidence。
- 证明 `FileEventLogStore` append-only facts source 经 replay 后可生成同一 summary，并驱动 SQLite runtime projection。
- 回填 contracts、validation plan、Trading Validation Matrix 和 latest verification summary。

文件范围：

- Added：
  - `Sources/Core/PaperSessionReplay.swift`
- Updated：
  - `Sources/Core/DomainEvents.swift`
  - `Sources/Persistence/Persistence.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/persistence-boundary.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未解锁下一 issue。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未新增生产级 event sourcing 平台。
- 未新增 schema migration framework。
- 未新增真实 broker event replay。
- 未接外部 execution venue。
- 未暴露 SQLite / DuckDB schema 给 UI。
- 未实现完整 Paper execution workflow。
- 未实现 Live execution。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 80 个 XCTest 通过；新增 `testPaperSessionReplayEvidenceSummarizesRuntimeEventsDeterministically`、`testPaperSessionReplayEvidenceRejectsOutOfOrderReplayResult`、`testPaperSessionReplayEvidenceUsesFileAppendOnlyFactsSource`，覆盖 replay summary、乱序 replay 拒绝、append-only facts source、SQLite runtime projection replay 和 paper-only boundary flags。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build、dashboard smoke 和 `swift test` 全部通过；80 个 XCTest 0 failures，输出 `MTPRO checks passed.` |

## Stage Code Audit Report - MTPRO Paper Session Runtime v1

日期：2026-05-19

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 将 `MTPRO Paper Session Runtime v1` 的 Project 级 Stage Code Audit Report 落仓为 canonical 文档。
- 固化 `MTP-31` 至 `MTP-37` 全部 Linear `Done`、PR #62 至 #68、merge commit、GitHub required check、Post-Issue Ledger 和边界审计证据。
- 更新 latest verification summary，指向 `docs/audit/mtpro-paper-session-runtime-v1-stage-code-audit.md`。

文件范围：

- Added：
  - `docs/audit/mtpro-paper-session-runtime-v1-stage-code-audit.md`
- Updated：
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未推进任何 issue 到 `Todo`。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未写业务代码。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 本轮审计落仓后执行通过。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 全部通过；80 个 XCTest 0 failures，输出 `MTPRO checks passed.` |

## MTP-36 Paper Session Runtime Evidence Report / Dashboard Read Model

日期：2026-05-19

执行者：Codex

目的：

- 将 Paper Session lifecycle、proposal、risk blocker、portfolio exposure 和 replay evidence 汇总到 Report / Dashboard read model。
- 新增 `PaperSessionRuntimeEvidenceSummary`，只消费 append-only event timeline replay summary 和 runtime projection read model。
- 扩展 `ResearchBacktestReportArtifact.paperRuntimeEvidence`、`ReportArtifactViewModel.paperRuntimeEvidence` 和 `ReportViewModel` runtime evidence 汇总字段。
- 扩展 Dashboard Report section，展示 runtime evidence、replay facts、runtime sessions、proposal IDs、runtime blocker IDs、portfolio update IDs、replay streams、deterministic replay 和 paper-only boundary。
- 回填 contracts、product surface、validation plan、Trading Validation Matrix 和 latest verification summary。

文件范围：

- Updated：
  - `Sources/App/App.swift`
  - `Sources/App/DashboardShell.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未解锁下一 issue。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未新增 UI 大改版。
- 未新增完整报告系统。
- 未新增 Paper execution workflow 扩展。
- 未新增 risk control command 或 position management command。
- 未暴露 SQLite / DuckDB schema、SQL、ORM model、runtime object 或 adapter request 给 UI。
- 未实现 Live execution。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 9 个 AppTests 通过；覆盖 Report / Dashboard runtime evidence read model、Codable deterministic snapshot、Dashboard shell runtime evidence 展示和 read-model-only 边界。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build、dashboard smoke 和 `swift test` 全部通过；80 个 XCTest 0 failures，输出 `MTPRO checks passed.` |

## MTP-37 Validation Docs, Automation Evidence, and Stage Audit Input

日期：2026-05-19

执行者：Codex

目的：

- 收口 `MTPRO Paper Session Runtime v1` 的 validation docs、automation evidence、known boundaries 和 Stage Code Audit input。
- 新增 `docs/validation/mtp-37-stage-audit-input.md`，汇总 MTP-31 至 MTP-36 的 PR evidence、merge commit、required check、paper runtime validation evidence chain、known boundaries、automation readiness evidence、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- 更新 `docs/validation/latest-verification-summary.md`，记录 MTP-37 live-read issue 状态、当前 Project PR evidence 和 MTP-37 本地验证摘要。
- 更新 `docs/validation/trading-validation-matrix.md` 和 `docs/validation/validation-plan.md`，补充 MTP-37 Paper Session Runtime 阶段收口和 required validation。
- 更新 `checks/automation-readiness.sh`，把 MTP-37 stage audit input、latest summary、matrix 和 validation plan anchors 纳入机械检查。

文件范围：

- Added：
  - `docs/validation/mtp-37-stage-audit-input.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未解锁下一 issue。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未输出最终 Stage Code Audit Report。
- 未推进下一 Project / Issue。
- 未修改 production code。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；确认 MTP-37 Stage Code Audit input、Trading Validation Matrix、latest summary 和 automation readiness anchors 完整。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build、dashboard smoke 和 `swift test` 全部通过；80 个 XCTest 0 failures，输出 `MTPRO checks passed.` |

## MTPRO Paper Session Runtime v1 Root Docs Refresh Gate closure

日期：2026-05-19

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 基于 `docs/audit/mtpro-paper-session-runtime-v1-stage-code-audit.md` 逐项核查 root docs 是否需要事实刷新。
- 确认 `GOAL.md`、`ENVIRONMENT.md` 和 `ARCHITECTURE.md` 与已完成事实一致，无需更新。
- 更新 `ROADMAP.md`，记录最近完成 Project 为 `MTPRO Paper Session Runtime v1`，并指向 canonical Stage Code Audit Report。
- 更新 Stage Code Audit Report 的 Root Docs Delta pending note，记录本轮 closure 已执行。
- 更新 `docs/validation/latest-verification-summary.md`，记录 Root Docs Refresh Gate closure 已执行。

文件范围：

- Updated：
  - `docs/audit/mtpro-paper-session-runtime-v1-stage-code-audit.md`
  - `ROADMAP.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未推进任何 issue 到 `Todo`。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未写业务代码。
- 未决定下一阶段方向。

Root Docs Refresh Gate 逐项结论：

| 文档 | 结果 | 原因 |
| --- | --- | --- |
| `GOAL.md` | no update needed | 目标仍是 Research -> Backtest -> Paper 一致性工作台，Live trading 禁区未变化。 |
| `ENVIRONMENT.md` | no update needed | Stage Code Audit Report 确认未新增本地运行依赖，统一验证入口仍是 `bash checks/run.sh`。 |
| `ARCHITECTURE.md` | no update needed | Core / Persistence / App / Dashboard 边界继续成立；paper-only event log、runtime projection 和 read-model-only Dashboard 仍落在既有架构边界内。 |
| `ROADMAP.md` | updated | 原文仍指向上一完成 Project，已同步为 `MTPRO Paper Session Runtime v1` 和对应 audit report 路径。 |

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 本轮 docs-only Root Docs Refresh Gate closure 变更无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 全部通过；80 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## MTPRO Paper Execution Workflow v1 Project Planning Record

日期：2026-05-19

执行者：Codex（`@001 / PLN`）

目的：

- 基于 Human 确认的 `MTPRO Paper Execution Workflow v1` Linear Project Draft 和 Candidate Linear Issue Drafts，落仓下一阶段 Project-level planning record。
- 新增 `docs/planning/projects/mtpro-paper-execution-workflow-v1-plan.md`，只保存 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable issue candidate、WIP=1 和边界。
- 更新 `docs/planning/linear-draft-plan.md`，将当前 Project planning record 指向 `MTPRO Paper Execution Workflow v1`。
- 更新 `docs/validation/latest-verification-summary.md`，记录 planning record 已落仓但尚未写入 Linear。
- 更新 `checks/automation-readiness.sh`，把新 planning record 的命名、边界和不授权执行规则纳入机械检查。

文件范围：

- Added：
  - `docs/planning/projects/mtpro-paper-execution-workflow-v1-plan.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未复制完整 Linear issue body 到仓库。
- Planning record 不授权执行。
- 完整 issue execution contract 以后以 Linear issue body 为准。
- Project 写入 Linear 后，所有 issue 初始必须保持 `Backlog / non-executable`。
- 后续由 Parent Codex queue preflight 自动判断唯一 eligible issue，并在 WIP=1、依赖满足、无 active conflict、execution contract 格式完整时推进 Todo。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 本轮 docs-only planning record 变更无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 全部通过；80 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## Stage Audit Input Location Normalization

日期：2026-05-19

执行者：Codex

目的：

- 将 Project 级阶段证据和 Stage Code Audit 输入材料从 `docs/validation/` 迁移到 `docs/audit/inputs/`。
- 使用 Project slug 命名输入材料，避免继续用单个 Linear issue 编号污染验证目录。
- 保留 `docs/validation/` 作为长期验证入口目录。

文件范围：

- Renamed：
  - `docs/validation/mtp-23-stage-evidence.md` -> `docs/audit/inputs/mtpro-runtime-research-workbench-v1-stage-evidence.md`
  - `docs/validation/mtp-30-stage-audit-input.md` -> `docs/audit/inputs/mtpro-trading-validation-and-parity-hardening-stage-audit-input.md`
  - `docs/validation/mtp-37-stage-audit-input.md` -> `docs/audit/inputs/mtpro-paper-session-runtime-v1-stage-audit-input.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/audit/mtpro-trading-validation-and-parity-hardening-stage-code-audit.md`
  - `docs/audit/mtpro-paper-session-runtime-v1-stage-code-audit.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未重写 `verification.md` 历史记录；旧路径只保留为历史流水账。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 本轮迁移和规则变更无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 全部通过；80 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## Project Completed State Gate

日期：2026-05-19

执行者：Codex

目的：

- 将 MTPRO Project closure 规则收口为 Linear Project status `Completed`。
- 明确全部有效 issues `Done` 只是 Project closure 前置条件，不等于 Project 已关闭。
- 明确 Parent Codex 必须确认 `type=completed`、`completedAt` 非空后，才能进入 Stage Code Audit Report 和 Root Docs Refresh Gate。
- 记录已完成历史 Project 的 Linear status 修正结果，并保留当前 `MTPRO Paper Execution Workflow v1` 为 `Planned`。

Linear 状态修正：

- `MTPRO Runtime Research Workbench v1`：已从 `Planned` 修正为 `Completed`，Linear 返回 `type=completed`、`completedAt` 非空。
- `MTPRO Trading Validation and Parity Hardening`：已从 `Planned` 修正为 `Completed`，Linear 返回 `type=completed`、`completedAt` 非空。
- `MTPRO Paper Session Runtime v1`：已从 `Planned` 修正为 `Completed`，Linear 返回 `type=completed`、`completedAt` 非空。
- `MTPRO Paper Execution Workflow v1`：保持 `Planned`，不作为已完成 Project 处理。

文件范围：

- Updated：
  - `AGENTS.md`
  - `README.md`
  - `ROADMAP.md`
  - `checks/automation-readiness.sh`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 当前 `MTPRO Paper Execution Workflow v1` 仍为 `Planned`，不授权执行。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Project Completed State Gate 文档变更无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 全部通过；80 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## Dashboard Source Naming Cleanup

日期：2026-05-19

执行者：Codex

目的：

- 移除 `Sources/MTPRODashboard` 目录中的项目名前缀。
- 移除 `MTPRODashboardApplication.swift` 文件名和入口类型中的项目名前缀。
- 将 SwiftPM executable product / target 收口为 `Dashboard`。
- 同步 macOS dashboard build / smoke 命令和当前文档引用。

文件范围：

- Renamed：
  - `Sources/MTPRODashboard/MTPRODashboardApplication.swift` -> `Sources/Dashboard/DashboardApplication.swift`
- Updated：
  - `Package.swift`
  - `Sources/App/DashboardShell.swift`
  - `Sources/Dashboard/DashboardApplication.swift`
  - `Tests/AppTests/AppTests.swift`
  - `checks/run.sh`
  - `README.md`
  - `ARCHITECTURE.md`
  - `ENVIRONMENT.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/macos-build-run-loop.md`
  - `docs/validation/validation-plan.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未修改业务交易逻辑。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Dashboard source naming cleanup 无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、`swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `swift test` 全部通过；80 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## MTP-38 Paper-only Execution Workflow Contract

日期：2026-05-19

执行者：Codex

目的：

- 定义 paper-only execution workflow 的阶段顺序和事件边界。
- 明确 proposal、risk decision、paper execution decision、paper order、simulated fill 和 portfolio projection 的关系。
- 用 deterministic Core fixture / tests 固定 paper-only capability 禁区。
- 回填 Trading Validation Matrix、contract docs、validation plan 和最近验证摘要。

文件范围：

- Added：
  - `Sources/Core/PaperExecutionWorkflowContract.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `checks/automation-readiness.sh`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未实现 paper order lifecycle。
- 未实现 simulated fill。
- 未实现完整 OMS。
- 未接 Live trading、signed endpoint、account endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 82 个 XCTest 通过；新增 `testPaperExecutionWorkflowContractDefinesPaperOnlyStageAndEventBoundaries` 和 `testPaperExecutionWorkflowContractRejectsRealTradingCapabilityAndOrderBypass`。 |
| `swift test --filter CoreTests/testPaperExecutionWorkflowContract` | pass | 2 个 focused CoreTests 通过，覆盖 MTP-38 workflow contract stage order、event boundary、future issue 占位和 capability 禁区。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；确认新增 `TVM-PAPER-EXECUTION-WORKFLOW` anchor 可被机械检查定位。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、`swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `swift test` 全部通过；82 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## Role Alias Reference Roles

日期：2026-05-19

执行者：Codex

目的：

- 固定 MTPRO 的三位数字编号和三字母角色代号。
- 将 `@003 / PRD`、`@004 / DSG`、`@005 / ARC` 明确为 Linear 外 reference / root docs 角色。
- 明确 symphony-issue、Codex Execution Agent 和 GitHub PR Automation 是流程工具 / 执行层 actor，按名称调用，不占用 `@003`、`@004`、`@005` 编号。

文件范围：

- `AGENTS.md`
- `docs/automation/parent-codex-supervision.md`
- `docs/planning/project-role-map.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Role Alias Reference Roles 文档变更通过 whitespace 检查。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 `swift test` 全部通过；82 个 XCTest 0 failures，输出 `MTPRO checks passed.`。首次两次 `swift test` 在 `PersistenceTests/testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant` 附近触发 `xctest` signal 11，执行 `swift package clean` 后完整入口通过；未修改业务代码。 |

## MTP-39 Paper Order Intent / Lifecycle

日期：2026-05-19

执行者：Codex

目的：

- 定义 paper-only order intent 和 paper order lifecycle 的最小 Core value model。
- 映射 allowed / blocked risk result 到 `intentCreated` / `rejectedByRisk`。
- 用 deterministic fixture / tests 固定 paper-only capability 禁区。
- 回填 Trading Validation Matrix、contract docs、validation plan 和最近验证摘要。

文件范围：

- Added：
  - `Sources/Core/PaperOrderIntent.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Sources/Core/PaperExecutionWorkflowContract.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `checks/automation-readiness.sh`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未实现 paper execution decision。
- 未实现 simulated fill。
- 未实现完整 OMS。
- 未实现 cancel / replace 工作流。
- 未接 Live trading、signed endpoint、account endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests` | pass | 45 个 CoreTests 通过；新增 `testPaperOrderIntentCreatesPaperOnlyLifecycleFromAllowedRiskDecision`、`testPaperOrderIntentMapsBlockedRiskDecisionToRejectedLifecycle` 和 `testPaperOrderIntentDecodingRejectsCapabilityAndLifecycleBypass`。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；确认新增 `TVM-PAPER-ORDER-LIFECYCLE` anchor 可被机械检查定位。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、`swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `swift test` 全部通过；85 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## AI Engineer Role Alias

日期：2026-05-19

执行者：Codex

目的：

- 将 `000 / AIE` 固定为 MTPRO 的 AI Engineer 角色。
- 明确 `@000 / AIE` 是当前 Codex 协作入口，负责任务理解、仓库 / 流程选择、代码 / 文档执行、验证、PR handoff、角色路由和边界守护。
- 明确 `@000 / AIE` 不替代 Human decision，不绕过 Linear configured executable issue，不替代 `@001 / PLN`、`@002 / PAR` 或 Linear 外 reference 角色。

文件范围：

- `AGENTS.md`
- `docs/automation/parent-codex-supervision.md`
- `docs/planning/project-role-map.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | AI Engineer Role Alias 文档变更通过 whitespace 检查。 |
| `bash checks/run.sh` | pass | rebase 到最新 `main` 后，先遇到一次 SwiftPM 增量缓存导致的错误文案污染；执行 `swift package clean` 后完整入口通过，automation readiness、Dashboard build / smoke 和 `swift test` 全部通过；85 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## Documentation Entry Point Compression

日期：2026-05-19

执行者：Codex

目的：

- 从 `README.md` 开始压缩 MTPRO 项目入口文档，减少多轮迭代后残留的历史叙事、旧 Project pointer 和重复规则。
- 保留必要流程边界：Linear live-read、父 Codex queue gate、`symphony-issue` 执行边界、GitHub PR Automation、Post-Issue Ledger、Stage Code Audit Report 和 Root Docs Refresh Gate。
- 继续保持 `verification.md` append-only；默认验证入口仍是 `docs/validation/latest-verification-summary.md`。

文件范围：

- `README.md`
- `ROADMAP.md`
- `AGENTS.md`
- `docs/automation/automation-readiness.md`
- `docs/automation/parent-codex-supervision.md`
- `docs/automation/symphony-issue-workflow-template.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

收口结果：

- `README.md` 压缩为项目目标、硬边界、当前执行源、代码结构、文档入口和验证入口。
- `ROADMAP.md` 压缩为阶段地图；当前 Project / active issue 必须从 Linear live-read，不固化到仓库。
- `AGENTS.md` 压缩为角色、执行链路、父 Codex、`symphony-issue`、Root Docs Refresh Gate 和代码 / 文档规则。
- `docs/automation/*` 移除旧 active Project slug，改为标准 workflow pointer / queue gate 规则。
- `latest-verification-summary.md` 保留轻量当前态和最近事实，避免日常读取完整 `verification.md`。

边界确认：

- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 文档压缩变更通过 whitespace 检查。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 `swift test` 全部通过；85 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## MTP-40 Simulated Fill Evidence

日期：2026-05-19

执行者：Codex

目的：

- 定义 paper-only simulated fill evidence 的最小 Core value model。
- 定义 deterministic fill assumption，并复用 MTP-27 fixed fee / slippage cost evidence。
- 将 simulated fill stage 标记为当前代码已实现，但不写 event log、不做 replay / projection 串联。
- 回填 Trading Validation Matrix、contract docs、validation plan 和最近验证摘要。

文件范围：

- Added：
  - `Sources/Core/PaperSimulatedFillEvidence.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Sources/Core/PaperExecutionWorkflowContract.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `checks/automation-readiness.sh`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未实现 paper execution decision。
- 未写 event log。
- 未新增 projection / ViewModel。
- 未实现真实撮合或真实成交回报。
- 未实现动态滑点模型、交易所费率表或执行成本优化。
- 未接 Live trading、signed endpoint、account endpoint、broker fill、account update、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests` | pass | 首次执行在 SwiftPM 拉取 `duckdb-swift` 时遇到 GitHub TLS transient fetch failure，重试后通过；48 个 CoreTests 0 failures，新增 `testPaperSimulatedFillEvidenceCreatesDeterministicPaperOnlyFillFromAllowedOrderIntent`、`testPaperSimulatedFillEvidenceRejectsRejectedIntentAndAssumptionMismatch` 和 `testPaperSimulatedFillEvidenceDecodingRejectsRealFillBrokerAndAccountBypass`。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；确认新增 `TVM-PAPER-SIMULATED-FILL` anchor 可被机械检查定位。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、`swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `swift test` 全部通过；88 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## MTP-41 Paper Execution Decision

日期：2026-05-19

执行者：Codex

目的：

- 定义 paper execution decision 本地链路。
- 串联 allowed risk decision -> paper order intent -> simulated fill evidence。
- 确认 blocked risk decision 只保留 blocker evidence，不生成 paper order、simulated fill assumption 或 simulated fill evidence。
- 回填 Trading Validation Matrix、contract docs、validation plan 和最近验证摘要。

文件范围：

- Added：
  - `Sources/Core/PaperExecutionDecision.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Sources/Core/PaperExecutionWorkflowContract.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `checks/automation-readiness.sh`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写 event log。
- 未新增 replay / projection / ViewModel。
- 未实现完整 execution engine。
- 未实现完整风险引擎。
- 未实现 broker rejection fallback。
- 未接 Live trading、signed endpoint、account endpoint、broker fill、account update、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests/testPaperExecutionDecision` | pass | 3 个 MTP-41 focused XCTest 0 failures，覆盖 allowed decision chain、blocked no-order 和 Codable bypass。 |
| `swift test --filter CoreTests` | pass | 51 个 CoreTests 0 failures。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、`swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `swift test` 全部通过；91 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## NautilusTrader Reference Study

日期：2026-05-19

执行者：Codex

目的：

- 记录 `@003 / PRD`、`@004 / DSG`、`@005 / ARC` 对 NautilusTrader 的 Linear 外 reference study。
- 汇总 NautilusTrader 对 MTPRO Product / Design / Architecture 的参考价值。
- 输出 root docs delta proposal，作为 Human + `@001 / PLN` 后续规划输入。

文件范围：

- Added：
  - `docs/reference/nautilus-trader/README.md`
  - `docs/reference/nautilus-trader/product-reference.md`
  - `docs/reference/nautilus-trader/design-reference.md`
  - `docs/reference/nautilus-trader/architecture-reference.md`
  - `docs/reference/nautilus-trader/root-docs-delta-proposal.md`
- Updated：
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未直接修改 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md` 或 `ROADMAP.md`。
- 未复制 NautilusTrader 代码。
- 未引入 NautilusTrader 作为运行依赖。
- 未接 Live trading、signed endpoint、account endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift package clean` | pass | 先清理 SwiftPM 增量缓存；此前本地曾因缓存污染导致 `testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant` 报旧错误。 |
| `swift test --filter PersistenceTests/testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant` | pass | 清理后 focused test 通过，确认不是 reference docs 引入的逻辑回归。 |
| `git diff --check` | pass | Reference study 文档通过 whitespace 检查。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、Dashboard build / smoke 和 `swift test` 全部通过；91 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## MTP-42 Paper Execution Event Log Replay Projection

日期：2026-05-19

执行者：Codex

目的：

- 串联 paper execution decision、paper order intent 和 simulated fill evidence 到 append-only event log。
- 通过 deterministic replay 提取 paper-only simulated fill evidence。
- 将 replay 后的 simulated fill evidence 作为 paper-only portfolio projection 的唯一来源。
- 回填 Trading Validation Matrix、contract docs、validation plan 和最近验证摘要。

文件范围：

- Added：
  - `Sources/Core/PaperExecutionEventLog.swift`
- Updated：
  - `Sources/App/App.swift`
  - `Sources/Core/DomainEvents.swift`
  - `Sources/Core/PaperPortfolioProjectionUpdate.swift`
  - `Sources/Core/PaperSessionReplay.swift`
  - `Sources/Persistence/Persistence.swift`
  - `Tests/AppTests/AppTests.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/persistence-boundary.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未实现完整 execution engine。
- 未实现完整风险引擎。
- 未实现 broker rejection fallback。
- 未接 Live trading、signed endpoint、account endpoint、broker fill、account update、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests/testPaperExecution` | pass | 8 个 focused XCTest 0 failures，覆盖 MTP-41 decision 链路和 MTP-42 event append / replay / projection focused path。 |
| `swift test --filter CoreTests` | pass | 53 个 CoreTests 0 failures。 |
| `swift test` | pass | 93 个 XCTest 0 failures。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、`swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `swift test` 全部通过；93 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## MTP-44 Paper Execution Workflow Report / Dashboard Evidence

日期：2026-05-19

执行者：Codex

目的：

- 将 paper execution workflow evidence 汇总到 Report read model。
- 在 Dashboard Report snapshot 中展示 decision、paper order、simulated fill、workflow streams、portfolio projection 和 paper-only boundary。
- 保持 UI 只消费 ViewModel / Read Model，不新增交易入口。
- 回填 product surface、read model / ViewModel contract 和 Trading Validation Matrix。

文件范围：

- Updated：
  - `Sources/App/App.swift`
  - `Sources/App/DashboardShell.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/product/product-surface-map.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未实现完整报告系统。
- 未新增 UI command、order command、risk control command 或 position management command。
- 未暴露 SQLite / DuckDB schema、SQL、ORM model、runtime object 或 adapter request。
- 未接 Live trading、signed endpoint、account endpoint、broker fill、account update、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 9 个 AppTests 0 failures，覆盖 Report / Dashboard workflow evidence、Codable snapshot、read-model-only boundary 和无 UI execution surface。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、`swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `swift test` 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true`；93 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## MTP-45 Paper Execution Workflow Validation Docs / Stage Audit Input

日期：2026-05-19

执行者：Codex

目的：

- 收口 `MTPRO Paper Execution Workflow v1` 的 validation docs、automation evidence、known boundaries 和 Stage Code Audit 输入材料。
- 汇总 `MTP-38`、`MTP-39`、`MTP-40`、`MTP-41`、`MTP-42`、`MTP-44` 的 issue / PR evidence、merge commit 和 required check evidence。
- 为 Parent Codex 在 Project 全部 Done 且 Linear Project `Completed` 后输出最终 Stage Code Audit Report 提供输入。
- 保持本 issue 为 docs-only / evidence-only，不新增业务交易能力。

文件范围：

- Added：
  - `docs/audit/inputs/mtpro-paper-execution-workflow-v1-stage-audit-input.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/automation/automation-readiness.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未输出最终 Stage Code Audit Report。
- 未创建下一 Project / Issue。
- 未触碰 Live trading、signed endpoint、account endpoint、broker fill、account update、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；确认 MTP-45 audit input、matrix、latest summary 和 validation plan anchors 完整。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、`swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `swift test` 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true`；93 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## MTPRO Paper Execution Workflow v1 Stage Code Audit Report

日期：2026-05-19

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 将 `MTPRO Paper Execution Workflow v1` 的 canonical Stage Code Audit Report 落仓。
- 固化 `MTP-38`、`MTP-39`、`MTP-40`、`MTP-41`、`MTP-42`、`MTP-44`、`MTP-45` 的 issue / PR evidence、merge commit、required check、validation、boundary audit、Known CI Boundary、Root Docs Delta 和 Next Human Project Planning handoff。
- 记录 `MTP-43`、`MTP-46` 为 Duplicate 并排除 canonical queue。
- 记录 Linear Project status `Completed`，`completedAt=2026-05-19T14:48:42.973Z`。
- 更新最近验证摘要，指向 canonical Stage Code Audit Report。

文件范围：

- Added：
  - `docs/audit/mtpro-paper-execution-workflow-v1-stage-code-audit.md`
- Updated：
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未创建 Linear Project / Issue。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify full rebuild。
- 未写业务代码。
- 未进入下一阶段规划。
- 未触碰 Live trading、signed endpoint、account endpoint、broker fill、account update、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 无 whitespace error。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、Dashboard build、Dashboard smoke 和 `swift test` 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true`；93 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |
## MTPRO Complete Blueprint Design

日期：2026-05-19
执行者：Codex（`@000 / AIE`）
PR：
Commit：

目的：
- 将 MTPRO 的完整产品 / 系统 / 设计蓝图落仓。
- 明确 Human + `@000 / AIE` 共同负责 Complete Blueprint Design。
- 明确 `@001 / PLN` 只在蓝图确认后基于 Current Construction Scope 进入下一阶段 Project Planning。
- 明确 Live / signed endpoint / broker / OMS 等长期能力可以进入最终蓝图，但当前仍保持 future / gated，不授权执行。

文件范围：
- Created:
  - `docs/design/mtpro-complete-blueprint.md`
- Updated:
  - `README.md`
  - `AGENTS.md`
  - `docs/planning/project-role-map.md`
  - `docs/reference/nautilus-trader/README.md`
  - `docs/reference/nautilus-trader/root-docs-delta-proposal.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`
- Deleted:

收口结果：
- 新增 MTPRO Complete Blueprint Design，覆盖 Final Product Blueprint、System Architecture Blueprint、Workbench / UX Blueprint、Complete Capability Map、Current Construction Scope、Future Construction Zones、Root Docs Delta Proposal 和 Linear Planning Handoff。
- `@000 / AIE` 职责补充为 Human 的完整蓝图协作入口，负责把 reference study、Stage Code Audit、root docs 和现有代码能力综合成 MTPRO 自己的蓝图。
- NautilusTrader reference study 的后续路径调整为先进入 Human + `@000 / AIE` Complete Blueprint Design，再进入 Human + `@001 / PLN` Project Planning。
- automation readiness 增加蓝图文件和角色边界锚点。

边界确认：
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Backlog` -> `Todo`。
- 未启动 `@002 / PAR`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Complete Blueprint Design docs-only 变更通过 whitespace 检查。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 93 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |
## Blueprint Responsibility Cleanup and Phase Progress Rule

日期：2026-05-20
执行者：Codex（`@000 / AIE`）
PR：
Commit：

目的：
- 将 `@000 / AIE` 的详细职责清单从 `docs/design/mtpro-complete-blueprint.md` 移出，保持蓝图文档专注产品 / 系统 / 设计蓝图本体。
- 明确当前阶段完成进度条由 `@002 / PAR` 在 Project closure、Stage Code Audit Report 和 Root Docs Refresh Gate closure 后输出。
- 明确阶段进度条不写入蓝图文档，不授权下一阶段执行。

文件范围：
- Updated:
  - `AGENTS.md`
  - `checks/automation-readiness.sh`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/design/mtpro-complete-blueprint.md`
  - `docs/planning/project-role-map.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

收口结果：
- 蓝图文档删除 `@000 / AIE 蓝图职责` 大段职责清单，只保留蓝图本体和边界说明。
- `@000 / AIE` 职责继续由 `AGENTS.md` 和 `docs/planning/project-role-map.md` 维护。
- `@002 / PAR` closure 规则新增 `Current Phase Progress Bar / 当前阶段完成进度条`。
- 进度条必须基于当前 Human-approved phase 内 completed Project 数量计算，不能基于完整蓝图或 Future Construction Zones 计算。

边界确认：
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Backlog` -> `Todo`。
- 未启动 `@002 / PAR`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Blueprint responsibility cleanup 和 progress rule docs-only 变更通过 whitespace 检查。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 93 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## Current Phase Progress Baseline

日期：2026-05-20
执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：
- 补齐当前版本的 Current Phase Progress baseline。
- 明确当前阶段为 `MTPRO paper-only research / validation / execution foundation`。
- 明确 Completed Projects 为 5 / 5（100%），Progress 为 `[##########] 100%`。
- 明确进度条只统计当前已 Human-approved、已执行、已 closure 的建设阶段 Project。
- 明确进度条不统计 `docs/design/mtpro-complete-blueprint.md` 中的 Future Construction Zones，不授权下一阶段执行。

Completed Projects：
- `MTPRO 引导`
- `MTPRO Runtime Research Workbench v1`
- `MTPRO Trading Validation and Parity Hardening`
- `MTPRO Paper Session Runtime v1`
- `MTPRO Paper Execution Workflow v1`

Latest Completed Project：`MTPRO Paper Execution Workflow v1`

Next Handoff：Human + `@001 / PLN`

文件范围：
- Updated:
  - `docs/validation/latest-verification-summary.md`
  - `ROADMAP.md`
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`

边界确认：
- docs-only。
- 未修改 `docs/design/mtpro-complete-blueprint.md`。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未把 future capability 计入 progress。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Current Phase Progress baseline docs-only 变更无 whitespace error。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 93 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## Goal / Roadmap Progress Baseline Correction

日期：2026-05-20
执行者：Codex（`@000 / AIE`）

目的：
- 修正 Current Phase Progress baseline 的计算口径。
- 明确 Project Closure Count 只说明已关闭 Project 数量，不代表 `GOAL.md` / `ROADMAP.md` 目标完成度。
- 将真正的进度条改为 Goal / Roadmap Target Progress。

修正结果：
- Project Closure Count：5 / 5（100%）。
- Goal / Roadmap Target Progress：3 / 5（60%）。
- Progress：`[######----] 60%`。

目标切片：
- Complete：Research / Backtest / Report / Paper readiness。
- Complete：Paper-only execution evidence。
- Complete / enforced：Live trading 禁区和 future boundary。
- Pending：Paper workflow 可观察性和本地控制壳。
- Pending：更长周期 market data replay / operations。

文件范围：
- Updated:
  - `AGENTS.md`
  - `ROADMAP.md`
  - `checks/automation-readiness.sh`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：
- docs-only。
- 未修改 `docs/design/mtpro-complete-blueprint.md`。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Goal / Roadmap progress baseline correction 无 whitespace error。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 93 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTPRO Paper Workflow Control Shell v1 Project Planning Record

日期：2026-05-20

执行者：Codex（`@001 / PLN`）

目的：

- 基于 Human 确认的 `MTPRO Paper Workflow Control Shell v1` Linear Project Draft 和 Candidate Linear Issue Drafts，落仓下一阶段 Project-level planning record。
- 新增 `docs/planning/projects/mtpro-paper-workflow-control-shell-v1-plan.md`，只保存 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable issue candidate、WIP=1 和边界。
- 更新 `docs/planning/linear-draft-plan.md`，将当前 Project planning record 指向 `MTPRO Paper Workflow Control Shell v1`。
- 更新 `docs/validation/latest-verification-summary.md`，记录 planning record 已落仓但尚未写入 Linear。
- 更新 `checks/automation-readiness.sh`，把新 planning record 的命名、边界和不授权执行规则纳入机械检查。

文件范围：

- Added：
  - `docs/planning/projects/mtpro-paper-workflow-control-shell-v1-plan.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 `@002 / PAR`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未复制完整 Linear issue body 到仓库。
- Planning record 不授权执行。
- 完整 issue execution contract 以后以 Linear issue body 为准。
- Project 写入 Linear 后，所有 issue 初始必须保持 `Backlog / non-executable`。
- 后续由 Parent Codex queue preflight 自动判断唯一 eligible issue，并在 WIP=1、依赖满足、无 active conflict、execution contract 格式完整时推进 Todo。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 本轮 docs-only planning record 变更无 whitespace error。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 93 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-47 Paper workflow Workbench information architecture / control shell boundary

日期：2026-05-20

执行者：Codex（Codex Execution Agent）

目的：

- 按 Linear issue `MTP-47` 定义 Paper workflow Workbench information architecture 和控制壳边界。
- 新增 App 层 `PaperWorkflowWorkbenchInformationArchitecture` deterministic fixture，固定 session-level controls、observability sections 和 forbidden capability。
- 将 `TVM-PAPER-WORKFLOW-CONTROL-SHELL` 回填到 trading validation matrix，并更新 product / contract / validation docs。

文件范围：

- Added：
  - `Sources/App/PaperWorkflowWorkbenchArchitecture.swift`
- Updated：
  - `Tests/AppTests/AppTests.swift`
  - `checks/automation-readiness.sh`
  - `docs/product/product-surface-map.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 只定义 Workbench information architecture、session-level control shell 边界、validation anchor 和合同文档。
- session-level controls 只允许 `start` / `pause` / `close` / `reset`。
- 未实现 Command Model。
- 未实现 UI 控件。
- 未实现 Event Timeline。
- 未实现 order-level command、OMS、Live trading、signed endpoint、account endpoint、listenKey、broker action 或真实订单提交 / 撤销 / 替换。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 11 个 AppTests，0 failures；覆盖 MTP-47 Workbench IA fixture、session-level controls、observability sections、forbidden capability 和 no order-level command 合同拒绝。 |
| `bash checks/automation-readiness.sh` | pass | `TVM-PAPER-WORKFLOW-CONTROL-SHELL`、MTP-47 validation-plan、contract docs 和 product surface anchors 均可机械定位。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 95 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-48 Paper session local control Command Model

日期：2026-05-20

执行者：Codex（Codex Execution Agent）

目的：

- 按 Linear issue `MTP-48` 新增 session-level Paper local control Command Model。
- 支持 `start` / `pause` / `close` / `reset` 四个本地 Paper session control intent。
- 定义 command validation、rejected reason 和 Codable capability bypass 拒绝边界。
- 保持不实现 UI 控件、不写 event log、不触碰 order-level command、broker action、signed endpoint 或真实订单行为。

文件范围：

- Added：
  - `Sources/Core/PaperSessionLocalControlCommand.swift`
- Updated：
  - `Sources/Core/CommandsAndQueries.swift`
  - `Sources/Core/CoreError.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `checks/automation-readiness.sh`
  - `docs/product/product-surface-map.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- accepted command 只能作用于本地 Paper session。
- session-level controls 只允许 `start` / `pause` / `close` / `reset`。
- 非 session-level command、order-level command、`submit` / `cancel` / `replace`、broker action 和非 paper execution mode 均被 validation 拒绝。
- Codable 解码拒绝恢复 order-level command、真实交易授权、Live trading、signed endpoint、account endpoint、listenKey、broker action 或真实订单 submit / cancel / replace capability。
- 未实现 session-level control -> event boundary 串联。
- 未实现 UI 控件或 Event Timeline。
- 未连接 broker / exchange。
- 未接 signed endpoint、account endpoint、listenKey 或 Live execution。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests/testPaperSessionLocalControl` | pass | 3 个 CoreTests，0 failures；覆盖 Command Model 四个 session-level controls、raw request rejected reason、no submit / cancel / replace / broker action 和 Codable capability bypass 拒绝。 |
| `bash checks/automation-readiness.sh` | pass | `PaperSessionLocalControlCommand`、MTP-48 validation-plan、contract docs、product surface 和 matrix anchors 均可机械定位。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 98 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-49 Paper session local control event boundary

日期：2026-05-20

执行者：Codex（Codex Execution Agent）

目的：

- 按 Linear issue `MTP-49` 串联 session-level control -> paper-only event boundary。
- 将 valid `start` / `pause` / `close` / `reset` command 映射为 `.paper` stream 中的本地 session control fact。
- 将 invalid command rejection reason 写为可 replay 的本地 rejection evidence。
- 保持 append-only event boundary，不生成 order command、broker action、signed endpoint 或真实交易行为。

文件范围：

- Added：
  - `Sources/Core/PaperSessionLocalControlEventLog.swift`
- Updated：
  - `Sources/Core/DomainEvents.swift`
  - `Sources/Core/PaperSessionReplay.swift`
  - `Sources/Persistence/Persistence.swift`
  - `Sources/App/App.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `checks/automation-readiness.sh`
  - `docs/product/product-surface-map.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- accepted command 只能写入 `PaperEvent.sessionControlApplied`，并固定为 `.paper` stream。
- rejected command 只能写入 `PaperEvent.sessionControlRejected`，保留 `PaperSessionLocalControlRejectedReason`。
- event sequence 继续由 `AppendOnlyEventLog` 单调分配，不能重排或覆盖既有 facts。
- replay summary、SQLite projection 和 App matcher 已显式识别新增 paper event cases；当前不新增 projection schema、ViewModel、UI 控件或 Event Timeline。
- 未生成 paper order command、real order command、order intent、simulated fill、broker action、signed endpoint、account endpoint、listenKey 或 Live execution。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests/testPaperSessionLocalControl` | pass | 6 个 CoreTests，0 failures；覆盖 accepted command -> `sessionControlApplied`、invalid command -> `sessionControlRejected`、append-only `.paper` stream 和 no order / no broker event。 |
| `bash checks/automation-readiness.sh` | pass | `PaperSessionLocalControlEventLogBoundary`、MTP-49 validation-plan、contract docs、product surface 和 matrix anchors 均可机械定位。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 101 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-50 Paper workflow observability Read Model / ViewModel

日期：2026-05-20

执行者：Codex（Codex Execution Agent）

目的：

- 按 Linear issue `MTP-50` 扩展 Paper workflow observability Read Model / ViewModel。
- 展示 session status、proposal evidence、allowed paper execution chain、blocked risk evidence、portfolio projection evidence、replay freshness 和 report artifact status。
- 保持 UI-facing shape 只通过 ViewModel / Read Model，不暴露 SQLite / DuckDB schema、adapter request 或 runtime object。

文件范围：

- Added：
  - `Sources/App/PaperWorkflowObservability.swift`
- Updated：
  - `Sources/App/App.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/product/product-surface-map.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- `PaperWorkflowObservabilityReadModel` 只从既有 `ReportReadModel`、`PaperReadModel`、`RiskReadModel`、`PortfolioReadModel` 和 `EventTimelineReadModel` 聚合稳定输入。
- `PaperWorkflowObservabilityViewModel` 是 Codable deterministic snapshot，展示 blocked / allowed evidence、chain coverage、replay freshness 和 report artifact status。
- `DashboardReadModel` / `DashboardViewModel` 只新增 read-model-only 观察快照，不修改 Dashboard shell UI。
- 未新增 projection schema、Runtime wiring、adapter request、Event Timeline explorer、UI control 或 order-level command。
- 未接 Live trading、signed endpoint、account endpoint、listenKey、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 13 个 AppTests，0 failures；覆盖 Paper workflow observability snapshot、session status、blocked / allowed evidence、chain coverage、replay freshness、report artifact status、Codable deterministic equality 和 schema / runtime / adapter non-exposure。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 103 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-51 read-model-only Event Timeline / Evidence Explorer 子集

日期：2026-05-20

执行者：Codex（Codex Execution Agent）

目的：

- 按 Linear issue `MTP-51` 新增 Event Timeline / Evidence Explorer 的 read-model-only 子集。
- 让用户可以按 timeline snapshot 观察 market event、strategy signal、risk decision、paper order、simulated fill、portfolio projection 和 report artifact 的 evidence links。
- 保持 Explorer 只读，不提供 query language、command surface、Persistence adapter direct read、Runtime command、UI control 或交易操作。

文件范围：

- Added：
  - `Sources/App/PaperWorkflowEvidenceExplorer.swift`
- Updated：
  - `Sources/App/App.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/product/product-surface-map.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- `PaperWorkflowEvidenceExplorerReadModel` 只从既有 `MarketReadModel`、`StrategyReadModel`、`ReportReadModel`、`PaperWorkflowObservabilityReadModel` 和 `EventTimelineReadModel` 聚合稳定输入。
- `PaperWorkflowEvidenceExplorerViewModel` 是 Codable deterministic snapshot，展示 timeline items、evidence links、section snapshots、read-only filter snapshot 和 coverage flags。
- filter 只在已生成 ViewModel snapshot 内筛选 section，不下推为 query language，不读取 SQLite / DuckDB schema，不调用 Runtime 或 Persistence adapter。
- `DashboardReadModel` / `DashboardViewModel` 只新增 read-model-only Explorer 快照，不修改 Dashboard shell UI。
- 未新增 projection schema、Runtime wiring、adapter request、UI control、order-level command、risk control、position management、broker action、signed endpoint、account endpoint、listenKey、真实订单或 Live execution。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 15 个 AppTests，0 failures；覆盖 Event Timeline / Evidence Explorer deterministic snapshot、market / strategy / risk / order / fill / portfolio / report section coverage、evidence links、read-only filter、Codable deterministic equality 和 schema / runtime / adapter / command non-exposure。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 105 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-52 增量扩展 Dashboard / Workbench shell 并保持 read-model-only

日期：2026-05-20

执行者：Codex（Codex Execution Agent）

目的：

- 按 Linear issue `MTP-52` 在现有 Dashboard / Workbench shell 上增量呈现 Paper workflow control shell、observability read model 和 Event Timeline / Evidence Explorer 子集。
- 让 shell snapshot 展示 `start` / `pause` / `close` / `reset` 四个 session-level local controls，并证明它们只消费 Command Model，不形成按钮、表单或可执行交易入口。
- 保持 Dashboard smoke、read-model-only、paper-only、no schema / runtime / adapter direct access 和 forbidden command evidence。

文件范围：

- Updated：
  - `Sources/App/DashboardShell.swift`
  - `Tests/AppTests/AppTests.swift`
  - `checks/automation-readiness.sh`
  - `docs/product/product-surface-map.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- `DashboardShellControlSnapshot` 只把 `PaperWorkflowSessionControl` 映射到 `PaperSessionLocalControlAction`，scope 固定为 local paper session，control level 固定为 session，execution mode 固定为 paper。
- `DashboardShellWorkbenchSnapshot` 只组合现有 App 层 ViewModel / Read Model / Command Model，展示 observability metrics、Event Timeline / Evidence Explorer preview 和 workbench boundary flags。
- SwiftUI shell 只渲染文本、指标和 read-only preview，不包含按钮、文本输入、开关、order-level command、Runtime command、adapter request 或 schema direct access。
- Dashboard smoke 继续保持八个 Dashboard sections，并新增 `workbenchReadModelOnly=true`、controls 和 timeline item evidence。
- 未接 Live trading、signed endpoint、account endpoint、listenKey、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 16 个 AppTests，0 failures；覆盖 Dashboard / Workbench shell snapshot control / observability / explorer binding、Dashboard smoke workbench evidence、session-level local command presentation 和 no button / no command / schema / runtime / adapter boundary tests。 |
| `bash checks/automation-readiness.sh` | pass | 新增 MTP-52 contract / product / validation / matrix / source / test anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 106 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset`，最终输出 `MTPRO checks passed.`。 |

## MTP-53 加固 deterministic validation、Dashboard smoke 和 automation readiness evidence

日期：2026-05-20

执行者：Codex（Codex Execution Agent）

目的：

- 按 Linear issue `MTP-53` 收口 `MTPRO Paper Workflow Control Shell v1` 的 deterministic validation、Dashboard smoke、automation readiness anchor、known boundaries 和 Stage Code Audit input。
- 汇总 MTP-47 至 MTP-52 的 issue / PR evidence、merge commit、required check、Dashboard smoke 和 validation evidence chain。
- 明确最终 Stage Code Audit Report 仍由 Parent Codex 在 Project 全部 Done 且 Linear Project `Completed` 后单独输出。

文件范围：

- Added：
  - `docs/audit/inputs/mtpro-paper-workflow-control-shell-v1-stage-audit-input.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 本 issue 只准备阶段证据材料，不输出最终 Stage Code Audit Report。
- 未创建下一 Project / Issue，未推进下一 Project / Issue，未启动下一阶段 `symphony-issue`。
- 未写业务功能扩展，未修改 production code。
- Dashboard smoke evidence 覆盖 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`controls=start,pause,close,reset` 和 `timelineItems=0`。
- `timelineItems=0` 来自空启动 read model；fixture 级 Event Timeline / Evidence Explorer coverage 仍由 App deterministic tests 覆盖。
- 未接 Live trading、signed endpoint、account endpoint、listenKey、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `DASHBOARD_SMOKE=1 swift run Dashboard` | pass | 输出 `Dashboard smoke: sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 |
| `bash checks/automation-readiness.sh` | pass | MTP-53 stage audit input、validation plan、matrix、latest summary 和 Dashboard smoke anchors 均可机械定位，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 106 个 XCTest 全部通过，最终输出 `MTPRO checks passed.`。 |

## MTPRO Paper Workflow Control Shell v1 Stage Code Audit Report

日期：2026-05-20

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 将 `MTPRO Paper Workflow Control Shell v1` 的 canonical Stage Code Audit Report 落仓。
- 基于 Linear live-read、PR #91 至 #97、Post-Issue Ledger 和 `MTP-53` Stage Audit Input 固化 Project closure 证据。
- 更新最近验证摘要，指向 canonical Stage Code Audit Report。

文件范围：

- Added：
  - `docs/audit/mtpro-paper-workflow-control-shell-v1-stage-code-audit.md`
- Updated：
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

证据：

- Canonical issues `MTP-47`、`MTP-48`、`MTP-49`、`MTP-50`、`MTP-51`、`MTP-52`、`MTP-53` 全部 Linear `Done`。
- Linear Project status 已设置为 `Completed`，`completedAt=2026-05-19T21:37:34.706Z`。
- `MTP-53` PR #97 已 merge，merge commit 为 `f2efe3d23a092b9e938c7697a8002860abc1962a`。
- GitHub required check `checks` 已通过：`https://github.com/atxinbao/MTPRO/actions/runs/26126719584/job/76842160441`。
- Post-Issue Ledger 对 `MTP-53` 的 `git_pull_ff_only` 和 `graphify_update` 均为 `passed`；`graphify-out/*` 未提交。

边界确认：

- 本轮只落仓 Stage Code Audit Report，不创建 Linear Project / Issue。
- 未推进任何 issue 到 `Todo`。
- 未启动新的 Symphony。
- 未运行 Graphify manual update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- Root Docs Refresh Gate 尚未执行；Current Phase Progress Bar 需在该 gate closure 后单独刷新。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Stage Code Audit Report 落仓变更无 whitespace error。 |
| `bash checks/run.sh` | pass | 首次运行暴露 persistent repo `.build` 缓存污染导致的 `CoreError` enum layout 断言串扰；执行 `swift package clean` 后完整验证通过，Dashboard build / smoke 和 106 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTPRO Paper Workflow Control Shell v1 Root Docs Refresh Gate closure

日期：2026-05-20

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 基于 `docs/audit/mtpro-paper-workflow-control-shell-v1-stage-code-audit.md` 逐项核查 root docs 是否落后于已完成事实。
- 同步当前 Goal / Roadmap Target Progress，明确进度按目标切片计算，不按 Project 数量直接计算。
- 记录 Root Docs Refresh Gate closure，作为交给 Human + `@001 / PLN` 的事实输入。

Root docs 判断：

- `GOAL.md`：updated。同步 Paper workflow 可观察性、本地 session-level control shell 和当前 Goal / Roadmap Target Progress 4 / 5（80%）。
- `ENVIRONMENT.md`：no update needed。未新增本地运行依赖；统一验证入口仍是 `bash checks/run.sh`，并继续包含 Dashboard smoke。
- `ARCHITECTURE.md`：updated。同步 Core paper-only command / event boundary、App read model / ViewModel 和 Dashboard / Workbench read-only shell snapshot 的已完成事实。
- `ROADMAP.md`：updated。新增 `MTPRO Paper Workflow Control Shell v1` 为 Completed，Project Closure Count 更新为 6 / 6，Goal / Roadmap Target Progress 更新为 4 / 5（80%）。

边界确认：

- 本轮只同步已发生事实，不写下一阶段方向、目标、架构路线或优先级。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未修改 `docs/design/mtpro-complete-blueprint.md`。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Root Docs Refresh Gate closure docs-only 变更无 whitespace error。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 106 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTPRO Market Data Replay Operations v1 Project Planning Record

日期：2026-05-20

执行者：Codex（`@001 / PLN`）

目的：

- 将 Human 确认的 `MTPRO Market Data Replay Operations v1` 下一阶段 Project-level planning record 落仓。
- 只保存 Project 级计划摘要和格式门槛，不复制维护完整 Linear issue body。
- 更新 Project Planning Record 索引、最近验证摘要和 automation readiness anchor。

文件范围：

- Added：
  - `docs/planning/projects/mtpro-market-data-replay-operations-v1-plan.md`
- Updated：
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

规划摘要：

- Project name：`MTPRO Market Data Replay Operations v1`
- Project goal：建立本地、paper-only、public-read-only 的 market data batch / replay operations 基线。
- First executable issue candidate：定义 Binance public read-only market data batch / replay boundary。
- WIP=1：所有候选 issue 写入 Linear 后必须初始保持 `Backlog / non-executable`。
- 完整 issue execution contract 以后以 Linear issue body 为准。

边界确认：

- 本轮只落仓 Project Planning Record。
- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 `@002 / PAR`。
- 未启动 Symphony / `symphony-issue`。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 本 planning record 不授权执行。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Project Planning Record 落仓 docs-only 变更无 whitespace error。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 106 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-54 Binance public read-only market data batch / replay boundary

日期：2026-05-20

执行者：Codex Execution Agent

目的：

- 定义 `MTPRO Market Data Replay Operations v1` 第一项 issue 的 Binance public read-only market data batch / replay boundary。
- 固化本地 fixture / batch replay contract 的最小字段、required validation mode、optional manual network smoke 边界和 forbidden capability。
- 更新 contract、product surface、validation plan、trading validation matrix 和 automation readiness anchor。

Linear live-read：

- Linear Project：`MTPRO Market Data Replay Operations v1`。
- 当前 issue：`MTP-54` 为唯一 `In Progress` issue。
- `MTP-55`、`MTP-56`、`MTP-57`、`MTP-58`、`MTP-59` 和 `MTP-60` 均为 `Backlog`。
- WIP=1。

文件范围：

- Added：
  - `Sources/Adapters/BinanceMarketDataBatchReplayBoundary.swift`
- Updated：
  - `Tests/AdaptersTests/AdaptersTests.swift`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

证据：

- `BinanceMarketDataBatchReplayBoundary` 固定 public read-only、local fixture replay、required validation 离线可重复和 production operations 禁区。
- `BinanceMarketDataBatchReplayContractField` 覆盖 batch id、replay run id、symbol、interval、time window、fixture source、record count 和 checksum / parity hint。
- `BinanceMarketDataBatchReplayValidationMode` 区分 required mock transport / fixture parity / local batch replay 与 optional manual Binance public network smoke。
- `BinanceMarketDataBatchReplayForbiddenCapability` 显式禁止 API key、signed endpoint、account endpoint、listenKey、Live trading、broker action、真实订单、production runtime operations、large-scale historical downloader 和 data platform。
- Trading Validation Matrix 新增 `TVM-MARKET-DATA-REPLAY-OPERATIONS`，并由 `checks/automation-readiness.sh` 机械检查。

边界确认：

- 不实现真实长周期历史下载器。
- 不实现 production scheduler、多节点运行、云端数据湖或大规模数据平台。
- 不新增 Dashboard UI、Event Timeline evidence 或 read model 输出。
- 不暴露 SQLite / DuckDB schema、runtime object 或 adapter request。
- 不接 API key、signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AdaptersTests/testBatchReplay` | pass | 2 个 focused XCTest，0 failures；覆盖 boundary 最小字段、required / optional validation mode、forbidden capability 和 Codable deterministic snapshot。 |
| `bash checks/automation-readiness.sh` | pass | 新增 MTP-54 validation matrix、validation plan、contract docs、source/test anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 108 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-55 local replay operations metadata 和 batch replay contract

日期：2026-05-20

执行者：Codex Execution Agent

目的：

- 新增 `MTPRO Market Data Replay Operations v1` 第二项 issue 的本地 replay operations metadata 和 batch replay contract。
- 将 MTP-54 的 batch / replay 字段集合落实为 deterministic metadata value model，覆盖 batch id、replay run id、symbol、interval、time window、fixture source、record count 和 checksum / parity hint。
- 更新 contract、product surface、validation plan、trading validation matrix、latest verification summary 和 automation readiness anchor。

Linear live-read：

- Linear Project：`MTPRO Market Data Replay Operations v1`。
- 当前 issue：`MTP-55` 为唯一 `In Progress` issue。
- `MTP-54` 已 `Done`。
- `MTP-56`、`MTP-57`、`MTP-58`、`MTP-59` 和 `MTP-60` 均为 `Backlog`。
- WIP=1。

文件范围：

- Added：
  - `Sources/Adapters/BinanceMarketDataReplayOperationsMetadata.swift`
- Updated：
  - `Sources/Adapters/BinanceMarketDataBatchReplayBoundary.swift`
  - `Tests/AdaptersTests/AdaptersTests.swift`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

证据：

- `BinanceMarketDataReplayOperationsMetadata` 固定 local replay operations metadata 字段，且 Codable round-trip 后保持 deterministic equality。
- `BinanceMarketDataBatchReplayContract` 把 metadata 绑定到 `BinanceMarketDataBatchReplayBoundary`，并证明 required fields、required validation mode、optional validation mode 和 forbidden capability 未漂移。
- `BinanceMarketDataReplayOperationsFixture` 提供 BTCUSDT / 1m / 单条本地 fixture 的 deterministic metadata / contract evidence。
- Tests 覆盖 invalid metadata：负数 record count、空 checksum / parity hint 和不完整 boundary contract。
- Tests 验证 metadata field values 不包含 signed endpoint、account endpoint、listenKey、broker、real order 或 production runtime operations surface。
- Trading Validation Matrix 继续使用 `TVM-MARKET-DATA-REPLAY-OPERATIONS`，并由 `checks/automation-readiness.sh` 机械检查 MTP-55 source / tests / docs anchors。

边界确认：

- 不实现真实长周期历史下载器。
- 不实现 production scheduler、多节点运行、云端数据湖或大规模数据平台。
- 不实现 retention engine、freshness read model、fixture parity hardening、event log / projection consistency 或 UI evidence 接入。
- 不暴露 SQLite / DuckDB schema、runtime object 或 adapter request。
- 不接 API key、signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AdaptersTests/testBatchReplay` | pass | 5 个 focused XCTest，0 failures；覆盖 metadata Codable deterministic equality、batch replay contract completeness、required validation local-only、invalid metadata 和 forbidden field surface tests。 |
| `bash checks/automation-readiness.sh` | pass | 新增 MTP-55 validation matrix、validation plan、contract docs、product surface、source/test anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 111 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-56 最小 retention policy 和 freshness evidence read model

日期：2026-05-20

执行者：Codex Execution Agent

目的：

- 新增 `MTPRO Market Data Replay Operations v1` 第三项 issue 的最小 retention policy 和 freshness evidence read model。
- 让本地 replay operations 可以表达 batch 是否 retained、stale、expired 或 not retained。
- 更新 contract、product surface、validation plan、trading validation matrix、latest verification summary 和 automation readiness anchor。

Linear live-read：

- Linear Project：`MTPRO Market Data Replay Operations v1`。
- 当前 issue：`MTP-56` 为唯一 `In Progress` issue。
- `MTP-54` 和 `MTP-55` 已 `Done`。
- `MTP-57`、`MTP-58`、`MTP-59` 和 `MTP-60` 均为 `Backlog`。
- WIP=1。

文件范围：

- Added：
  - `Sources/Adapters/BinanceMarketDataReplayFreshness.swift`
- Updated：
  - `Tests/AdaptersTests/AdaptersTests.swift`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

证据：

- `BinanceMarketDataReplayRetentionPolicy` 固定最小本地 retention policy，并 deterministic 计算 fresh、stale、expired 和 not retained。
- `BinanceMarketDataReplayFreshnessEvidenceReadModel` 从 `BinanceMarketDataBatchReplayContract` 派生 batch / replay metadata、policy 摘要、batch age、freshness status 和 retention evidence。
- `BinanceMarketDataReplayBatchFreshnessSummary` 聚合 fresh / stale / expired / not retained / retained batch ids，并输出稳定 summary line。
- Tests 验证 freshness read model 不暴露 SQLite / DuckDB schema、adapter request、runtime object、storage tiering、cloud archive、production deletion job 或 command surface。
- Tests 验证 non-local replay contract 会被拒绝，required validation 继续只依赖 mock transport / fixture parity / local batch replay。
- Trading Validation Matrix 继续使用 `TVM-MARKET-DATA-REPLAY-OPERATIONS`，并由 `checks/automation-readiness.sh` 机械检查 MTP-56 source / tests / docs anchors。

边界确认：

- 不实现完整 retention engine。
- 不执行生产数据清理任务。
- 不做云端 archive、storage tiering、多节点运行或数据湖。
- 不串联 event log / projection consistency，不接 Dashboard UI 或 operations console。
- 不暴露 SQLite / DuckDB schema、runtime object、adapter request 或 persistence adapter direct read。
- 不接 API key、signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AdaptersTests/testBatchReplay` | pass | 8 个 focused XCTest，0 failures；覆盖 retention policy、freshness evidence read model、batch freshness summary、schema / adapter / runtime non-exposure 和 non-local replay contract rejection tests。 |
| `bash checks/automation-readiness.sh` | pass | 新增 MTP-56 validation matrix、validation plan、contract docs、product surface、source/test anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 114 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-57 deterministic fixture parity 和 replay consistency

日期：2026-05-20

执行者：Codex Execution Agent

目的：

- 新增 `MTPRO Market Data Replay Operations v1` 第四项 issue 的 deterministic fixture parity 和 replay consistency evidence。
- 验证本地 batch replay output、metadata record count、record ordering、checksum / parity hint 和 metadata consistency。
- 更新 contract、product surface、validation plan、trading validation matrix、latest verification summary 和 automation readiness anchor。

Linear live-read：

- Linear Project：`MTPRO Market Data Replay Operations v1`。
- 当前 issue：`MTP-57` 为唯一 `In Progress` issue。
- `MTP-54`、`MTP-55` 和 `MTP-56` 已 `Done`。
- `MTP-58`、`MTP-59` 和 `MTP-60` 均为 `Backlog`。
- WIP=1。

文件范围：

- Added：
  - `Sources/Adapters/BinanceMarketDataReplayParity.swift`
- Updated：
  - `Sources/Adapters/BinanceMarketDataReplayOperationsMetadata.swift`
  - `Tests/AdaptersTests/AdaptersTests.swift`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

证据：

- `BinanceMarketDataBatchReplayConsistencyEvidence` 从 `BinanceMarketDataBatchReplayContract` 和本地 replayed `MarketBar` records 派生，不读取真实 Binance 网络、不写 event log、不触发 projection。
- `BinanceMarketDataBatchReplayDeterministicParity` 生成 deterministic replay output summary 和稳定 FNV-1a parity hint。
- Tests 验证 metadata record count、symbol、interval、time window、record ordering 和 checksum / parity hint 与 replay output 一致。
- Tests 验证 record count drift、乱序 replay output、checksum drift、metadata drift 和 non-local replay contract 会被拒绝。
- Trading Validation Matrix 继续使用 `TVM-MARKET-DATA-REPLAY-OPERATIONS`，并由 `checks/automation-readiness.sh` 机械检查 MTP-57 source / tests / docs anchors。

边界确认：

- 不做真实 Binance 网络 required validation。
- 不实现真实长周期历史下载器。
- 不进入 production operations。
- 不串联 event log / projection consistency，不接 Dashboard UI 或 operations console。
- 不暴露 SQLite / DuckDB schema、runtime object、adapter request 或 persistence adapter direct read。
- 不接 API key、signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AdaptersTests/testBatchReplay` | pass | 11 个 focused XCTest，0 failures；覆盖 deterministic fixture parity、replay consistency、metadata count / ordering / checksum drift rejection 和 network boundary drift tests。 |
| `bash checks/automation-readiness.sh` | pass | 新增 MTP-57 validation matrix、validation plan、contract docs、product surface、source/test anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 117 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-58 event log / projection snapshot consistency evidence

日期：2026-05-20

执行者：Codex Execution Agent

目的：

- 新增 `MTPRO Market Data Replay Operations v1` 第五项 issue 的 event log / projection snapshot consistency evidence。
- 将 MTP-55 replay metadata、MTP-56 freshness evidence、MTP-57 deterministic replay consistency evidence 与 append-only `.market` event log、replay result、cache snapshot、SQLite runtime projection 空快照和 DuckDB analytical projection snapshot 串联。
- 更新 contract、read-model projection、persistence boundary、product surface、validation plan、trading validation matrix、latest verification summary 和 automation readiness anchor。

Linear live-read：

- Linear Project：`MTPRO Market Data Replay Operations v1`。
- 当前 issue：`MTP-58` 为唯一 `In Progress` issue。
- `MTP-54`、`MTP-55`、`MTP-56` 和 `MTP-57` 已 `Done`。
- `MTP-59` 和 `MTP-60` 均为 `Backlog`。
- WIP=1。

文件范围：

- Added：
  - `Sources/Runtime/MarketDataReplayProjectionConsistency.swift`
- Updated：
  - `Tests/RuntimeTests/RuntimeTests.swift`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/contracts/persistence-boundary.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

证据：

- `MarketDataReplayProjectionConsistency` 从本地 batch replay contract、freshness evidence、fixture parity evidence 和 append-only event log facts 生成 consistency summary。
- `MarketDataReplayEventLogConsistencyEvidence` 验证 `.market` stream sequence、replay result sequence、metadata record count 和 event log record count 一致。
- `MarketDataReplayProjectionSnapshotConsistencySummary` 验证 replay output summary、event log summary、cache snapshot summary 和 DuckDB analytical projection summary 一致。
- Tests 验证 market-only replay 不在 SQLite runtime projection 中产生 Paper / Risk / Portfolio 状态。
- Tests 验证 summary 可 Codable encode / decode，并保持 deterministic equality。
- Tests 验证 event log drift、projection snapshot drift、schema / runtime source drift 和 non-local replay contract drift 会被拒绝。
- Trading Validation Matrix 继续使用 `TVM-MARKET-DATA-REPLAY-OPERATIONS`，并由 `checks/automation-readiness.sh` 机械检查 MTP-58 source / tests / docs anchors。

边界确认：

- 不做完整数据库 schema 设计。
- 不做 migration framework。
- 不做 production data pipeline。
- 不接 Dashboard / Report / Event Timeline UI。
- 不暴露 SQLite / DuckDB schema、SQL、ORM、runtime object、adapter request 或 persistence adapter direct read。
- 不接 API key、signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter RuntimeTests` | pass | 7 个 RuntimeTests，0 failures；覆盖 event log / projection consistency、deterministic summary、schema non-exposure、event log drift、projection drift 和 source boundary drift tests。 |
| `bash checks/automation-readiness.sh` | pass | 新增 MTP-58 Runtime source / tests、validation-plan、matrix、contract docs、product surface anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## 2026-05-20 — MTP-59 Report / Dashboard / Event Timeline replay operations evidence

执行者：Codex

上下文：

- Linear live-read 确认 `MTP-59` 为唯一 `In Progress` issue；`MTP-54`、`MTP-55`、`MTP-56`、`MTP-57` 和 `MTP-58` 已 `Done`；`MTP-60` 为 `Backlog`；WIP=1。
- 本轮 scope 限定为 Report / Dashboard / Event Timeline read-model-only evidence 接入，展示 batch id、replay run id、freshness status、retention status 和 projection consistency summary。

文件范围：

- Added：
  - `Sources/App/MarketDataReplayOperationsEvidence.swift`
- Updated：
  - `Package.swift`
  - `Sources/App/App.swift`
  - `Sources/App/PaperWorkflowEvidenceExplorer.swift`
  - `Sources/App/DashboardShell.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

证据：

- `MarketDataReplayOperationsEvidenceReadModel` 和 `MarketDataReplayOperationsEvidenceViewModel` 将 MTP-58 summary 复制成 App 层 read-model-only evidence，不让 Dashboard shell 直接导入 Runtime / Adapters。
- `ReportViewModel` 展示 replay operations evidence count、batch ids、replay run ids、freshness / retention status、event log / replay record counts 和 projection consistency boundary。
- `PaperWorkflowEvidenceExplorerSection.marketDataReplayOperation` 新增 Event Timeline 专用分区，展示 replay operations evidence item。
- `DashboardShellSnapshot` Report section 新增 `Replay ops` 指标和 replay operation details；Dashboard smoke 保持 8 个主 sections。

边界确认：

- 不做完整 UI redesign。
- 不做 production operations console。
- 不新增 Runtime command、retention cleanup、projection rebuild、order-level command、按钮或表单。
- 不暴露 SQLite / DuckDB schema、SQL、ORM、Runtime object、adapter request 或 persistence implementation。
- 不接 API key、signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 16 个 AppTests，0 failures；覆盖 Report / Dashboard / Event Timeline replay operations evidence、Codable snapshot、market data replay operation timeline item 和 no schema / no runtime / no adapter / no command boundary tests。 |
| `bash checks/automation-readiness.sh` | pass | 新增 MTP-59 App read model / ViewModel、Report / Dashboard / Event Timeline evidence、validation-plan、matrix、contract docs、product surface 和 source/test anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Professional Trading Workstation Goal Alignment

日期：2026-05-20

执行者：Codex

目的：

- 将 MTPRO 最终产品定位明确为 local-first 的 macOS 原生专业交易工作台。
- 将 `GOAL.md` 从旧的 paper-only 5/5 口径调整为两层进度：Current Foundation Progress 和 Final Product Goal Progress。
- 将最终产品目标拆成 9 个中文优先目标切片，覆盖 Research / Backtest / Report、Paper、Workbench、Market Data Replay，以及 future-gated 的实盘交易基础边界、实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制。
- 同步 `BLUEPRINT.md`、`ROADMAP.md`、Parent Codex 进度条规则和 automation readiness 锚点。

文件范围：

- Updated：
  - `README.md`
  - `AGENTS.md`
  - `GOAL.md`
  - `BLUEPRINT.md`
  - `ROADMAP.md`
  - `docs/automation/parent-codex-supervision.md`
  - `checks/automation-readiness.sh`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Professional Trading Workstation Goal Alignment 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | 两层进度、专业交易工作台定位、final product goal slices 和 future-gated 实盘切片锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Goal Charter Progress Scope Compression

日期：2026-05-20

执行者：Codex

目的：

- 将 `GOAL.md` 中的当前进度内容压回 Project Charter 级别。
- 保留 Current Foundation Progress 和 Final Product Goal Progress 两层总数。
- 保留已完成 foundation 摘要和 future-gated 实盘目标名称。
- 明确完整 9 项目标切片、状态和证据口径由 `ROADMAP.md` 维护，`GOAL.md` 不复制维护详细进度表。

文件范围：

- Updated：
  - `GOAL.md`
  - `checks/automation-readiness.sh`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Goal Charter Progress Scope Compression 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | `GOAL.md` 保留两层进度总数并指向 `ROADMAP.md` 维护详细目标切片。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Complete Blueprint Product / Architecture / Design Structure

日期：2026-05-20

执行者：Codex

目的：

- 将 `BLUEPRINT.md` 明确为产品、架构、设计三线合一的完整蓝图。
- 新增 Blueprint Design Lenses，说明 Product / Architecture / Design 三条线分别回答什么问题。
- 将蓝图结构调整为 Product Blueprint、Architecture Blueprint、Design Blueprint、Infrastructure Blueprint、Trading Capability Blueprint、Live Gate Blueprint、Current / Future Boundary、Blueprint -> Architecture -> Roadmap Handoff。
- 明确 `ARCHITECTURE.md` 承接 `BLUEPRINT.md`，把蓝图翻译为系统模块、边界、数据流、接口、约束和技术分层；`ROADMAP.md` 再承接施工顺序。

文件范围：

- Updated：
  - `BLUEPRINT.md`
  - `checks/automation-readiness.sh`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Complete Blueprint Product / Architecture / Design Structure 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | 蓝图三线结构、基础设施、交易能力、实盘准入和蓝图到架构 / 路线交接锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Remove Legacy Blueprint Compatibility Entry

日期：2026-05-20

执行者：Codex

目的：

- 删除 `docs/design/mtpro-complete-blueprint.md` 旧兼容入口。
- 明确蓝图本体只维护在根目录 `BLUEPRINT.md`。
- 清理当前入口文档、shared language、latest verification summary 和 automation readiness 中的旧兼容入口引用。
- 保留 `verification.md` 历史记录中的旧路径引用，保持 append-only 审计历史不重写。

文件范围：

- Deleted：
  - `docs/design/mtpro-complete-blueprint.md`
- Updated：
  - `BLUEPRINT.md`
  - `README.md`
  - `docs/domain/context.md`
  - `checks/automation-readiness.sh`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Remove Legacy Blueprint Compatibility Entry 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | readiness 确认旧兼容入口不存在，蓝图入口只保留 `BLUEPRINT.md`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## 2026-05-20 — MTP-60 automation readiness、validation evidence 和 stage audit input material 收口

执行者：Codex

上下文：

- Linear live-read 确认 `MTP-60` 为唯一 `In Progress` issue；`MTP-54`、`MTP-55`、`MTP-56`、`MTP-57`、`MTP-58` 和 `MTP-59` 已 `Done`；WIP=1。
- 本轮 scope 限定为 validation evidence、automation readiness anchor、Dashboard smoke evidence、known boundaries 和 Stage Code Audit input material。
- 本 issue 不输出最终 Stage Code Audit Report；最终报告仍由 Parent Codex 在 Project 全部 Done 且 Linear Project `Completed` 后单独输出。

文件范围：

- Added：
  - `docs/audit/inputs/mtpro-market-data-replay-operations-v1-stage-audit-input.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/automation/automation-readiness.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

证据：

- MTP-60 Stage Audit Input 汇总 PR #101、#102、#103、#104、#105、#106 和当前 issue PR 的 evidence 输入。
- Market data replay operations validation evidence chain 覆盖 MTP-54 batch / replay boundary、MTP-55 metadata contract、MTP-56 retention / freshness evidence、MTP-57 fixture parity、MTP-58 event log / projection consistency 和 MTP-59 Report / Dashboard / Event Timeline read-model-only evidence。
- `checks/automation-readiness.sh` 新增 MTP-60 audit input、validation plan、matrix、latest summary 和 Dashboard smoke anchors。
- Trading Validation Matrix 新增 MTP-60 阶段收口说明，指向 `docs/audit/inputs/mtpro-market-data-replay-operations-v1-stage-audit-input.md`。

边界确认：

- 不输出最终 Stage Code Audit Report。
- 不创建下一 Project / Issue。
- 不推进下一 Project / Issue。
- 不启动下一阶段 `symphony-issue`。
- 不写业务功能扩展。
- 不接 API key、signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。
- 不实现 production data platform、production scheduler、retention cleanup job、projection rebuild command 或 operations console。
- 未修改 Linear status。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 新增 MTP-60 stage audit input、validation plan、matrix、latest summary 和 Dashboard smoke anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## MTPRO Market Data Replay Operations v1 Stage Code Audit Report

日期：2026-05-20

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 完成 `MTPRO Market Data Replay Operations v1` 的 Project closure evidence。
- 确认 `MTP-54`、`MTP-55`、`MTP-56`、`MTP-57`、`MTP-58`、`MTP-59`、`MTP-60` 全部 Linear `Done/type=completed`。
- 将 Linear Project status 设置并确认为 `Completed/type=completed`，`completedAt=2026-05-20T08:23:20Z`。
- 将 Project 级 Stage Code Audit Report 落仓为 canonical 文档。
- 更新最近验证摘要，指向 canonical Stage Code Audit Report。

文件范围：

- Added：
  - `docs/audit/mtpro-market-data-replay-operations-v1-stage-code-audit.md`
- Updated：
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

证据：

- PR #101、#102、#103、#104、#105、#106、#107 全部已通过 GitHub required check `checks` 并 squash merge。
- 末端 merge commit 为 `640c7c096fc236f7037551edb7611cbe17f226a2`。
- Post-Issue Ledger 对 `MTP-60` 记录 `git_pull_ff_only` 和 `graphify_update` 均为 `passed`。
- Graphify resource relationship graph 由 Post-Issue Ledger 刷新为 1140 nodes、1092 edges、66 communities。
- Stage Code Audit Report 已记录 Known CI Boundary：本 Project 无当前 main 遗留 failing PR run；MTP-57 的 Linear 状态 race 属于临时 automation 现象，不是 GitHub checks 失败。

边界确认：

- 本轮只落仓 Stage Code Audit Report，不创建 Linear Project / Issue。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update；Graphify evidence 来自 Post-Issue Ledger 已完成记录。
- 未写业务代码。
- 未修改 root docs；Root Docs Refresh Gate 需在本 Stage Code Audit Report 合并后单独执行。
- 未提交 `.codex/*` 或 `graphify-out/*`。
- 不接 Live trading、signed endpoint、account endpoint、listenKey、broker action 或真实订单行为。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 本轮 Stage Code Audit Report 落仓变更无 whitespace error。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## MTPRO Market Data Replay Operations v1 Root Docs Refresh Gate closure

日期：2026-05-20

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 基于已合并的 `docs/audit/mtpro-market-data-replay-operations-v1-stage-code-audit.md` 执行 Root Docs Refresh Gate closure。
- 逐项核查 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md`、`ROADMAP.md` 是否落后于已完成事实。
- 更新当前 Goal / Roadmap Target Progress 和 Current Phase Progress Bar。

Root docs 判断：

- `GOAL.md`：updated。同步 “更长周期 market data replay / operations” 已形成本地 evidence baseline，并将当前目标进度更新为 5 / 5（100%）。
- `ENVIRONMENT.md`：no update needed。本 Project 未新增外部依赖或验证入口；统一验证入口仍是 `bash checks/run.sh`。
- `ARCHITECTURE.md`：updated。同步 Adapters / Runtime / App / Dashboard 的 market data replay operations evidence flow。
- `ROADMAP.md`：updated。新增 `MTPRO Market Data Replay Operations v1` 为 Completed，并将 Project Closure Count 更新为 7 / 7、Goal / Roadmap Target Progress 更新为 5 / 5（100%）。

文件范围：

- Updated：
  - `GOAL.md`
  - `ARCHITECTURE.md`
  - `ROADMAP.md`
  - `docs/audit/mtpro-market-data-replay-operations-v1-stage-code-audit.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 本轮只同步已发生事实。
- 不决定下一阶段方向。
- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 `Todo`。
- 不启动 Symphony。
- 不运行 Graphify update。
- 不写业务代码。
- 不修改 `docs/design/mtpro-complete-blueprint.md`。
- 不把 future capability 计入 progress。

Current Phase Progress：

```text
Current Phase Progress
Phase: MTPRO paper-only research / validation / execution foundation
Project Closure Count: 7/7 (100%)
Goal / Roadmap Target Progress: 5/5 (100%)
Progress: [##########] 100%
Latest Completed Project: MTPRO Market Data Replay Operations v1
Next Handoff: Human + @001 / PLN
```

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Root Docs Refresh Gate closure docs-only 变更无 whitespace error。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## AEP Numbered Blueprint Flow Alignment

日期：2026-05-20

执行者：Codex

目的：

- 将调整后的 AEP Root Blueprint / Complete Blueprint / Construction Plan 分层应用到 MTPRO。
- 新增根目录 `BLUEPRINT.md` 作为 Root Blueprint 入口和默认读取顺序事实源。
- 将 MTPRO root docs 对齐到 AEP 编号方法论：`GOAL.md` 是 Project Charter，`BLUEPRINT.md` 是 Root Blueprint，`ARCHITECTURE.md` 是 Architecture Map，`ROADMAP.md` 是 Construction Plan。
- 将 `docs/validation/latest-verification-summary.md` 从长历史摘录压缩回轻量入口，同时保留 automation readiness 所需锚点。

文件范围：

- Added：
  - `BLUEPRINT.md`
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `GOAL.md`
  - `ARCHITECTURE.md`
  - `ROADMAP.md`
  - `checks/automation-readiness.sh`
  - `docs/design/mtpro-complete-blueprint.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | AEP alignment docs-only 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | Root Blueprint、默认读取顺序、Complete Blueprint 分层和 latest summary 锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；输出 `MTPRO checks passed.`。 |

## Skill-derived Agent Engineering Practices Integration

日期：2026-05-20

执行者：Codex

目的：

- 将 `mattpocock/skills` 中适合 MTPRO 的 shared language、Feedback Loop First、TDD / Tracer Bullet、Diagnose Loop、Architecture Deepening Review 和 Handoff Discipline 整合到 MTPRO 项目流程。
- 新增 MTPRO 领域上下文入口，让 Agent 在 Project Planning、Linear issue、PR、Stage Audit 和代码注释中使用统一术语。
- 用 automation readiness 将新增方法论文档和关键锚点变成机械检查项。

参考来源：

- `https://github.com/mattpocock/skills`
- `https://github.com/mattpocock/skills/blob/main/CONTEXT.md`
- `https://github.com/mattpocock/skills/tree/main/skills/engineering/grill-with-docs`
- `https://github.com/mattpocock/skills/tree/main/skills/engineering/tdd`
- `https://github.com/mattpocock/skills/tree/main/skills/engineering/diagnose`
- `https://github.com/mattpocock/skills/tree/main/skills/engineering/to-issues`
- `https://github.com/mattpocock/skills/tree/main/skills/engineering/improve-codebase-architecture`

文件范围：

- Added：
  - `docs/domain/context.md`
  - `docs/automation/agent-engineering-practices.md`
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `BLUEPRINT.md`
  - `checks/automation-readiness.sh`
  - `docs/design/mtpro-complete-blueprint.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | docs-only methodology 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | shared language、agent engineering practices、Root Blueprint 读序和关键锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Root Docs Compression Pass After Skills Integration

日期：2026-05-20

执行者：Codex

目的：

- 基于 `mattpocock/skills` 方法论整合后的版本，从 `README.md` 开始再压缩一轮默认读路径。
- 保持 `README.md` 为仓库入口，`BLUEPRINT.md` 为 Root Blueprint，`AGENTS.md` 为行为边界，`docs/domain/context.md` 为 shared language，`docs/automation/agent-engineering-practices.md` 为方法论入口，`docs/validation/latest-verification-summary.md` 为轻量验证入口。
- 删除重复解释，保留必要锚点和 automation readiness 机械检查。

文件范围：

- Updated：
  - `README.md`
  - `AGENTS.md`
  - `BLUEPRINT.md`
  - `checks/automation-readiness.sh`
  - `docs/domain/context.md`
  - `docs/automation/agent-engineering-practices.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

压缩结果：

- 默认入口相关文档从 1054 行压缩到约 965 行。
- `AGENTS.md` 将角色长解释收回 `docs/planning/project-role-map.md`。
- `docs/domain/context.md` 合并 Project / Execution 术语表。
- `docs/automation/agent-engineering-practices.md` 保留规则和锚点，减少解释性展开。
- `docs/validation/latest-verification-summary.md` 保持轻量入口，不复制完整 audit/input 路径清单。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | docs compression 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | root docs、shared language、skills practices、latest summary 和关键锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Canonical Blueprint Unification

日期：2026-05-20

执行者：Codex

目的：

- 将 Root Blueprint 与 Complete Blueprint 统一到根目录 `BLUEPRINT.md`。
- 保留 `docs/design/mtpro-complete-blueprint.md` 为旧链接兼容入口，避免蓝图正文双写漂移。
- 同步 README、AGENTS、GOAL、ROADMAP、shared language、role map、Parent Codex supervision、latest summary 和 automation readiness 锚点。

文件范围：

- Updated：
  - `README.md`
  - `AGENTS.md`
  - `GOAL.md`
  - `BLUEPRINT.md`
  - `ROADMAP.md`
  - `checks/automation-readiness.sh`
  - `docs/domain/context.md`
  - `docs/design/mtpro-complete-blueprint.md`
  - `docs/planning/project-role-map.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | blueprint unification docs/checks 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | canonical `BLUEPRINT.md`、兼容入口、root docs、shared language 和关键锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Goal / Blueprint Responsibility Optimization

日期：2026-05-20

执行者：Codex

目的：

- 将 `GOAL.md` 压回 Project Charter：为什么建、服务谁、永久硬边界、成功标准和当前目标进度入口。
- 将最终产品 / 系统 / 设计规划集中到 `BLUEPRINT.md`。
- 在 `BLUEPRINT.md` 中固化 `GOAL.md` / `BLUEPRINT.md` / `ARCHITECTURE.md` / `ROADMAP.md` 的职责分工。
- 将 Goal / Blueprint 分工加入 automation readiness 机械锚点。

文件范围：

- Updated：
  - `GOAL.md`
  - `BLUEPRINT.md`
  - `checks/automation-readiness.sh`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Goal / Blueprint 分工优化变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | Project Charter、Blueprint responsibility contract、Blueprint update rule 和 root docs 锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Blueprint Boundary Chinese Labels

日期：2026-05-20

执行者：Codex

目的：

- 为 `Future Construction Zones` 增加中文并列描述：`未来建设区`。
- 为 `Gated / Forbidden Capabilities` 增加中文并列描述：`受门禁保护或当前禁止的能力`。
- 为 `Forbidden Terms` 增加中文并列描述：`当前禁用或必须带门禁语义的词`。
- 将中英并列写法加入 automation readiness，避免蓝图边界退回全英文标签。

文件范围：

- Updated：
  - `BLUEPRINT.md`
  - `GOAL.md`
  - `ROADMAP.md`
  - `AGENTS.md`
  - `docs/domain/context.md`
  - `docs/planning/project-role-map.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Blueprint boundary Chinese labels 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | Future Construction Zones / 未来建设区、Gated / Forbidden Capabilities / 受门禁保护或当前禁止的能力等锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Secondary Weight Docs Rehome

日期：2026-05-20

执行者：Codex

目的：

- 将旧大写根入口 `ARCHITECTURE.md`、`ENVIRONMENT.md`、`ROADMAP.md` 清理为小写文档入口；本轮之后 `architecture.md` 与 `environment.md` 已重新提升为根目录高权重承接文档。
- 固定 `architecture.md` 的中文语义为 Engineering Module Map / 工程模块地图。
- 固定 `docs/roadmap.md` 的职责为“根据蓝图和工程模块定义施工顺序、进度和下一阶段 handoff”。
- 明确 `architecture.md`、`environment.md` 和 `docs/roadmap.md` 只能承接并细化 `BLUEPRINT.md`，不能推翻蓝图。

文件范围：

- Moved：
  - `ARCHITECTURE.md` -> `architecture.md`
  - `ENVIRONMENT.md` -> `environment.md`
  - `ROADMAP.md` -> `docs/roadmap.md`
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `GOAL.md`
  - `BLUEPRINT.md`
  - `checks/automation-readiness.sh`
  - `docs/domain/context.md`
  - `docs/planning/project-role-map.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/automation/graphify-resource-graph-scope.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/automation/codex-use-cases-alignment.md`
  - `docs/automation/post-issue-ledger.md`
  - `docs/reference/nautilus-trader/*`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Secondary Weight Docs Rehome 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | 根目录高权重文档位置、工程模块地图语义、roadmap 施工路线语义和旧大写根目录入口反向检查通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Environment / Architecture Docs Deepening

日期：2026-05-20

执行者：Codex

目的：

- 补强 `environment.md`，使其成为运行 / 验证 / 外部系统边界的清晰合同，而不是简短摘要。
- 补强 `architecture.md`，使其成为承接 `BLUEPRINT.md` 的工程模块地图，明确 SwiftPM 依赖方向、模块边界、能力流、架构不变量和 Future Live 隔离。
- 将关键章节写入 `checks/automation-readiness.sh` 锚点，降低后续文档漂移风险。

文件范围：

- `environment.md`
- `architecture.md`
- `checks/automation-readiness.sh`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Environment / Architecture Docs Deepening 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | environment / architecture 新章节锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Roadmap Docs Deepening

日期：2026-05-20

执行者：Codex

目的：

- 补强 `docs/roadmap.md`，使其成为承接 `BLUEPRINT.md` 和 `architecture.md` 的施工路线、进度口径和下一轮 handoff 合同。
- 明确路线输入、已完成阶段地图、两层进度模型、施工切片选择规则、实盘路线门槛、Project 收口规则和下一轮交接合同。
- 将关键章节写入 `checks/automation-readiness.sh` 锚点，降低后续路线和进度口径漂移风险。

文件范围：

- `docs/roadmap.md`
- `checks/automation-readiness.sh`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Roadmap Docs Deepening 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | roadmap 新章节锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Root Docs Stack Compression

日期：2026-05-20
执行者：Codex
PR：本 PR
Commit：

目的：
- 从 `README.md` 开始继续压缩 MTPRO 文档栈。
- 保持 `GOAL.md` / `BLUEPRINT.md` / `environment.md` / `architecture.md` / `docs/roadmap.md` 的权重分工。
- 压缩重复叙述，让 `README.md` 只做入口，`GOAL.md` 只做 Project Charter，`BLUEPRINT.md` 只做 canonical Root / Complete Blueprint。
- 保留 `architecture.md` 作为 Engineering Module Map / 工程模块地图。
- 保留 `docs/roadmap.md` 作为 Construction Plan / 施工路线。

文件范围：
- Updated:
  - `README.md`
  - `AGENTS.md`
  - `GOAL.md`
  - `BLUEPRINT.md`
  - `architecture.md`
  - `docs/roadmap.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：
- docs-only。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未推进 Todo。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Root Docs Stack Compression 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | root docs / blueprint / roadmap / architecture 锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## MTPRO Live Trading Boundary Definition v1 Project Planning Record

日期：2026-05-20

执行者：Codex（`@000 / AIE`）

目的：

- 将 Human 确认的 `MTPRO Live Trading Boundary Definition v1` 下一阶段 Project-level planning record 落仓。
- 只保存 Project 级计划摘要和格式门槛，不复制维护完整 Linear issue body。
- 更新 Project Planning Record 索引、最近验证摘要和 automation readiness anchor。

文件范围：

- Added：
  - `docs/planning/projects/mtpro-live-trading-boundary-definition-v1-plan.md`
- Updated：
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

规划摘要：

- Project name：`MTPRO Live Trading Boundary Definition v1`
- Project goal：定义 Live trading foundation 的 gate、contract、blocked evidence 和 forbidden capability tests。
- First executable issue candidate：定义 Live trading foundation capability taxonomy 和 gate。
- WIP=1：所有候选 issue 写入 Linear 后必须初始保持 `Backlog / non-executable`。
- 完整 issue execution contract 以后以 Linear issue body 为准。

边界确认：

- 本轮只落仓 Project Planning Record。
- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 `@002 / PAR`。
- 未启动 Symphony / `symphony-issue`。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 本 planning record 不授权执行。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Live Trading Boundary planning record docs-only 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | Live Trading Boundary planning record 锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## MTP-61 Live Trading Foundation taxonomy / gate

日期：2026-05-21

执行者：Codex

目的：

- 定义 Live trading foundation capability taxonomy、gate 顺序和当前禁止边界。
- 为 `live capability`、`blocked capability`、`future gate` 和 `forbidden capability` 建立 shared language。
- 将 MTP-61 的验证入口固定到 `TVM-LIVE-TRADING-FOUNDATION` 和 automation readiness anchor。

文件范围：

- Added：
  - `docs/contracts/live-trading-boundary-contract.md`
- Updated：
  - `docs/domain/context.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未实现 API key。
- 未实现 secret storage。
- 未实现 signed endpoint。
- 未实现 account endpoint。
- 未实现 listenKey user data stream。
- 未连接 broker / exchange execution adapter。
- 未实现 real order submit / cancel / replace。
- 未实现 OMS。
- 未实现 `LiveExecutionAdapter`。
- 未做实盘监控台、执行控制、风险控制、审计 / 停机控制。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | MTP-61 docs / checks 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | `docs/contracts/live-trading-boundary-contract.md`、`TVM-LIVE-TRADING-FOUNDATION`、MTP-61 validation-plan 和 domain terms anchors 通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## MTP-62 API key / signed endpoint / account endpoint / listenKey boundary

日期：2026-05-21

执行者：Codex

目的：

- 定义 API key / secret / signed endpoint / account endpoint / listenKey 的禁止边界和 future gate。
- 证明 public read-only market data adapter 不能升级为 signed / account capability。
- 将 Gate 1 validation anchor 回填到 `TVM-LIVE-TRADING-FOUNDATION`、validation plan 和 automation readiness。

文件范围：

- Added：
  - `Sources/Core/LiveTradingBoundary.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/AdaptersTests/AdaptersTests.swift`
  - `docs/contracts/live-trading-boundary-contract.md`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/domain/context.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未读取真实 API key。
- 未新增环境变量、配置项、Keychain 读取或 secret 文件读取。
- 未实现 secret storage。
- 未实现 request signature / signed request helper。
- 未调用 signed endpoint。
- 未调用 account endpoint。
- 未创建 listenKey 或 user data stream。
- 未连接 broker / exchange execution adapter。
- 未实现真实账户 payload、真实订单、OMS 或 `LiveExecutionAdapter`。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter LiveTradingCredentialEndpointBoundary` | pass | 2 tests, 0 failures；覆盖 MTP-62 Core Gate 1 fixture、Codable round trip 和 forbidden flag bypass rejection。 |
| `swift test --filter PublicReadOnlyAdapterCannotUpgradeIntoMTP62CredentialOrAccountCapability` | pass | 1 test, 0 failures；覆盖 public read-only adapter 对 keyed / signature / account / listenKey contract 的 transport 前拒绝。 |
| `bash checks/automation-readiness.sh` | pass | MTP-62 contract、matrix、validation-plan、domain terms 和 deterministic test anchors 通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 124 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## MTP-63 public read-only adapter / future live adapter capability isolation

日期：2026-05-21

执行者：Codex

目的：

- 定义 current Binance public read-only adapter 与 future live adapter capability 的隔离合同。
- 证明 future live adapter、`LiveExecutionAdapter`、broker / exchange execution adapter 和 execution venue 只能作为 future gate / forbidden capability 出现。
- 将 Gate 2 validation anchor 回填到 `TVM-LIVE-TRADING-FOUNDATION`、validation plan 和 automation readiness。

文件范围：

- Updated：
  - `Sources/Core/LiveTradingBoundary.swift`
  - `Sources/Adapters/Adapters.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/AdaptersTests/AdaptersTests.swift`
  - `docs/contracts/live-trading-boundary-contract.md`
  - `docs/domain/context.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未实现 future live adapter。
- 未实现 `LiveExecutionAdapter` public type / protocol / actor / class / enum。
- 未连接 broker / exchange execution adapter。
- 未连接 execution venue。
- 未调用 signed endpoint、account endpoint 或 listenKey。
- 未提交、撤销或替换真实订单。
- 未实现 real order lifecycle 或 OMS。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter LiveAdapterCapabilityIsolationBoundary` | pass | 2 tests, 0 failures；覆盖 MTP-63 Core Gate 2 fixture、Codable round trip、`LiveExecutionAdapter` non-implementation、broker / exchange adapter instantiation rejection 和 real order bypass rejection。 |
| `swift test --filter PublicReadOnlyAdapterCannotInstantiateMTP63LiveAdapterOrExecutionVenueCapability` | pass | 1 test, 0 failures；覆盖 public read-only adapter 对 broker、`LiveExecutionAdapter`、submit、cancel 和 replace contract 的 transport 前拒绝。 |
| `swift test --filter MTP63` | pass | 2 tests, 0 failures；覆盖 Core deterministic fixture 和 Adapters execution semantic rejection fast path。 |
| `bash checks/automation-readiness.sh` | pass | MTP-63 contract、matrix、validation-plan、domain terms、deterministic test anchors 和 `LiveExecutionAdapter` declaration guard 通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 127 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## MTP-64 real order lifecycle terminology / future gate / forbidden capability tests

日期：2026-05-21

执行者：Codex

目的：

- 定义 Gate 3 real order lifecycle terminology、future gate 和 forbidden capability tests。
- 证明 submit / cancel / replace、execution report、broker fill、reconciliation、OMS、真实账户状态和 broker position sync 仍是 future / forbidden capability。
- 证明 paper order lifecycle、simulated fill 和 paper portfolio projection 不能升级为 real order、broker fill 或 account state。

文件范围：

- Updated：
  - `Sources/Core/LiveTradingBoundary.swift`
  - `Sources/Adapters/Adapters.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/AdaptersTests/AdaptersTests.swift`
  - `docs/contracts/live-trading-boundary-contract.md`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/domain/context.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未实现 real order state machine。
- 未实现 submit / cancel / replace。
- 未实现 execution report ingestion。
- 未记录 broker fill 或 real fill。
- 未执行 reconciliation。
- 未实现 OMS。
- 未读取真实账户状态。
- 未同步 broker position。
- 未把 paper order intent、simulated fill 或 paper portfolio projection 升级为真实订单、broker fill 或 account state。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter RealOrderLifecycle` | pass | 4 tests, 0 failures；覆盖 Gate 3 Core fixture、paper / real lifecycle isolation 和 Adapters real order lifecycle rejection。 |
| `swift test --filter MTP64` | pass | 3 tests, 0 failures；覆盖 Core deterministic fixture、forbidden bypass rejection 和 Adapters transport-before-network rejection fast path。 |
| `bash checks/automation-readiness.sh` | pass | MTP-64 contract、matrix、validation-plan、domain terms、deterministic test anchors 和 `RealOrderStateMachine` declaration guard 通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 131 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## MTP-65 LiveReadiness / LiveBlockedEvidence read model

日期：2026-05-21

执行者：Codex

目的：

- 新增 Gate 4 `LiveReadiness` / `LiveBlockedEvidence` read-model-only blocked evidence。
- 表达 API key、signed endpoint、account endpoint、listenKey、broker adapter 和 real order lifecycle gates 当前全部 blocked。
- 证明 read model 不提供 live command、交易按钮、adapter / runtime / SQLite / DuckDB schema 暴露、真实订单生命周期或真实交易授权。

文件范围：

- Updated：
  - `Sources/Core/LiveTradingBoundary.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `docs/contracts/live-trading-boundary-contract.md`
  - `docs/domain/context.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未实现 live command。
- 未新增交易按钮。
- 未读取 API key。
- 未新增 secret storage。
- 未实现 signed endpoint、account endpoint 或 listenKey。
- 未实例化 broker adapter。
- 未暴露 Runtime object、adapter surface、SQLite schema 或 DuckDB schema。
- 未实现 real order lifecycle、real order state machine、submit / cancel / replace、execution report、broker fill、reconciliation、OMS、真实账户状态或 broker position sync。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP65` | pass | 3 tests, 0 failures；覆盖 `LiveReadiness` deterministic snapshot、`LiveBlockedEvidence` per-gate evidence、Codable round trip、blocked capability drift rejection、command / schema / adapter / runtime / Live bypass rejection。 |
| `bash checks/automation-readiness.sh` | pass | MTP-65 contract、matrix、validation-plan、domain terms、Core type anchors 和 deterministic test anchors 通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 134 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## MTP-66 Dashboard / Report / Event Timeline Live blocked evidence

日期：2026-05-21

执行者：Codex

目的：

- 将 Gate 4 `LiveReadiness` / `LiveBlockedEvidence` 接入 Gate 5 Dashboard / Report / Event Timeline read-model-only 展示面。
- 展示 API key、signed endpoint、account endpoint、listenKey、broker adapter 和 real order lifecycle 六个 Live gates 仍为 blocked。
- 证明 Dashboard / Report / Event Timeline 不提供 live command、交易按钮、adapter / runtime / SQLite / DuckDB schema 暴露、真实订单生命周期或真实交易授权。

文件范围：

- Added：
  - `Sources/App/LiveTradingBlockedEvidence.swift`
- Updated：
  - `Sources/App/App.swift`
  - `Sources/App/PaperWorkflowEvidenceExplorer.swift`
  - `Sources/App/DashboardShell.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/contracts/live-trading-boundary-contract.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/product/product-surface-map.md`
  - `docs/domain/context.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未实现 live monitoring console。
- 未实现 live execution control。
- 未实现 live risk control。
- 未实现 live audit / incident replay / stop controls。
- 未新增 live command、order-level command、risk control command 或 position management command。
- 未新增交易按钮、表单或真实订单入口。
- 未读取 API key、secret 或真实账户数据。
- 未实现 signed endpoint、account endpoint 或 listenKey。
- 未实例化 broker adapter。
- 未暴露 Runtime object、adapter surface、SQLite schema 或 DuckDB schema。
- 未实现 real order lifecycle、real order state machine、submit / cancel / replace、execution report、broker fill、reconciliation、OMS、真实账户状态或 broker position sync。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 17 tests, 0 failures；覆盖 `LiveTradingBlockedEvidenceViewModel` deterministic Codable snapshot、Report / Dashboard / Event Timeline blocked evidence、read-model-only boundary、no command / no button / no adapter / no runtime / no schema assertions。 |
| `bash checks/automation-readiness.sh` | pass | MTP-66 contract、matrix、validation-plan、frontend contract、product surface、domain term、App source anchors、Dashboard smoke anchor 和 deterministic test anchors 通过。 |
| `DASHBOARD_SMOKE=1 swift run Dashboard` | pass | 输出 `Dashboard smoke: sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 135 个 XCTest 全部通过；最终输出 `MTPRO checks passed.`。 |

## MTP-67 validation matrix、automation readiness 和 stage audit input material 收口

日期：2026-05-21

执行者：Codex

目的：

- 收口 `MTPRO Live Trading Boundary Definition v1` 的 validation matrix、automation readiness anchor、known boundaries、Dashboard smoke evidence 和 Stage Code Audit input material。
- 汇总 `MTP-61` 至 `MTP-66` 的 PR evidence、merge commit 和 GitHub required check，为 Parent Codex 最终 Stage Code Audit Report 提供输入。
- 明确 MTP-67 不输出最终 Stage Code Audit Report，不创建或推进下一 Project / Issue，不启动下一阶段 `symphony-issue`，不实现任何 Live capability。

文件范围：

- Added：
  - `docs/audit/inputs/mtpro-live-trading-boundary-definition-v1-stage-audit-input.md`
- Updated：
  - `docs/contracts/live-trading-boundary-contract.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未修改 production code。
- 未输出最终 Stage Code Audit Report。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未启动下一阶段 `symphony-issue`。
- 未实现 API key、secret storage、signed endpoint、account endpoint、listenKey、broker adapter、`LiveExecutionAdapter`、真实订单、OMS、live command 或交易按钮。
- 未暴露 adapter request、Runtime object、SQLite / DuckDB schema、SQL、ORM、真实账户或 broker state。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | MTP-67 stage audit input、Live boundary contract、latest summary、validation plan、matrix、Dashboard smoke evidence 和关键锚点均可机械定位；输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6`；135 个 XCTest 通过；最终输出 `MTPRO checks passed.`。 |

## MTPRO Live Trading Boundary Definition v1 Stage Code Audit Report

日期：2026-05-21

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 将 `MTPRO Live Trading Boundary Definition v1` 的 canonical Stage Code Audit Report 落仓。
- 固化 `MTP-61`、`MTP-62`、`MTP-63`、`MTP-64`、`MTP-65`、`MTP-66`、`MTP-67` 的 issue / PR evidence、merge commit、required check、validation、Boundary Audit、Known CI Boundary、Root Docs Delta pending 和 Next Human Project Planning handoff。
- 记录 Linear Project closure：status `Completed`，type `completed`，`completedAt=2026-05-20T18:40:57.214Z`。

文件范围：

- Added：
  - `docs/audit/mtpro-live-trading-boundary-definition-v1-stage-code-audit.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

证据：

- `MTP-61` 至 `MTP-67` 全部 Linear `Done`。
- PR #132 已 merge。
- Merge commit：`ad1e64c3d52b0e037cd72de59edf520ab403d81d`。
- GitHub required check：`checks` pass，run `https://github.com/atxinbao/MTPRO/actions/runs/26182443581/job/77028886608`。
- Final validation：`bash checks/run.sh` passed。
- XCTest：135 tests, 0 failures。
- Dashboard smoke：`sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6`。
- Post-Issue Ledger：`git_pull_ff_only` failed because `/Users/mac/Documents/MTPRO` had unrelated local Workbench 中文优先设计 changes; `graphify_update` skipped to avoid stale graph.

边界确认：

- 本轮只落仓 Stage Code Audit Report，不创建 Linear Project / Issue。
- 不推进 Todo。
- 不启动 Symphony。
- 不运行 Graphify update。
- 不写业务代码。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

## MTPRO Workbench Screen Layout v1 Design Record

日期：2026-05-22

执行者：Codex（`@000 / AIE`）

目的：

- 将已通过 `@005 / ARC` 复审的 `MTPRO Workbench Screen Layout v1` 落仓为设计层依据。
- 记录 Figma canonical `40:2`、frame node-id 清单、页面 layout 摘要、Product Interaction Model 映射和 P1 文案修正结果。
- 明确该文档只定义 macOS 工作台 screen layout、页面区域、信息优先级、状态表达和禁止动作，不是最终高保真视觉稿、组件规范、SwiftUI 实现稿或 Linear execution 授权。

文件范围：

- `docs/design/mtpro-workbench-screen-layout-v1.md`
- `docs/product/product-surface-map.md`
- `BLUEPRINT.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增 `docs/design/mtpro-workbench-screen-layout-v1.md`。
- 记录统一 macOS workstation screen structure：Sidebar、Top status、Main evidence workspace、Detail inspector、Events / Audit timeline preview、Status presentation、Future Gated placeholder area。
- 记录 Overview、Market Replay、Research、Backtest、Report、Paper、Portfolio、Risk、Events / Audit、Live Readiness、Live Monitoring、Future Gated 和三类 Future placeholder 的 screen layout 摘要。
- 记录 `@005 / ARC` 初审 P1 和复审通过结论。
- 记录 P1 修正：`future gate opened` -> `future gate reviewed`、`boundary source opened` -> `boundary source linked`、`policy placeholder opened` -> `policy placeholder reviewed`、`source evidence opened` -> `source evidence linked`、`source anchor opened` -> `source anchor linked`。

边界确认：

- 不修改 Figma。
- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony。
- 不运行 Graphify update。
- 不写业务代码。
- 不把 Future Live trading 写成当前 execution scope。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

## MTPRO Product Interaction Model v1 Product Record

日期：2026-05-22

执行者：Codex（`@000 / AIE`）

目的：

- 将 Human 提供的 `@003 / PRD` `MTPRO Product Interaction Model v1` 草案落仓为产品层交互模型。
- 承接 `docs/product/mtpro-workbench-user-flow-blueprint-v1.md`，补齐“用户能看什么、判断什么、点什么、不能点什么”的产品交互规则。
- 明确该文档用于指导后续 `@004 / DSG` 的 `Workbench Screen Layout v1`，不是最终 UI/UX 视觉稿、组件规范或 SwiftUI 实现稿。

文件范围：

- `docs/product/mtpro-product-interaction-model-v1.md`
- `docs/product/product-surface-map.md`
- `BLUEPRINT.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增全局交互原则、状态语言、页面级交互模型和六条核心动线交互规则。
- 明确 read-only evidence interaction、local paper session-level control、blocked / unavailable future action 和 forbidden live trading action 的控制面边界。
- 记录 Live Monitoring 已完成但仅为 read-model-only evidence surface；禁止 reconnect、start live、stop live、broker stream 操作或真实 order stream runtime。
- 记录 Future Live Execution / Risk / Incident Replay 仍是 planning / boundary placeholder，不提供执行入口，不自动创建 Linear 或推进 Todo。

边界确认：

- 不修改 Figma。
- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony。
- 不运行 Graphify update。
- 不写业务代码。
- 不把 Future Live trading 写成当前 execution scope。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
- Root Docs Refresh Gate 仍需在本 Stage Code Audit Report 合并后单独执行。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Stage Code Audit Report 落仓变更无 whitespace error。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 135 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6`；最终输出 `MTPRO checks passed.`。 |

## MTPRO Live Monitoring Console v1 Planning Record

日期：2026-05-21

执行者：Codex（`@001 / PLN`）

目的：

- 将 Human 已确认的 `MTPRO Live Monitoring Console v1` Project-level planning record 落仓。
- 承接 Final Product Goal Slice #6：实盘监控台。
- 仓库只保存 Project 级计划摘要和格式门槛，不复制维护完整 Linear issue body。
- 明确本阶段保持 read-model-only，订单流 / 订单事件流仅表示 blocked / simulated / future evidence，不表示真实订单状态机。

文件范围：

- `docs/planning/projects/mtpro-live-monitoring-console-v1-plan.md`
- `docs/planning/linear-draft-plan.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未推进 Todo。
- 未启动 `@002 / PAR`。
- 未启动 Symphony / symphony-issue。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Live Monitoring Console planning record docs / checks 变更无 whitespace error。 |
| `bash checks/run.sh` | pass | 首轮 `swift test` 出现一次 `xctest` signal 11；执行 `swift package clean` 后重跑通过，automation readiness、Dashboard build / smoke 和 135 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6`；最终输出 `MTPRO checks passed.`。 |

## MTPRO Live Trading Boundary Definition v1 Root Docs Refresh Gate Closure

日期：2026-05-21

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 基于已落仓的 `docs/audit/mtpro-live-trading-boundary-definition-v1-stage-code-audit.md` 执行 Root Docs Refresh Gate closure。
- 只同步已发生事实：`MTPRO Live Trading Boundary Definition v1` 已完成，Live trading foundation boundary 已从 Pending / gated 进入 Complete。
- 重新计算 Current Foundation Progress、Final Product Goal Progress 和 Project Closure Count。
- 保持下一阶段方向、目标、架构路线和优先级交给 Human + `@001 / PLN`。

文件范围：

- Updated：
  - `GOAL.md`
  - `architecture.md`
  - `docs/roadmap.md`
  - `docs/audit/mtpro-live-trading-boundary-definition-v1-stage-code-audit.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

Root docs 判断：

| Root doc | 结果 | 原因 |
| --- | --- | --- |
| `GOAL.md` | updated | Final Product Goal Progress 从 `4 / 9 (44%)` 更新为 `5 / 9 (56%)`，并明确 Live trading foundation 只完成 boundary / blocked evidence / read-only surface。 |
| `environment.md` | no update needed | 本 Project 未新增 required validation、secret、broker credential、signed endpoint、Graphify 或外部写能力；统一验证入口仍是 `bash checks/run.sh`。 |
| `architecture.md` | updated | 同步 Core / Adapters / App / Dashboard 的 Live boundary evidence flow 和 public read-only / future execution adapter isolation。 |
| `docs/roadmap.md` | updated | 新增 completed Project，Project Closure Count 更新为 `8 / 8 (100%)`，Final Product Goal Progress 更新为 `5 / 9 (56%)`。 |

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 Symphony。
- 不运行 Graphify update。
- 不写业务代码。
- 不决定下一阶段方向。
- 不修改 `BLUEPRINT.md`。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Root Docs Refresh Gate closure 变更无 whitespace error。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 135 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6`；最终输出 `MTPRO checks passed.`。 |

## MTPRO-native PR Evidence Fields

日期：2026-05-21

执行者：Codex（`@000 / AIE`）

目的：

- 将 `mattpocock/skills` 中已经吸收的方法论继续收敛为 MTPRO-native PR evidence fields。
- 不安装、不调用、不复制外部 skill runtime，避免新增执行入口和 AEP / Linear / Parent Codex 流程冲突。
- 通过 PR 模板和 automation readiness 机械化以下证据字段：
  - `Feedback Loop Evidence`
  - `Tracer Bullet / Fixture Evidence`
  - `Diagnose Evidence`
  - `Architecture Deepening Candidate`

文件范围：

- `.github/pull_request_template.md`
- `docs/automation/agent-engineering-practices.md`
- `checks/automation-readiness.sh`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未推进 Todo。
- 未启动 `@002 / PAR`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未安装外部 `mattpocock/skills` runtime。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | MTPRO-native PR evidence fields docs / checks 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | PR 模板和工程实践文档中的 `Feedback Loop Evidence`、`Tracer Bullet / Fixture Evidence`、`Diagnose Evidence`、`Architecture Deepening Candidate` 锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 135 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6`；最终输出 `MTPRO checks passed.`。 |

## MTP-68 Live Monitoring Console IA / Read-model-only Boundary

日期：2026-05-21

执行者：Codex

目的：

- 定义 Live monitoring console information architecture、术语、状态分类和 read-model-only 边界。
- 为后续 runtime health、connection、market stream、order stream、latency、error、degraded state 和 operations evidence 提供统一合同。
- 只定义 validation anchor 名称 / 入口，不在本 issue 实际修改 `checks/automation-readiness.sh`。

文件范围：

- `docs/contracts/live-monitoring-console-contract.md`
- `docs/contracts/frontend-view-model-contract.md`
- `docs/product/product-surface-map.md`
- `docs/domain/context.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增 `MTP-68-LIVE-MONITORING-CONSOLE-IA`，覆盖 Overview、Runtime Health、Connection、Market Stream、Order Stream Evidence、Latency、Error / Degraded State 和 Operations Evidence。
- 新增 `MTP-68-LIVE-MONITORING-TERMS` 和 `MTP-68-LIVE-MONITORING-STATUS-TAXONOMY`，定义 live runtime health、connection status、market stream status、order stream evidence、latency evidence、error evidence、degraded state、operations evidence，以及 blocked / simulated / futureOnly / unknown / nominal / stale / degraded / error / recovered 状态分类。
- 新增 `MTP-68-LIVE-MONITORING-READ-MODEL-ONLY`，明确 Dashboard / Report / Event Timeline 只能展示 Read Model / ViewModel。
- 新增 `MTP-68-ORDER-STREAM-EVIDENCE-NOT-REAL-ORDER-STATE`，明确订单流 / 订单事件流只表示 blocked / simulated / future evidence，不表示真实订单状态机。
- 新增 `TVM-LIVE-MONITORING-CONSOLE` 候选矩阵入口和 `MTP-68-NO-AUTOMATION-READINESS-CLOSEOUT`，确认 automation readiness 实际收口保留给 MTP-74。

边界确认：

- 不实现 live runtime。
- 不接 signed endpoint、account endpoint 或 listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine、execution report、broker fill、order reconciliation、OMS、真实账户状态或 broker position sync。
- 不提供 live command、交易按钮、表单、order-level command、risk control command、position management command、submit / cancel / replace 或自动恢复动作。
- 不修改 `checks/automation-readiness.sh`。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 新增合同文件和 docs 变更无 whitespace error。 |
| docs anchor check | pass | `MTP-68-LIVE-MONITORING-CONSOLE-IA`、`MTP-68-LIVE-MONITORING-READ-MODEL-ONLY`、`MTP-68-ORDER-STREAM-EVIDENCE-NOT-REAL-ORDER-STATE`、`MTP-68-NO-AUTOMATION-READINESS-CLOSEOUT` 和 `TVM-LIVE-MONITORING-CONSOLE` 均可定位。 |
| automation readiness boundary check | pass | `checks/automation-readiness.sh` 中没有 MTP-68 / `TVM-LIVE-MONITORING-CONSOLE` 收口项。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 135 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6`；最终输出 `MTPRO checks passed.`。 |

## MTP-69 Live Runtime Health / Connection Status Read Model

日期：2026-05-21

执行者：Codex

目的：

- 新增 live runtime health / connection status 最小 read model。
- 用只读 evidence 表达 future live runtime health 和 connection 状态分类。
- 保持无真实 runtime、无真实连接、无 secret、无 account payload、无 broker、无 command surface。

文件范围：

- `Sources/Core/CoreError.swift`
- `Sources/Core/LiveMonitoringConsole.swift`
- `Tests/CoreTests/CoreTests.swift`
- `docs/contracts/live-monitoring-console-contract.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增 `LiveMonitoringStatus`，覆盖 `healthy`、`blocked`、`disconnected`、`degraded` 和 `unavailable`。
- 新增 `LiveConnectionKind`，覆盖 public market data、future private user data 和 future broker session 三类 connection evidence。
- 新增 `LiveConnectionStatusReadModel`，fixture 状态为 public market data `disconnected`、future private user data `blocked`、future broker session `unavailable`。
- 新增 `LiveRuntimeHealthReadModel`，fixture 状态为 `blocked`，并聚合三类 connection status evidence。
- 新增 constructor / Codable 解码校验，拒绝 command surface、runtime polling、真实网络连接、WebSocket、API key、secret、signed endpoint、account endpoint、listenKey、account payload、broker adapter、adapter surface、Runtime object、SQLite / DuckDB schema、Live trading authorization、trading execution authorization 和 network-dependent validation。

边界确认：

- 不实现 live runtime。
- 不建立真实网络连接。
- 不接 signed endpoint、account endpoint 或 listenKey。
- 不读取 API key、secret 或 account payload。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine。
- 不提供 reconnect、start / stop live command、交易按钮或真实交易授权。
- 不修改 `checks/automation-readiness.sh`；MTP-74 才做 MTP-68 至 MTP-73 的统一机械收口。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP69` | pass | 3 个 focused XCTest 通过；覆盖 deterministic fixture、Codable round trip、connection source anchors、no command、no network、no secret、no account payload、no broker、no schema。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 138 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6`；最终输出 `MTPRO checks passed.`。 |

## MTP-70 Market Stream / Order Stream Blocked Evidence Read Model

日期：2026-05-21

执行者：Codex

目的：

- 新增 market stream / order stream blocked evidence read model。
- 用只读 evidence 表达 public market stream、blocked order stream、simulated order stream 和 future order stream。
- 明确订单流 / 订单事件流仅表示 blocked / simulated / future evidence，不表示真实订单状态机。

文件范围：

- `Sources/Core/LiveMonitoringConsole.swift`
- `Tests/CoreTests/CoreTests.swift`
- `docs/contracts/live-monitoring-console-contract.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增 `LiveStreamMonitoringEvidenceKind`，覆盖 public read-only market stream evidence、blocked order stream evidence、simulated paper order evidence 和 future order stream gate evidence。
- 新增 `LiveStreamMonitoringKind`，覆盖 public market stream、blocked order stream、simulated order stream 和 future order stream。
- 新增 `LiveStreamMonitoringEvidenceItem`，固定每个 stream evidence 的 source anchors、状态、paper evidence 引用和 forbidden capability flags。
- 新增 `LiveStreamMonitoringEvidenceReadModel`，聚合 MTP-69 runtime health fixture 和四类 MTP-70 stream evidence。
- 新增 constructor / Codable 解码校验，拒绝 active market/order stream、market WebSocket、private user data stream、signed endpoint、account endpoint、listenKey、API key、secret、account payload、execution report、broker fill、real order state machine、order command、submit / cancel / replace、broker adapter、adapter surface、Runtime object、SQLite / DuckDB schema、Live trading authorization、trading execution authorization 和 network-dependent validation。
- 回填 `MTP-70-MARKET-STREAM-ORDER-STREAM-READ-MODEL`、`MTP-70-MARKET-STREAM-PUBLIC-READ-ONLY-EVIDENCE`、`MTP-70-ORDER-STREAM-BLOCKED-SIMULATED-FUTURE-EVIDENCE`、`MTP-70-NO-LISTENKEY-ACCOUNT-ENDPOINT-REAL-ORDER-STATE` 和 `MTP-70-LIVE-STREAM-MONITORING-VALIDATION`。

边界确认：

- 不实现 market streaming runtime 或 production subscription control。
- 不实现 account/order streaming runtime。
- 不接 signed endpoint、account endpoint 或 listenKey。
- 不读取 API key、secret 或 account payload。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不消费 execution report，不记录 broker fill，不实现 real order state machine、OMS 或 submit / cancel / replace。
- 不提供 order command、live command、交易按钮或真实交易授权。
- 不修改 `checks/automation-readiness.sh`；MTP-74 才做 MTP-68 至 MTP-73 的统一机械收口。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP70` | pass | 3 个 focused XCTest 通过；覆盖 deterministic fixture、Codable round trip、market stream public read-only boundary、order stream blocked / simulated / future-only evidence、no listenKey、no account endpoint、no execution report、no broker fill、no real order state machine、no order command。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 141 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6`；最终输出 `MTPRO checks passed.`。 |

## MTP-71 Latency / Error / Degraded State Monitoring Evidence

日期：2026-05-21

执行者：Codex

目的：

- 新增 latency / error / degraded state monitoring evidence read model。
- 用本地 deterministic fixtures 表达 future live monitoring console 的运行健康证据。
- 保持 Report / Dashboard 后续可消费的 read-model-only 结构，不提供 production telemetry、alerting、reconnect、stop control 或 live command。

文件范围：

- `Sources/Core/LiveMonitoringConsole.swift`
- `Tests/CoreTests/CoreTests.swift`
- `docs/contracts/live-monitoring-console-contract.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增 `LiveMonitoringEvidenceScope` 和 `LiveMonitoringLatencyBucket`，固定 latency / error / degraded evidence 的只读 scope 与 bucket。
- 新增 `LiveMonitoringLatencyEvidenceItem`，fixture 覆盖 runtime health `stale`、public market stream `degraded`、simulated order stream `nominal`、future private user data `unavailable` 和 future broker session `unavailable`。
- 新增 `LiveMonitoringErrorEvidenceItem`，fixture 覆盖 public market stream disconnected、private user data blocked 和 broker session unavailable。
- 新增 `LiveMonitoringDegradedStateEvidenceItem`，fixture 覆盖 public market stream `degraded` 和 future broker session `unavailable`，只把 latency / error evidence 串成只读状态摘要。
- 新增 `LiveLatencyErrorDegradedMonitoringEvidenceReadModel`，聚合 MTP-70 stream evidence fixture、MTP-71 latency evidence、error evidence 和 degraded state evidence。
- 新增 constructor / Codable 解码校验，拒绝 production telemetry、runtime profiler、external metrics service、runtime monitor、runtime polling、真实网络连接、alerting / paging、incident command、auto recovery、reconnect / stop control、live risk control、signed endpoint、account endpoint、listenKey、API key、secret、account payload、broker adapter、adapter surface、Runtime object、SQLite / DuckDB schema、Live trading authorization、trading execution authorization 和 network-dependent validation。
- 回填 `MTP-71-LATENCY-ERROR-DEGRADED-READ-MODEL`、`MTP-71-LATENCY-EVIDENCE-READ-MODEL`、`MTP-71-ERROR-EVIDENCE-READ-MODEL`、`MTP-71-DEGRADED-STATE-READ-MODEL`、`MTP-71-NO-PRODUCTION-TELEMETRY-OR-COMMAND` 和 `MTP-71-LIVE-MONITORING-LATENCY-ERROR-DEGRADED-VALIDATION`。

边界确认：

- 不实现 production telemetry、runtime profiler 或 external metrics service。
- 不实现真实 runtime monitoring、runtime polling 或 production monitor。
- 不建立真实网络连接、WebSocket 或 private user data stream。
- 不接 signed endpoint、account endpoint 或 listenKey。
- 不读取 API key、secret 或 account payload。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不提供 alerting、paging、reconnect、stop control、incident command、auto recovery、live risk control、live command、交易按钮或真实交易授权。
- 不修改 `checks/automation-readiness.sh`；MTP-74 才做 MTP-68 至 MTP-73 的统一机械收口。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP71` | pass | 3 个 focused XCTest 通过；覆盖 deterministic fixture、Codable round trip、latency / error / degraded source anchors、no production telemetry、no external metrics、no alerting / paging、no reconnect / stop control、no incident command、no auto recovery、no signed endpoint、no broker、no live risk control。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 144 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6`；最终输出 `MTPRO checks passed.`。 |

## MTP-72 Dashboard / Report Live Monitoring Evidence

日期：2026-05-21

执行者：Codex

目的：

- 将 MTP-69 / MTP-70 / MTP-71 的 live monitoring evidence 接入 Dashboard / Report 的 read-model-only 展示面。
- 让 Report 和 Dashboard 能展示 runtime health、connection、market stream、order stream、latency、error 和 degraded state summary。
- 保持 Dashboard smoke，不新增 live command、交易按钮、完整实盘监控台 redesign、真实外部系统连接、execution control、risk control 或 stop control。

文件范围：

- `Sources/App/LiveMonitoringEvidence.swift`
- `Sources/App/App.swift`
- `Sources/App/DashboardShell.swift`
- `Tests/AppTests/AppTests.swift`
- `docs/contracts/live-monitoring-console-contract.md`
- `docs/contracts/frontend-view-model-contract.md`
- `docs/product/product-surface-map.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增 `LiveMonitoringEvidenceReadModel`，只接收 Core 层 `LiveLatencyErrorDegradedMonitoringEvidenceReadModel` 稳定输入。
- 新增 `LiveMonitoringEvidenceViewModel`，汇总 runtime health status、connection statuses、stream counts、latency buckets、error codes、degraded states、source anchors 和 forbidden capability flags。
- `ReportReadModel` / `ReportViewModel` 新增 `liveMonitoringEvidence` 和 monitoring summary fields。
- `DashboardShellSnapshot` Report section 新增 `Monitoring` 指标，Workbench 新增 `Live Monitoring` 只读组。
- Dashboard smoke 新增 `liveMonitoringHealth=blocked` 和 `liveMonitoringErrors=3` evidence。
- AppTests 新增 MTP-72 deterministic ViewModel 测试，并扩展 Report / Dashboard / Workbench / smoke snapshot assertions。

边界确认：

- 不新增 live command、交易按钮、order-level command、risk command、position command。
- 不实现 production telemetry、runtime profiler、external metrics service、真实 runtime monitoring、真实网络连接、alerting / paging、reconnect、stop control、incident command 或 auto recovery。
- 不接 signed endpoint、account endpoint、listenKey。
- 不读取 API key、secret 或 account payload。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`、real order state machine、execution report、broker fill、OMS 或真实交易授权。
- 不暴露 adapter surface、Runtime object、SQLite / DuckDB schema、SQL、ORM、table、column 或 persistence implementation。
- 不修改 `checks/automation-readiness.sh`；MTP-74 才做 MTP-68 至 MTP-73 的统一机械收口。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 18 个 AppTests 通过；覆盖 MTP-72 ViewModel deterministic snapshot、Report / Dashboard / Workbench monitoring evidence、Dashboard smoke、no command / no button / no schema / no adapter / no runtime / no network / no production telemetry / no signed endpoint / no account endpoint / no listenKey / no broker / no real order state machine。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 145 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；最终输出 `MTPRO checks passed.`。 |

## Target System Architecture v3 docs-only 收口

日期：2026-05-21

执行者：Codex

目的：

- 将 @005 / ARC 的 Target System Architecture v3 最终版收口到 root docs。
- 在 `BLUEPRINT.md` 中补充 Product Workbench Map / 产品工作台地图，明确 Current / In Progress / Future Gated 三块状态。
- 在 `architecture.md` 中补充 Engineering Layer Map / 工程分层地图和 Evidence Data Flow / 证据数据流。
- 明确 `Live Monitoring` 当前只代表 read-model-only health / connection / stream / latency / error evidence，不代表真实交易执行入口。

文件范围：

- `BLUEPRINT.md`
- `architecture.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- `BLUEPRINT.md`：把 Final Product Goal Slice #5 更新为 Complete，并说明只完成 Live boundary / blocked evidence；把 Slice #6 标为 In Progress / read-model-only。
- `BLUEPRINT.md`：新增 Product Workbench Map，拆分 Current / 已完成基础工作台、In Progress / 当前建设、Future Gated / 未来门禁区。
- `architecture.md`：新增五层 Engineering Layer Map：Workbench UI Layer、App Interface Layer、Evidence Read Model Layer、Local Runtime / Eventing Layer、Domain + Adapter Boundary Layer。
- `architecture.md`：新增标准 Evidence Data Flow：Input source -> Domain interpretation -> Event fact -> Append-only Event Log -> Replay -> Projection -> Read Model -> ViewModel -> Workbench evidence surface。
- `architecture.md`：明确 Dashboard / App 不直接读取 Runtime、Adapter、SQLite / DuckDB schema；Paper intent / simulated fill 不能升级为 real order lifecycle。

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 @002 / PAR。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不写业务代码。
- 不修改当前正在执行的 Live Monitoring issue 内容。
- 不把 Future Live trading 写成当前 execution scope。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 文档 diff whitespace 检查通过。 |
| `bash checks/run.sh` | pass after clean | 前两次本地 XCTest 进程尾部出现 `xctest ... unexpected signal code 11`；执行 `swift package clean` 后同一入口通过。 |
| Dashboard smoke | pass | `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`。 |
| XCTest | pass | 145 tests, 0 failures。 |

## MTP-73 Event Timeline Live Monitoring Evidence Preview

日期：2026-05-21

执行者：Codex

目的：

- 将 MTP-69 / MTP-70 / MTP-71 的 live monitoring evidence 接入 Event Timeline / Evidence Explorer read-model-only preview。
- 让 Explorer 能展示 runtime health、connection、market / order stream、latency、error 和 degraded state evidence links。
- 保持 Dashboard smoke，不新增 live command、交易按钮、query language、live audit、incident replay、stop control、真实外部系统连接、execution control 或 risk control。

文件范围：

- `Sources/App/PaperWorkflowEvidenceExplorer.swift`
- `Sources/App/App.swift`
- `Tests/AppTests/AppTests.swift`
- `docs/contracts/live-monitoring-console-contract.md`
- `docs/contracts/frontend-view-model-contract.md`
- `docs/product/product-surface-map.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增 `PaperWorkflowEvidenceExplorerSection.liveMonitoringEvidence` 分区。
- `PaperWorkflowEvidenceExplorerReadModel` 新增 `liveMonitoringEvidence` 输入，默认复用 `ReportReadModel.liveMonitoringEvidence`。
- `PaperWorkflowEvidenceExplorerViewModel` 新增 `coversLiveMonitoringEvidence`、`providesLiveAudit`、`providesIncidentReplay` 和 `providesStopControl` boundary flags。
- Event Timeline 新增 18 条 live monitoring timeline item：runtime health 1 条、connection 3 条、stream 4 条、latency 5 条、error 3 条、degraded state 2 条。
- Full dashboard fixture `timelineItems=42`；empty Dashboard smoke snapshot `timelineItems=24`。
- AppTests 新增 MTP-73 deterministic Explorer preview 测试，并扩展 timeline item count、section count、evidence IDs 和 no command / no live audit / no incident replay / no stop control assertions。

边界确认：

- 不新增 live command、交易按钮、order-level command、risk command、position command 或 query language。
- 不实现 live audit、incident replay、stop control、alerting / paging、reconnect、incident command 或 auto recovery。
- 不实现 production telemetry、runtime profiler、external metrics service、真实 runtime monitoring、真实网络连接或 WebSocket。
- 不接 signed endpoint、account endpoint、listenKey。
- 不读取 API key、secret 或 account payload。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`、real order state machine、execution report、broker fill、OMS 或真实交易授权。
- 不暴露 adapter surface、Runtime object、SQLite / DuckDB schema、SQL、ORM、table、column 或 persistence implementation。
- 不修改 `checks/automation-readiness.sh`；MTP-74 才做 MTP-68 至 MTP-73 的统一机械收口。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests/testLiveMonitoringEvidenceExplorerPreviewDefinesMTP73ReadOnlyTimelineItems` | pass | 1 个 AppTests 通过；覆盖 MTP-73 live monitoring evidence 分区 18 条 timeline item、runtime health / connection / stream / latency / error / degraded title、关键 evidence IDs、read-only filter 和 no command / no live audit / no incident replay / no stop control assertions。 |
| `swift test --filter AppTests` | pass | 19 个 AppTests 通过；覆盖 MTP-73 Event Timeline preview、MTP-72 Dashboard / Report monitoring evidence、Dashboard smoke、Workbench snapshot、Codable deterministic snapshot 和 no schema / no adapter / no runtime / no broker / no trading execution。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 146 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=24; liveBlockedGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；最终输出 `MTPRO checks passed.`。 |

## MTP-74 Live Monitoring Console Validation Closeout

日期：2026-05-21

执行者：Codex

目的：

- 收口 MTPRO Live Monitoring Console v1 的 validation matrix、automation readiness 和 Stage Audit input material。
- 汇总 MTP-68 至 MTP-73 的 PR evidence、merge commit、required check、Dashboard smoke 和 read-model-only boundary evidence。
- 明确最终 Stage Code Audit Report 仍由 Parent Codex 在 Project 全部 Done 且 Linear Project `Completed` 后单独输出。

文件范围：

- `docs/audit/inputs/mtpro-live-monitoring-console-v1-stage-audit-input.md`
- `docs/contracts/live-monitoring-console-contract.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

更新重点：

- 新增 MTP-74 stage audit input，覆盖 MTP-68 至 MTP-73 的 PR #137、#138、#139、#140、#141、#143 evidence、merge commit 和 `checks` success URL。
- 在 `TVM-LIVE-MONITORING-CONSOLE` 回填 MTP-74 阶段收口，并把该 Matrix ID 纳入 automation readiness anchors。
- 新增 `MTP-74-LIVE-MONITORING-STAGE-CLOSEOUT`、`MTP-74-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-74-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-74-LIVE-MONITORING-STAGE-AUDIT-INPUT`、`MTP-74-LIVE-MONITORING-VALIDATION-EVIDENCE-CHAIN` 和 `MTP-74-AUTOMATION-READINESS-STAGE-CLOSEOUT`。
- `checks/automation-readiness.sh` 机械检查 MTP-68 至 MTP-74 的 contract、matrix、validation plan、latest summary、stage audit input、source / test anchors 和 Dashboard smoke evidence。

边界确认：

- 不输出最终 Stage Code Audit Report。
- 不创建下一 Project 或下一 Project issues。
- 不推进下一 Project / Issue。
- 不把 planning notes 当执行授权。
- 不启动下一阶段 `symphony-issue`。
- 不写业务功能扩展。
- 不实现 Live trading、execution control、risk control、live audit、incident replay 或 stop control capability。
- 不接 signed endpoint、account endpoint、listenKey、broker adapter、`LiveExecutionAdapter`、real order state machine 或真实订单行为。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | MTP-74 stage audit input、contract、matrix、validation plan、latest summary、source / test anchors 和 Dashboard smoke anchors 均可机械定位；输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=24; liveBlockedGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；146 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTPRO Live Monitoring Console v1 Stage Code Audit Report

日期：2026-05-22

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 将 `MTPRO Live Monitoring Console v1` 的 canonical Stage Code Audit Report 落仓。
- 固化 MTP-68 至 MTP-74 的 Linear Done、PR merge、GitHub `checks`、validation、boundary 和 handoff evidence。
- 记录 Root Docs Refresh Gate input，但不执行 root docs closure，不决定下一阶段方向。

文件范围：

- `docs/audit/mtpro-live-monitoring-console-v1-stage-code-audit.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- Linear Project closure 已完成：Project status `Completed`，`type=completed`，`completedAt=2026-05-21T16:22:45.521Z`。
- `MTP-68` 至 `MTP-74` 全部 Linear `Done`。
- PR #137、#138、#139、#140、#141、#143、#144 均通过 GitHub required check `checks` 并 merge。
- Project 末端 merge commit 为 `378ca31f6de5d4bbead3c4c9bd3f96d9fa3875cb`。
- 记录 MTP-68 / MTP-73 的 host-side Linear status fallback、MTP-74 Post-Issue Ledger `git_pull_ff_only` failed / `graphify_update` skipped，以及 Parent Codex 后续只修复持久仓同步的事实。
- Stage Code Audit Report 明确 `graphify-out/*` 未提交，`.codex/*` 未提交，Parent Codex 未运行 Graphify update。

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 issue body。
- 不推进任何 issue 到 `Todo`。
- 不启动 Symphony。
- 不运行 Graphify update。
- 不写业务代码。
- 不修改 root docs factual state；Root Docs Refresh Gate 保持 pending。
- 不授权下一阶段 planning 或 execution。

## MTPRO Live Monitoring Console v1 Root Docs Refresh Gate Closure

日期：2026-05-22

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 基于已合并的 `docs/audit/mtpro-live-monitoring-console-v1-stage-code-audit.md` 执行 Root Docs Refresh Gate closure。
- 将 `MTPRO Live Monitoring Console v1` 从 In Progress / Pending 事实更新为 Completed / read-model-only evidence surface。
- 将 Final Product Goal Progress 从 `5 / 9 (56%)` 更新为 `6 / 9 (67%)`。
- 保持 Future Live Execution、Future Live Risk、Future Incident Replay / Stop Controls 为 Future Gated。

Root docs 判断：

| 文档 | 结论 | 原因 |
| --- | --- | --- |
| `GOAL.md` | updated | Final Product Goal Progress 更新为 `6 / 9 (67%)`，并明确 Live Monitoring 只完成 read-model-only evidence surface。 |
| `BLUEPRINT.md` | updated | Live Monitoring Console 从 In Progress 改为 Completed / current evidence surface；真实 live runtime、signed/account stream、broker stream 和交易控制仍 gated。 |
| `environment.md` | no update needed | 本 Project 未新增 required validation 入口、secret、broker credential、外部写能力、production telemetry 或网络必需验证。 |
| `architecture.md` | updated | Live monitoring read-model-only evidence chain 已同步为已完成事实，并保持 no adapter / runtime / schema leakage 边界。 |
| `docs/roadmap.md` | updated | 新增 completed Project，Project Closure Count 更新为 `9 / 9 (100%)`，Final Product Goal Progress 更新为 `6 / 9 (67%)`。 |
| `docs/validation/latest-verification-summary.md` | updated | 当前基线、Root Docs Refresh Gate 状态、Progress baseline 和 evidence pointers 已同步。 |
| `docs/audit/mtpro-live-monitoring-console-v1-stage-code-audit.md` | updated | Root Docs Delta 从 pending input 更新为 closure evidence。 |
| `checks/automation-readiness.sh` | updated | Progress anchor 和 Live Monitoring Stage Audit Report closure anchor 已同步。 |

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear issue / status。
- 不推进 Todo。
- 不启动 Symphony。
- 不运行 Graphify update。
- 不写业务代码。
- 不修改 Figma。
- 不启动下一阶段 planning。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

Validation：

| 验证项 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Root Docs Refresh Gate closure docs-only 变更无 whitespace error。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；146 个 XCTest 通过，0 failures。 |

## MTPRO Live Execution Control Contract v1 Planning Record

日期：2026-05-22

执行者：Codex（`@001 / PLN`）

目的：

- 将 Human 已确认的 `MTPRO Live Execution Control Contract v1` Project planning draft 落仓为 repo-side Project Planning Record。
- 承接 Final Product Goal Slice #7：实盘执行控制。
- 只记录 Project 级 planning summary 和格式门槛，作为后续 Linear 写入前的仓库侧 planning record。
- 明确该 planning record 不授权执行，完整 issue execution contract 以后以 Linear issue body 为准。

文件范围：

- `docs/planning/projects/mtpro-live-execution-control-contract-v1-plan.md`
- `docs/planning/linear-draft-plan.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

更新重点：

- 新增 `MTPRO Live Execution Control Contract v1` canonical Project Planning Record。
- 将 planning index 的当前 planning record 指向 `docs/planning/projects/mtpro-live-execution-control-contract-v1-plan.md`。
- 在 latest verification summary 记录该 planning record 已落仓但未写入 Linear。
- 在 automation readiness 中加入该 planning record 的命名、边界和 forbidden capability anchors。
- 明确本阶段只定义 Future Live Execution 的 execution-control contract / boundary。

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不写业务代码。
- 不修改 Figma。
- 不把 planning draft 当执行授权。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不新增交易按钮、order form、live command 或 order-level command UI。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | docs-only planning record 变更无 whitespace error。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；146 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTPRO Workbench User Flow Blueprint v1 Product Record

日期：2026-05-22

执行者：Codex（`@000 / AIE`）

目的：

- 将 Figma canonical `15:2` 的 `MTPRO Workbench User Flow Blueprint v1` 落仓为产品层用户动线蓝图。
- 记录 @003 / PRD Product UX Brief v1、@004 / DSG canonical Figma `15:*` 和 @005 / ARC 通过审查结论。
- 明确该蓝图只用于用户动线、页面角色、状态边界和禁止动作，不是最终 UI/UX 设计稿、组件规范或 SwiftUI 实现稿。

文件范围：

- `docs/product/mtpro-workbench-user-flow-blueprint-v1.md`
- `docs/product/product-surface-map.md`
- `BLUEPRINT.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 记录 Figma canonical file `0MkTyZXHmfBaZ2K9fqddCm` 和主节点 `15:2`。
- 记录六条用户动线：今日状态检查、策略研究到回测、回测到报告、Paper session 观察、异常追溯、Live readiness / monitoring 判断。
- 记录页面角色表和 Current completed / Completed read-model-only evidence surfaces / Future Gated 分区。
- 将 `Live Monitoring` 记录为已完成的 read-model-only evidence surface，不代表真实 live runtime、broker stream 或交易控制。
- 明确 Future Live Execution / Risk / Incident Replay 仍是 planning / boundary placeholder，不是执行授权。

边界确认：

- 不修改 Figma。
- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony。
- 不运行 Graphify update。
- 不写业务代码。
- 不把 Future Live trading 写成当前 execution scope。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

## MTP-75 Live Execution Control Terminology / Taxonomy

日期：2026-05-22

执行者：Codex

目的：

- 执行 Linear live-read 中当前唯一 active issue `MTP-75`：定义 Live execution control terminology 和 real order command taxonomy。
- 建立 `MTPRO Live Execution Control Contract v1` 的 Future / gated execution-control language、real order command taxonomy、paper / real command isolation 和 validation anchor 候选入口。
- 保持本 issue 为 terminology / taxonomy / deterministic forbidden evidence，不提供任何真实订单 command surface。

Linear / scope evidence：

- Linear read-only queue preview 确认 Project `MTPRO Live Execution Control Contract v1` 中 `MTP-75` 为唯一 active issue，状态 `In Progress`；`MTP-76` 至 `MTP-81` 均为 `Backlog`。
- 当前 issue scope 只允许定义 terminology、taxonomy、validation anchors、contract docs、Core deterministic fixture 和 focused tests。
- Non-goals：不实现 API key / secret storage，不实现 signed endpoint / account endpoint / listenKey，不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、real order state machine、OMS，不提交、撤销、替换真实订单，不实现 broker fill、execution report、reconciliation，不新增交易按钮、order form、live command 或 order-level command UI。
- MTP-75 不修改 `checks/automation-readiness.sh` 做最终机械收口；`MTPRO Live Execution Control Contract v1` 的 Issue 7 才允许统一机械化 MTP-75 至 MTP-80 anchors。

文件范围：

- `Sources/Core/LiveExecutionControlContract.swift`
- `Tests/CoreTests/CoreTests.swift`
- `docs/contracts/live-execution-control-contract.md`
- `docs/domain/context.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增 `LiveExecutionControlTerm`、`FutureRealOrderCommandTaxonomyTerm`、`LiveExecutionControlFutureGate`、`LiveExecutionControlForbiddenCapability`、`LiveExecutionControlEvidenceKind` 和 `LiveExecutionControlTerminologyBoundary`。
- `LiveExecutionControlTerminologyBoundary` 固定 `MTP-75-LIVE-EXECUTION-CONTROL-TERMINOLOGY`、`MTP-75-REAL-ORDER-COMMAND-TAXONOMY`、`MTP-75-PAPER-REAL-COMMAND-ISOLATION`、`MTP-75-NO-EXECUTABLE-COMMAND-SURFACE`、`MTP-75-LIVE-EXECUTION-CONTROL-VALIDATION` 和 `TVM-LIVE-EXECUTION-CONTROL`。
- 新增三条 focused Core tests，覆盖 deterministic fixture、Codable round trip、taxonomy drift rejection、command surface / submit / cancel / replace / execution report / reconciliation / adapter / state machine / UI bypass rejection，以及 paper-only evidence 不升级为 real order command。
- 新增 `docs/contracts/live-execution-control-contract.md`，并在 domain context、validation plan、trading validation matrix 和 latest verification summary 回填 MTP-75 anchors。

边界确认：

- 不读取 secret / credential。
- 不接真实 broker / exchange。
- 不执行真实交易动作。
- 不新增 Linear Project / Issue。
- 不修改 Linear status。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不实现 broker fill、execution report、reconciliation。
- 不实现 incident fallback automation、live command、order-level command UI、order form 或交易按钮。
- 不把 `PaperOrderIntent`、`PaperExecutionDecision` 或 `PaperSimulatedFillEvidence` 升级为 real order command。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP75` | pass | 3 个 MTP-75 focused Core XCTest 通过，0 failures。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=24; liveBlockedGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；149 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTP-76 Submit / Cancel / Replace Future Gates

日期：2026-05-22

执行者：Codex

目的：

- 执行 Linear live-read 中当前唯一 active issue `MTP-76`：定义 submit / cancel / replace future gates 和 forbidden capability tests。
- 在 `MTPRO Live Execution Control Contract v1` 中补齐真实订单提交、撤销、替换的 future gate 条件、forbidden capability tests 和 paper intent no real command upgrade evidence。
- 保持本 issue 为 contract / boundary / deterministic forbidden evidence，不提供任何真实订单 command surface。

Linear / scope evidence：

- Linear read-only queue preview 确认 Project `MTPRO Live Execution Control Contract v1` 中 `MTP-76` 为唯一 active issue，状态 `In Progress`；`MTP-75` 为 `Done`；`MTP-77` 至 `MTP-81` 均为 `Backlog`。
- 当前 issue scope 只允许定义 submit / cancel / replace future gate、blocked evidence 和 forbidden capability tests。
- Non-goals：不实现 API key / secret storage，不实现 signed endpoint / account endpoint / listenKey，不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、real order state machine、OMS，不提交、撤销、替换真实订单，不新增交易按钮、order form、live command 或 order-level command UI。
- MTP-76 不修改 `checks/automation-readiness.sh` 做最终机械收口；`MTPRO Live Execution Control Contract v1` 的 Issue 7 才允许统一机械化 MTP-75 至 MTP-80 anchors。

文件范围：

- `Sources/Core/LiveExecutionControlContract.swift`
- `Tests/CoreTests/CoreTests.swift`
- `docs/contracts/live-execution-control-contract.md`
- `docs/domain/context.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增 `LiveSubmitCancelReplaceFutureGate`、`LiveSubmitCancelReplaceForbiddenCapability` 和 `LiveSubmitCancelReplaceCommandBoundary`。
- `LiveSubmitCancelReplaceCommandBoundary` 固定 `MTP-76-SUBMIT-CANCEL-REPLACE-FUTURE-GATES`、`MTP-76-FORBIDDEN-SUBMIT-CANCEL-REPLACE-CAPABILITY-TESTS`、`MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE`、`MTP-76-PAPER-INTENT-NO-REAL-COMMAND-UPGRADE`、`MTP-76-LIVE-EXECUTION-CONTROL-VALIDATION` 和 `TVM-LIVE-EXECUTION-CONTROL`。
- 新增三条 focused Core tests，覆盖 deterministic fixture、Codable round trip、command taxonomy drift rejection、真实 submit / cancel / replace、signed submit / cancel / replace request、broker adapter、`LiveExecutionAdapter`、real order state machine、OMS、order form、trading button bypass rejection，以及 paper-only evidence 不升级为 real submit / cancel / replace。
- 在 contract docs、validation plan、trading validation matrix 和 latest verification summary 回填 MTP-76 anchors。

边界确认：

- 不读取 secret / credential。
- 不接真实 broker / exchange。
- 不执行真实交易动作。
- 不新增 Linear Project / Issue。
- 不修改 Linear status。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不发送 signed submit / cancel / replace request。
- 不实现 broker submit / cancel / replace action。
- 不实现 live command、order-level command UI、order form 或交易按钮。
- 不把 `PaperOrderIntent`、`PaperExecutionDecision` 或 `PaperSimulatedFillEvidence` 升级为 real submit / cancel / replace。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP76` | pass | 3 个 MTP-76 focused Core XCTest 通过，0 failures。 |
| `swift test --filter MTP75` | pass | 3 个 MTP-75 regression Core XCTest 通过，0 failures。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=24; liveBlockedGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；152 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTPRO Workbench UI/UX Design Rules v1 Design Record

日期：2026-05-22

执行者：Codex

目的：

- 将已通过 `@005 / ARC` 审查的 `MTPRO Workbench UI/UX Design Rules v1` 落仓为设计层依据。
- 记录 Figma canonical `51:2`，承接 Product User Flow Blueprint、Product Interaction Model 和 Screen Layout v1。
- 明确该文档只定义 macOS native 工作台的 UI/UX 规则，不是高保真最终视觉稿、组件规范、SwiftUI 实现稿或 Linear execution 授权。

文件范围：

- `docs/design/mtpro-workbench-ui-ux-design-rules-v1.md`
- `docs/product/product-surface-map.md`
- `BLUEPRINT.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 记录 Figma canonical file `0MkTyZXHmfBaZ2K9fqddCm` 和主节点 `51:2`。
- 记录 `51:*` frame node-id 清单。
- 固化 macOS native workstation 设计方向、统一布局规则、typography / spacing / density、evidence components、状态标签和三态分区。
- 记录 Paper 本地 session-level controls 只允许 `start` / `pause` / `close` / `reset`，且视觉权重必须弱于 evidence navigation。
- 记录 Live Monitoring 为 Complete / read-model-only evidence surface，只展示 health / connection / stream / latency / error / degraded evidence，不表达外部运行时控制。
- 记录 Future Gated 只作为 planning / boundary placeholder，不是执行授权，不创建规划或施工入口。
- 增加 Forbidden UI Surface Checklist：API key / secret storage input、signed endpoint、account endpoint / listenKey、broker adapter / broker action、`LiveExecutionAdapter`、real order state machine / OMS、submit / cancel / replace、broker fill / execution report / reconciliation、real account balance / broker position、trading button / live command / order-level command UI 均禁止出现在当前 UI surface。

边界确认：

- 不修改 Figma。
- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony。
- 不运行 Graphify update。
- 不写业务代码。
- 不把 Future Live trading 写成当前 execution scope。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

## MTPRO Workbench Component / Layout Specification v1 Design Record

日期：2026-05-22

执行者：Codex

目的：

- 将已通过 `@005 / ARC` 审查的 `MTPRO Workbench Component / Layout Specification v1` 落仓为设计层依据。
- 记录 Figma canonical `57:2`，承接 Product User Flow Blueprint、Product Interaction Model、Screen Layout v1 和 UI/UX Design Rules v1。
- 明确该文档只定义 macOS native 工作台的组件 / 布局规格，不是高保真最终视觉稿、SwiftUI 实现稿、真实交易能力或 Linear execution 授权。

文件范围：

- `docs/design/mtpro-workbench-component-layout-specification-v1.md`
- `docs/product/product-surface-map.md`
- `BLUEPRINT.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 记录 Figma canonical file `0MkTyZXHmfBaZ2K9fqddCm` 和主节点 `57:2`。
- 记录 `57:*` frame node-id 清单和补充可见标签 `60:2`。
- 固化 layout primitives：Sidebar、Top status、Main evidence workspace、Detail inspector、Events / Audit preview、Future placeholder area。
- 固化 evidence components：evidence row、evidence card、evidence table、source link、blocked reason panel、inspector section、timeline preview row。
- 固化 state components：`empty`、`healthy`、`stale`、`blocked`、`degraded`、`error`。
- 固化 partition components：Current completed、Completed read-model-only evidence surface、Future Gated。
- 固化 Paper local session controls 只允许 `start` / `pause` / `close` / `reset`，且视觉权重弱于 evidence navigation。
- 固化 Live Monitoring read-only evidence components 只表达 health / connection / stream / latency / error / degraded。
- 固化 Future Gated placeholder 只表达 planning / boundary placeholder、不是执行授权、不创建规划或施工入口。
- 记录 `@005 / ARC` 审查结论：通过，P0 / P1 / P2 均未发现问题。

边界确认：

- 不修改 Figma。
- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony。
- 不运行 Graphify update。
- 不写业务代码。
- 不把 Future Live trading 写成当前 execution scope。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
- 不授权 SwiftUI 实现、Linear execution、Future Live trading 或业务代码开发。

## MTPRO Workbench Visual Style Direction v1 Design Record

日期：2026-05-22

执行者：Codex

目的：

- 将已通过 `@005 / ARC` 复审的 `MTPRO Workbench Visual Style Direction v1` 落仓为设计层依据。
- 记录 Figma canonical `64:2`，承接 Product User Flow Blueprint、Product Interaction Model、Screen Layout v1、UI/UX Design Rules v1 和 Component / Layout Specification v1。
- 明确该文档只定义 macOS native 专业交易工作台的视觉方向、色彩语义、typography、density、核心组件视觉样例和关键页面视觉样例，不是最终高保真 UI、组件库、SwiftUI 实现稿、真实交易能力或 Linear execution 授权。

文件范围：

- `docs/design/mtpro-workbench-visual-style-direction-v1.md`
- `docs/product/product-surface-map.md`
- `BLUEPRINT.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 记录 Figma canonical file `0MkTyZXHmfBaZ2K9fqddCm` 和主节点 `64:2`。
- 记录关键节点 `64:4`、`64:47`、`64:95`、`64:398`、`64:460`、`64:523` 和 `64:567`。
- 固化视觉方向：macOS native professional workstation、evidence-first、compact / dense but readable、restrained visual language、中文优先、不是 Web SaaS dashboard。
- 固化色彩语义：neutral surface、evidence emphasis、healthy、stale、blocked、degraded、error、Future Gated、read-model-only；状态不能只靠颜色，必须配合中文标签、原因和 source。
- 固化 typography hierarchy：page title、section title、evidence row title、metadata / trace id、status label、warning / blocked copy。
- 固化 density：sidebar density、top status density、evidence table density、inspector density、timeline preview density。
- 固化核心组件视觉样例：evidence row、evidence card、evidence table、status label、blocked reason panel、detail inspector section、timeline preview row、Future Gated placeholder。
- 固化关键页面视觉样例：Overview、Paper、Live Monitoring、Future Gated。
- 明确 `runtime health: blocked` 是 read-model evidence label，不是底层 Runtime object。
- 记录 `@005 / ARC` 复审结论：通过，P0 / P1 均未发现，P2 无阻断项。

边界确认：

- 不修改 Figma。
- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony。
- 不运行 Graphify update。
- 不写业务代码。
- 不把 Future Live trading 写成当前 execution scope。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
- 不授权最终 UI、高保真实现、SwiftUI 实现、Linear execution、Future Live trading 或业务代码开发。

## MTP-77 Execution Report / Broker Fill / Reconciliation Future Gates

日期：2026-05-22

执行者：Codex

目的：

- 执行 Linear live-read 中当前唯一 active issue `MTP-77`：定义 execution report、broker fill 和 reconciliation future gates 与 forbidden capability tests。
- 在 `MTPRO Live Execution Control Contract v1` 中补齐执行回报、broker 成交和对账的 future gate 条件、forbidden capability tests、blocked evidence 和 simulated fill / paper portfolio isolation evidence。
- 保持本 issue 为 contract / boundary / deterministic forbidden evidence，不提供任何 execution report parser、broker fill recorder、reconciliation runtime、account sync 或 broker position sync。

Linear / scope evidence：

- Linear read-only queue preview 确认 Project `MTPRO Live Execution Control Contract v1` 中 `MTP-77` 为唯一 active issue，状态 `In Progress`；`MTP-75` 和 `MTP-76` 为 `Done`；`MTP-78` 至 `MTP-81` 均为 `Backlog`。
- 当前 issue scope 只允许定义 execution report / broker fill / reconciliation future gate、blocked evidence 和 forbidden capability tests。
- Non-goals：不实现 API key / secret storage，不实现 signed endpoint / account endpoint / listenKey，不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、real order state machine、OMS，不提交、撤销、替换真实订单，不实现 broker fill、execution report、reconciliation，不做 real account balance / broker position sync。
- MTP-77 不修改 `checks/automation-readiness.sh` 做最终机械收口；`MTPRO Live Execution Control Contract v1` 的 Issue 7 才允许统一机械化 MTP-75 至 MTP-80 anchors。

文件范围：

- `Sources/Core/LiveExecutionControlContract.swift`
- `Tests/CoreTests/CoreTests.swift`
- `docs/contracts/live-execution-control-contract.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增 `LiveExecutionReportBrokerFillReconciliationFutureGate`、`LiveExecutionReportBrokerFillReconciliationForbiddenCapability` 和 `LiveExecutionReportBrokerFillReconciliationBoundary`。
- `LiveExecutionReportBrokerFillReconciliationBoundary` 固定 `MTP-77-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-FUTURE-GATES`、`MTP-77-FORBIDDEN-REPORT-FILL-RECONCILIATION-CAPABILITY-TESTS`、`MTP-77-SIMULATED-FILL-NO-BROKER-FILL-OR-EXECUTION-REPORT`、`MTP-77-RECONCILIATION-BLOCKED-EVIDENCE-ONLY`、`MTP-77-LIVE-EXECUTION-CONTROL-VALIDATION` 和 `TVM-LIVE-EXECUTION-CONTROL`。
- 新增三条 focused Core tests，覆盖 deterministic fixture、Codable round trip、terms drift rejection、execution report consumption / parser / ingestion、broker fill recorder / event fact、reconciliation runtime、real account balance read、broker position sync、broker / `LiveExecutionAdapter` bypass rejection，以及 simulated fill / paper portfolio 不升级为 broker fill、execution report、real account 或 broker position。
- 在 contract docs、validation plan、trading validation matrix 和 latest verification summary 回填 MTP-77 anchors。

边界确认：

- 不读取 secret / credential。
- 不接真实 broker / exchange。
- 不执行真实交易动作。
- 不新增 Linear Project / Issue。
- 不修改 Linear status。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
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
- 不实现 live command、order-level command UI、order form 或交易按钮。
- 不把 simulated fill 升级为 broker fill 或 execution report。
- 不把 paper portfolio projection 升级为 broker position 或 real account state。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP77` | pass | 3 个 MTP-77 focused Core XCTest 通过，0 failures。 |
| `swift test --filter MTP76` | pass | 3 个 MTP-76 regression Core XCTest 通过，0 failures。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=24; liveBlockedGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；155 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTP-78 Paper / Simulated Evidence and Future Real Command Isolation

日期：2026-05-22

执行者：Codex

目的：

- 执行 Linear live-read 中当前唯一 active issue `MTP-78`：定义 paper order intent / paper execution decision / simulated fill / paper portfolio projection 与 future real order command 的隔离合同。
- 在 `MTPRO Live Execution Control Contract v1` 中补齐 paper evidence cannot upgrade to future real command 的 forbidden capability tests、read-model-only App surface evidence 和 validation anchors。
- 保持本 issue 为 contract / boundary / deterministic forbidden evidence，不提供任何 real order command、signed command、broker action、execution report ingestion、broker fill ingestion、reconciliation runtime、order form、trading button 或 order-level command UI。

Linear / scope evidence：

- Linear read-only queue preview 确认 Project `MTPRO Live Execution Control Contract v1` 中 `MTP-78` 为唯一 active issue，状态 `In Progress`；`MTP-75`、`MTP-76` 和 `MTP-77` 为 `Done`；`MTP-79` 至 `MTP-81` 均为 `Backlog`。
- 当前 issue scope 只允许定义 paper / simulated / read-model evidence 与 future real order command 的隔离合同、forbidden capability tests 和 Report / Dashboard / Event Timeline read-model-only evidence。
- Non-goals：不实现 API key / secret storage，不实现 signed endpoint / account endpoint / listenKey，不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、real order state machine、OMS，不提交、撤销、替换真实订单，不实现 execution report parser / ingestion、broker fill recorder / event fact、reconciliation runtime，不新增 order form、trading button、live command 或 order-level command UI。
- MTP-78 不修改 `checks/automation-readiness.sh` 做最终机械收口；`MTPRO Live Execution Control Contract v1` 的 Issue 7 才允许统一机械化 MTP-75 至 MTP-80 anchors。

文件范围：

- `Sources/Core/LiveExecutionControlContract.swift`
- `Tests/CoreTests/CoreTests.swift`
- `Tests/AppTests/AppTests.swift`
- `docs/contracts/live-execution-control-contract.md`
- `docs/domain/context.md`
- `docs/product/product-surface-map.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增 `LivePaperRealCommandIsolationEvidenceSource`、`LivePaperRealCommandIsolationForbiddenCapability` 和 `LivePaperRealCommandIsolationBoundary`。
- `LivePaperRealCommandIsolationBoundary` 固定 `MTP-78-PAPER-REAL-COMMAND-ISOLATION-CONTRACT`、`MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE`、`MTP-78-PAPER-PROJECTION-READ-MODEL-ONLY`、`MTP-78-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY`、`MTP-78-LIVE-EXECUTION-CONTROL-VALIDATION` 和 `TVM-LIVE-EXECUTION-CONTROL`。
- 新增三条 focused Core tests，覆盖 deterministic fixture、Codable round trip、MTP-75 / MTP-76 / MTP-77 boundary regression、real command / signed command / execution report / broker fill / reconciliation / `LiveExecutionAdapter` / OMS / order form / trading button bypass rejection，以及 paper-only evidence 不升级为 future real order command。
- 新增一条 App test，覆盖 Report、Dashboard shell、Workbench snapshot 和 Event Timeline / Evidence Explorer 仍然只消费 read model / ViewModel evidence，不提供 live command、order form、order-level command UI、trading button、broker action 或 `LiveExecutionAdapter`。
- 在 contract docs、domain context、product surface map、validation plan、trading validation matrix 和 latest verification summary 回填 MTP-78 anchors。

边界确认：

- 不读取 secret / credential。
- 不接真实 broker / exchange。
- 不执行真实交易动作。
- 不新增 Linear Project / Issue。
- 不修改 Linear status。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不实现 real order command、signed command request、execution report parser / ingestion、broker fill recorder / event fact 或 reconciliation service / runtime。
- 不读取真实账户余额，不执行 account sync，不执行 broker position sync。
- 不实现 live command、order-level command UI、order form 或交易按钮。
- 不把 `PaperOrderIntent`、`PaperExecutionDecision`、`PaperSimulatedFillEvidence` 或 `PaperPortfolioProjectionUpdate` 升级为 future real order command、broker fill、execution report、broker position 或 real account state。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP78` | pass | 4 个 MTP-78 focused Core / App XCTest 通过，0 failures。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=24; liveBlockedGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；159 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTP-79 Read-model-only LiveExecutionControlBlockedEvidence

日期：2026-05-22

执行者：Codex

目的：

- 执行 Linear live-read 中当前唯一 active issue `MTP-79`：新增 read-model-only `LiveExecutionControlBlockedEvidence`。
- 用只读模型汇总 submit / cancel / replace / execution report / broker fill / reconciliation / incident fallback 的 blocked reason。
- 输出 deterministic snapshot，供后续 Dashboard / Report / Event Timeline 展示 issue 使用。
- 保持本 issue 为 Core read-model-only blocked evidence，不暴露 schema、adapter、command 或 runtime control。

Linear / scope evidence：

- Linear read-only queue preview 确认 Project `MTPRO Live Execution Control Contract v1` 中 `MTP-79` 为唯一 active issue，状态 `In Progress`；`MTP-75` 至 `MTP-78` 为 `Done`；`MTP-80` 和 `MTP-81` 为 `Backlog`。
- 当前 issue scope 只允许定义 `LiveExecutionControlBlockedEvidence` 或等价 read model、汇总 execution-control gates blocked reasons、输出 deterministic fixture / snapshot，并保持模型 read-model-only。
- Non-goals：不实现 API key / secret storage，不实现 signed endpoint / account endpoint / listenKey，不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、real order state machine、OMS，不提交、撤销、替换真实订单，不实现 broker fill、execution report、reconciliation，不新增交易按钮、order form、live command 或 order-level command UI，不把数据库 schema 暴露给 UI。
- MTP-79 不修改 `checks/automation-readiness.sh` 做最终机械收口；`MTPRO Live Execution Control Contract v1` 的 Issue 7 才允许统一机械化 MTP-75 至 MTP-80 anchors。

文件范围：

- `Sources/Core/LiveExecutionControlContract.swift`
- `Tests/CoreTests/CoreTests.swift`
- `docs/contracts/live-execution-control-contract.md`
- `docs/domain/context.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增 `LiveExecutionControlBlockedGate`、`LiveExecutionControlBlockedReason`、`LiveExecutionControlBlockedEvidenceItem` 和 `LiveExecutionControlBlockedEvidence`。
- `LiveExecutionControlBlockedEvidence` 固定 `MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE`、`MTP-79-EXECUTION-CONTROL-GATES-BLOCKED-REASONS`、`MTP-79-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT`、`MTP-79-READ-MODEL-ONLY-NO-COMMAND-SURFACE`、`MTP-79-LIVE-EXECUTION-CONTROL-VALIDATION` 和 `TVM-LIVE-EXECUTION-CONTROL`。
- deterministic snapshot 覆盖 submit、cancel、replace、execution report、broker fill、reconciliation 和 incident fallback 的 blocked reason。
- 新增三条 focused Core tests，覆盖 deterministic fixture、Codable round trip、blocked item drift rejection、schema / adapter / runtime / command bypass rejection、真实 submit / cancel / replace、execution report、broker fill、reconciliation、incident fallback、order form / trading button bypass rejection，以及 MTP-76 / MTP-77 / MTP-78 boundary regression。
- 在 contract docs、domain context、validation plan、trading validation matrix 和 latest verification summary 回填 MTP-79 anchors。

边界确认：

- 不读取 secret / credential。
- 不接真实 broker / exchange。
- 不执行真实交易动作。
- 不新增 Linear Project / Issue。
- 不修改 Linear status。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不实现 execution report parser / ingestion、broker fill recorder / event fact、reconciliation service / runtime 或 incident fallback automation。
- 不读取真实账户余额，不执行 account sync，不执行 broker position sync。
- 不暴露 persistence schema、adapter 或 runtime control。
- 不实现 live command、order-level command UI、order form 或交易按钮。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP79` | pass | 初始 red run 因 MTP-79 类型尚未存在而失败；实现后 3 个 MTP-79 focused Core XCTest 通过，0 failures。 |
| `swift test --filter MTP78` | pass | 4 个 MTP-78 regression Core / App XCTest 通过，0 failures。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=24; liveBlockedGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；162 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTP-80 Dashboard / Report / Event Timeline execution-control blocked evidence

日期：2026-05-22

执行者：Codex

目的：

- 执行 Linear live-read 中当前唯一 active issue `MTP-80`：接入 Dashboard / Report / Event Timeline execution-control blocked evidence。
- 将 MTP-79 `LiveExecutionControlBlockedEvidence` 复制成 App 层 read model / ViewModel，并接入 Report、Dashboard Shell 和 Event Timeline / Evidence Explorer。
- 展示 submit / cancel / replace / execution report / broker fill / reconciliation / incident fallback blocked gates、blocked reasons、source anchors、deterministic snapshot 和 read-model-only boundary。
- 保持本 issue 为 App read-model-only 展示面，不暴露 schema、adapter、Runtime control、command surface、order form、交易按钮或真实交易授权。

Linear / scope evidence：

- Linear read-only queue preview 确认 Project `MTPRO Live Execution Control Contract v1` 中 `MTP-80` 为唯一 active issue，状态 `In Progress`；`MTP-75` 至 `MTP-79` 为 `Done`；`MTP-81` 为 `Backlog`。
- 当前 issue scope 只允许将 `LiveExecutionControlBlockedEvidence` 或等价 read model 接入 Dashboard / Report / Event Timeline，并展示 submit、cancel、replace、execution report、broker fill、reconciliation gates 仍被阻断。
- Non-goals：不新增交易按钮、order form、live command、order-level UI、API key / secret、signed endpoint、account endpoint、listenKey、broker / exchange adapter、`LiveExecutionAdapter`、real order state machine / OMS 或真实订单行为。
- MTP-80 不修改 `checks/automation-readiness.sh` 做最终机械收口；`MTPRO Live Execution Control Contract v1` 的 Issue 7 才允许统一机械化 MTP-75 至 MTP-80 anchors。

文件范围：

- `Sources/App/LiveExecutionControlBlockedEvidence.swift`
- `Sources/App/App.swift`
- `Sources/App/PaperWorkflowEvidenceExplorer.swift`
- `Sources/App/DashboardShell.swift`
- `Tests/AppTests/AppTests.swift`
- `docs/contracts/live-execution-control-contract.md`
- `docs/product/product-surface-map.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增 `LiveExecutionControlBlockedEvidenceReadModel`、`LiveExecutionControlBlockedEvidenceViewModel` 和 App 层 view item，只复制 Core blocked evidence，不读取 secret / schema / adapter / Runtime。
- `ReportViewModel` 新增 execution-control blocked gate / reason / source anchor / deterministic snapshot / forbidden flag 汇总，并保持 `authorizesTradingExecution=false`。
- `PaperWorkflowEvidenceExplorerViewModel` 新增 `live execution control blocked evidence` section，七个 gate 各生成只读 timeline item 和 evidence link。
- `DashboardShellSnapshot` 新增 `Execution control` report metric、Workbench `Live Execution Control` detail group 和 smoke `liveExecutionControlGates=7` evidence。
- App tests 覆盖 MTP-80 ViewModel deterministic snapshot、Event Timeline preview、Dashboard Shell Report / Workbench binding、Codable round trip 和 MTP-78 read-model-only regression。
- 在 contract docs、product surface map、validation plan、trading validation matrix 和 latest verification summary 回填 MTP-80 anchors。

边界确认：

- 不读取 secret / credential。
- 不接真实 broker / exchange。
- 不执行真实交易动作。
- 不新增 Linear Project / Issue。
- 不修改 Linear status。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不消费、解析或 ingest execution report。
- 不记录 broker fill，不写 broker fill event fact。
- 不实现 reconciliation service / runtime 或 incident fallback automation。
- 不读取真实账户余额，不执行 account sync，不执行 broker position sync。
- 不暴露 persistence schema、adapter 或 runtime control。
- 不实现 live command、order-level command UI、order form 或交易按钮。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests/testLiveExecutionControl` | pass | 2 个 MTP-80 focused App XCTest 通过，0 failures。 |
| `swift test --filter AppTests` | pass | 22 个 App XCTest 通过，覆盖 Report、Dashboard Shell、Event Timeline / Evidence Explorer 和 Codable regression，0 failures。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=31; liveBlockedGates=6; liveExecutionControlGates=7; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；164 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTP-81 validation matrix、automation readiness 和 stage audit input material 收口

日期：2026-05-22

执行者：Codex

目的：

- 执行 Linear live-read 中当前唯一 active issue `MTP-81`：收口 validation matrix、automation readiness 和 Stage Audit input material。
- 汇总 MTP-75 至 MTP-80 的 PR evidence、merge commit、required check、Dashboard smoke、forbidden capability evidence 和 read-model-only boundary evidence。
- 新增 `docs/audit/inputs/mtpro-live-execution-control-contract-v1-stage-audit-input.md`，作为 Parent Codex 后续 Stage Code Audit Report 输入。
- 明确 MTP-81 不输出最终 Stage Code Audit Report，不推进下一阶段，不启动下一阶段 `symphony-issue`，不实现任何真实 execution-control capability。

Linear / scope evidence：

- Linear read-only queue preview 确认 Project `MTPRO Live Execution Control Contract v1` 中 `MTP-81` 为唯一 active issue，状态 `In Progress`；`MTP-75` 至 `MTP-80` 为 `Done`。
- 当前 issue scope 只允许 validation / automation readiness / stage audit input closeout。
- Non-goals：不实现 API key / secret storage，不实现 signed endpoint / account endpoint / listenKey，不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、real order state machine、OMS，不提交、撤销、替换真实订单，不实现 execution report ingestion、broker fill event fact、reconciliation runtime、incident fallback automation，不新增交易按钮、order form、live command 或 order-level command UI。

文件范围：

- `checks/automation-readiness.sh`
- `docs/audit/inputs/mtpro-live-execution-control-contract-v1-stage-audit-input.md`
- `docs/contracts/live-execution-control-contract.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 在 `docs/contracts/live-execution-control-contract.md` 新增 `MTP-81-LIVE-EXECUTION-CONTROL-STAGE-CLOSEOUT`、`MTP-81-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-81-NO-FINAL-STAGE-CODE-AUDIT` 和 `MTP-81-LIVE-EXECUTION-CONTROL-VALIDATION-EVIDENCE-CHAIN`。
- 在 `docs/validation/trading-validation-matrix.md` 把 `TVM-LIVE-EXECUTION-CONTROL` 纳入矩阵清单，并补充 MTP-81 stage closeout 审计输入说明。
- 在 `docs/validation/validation-plan.md` 增加 MTP-81 Validation Docs / Stage Audit Input Validation。
- 新增 `docs/audit/inputs/mtpro-live-execution-control-contract-v1-stage-audit-input.md`，记录 PR #150、#151、#153、#156、#158、#159 的 merge commit 和 `checks` success 链接、validation evidence chain、Dashboard smoke、forbidden capability evidence、read-model-only boundary evidence、automation readiness evidence、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- 在 `checks/automation-readiness.sh` 机械检查 MTP-75 至 MTP-81 contract、matrix、validation plan、latest summary、audit input、source / test anchors 和 Dashboard smoke evidence。

边界确认：

- 不读取 secret / credential。
- 不接真实 broker / exchange。
- 不执行真实交易动作。
- 不新增 Linear Project / Issue。
- 不修改 Linear status。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
- 不输出最终 Stage Code Audit Report。
- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不消费、解析或 ingest execution report。
- 不记录 broker fill，不写 broker fill event fact。
- 不实现 reconciliation service / runtime 或 incident fallback automation。
- 不读取真实账户余额，不执行 account sync，不执行 broker position sync。
- 不暴露 persistence schema、adapter 或 runtime control。
- 不实现 live command、order-level command UI、order form 或交易按钮。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | MTP-81 stage audit input、contract、matrix、validation plan、latest summary、source / test anchors 和 Dashboard smoke anchors 均可机械定位；输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=31; liveBlockedGates=6; liveExecutionControlGates=7; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；164 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTPRO Live Execution Control Contract v1 Stage Code Audit Report

日期：2026-05-22

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 在 Linear Project `MTPRO Live Execution Control Contract v1` 完成后，输出 canonical Stage Code Audit Report。
- 固化 MTP-75 至 MTP-81 的 PR evidence、merge commit、GitHub `checks`、Linear Project Completed evidence、validation evidence chain、boundary audit 和 Next Human Project Planning handoff。
- 本轮只做 Stage Code Audit Report 落仓，不执行 Root Docs Refresh Gate，不更新 Final Product Goal Progress。

证据：

- Linear Project status：`Completed/type=completed`，`completedAt=2026-05-21T22:38:13.000Z`。
- Canonical issues：`MTP-75`、`MTP-76`、`MTP-77`、`MTP-78`、`MTP-79`、`MTP-80`、`MTP-81` 全部 `Done/type=completed`。
- PR evidence：#150、#151、#153、#156、#158、#159、#160 均通过 GitHub required check `checks` 后 squash merge。
- Project 末端 merge commit：`fb332c915bdbb39eb956f1efc5c9c77c7eb65961`。
- Stage Code Audit Report：`docs/audit/mtpro-live-execution-control-contract-v1-stage-code-audit.md`。
- Stage Audit Input：`docs/audit/inputs/mtpro-live-execution-control-contract-v1-stage-audit-input.md`。

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear issue body。
- 不推进任何 issue 到 `Todo`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不写业务代码。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
- 不实现 API key / secret storage、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real order state machine / OMS、真实 submit / cancel / replace、execution report ingestion、broker fill event fact、reconciliation runtime、incident fallback automation、live command、order form、order-level command UI 或交易按钮。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Stage Code Audit Report docs-only PR 创建前执行，通过。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=31; liveBlockedGates=6; liveExecutionControlGates=7; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；164 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTPRO Live Execution Control Contract v1 Root Docs Refresh Gate closure

日期：2026-05-22

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 在 Stage Code Audit Report PR #161 合并后，关闭 `MTPRO Live Execution Control Contract v1` 的 Root Docs Refresh Gate。
- 只同步已发生事实，把 Final Product Goal Progress 从 `6 / 9 (67%)` 更新为 `7 / 9 (78%)`。
- 明确 Live Execution Control 只完成 contract、future gates、forbidden capability tests、blocked evidence 和 read-model-only evidence surface，不代表真实 execution runtime、真实订单命令、broker fill、execution report 或 reconciliation。

文档结果：

- `GOAL.md`：updated，Final Product Goal Progress 更新为 `7 / 9 (78%)`。
- `BLUEPRINT.md`：updated，Live Execution Control 更新为 `Complete / contract + blocked evidence`，Future Live Risk 和 Future Incident Replay / Stop Controls 仍为 Future Gated。
- `environment.md`：no update needed，本 Project 未新增 secret、broker credential、外部写能力、signed endpoint、account endpoint、listenKey 或网络必需验证。
- `architecture.md`：updated，补充 `LiveExecutionControl` read-model-only blocked evidence flow 和真实 execution runtime / broker / command 禁区。
- `docs/roadmap.md`：updated，Project Closure Count 更新为 `10 / 10 (100%)`，Final Product Goal Progress 更新为 `7 / 9 (78%)`。
- `docs/validation/latest-verification-summary.md`：updated，记录 Root Docs Refresh Gate closure 和当前进度口径。
- `checks/automation-readiness.sh`：updated，机械检查最新 `7 / 9 (78%)` 进度锚点。
- `docs/audit/mtpro-live-execution-control-contract-v1-stage-code-audit.md`：updated，Root Docs Delta 改为 closure result。

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear issue body 或 Linear status。
- 不推进任何 issue 到 `Todo`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不写业务代码。
- 不修改 Figma。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
- 不实现 API key / secret storage、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real order state machine / OMS、真实 submit / cancel / replace、execution report ingestion、broker fill event fact、reconciliation runtime、incident fallback automation、live command、order form、order-level command UI 或交易按钮。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Root Docs Refresh Gate docs-only PR 创建前执行，通过。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=31; liveBlockedGates=6; liveExecutionControlGates=7; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；164 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTPRO Live Risk Gate Contract v1 Planning Record

日期：2026-05-22

执行者：Codex（`@001 / PLN`）

目的：

- 将 Human 已确认的 `MTPRO Live Risk Gate Contract v1` Project planning draft 落仓为 repo-side Project Planning Record。
- 承接 Final Product Goal Slice #8：Live Risk Control。
- 只记录 Project 级 planning summary 和格式门槛，作为后续 Linear 写入前的仓库侧 planning record。
- 明确该 planning record 不授权执行，完整 issue execution contract 以后以 Linear issue body 为准。

文件范围：

- `docs/planning/projects/mtpro-live-risk-gate-contract-v1-plan.md`
- `docs/planning/linear-draft-plan.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

更新重点：

- 新增 `MTPRO Live Risk Gate Contract v1` canonical Project Planning Record。
- 将 planning index 的当前 planning record 指向 `docs/planning/projects/mtpro-live-risk-gate-contract-v1-plan.md`。
- 在 latest verification summary 记录该 planning record 已落仓但未写入 Linear。
- 在 automation readiness 中加入该 planning record 的命名、边界和 forbidden capability anchors。
- 明确本阶段只定义 Future Live Risk 的 risk gate contract / boundary，不更新 `GOAL.md` 或 `docs/roadmap.md` 进度条。

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不写业务代码。
- 不修改 Figma。
- 不把 planning record 当执行授权。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
- 不实现真实 live risk engine。
- 不读取真实账户余额、broker position、margin、leverage。
- 不接 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 real pre-trade allow / reject runtime。
- 不实现 circuit breaker command。
- 不实现 stop trading command / emergency stop。
- 不实现 live command UI。
- 不新增交易按钮。
- 不提交、撤销、替换真实订单。
- 不实现 production operations 或 incident runtime。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | docs-only planning record 变更无 whitespace error。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `timelineItems=31`、`liveExecutionControlGates=7`；164 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTP-82 Live Risk terminology / future risk decision taxonomy

日期：2026-05-22

执行者：Codex

目的：

- 执行 Linear issue `MTP-82 定义 Live risk terminology 和 future risk decision taxonomy`。
- 定义 Future Live Risk 的 live pre-trade risk terminology、future risk decision taxonomy、future gates、forbidden capability baseline、paper / live risk isolation 和 validation anchors。
- 只建立 contract / deterministic fixture / focused tests / validation anchors，不实现真实 live risk runtime。

证据：

- Linear read-only queue preview：`MTP-82` 为唯一 active issue（`In Progress/type=started`），`MTP-83` 至 `MTP-88` 均为 `Backlog/type=backlog`。
- Contract：`docs/contracts/live-risk-gate-contract.md`，包含 `MTP-82-LIVE-RISK-TERMINOLOGY`、`MTP-82-FUTURE-RISK-DECISION-TAXONOMY`、`MTP-82-PAPER-RISK-LIVE-RISK-SEPARATION`、`MTP-82-NO-LIVE-RISK-RUNTIME` 和 `MTP-82-LIVE-RISK-GATE-VALIDATION`。
- Core：`Sources/Core/LiveRiskGateContract.swift`，新增 `LiveRiskTerm`、`FutureRiskDecisionTaxonomyTerm`、`LiveRiskGateFutureGate`、`LiveRiskForbiddenCapability`、`LiveRiskEvidenceKind` 和 `LiveRiskTerminologyBoundary`。
- Tests：`Tests/CoreTests/CoreTests.swift`，新增 `testLiveRiskTerminologyDefinesMTP82FutureOnlyTaxonomy`、`testLiveRiskTerminologyRejectsMTP82RuntimeAccountAndCommandBypass` 和 `testPaperRiskBlockerAndExposureCannotUpgradeToMTP82FutureLiveRiskDecision`。
- Validation docs：`TVM-LIVE-RISK-GATE`、`docs/validation/validation-plan.md` MTP-82 section、`docs/validation/latest-verification-summary.md` MTP-82 evidence、`checks/automation-readiness.sh` MTP-82 anchors。

边界确认：

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不读取真实账户余额，不同步 broker position，不读取 margin / leverage。
- 不实现 real pre-trade risk engine、real pre-trade allow / reject runtime、circuit breaker runtime 或 no-trade state runtime。
- 不新增 live command、risk command surface、position management command、order form 或交易按钮。
- 不把 paper risk blocker、paper exposure、paper execution decision 或 simulated fill 升级为 future live risk decision、real account state、broker position 或 live risk input。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP82` | pass | 3 个 focused Core tests 通过，0 failures。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.` |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=31; liveBlockedGates=6; liveExecutionControlGates=7; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；167 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTPRO Workbench User Dashboard Content Model v1 docs-only record

日期：2026-05-22

执行者：Codex（`@000 / AIE`）

目的：

- 将 Human 提供的 `MTPRO Workbench User Dashboard Content Model v1` 落仓为产品层文档。
- 把 Workbench 从 evidence-heavy 页面校正为用户每天可用的专业交易工作台内容模型。
- 明确 Figma High-Fidelity Key Screens v1 `69:*` 只作为 architecture-safe draft 参考，不作为最终用户面板设计依据。
- 为后续 `@004 / DSG` 输出 `User-Facing Dashboard High-Fidelity v2` 提供产品层输入。

文件范围：

- `docs/product/mtpro-workbench-user-dashboard-content-model-v1.md`
- `docs/product/product-surface-map.md`
- `BLUEPRINT.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增 `MTPRO Workbench User Dashboard Content Model v1`。
- 记录用户面板原则、Overview Content Model、页面内容模型、Content Priority Matrix、Figma `69:*` 修正建议、`@004 / DSG` High-Fidelity v2 输入摘要和 `@005 / ARC` 后续审查重点。
- 在 `docs/product/product-surface-map.md` 增加该产品层 dashboard content model 入口，并明确它处于 `Product User Flow Blueprint v1 -> Product Interaction Model v1 -> User Dashboard Content Model v1 -> User-Facing Dashboard High-Fidelity v2` 链路。
- 在 `BLUEPRINT.md` 增加轻量入口，不复制完整内容，不更新进度条。
- 在 `docs/validation/latest-verification-summary.md` 记录该文档已落仓且不授权 execution。

边界确认：

- 不修改 Figma。
- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不写业务代码。
- 不把 Future Live trading 写成当前 execution scope。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
- 不实现 API key / secret storage、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、real order state machine、submit / cancel / replace、trading button、live command 或 order-level command UI。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | docs-only 产品层文档落仓无 whitespace error。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=31; liveBlockedGates=6; liveExecutionControlGates=7; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；164 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTPRO Workbench User-Facing Dashboard High-Fidelity v2 docs-only record

日期：2026-05-22

执行者：Codex（`@000 / AIE`）

目的：

- 将已通过 `@005 / ARC` 审查的 `MTPRO Workbench User-Facing Dashboard High-Fidelity v2` 落仓为设计层依据。
- 记录 Figma canonical `85:2` 和 12 个 `85:*` frame。
- 明确 v2 承接 User Dashboard Content Model v1，把 Workbench 从 evidence-heavy 改为用户可读 dashboard。
- 明确该设计依据不是 SwiftUI 实现稿、不是组件库、不是 Live PRO Console、不是实盘操作台，也不授权 Linear execution。

文件范围：

- `docs/design/mtpro-workbench-user-facing-dashboard-high-fidelity-v2.md`
- `docs/product/product-surface-map.md`
- `BLUEPRINT.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增设计层用户面 dashboard 高保真关键页面依据。
- 记录 `85:*` frame 清单、v2 设计定位、页面内容摘要、与 Content Model v1 的映射、对 Figma `69:*` 的修正说明、`@005 / ARC` 审查结论。
- 在 `BLUEPRINT.md` 和 `docs/product/product-surface-map.md` 中增加轻量入口。
- 在 latest verification summary 中记录该文档已落仓且不授权 execution。

边界确认：

- 不修改 Figma。
- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不写业务代码。
- 不把 Future Live trading 写成当前 execution scope。
- 不把 v2 写成 Live PRO Console 或实盘操作台。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
- 不实现 API key / secret storage、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、real order state machine、submit / cancel / replace、trading button、live command 或 order-level command UI。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | docs-only 设计层文档落仓无 whitespace error。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=31; liveBlockedGates=6; liveExecutionControlGates=7; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；167 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTP-83 Live Risk exposure / order notional gates execution evidence

日期：2026-05-22

执行者：Codex

目的：

- 定义 exposure gate 和 order notional gate 的 Future Live Risk contract。
- 建立 account / position / margin / leverage forbidden capability tests。
- 证明当前 paper exposure 不能升级为 future live exposure gate、真实账户 exposure、broker position、margin 或 leverage。

文件范围：

- `Sources/Core/LiveRiskGateContract.swift`
- `Tests/CoreTests/CoreTests.swift`
- `docs/contracts/live-risk-gate-contract.md`
- `docs/domain/context.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

证据：

- Linear live-read：`MTP-83` 为当前 `In Progress/type=started` issue；`MTP-82` 为 `Done/type=completed`；`MTP-84` 至 `MTP-88` 为 `Backlog/type=backlog`。
- Contract：`docs/contracts/live-risk-gate-contract.md` 新增 `MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES`、`MTP-83-FORBIDDEN-ACCOUNT-POSITION-MARGIN-LEVERAGE-TESTS`、`MTP-83-NO-REAL-PRE-TRADE-ALLOW-REJECT`、`MTP-83-PAPER-EXPOSURE-NO-LIVE-EXPOSURE-UPGRADE` 和 `MTP-83-LIVE-RISK-GATE-VALIDATION`。
- Core：`Sources/Core/LiveRiskGateContract.swift` 新增 `LiveExposureOrderNotionalFutureGate`、`LiveExposureOrderNotionalForbiddenCapability` 和 `LiveExposureOrderNotionalGateBoundary`。
- Tests：`Tests/CoreTests/CoreTests.swift` 新增 `testLiveExposureOrderNotionalBoundaryDefinesMTP83FutureGatesAndForbiddenCapabilities`、`testLiveExposureOrderNotionalBoundaryRejectsMTP83AccountPositionMarginLeverageBypass` 和 `testPaperExposureCannotUpgradeToMTP83FutureLiveExposureGateDecision`。
- Validation docs：`TVM-LIVE-RISK-GATE`、`docs/validation/validation-plan.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh` 已回填 MTP-83 anchors。

边界确认：

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不读取真实账户余额，不同步 broker position，不读取 margin / leverage。
- 不计算真实账户 exposure。
- 不执行真实订单 notional allow / reject。
- 不实现 real pre-trade risk engine 或 real pre-trade allow / reject runtime。
- 不提交、撤销、替换真实订单。
- 不新增 live command、risk command surface、position management command、order form 或交易按钮。
- 不把 paper exposure 或 paper risk blocker 升级为 future live exposure gate、future live risk decision、real account state、broker position、margin 或 leverage。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP83` | pass | 3 个 focused Core tests 通过，0 failures。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.` |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=31; liveBlockedGates=6; liveExecutionControlGates=7; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；170 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTPRO Product Surface Split v1 docs-only record

日期：2026-05-22

执行者：Codex（`@000 / AIE`）

目的：

- 将已通过 `@005 / ARC` 审查的 `MTPRO Product Surface Split v1` 落仓为产品层边界文档。
- 明确当前 `MTPRO Workbench` 与未来 `MTPRO Live PRO Console` 是两个产品面。
- 明确 Figma `85:*` 只代表 Workbench 用户面 dashboard，不代表 Live PRO Console 或实盘操作台。
- 吸收 `@005 / ARC` 的 P2 小修：将 `Shared Evidence Layer` 收紧为 `Shared Evidence Semantics / Shared Evidence Contract`，并把 Live PRO Console 的 Human decision / 独立 Project Definition / signed / account / broker / risk / ops gates 前置写入定义段。

文件范围：

- `docs/product/mtpro-product-surface-split-v1.md`
- `docs/product/product-surface-map.md`
- `BLUEPRINT.md`
- `docs/design/mtpro-workbench-user-facing-dashboard-high-fidelity-v2.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增产品层 surface boundary 文档。
- 记录 Workbench / Live PRO Console 定义、Shared Evidence Semantics / Shared Evidence Contract、用户与任务对比、Surface Boundary Matrix、`85:*` 当前定位、后续设计路线、禁止动作和审查重点。
- 在 `BLUEPRINT.md` 和 `docs/product/product-surface-map.md` 增加轻量入口。
- 在 `docs/design/mtpro-workbench-user-facing-dashboard-high-fidelity-v2.md` 增加该产品边界引用，解释 `85:*` 是 Workbench dashboard，不是 Live PRO Console。
- 在 latest verification summary 中记录该文档已落仓且不授权 execution。

边界确认：

- 不修改 Figma。
- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不写业务代码。
- 不把 Future Live trading 写成当前 execution scope。
- 不把 Live PRO Console 写成当前可实现产品面。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
- 不实现 API key / secret storage、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、real order state machine、submit / cancel / replace、trading button、live command、emergency stop 或 order-level command UI。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | docs-only 产品层边界文档落仓无 whitespace error。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=31; liveBlockedGates=6; liveExecutionControlGates=7; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；170 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTP-84 frequency / loss / drawdown future risk gates

日期：2026-05-22

执行者：Codex

目的：

- 定义 frequency gate、loss gate 和 drawdown gate 的 Future Live Risk contract。
- 用 deterministic Core fixture 和 forbidden capability tests 锁定当前系统不实现真实限频、真实亏损阈值执行、真实回撤控制 runtime、PnL / equity 读取或停机命令。
- 将 MTP-84 anchors 回填到 contract、domain context、validation plan、trading validation matrix、latest verification summary 和 automation readiness。

文件范围：

- `Sources/Core/LiveRiskGateContract.swift`
- `Tests/CoreTests/CoreTests.swift`
- `docs/contracts/live-risk-gate-contract.md`
- `docs/domain/context.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

更新重点：

- 新增 `LiveFrequencyLossDrawdownFutureGate`、`LiveFrequencyLossDrawdownForbiddenCapability` 和 `LiveFrequencyLossDrawdownGateBoundary`。
- 新增 `testLiveFrequencyLossDrawdownBoundaryDefinesMTP84FutureGatesAndForbiddenCapabilities`、`testLiveFrequencyLossDrawdownBoundaryRejectsMTP84RuntimeBypass` 和 `testPaperRiskAndExposureCannotUpgradeToMTP84FrequencyLossDrawdownGateDecision`。
- 新增 anchors：`MTP-84-FREQUENCY-LOSS-DRAWDOWN-FUTURE-GATES`、`MTP-84-FORBIDDEN-FREQUENCY-LOSS-DRAWDOWN-RUNTIME-TESTS`、`MTP-84-NO-REAL-PNL-EQUITY-OR-DRAWDOWN-ENFORCEMENT`、`MTP-84-PAPER-RISK-EXPOSURE-NO-LIVE-RISK-UPGRADE` 和 `MTP-84-LIVE-RISK-GATE-VALIDATION`。

边界确认：

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不读取真实账户余额，不同步 broker position，不读取 margin / leverage。
- 不读取真实 PnL 或真实账户权益。
- 不统计真实下单频率，不执行生产限频或 broker-side throttling。
- 不执行真实亏损阈值或回撤阈值 allow / reject。
- 不实现 drawdown circuit breaker runtime。
- 不实现 circuit breaker command、stop trading command 或 emergency stop command。
- 不提交、撤销、替换真实订单。
- 不新增 live command、risk command surface、position management command、order form 或交易按钮。
- 不把 paper risk blocker 或 paper exposure 升级为 future frequency / loss / drawdown gate、future live risk decision、real PnL、real account equity 或 pre-trade runtime。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP84` | pass | 3 个 focused Core tests 通过，0 failures。 |
| `bash checks/automation-readiness.sh` | pass | 首次失败缺少 matrix exact anchor `MTP-84 已定义 frequency / loss / drawdown future gates`；补齐后通过并输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=31; liveBlockedGates=6; liveExecutionControlGates=7; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；173 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTP-85 circuit breaker / no-trade state future risk gates

日期：2026-05-22

执行者：Codex

目的：

- 定义 circuit breaker gate 和 no-trade state gate 的 Future Live Risk contract。
- 用 deterministic Core fixture 和 forbidden capability tests 锁定当前系统不实现真实熔断 runtime、禁交易状态 runtime、全局交易锁、broker session state mutation、停机 / 恢复命令或 production shutdown control。
- 将 MTP-85 anchors 回填到 contract、domain context、validation plan、trading validation matrix、latest verification summary 和 automation readiness。

文件范围：

- `Sources/Core/LiveRiskGateContract.swift`
- `Tests/CoreTests/CoreTests.swift`
- `docs/contracts/live-risk-gate-contract.md`
- `docs/domain/context.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

更新重点：

- 新增 `LiveCircuitBreakerNoTradeFutureGate`、`LiveCircuitBreakerNoTradeForbiddenCapability` 和 `LiveCircuitBreakerNoTradeGateBoundary`。
- 新增 `testLiveCircuitBreakerNoTradeBoundaryDefinesMTP85FutureGatesAndForbiddenCapabilities`、`testLiveCircuitBreakerNoTradeBoundaryRejectsMTP85RuntimeCommandAndStateBypass` 和 `testPaperRiskAndExposureCannotUpgradeToMTP85CircuitBreakerNoTradeGateDecision`。
- 新增 anchors：`MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES`、`MTP-85-FORBIDDEN-CIRCUIT-BREAKER-NO-TRADE-RUNTIME-TESTS`、`MTP-85-NO-CIRCUIT-BREAKER-OR-NO-TRADE-STATE-RUNTIME`、`MTP-85-PAPER-RISK-EXPOSURE-NO-CIRCUIT-BREAKER-UPGRADE` 和 `MTP-85-LIVE-RISK-GATE-VALIDATION`。

边界确认：

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不读取真实账户余额，不同步 broker position，不读取 margin / leverage。
- 不读取真实 PnL 或真实账户权益。
- 不执行真实亏损阈值或回撤阈值 allow / reject。
- 不实现 real pre-trade risk engine 或 real pre-trade allow / reject runtime。
- 不实现 circuit breaker runtime。
- 不实现 no-trade state runtime 或 no-trade state transition runtime。
- 不实现 global trading lock 或 broker session state mutation。
- 不实现 circuit breaker command、stop trading command、emergency stop command、automatic recovery command 或 production shutdown control。
- 不提交、撤销、替换真实订单。
- 不新增 live command、risk command surface、position management command、order form 或交易按钮。
- 不把 paper risk blocker 或 paper exposure 升级为 future circuit breaker / no-trade state gate、future live risk decision、real PnL、real account equity、真实账户状态或 pre-trade runtime。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP85` | pass | 3 个 focused Core tests 通过，0 failures。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=31; liveBlockedGates=6; liveExecutionControlGates=7; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；176 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTP-86 paper risk / future live risk decision isolation contract

日期：2026-05-22

执行者：Codex

目的：

- 定义 paper risk blocker / paper exposure 与 future live risk decision 的隔离合同。
- 用 deterministic Core fixture 和 forbidden capability tests 锁定当前系统不把 `RiskBlockerEvidence`、`PortfolioExposureSnapshot` 或 paper risk decision 升级为 future live risk decision、真实 pre-trade allow / reject、真实账户风险输入、circuit breaker trigger 或 no-trade state trigger。
- 将 MTP-86 anchors 回填到 contract、domain context、validation plan、trading validation matrix、latest verification summary 和 automation readiness。

文件范围：

- `Sources/Core/LiveRiskGateContract.swift`
- `Tests/CoreTests/CoreTests.swift`
- `docs/contracts/live-risk-gate-contract.md`
- `docs/domain/context.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

更新重点：

- 新增 `LivePaperRiskLiveDecisionIsolationEvidenceSource`、`LivePaperRiskLiveDecisionForbiddenCapability` 和 `LivePaperRiskLiveDecisionIsolationBoundary`。
- 新增 `testPaperRiskLiveDecisionIsolationBoundaryDefinesMTP86Contract`、`testPaperRiskLiveDecisionIsolationBoundaryRejectsMTP86UpgradeAndRuntimeBypass` 和 `testPaperRiskBlockerAndExposureCannotUpgradeToMTP86FutureLiveRiskDecision`。
- 新增 anchors：`MTP-86-PAPER-RISK-LIVE-DECISION-ISOLATION-CONTRACT`、`MTP-86-PAPER-RISK-EVIDENCE-NO-FUTURE-LIVE-RISK-DECISION`、`MTP-86-PAPER-EXPOSURE-NO-REAL-ACCOUNT-RISK-INPUT`、`MTP-86-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY` 和 `MTP-86-LIVE-RISK-GATE-VALIDATION`。

边界确认：

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不读取真实账户余额，不同步 broker position，不读取 margin / leverage。
- 不读取真实 PnL 或真实账户权益。
- 不实现 real pre-trade risk engine 或 real pre-trade allow / reject runtime。
- 不实现 circuit breaker runtime。
- 不实现 no-trade state runtime。
- 不提交、撤销、替换真实订单。
- 不新增 live command、risk command surface、position management command、order form 或交易按钮。
- 不把 paper risk blocker、paper exposure 或 paper risk decision 升级为 future live risk decision、real account exposure、broker position、real pre-trade allow / reject、circuit breaker trigger、no-trade state trigger 或 live risk runtime input。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP86` | pass | 3 个 focused Core tests 通过，0 failures。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=31; liveBlockedGates=6; liveExecutionControlGates=7; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；179 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTP-88 Live Risk Gate Contract validation matrix、automation readiness 和 stage audit input material 收口

日期：2026-05-22

执行者：Codex

目的：

- 收口 `MTPRO Live Risk Gate Contract v1` 的 validation matrix、automation readiness anchors、forbidden capability evidence、read-model-only boundary evidence、Dashboard smoke evidence 和 Stage Code Audit input material。
- 为 Project closure 后的 Parent Codex Stage Code Audit Report 提供输入材料。
- 明确 MTP-88 不输出最终 Stage Code Audit Report，不推进下一阶段，不启动下一阶段 `symphony-issue`，不实现任何真实 live risk capability。

Linear queue evidence：

- Linear read-only queue preview 确认 Project `MTPRO Live Risk Gate Contract v1` 中 `MTP-88` 为唯一 active issue，状态 `In Progress/type=started`。
- `MTP-82`、`MTP-83`、`MTP-84`、`MTP-85`、`MTP-86` 和 `MTP-87` 均为 `Done/type=completed`。
- 当前 issue scope 只允许 validation / automation readiness / stage audit input closeout。

文件范围：

- `docs/audit/inputs/mtpro-live-risk-gate-contract-v1-stage-audit-input.md`
- `docs/contracts/live-risk-gate-contract.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/validation-plan.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

更新重点：

- 新增 `docs/audit/inputs/mtpro-live-risk-gate-contract-v1-stage-audit-input.md`，汇总 MTP-82 至 MTP-87 PR evidence、merge commit、GitHub required check、Live risk gate validation evidence chain、Dashboard smoke、forbidden capability evidence、read-model-only boundary evidence、automation readiness evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- 在 `docs/contracts/live-risk-gate-contract.md` 新增 `MTP-88-LIVE-RISK-GATE-STAGE-CLOSEOUT`、`MTP-88-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-88-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-88-LIVE-RISK-GATE-VALIDATION-EVIDENCE-CHAIN` 和 `MTP-88-AUTOMATION-READINESS-STAGE-CLOSEOUT`。
- 在 `docs/validation/trading-validation-matrix.md` 新增 MTP-88 Live Risk Gate Contract 阶段收口说明。
- 在 `docs/validation/validation-plan.md` 新增 MTP-88 Validation Docs / Stage Audit Input Validation。
- 在 `checks/automation-readiness.sh` 机械检查 MTP-87 read-model-only surface 和 MTP-88 stage closeout anchors。
- 在 `docs/validation/latest-verification-summary.md` 增加 MTP-88 当前验证摘要和本地验证结果。

PR evidence input：

| Issue | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- |
| `MTP-82` | [#165](https://github.com/atxinbao/MTPRO/pull/165) | `643612a74d71f49d38f45bba657c8c6e35cbc510` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26286848821/job/77376514320) |
| `MTP-83` | [#167](https://github.com/atxinbao/MTPRO/pull/167) | `49ba28ffd8343c969ed37064000d30a635229fa0` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26288214173/job/77381140111) |
| `MTP-84` | [#169](https://github.com/atxinbao/MTPRO/pull/169) | `76a8f03971b0894e3d35fbe4e49563fda720434d` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26291446322/job/77392466957) |
| `MTP-85` | [#170](https://github.com/atxinbao/MTPRO/pull/170) | `262056accde123ef3f5a1a68c66727f7bc899929` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26292762287/job/77397126541) |
| `MTP-86` | [#171](https://github.com/atxinbao/MTPRO/pull/171) | `2e72938a15e76ec7f457148a2a3c055ecb0101e1` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26294166908/job/77402101062) |
| `MTP-87` | [#172](https://github.com/atxinbao/MTPRO/pull/172) | `56e105f0855a182a93780a8beceaef9449d6db49` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26299370909/job/77420288078) |

边界确认：

- 不输出最终 Stage Code Audit Report。
- 不创建下一 Project / Issue，不推进下一阶段，不启动下一阶段 `symphony-issue`。
- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现真实 live risk engine 或 real pre-trade allow / reject runtime。
- 不读取真实账户余额、broker position、margin、leverage、PnL 或 equity。
- 不实现真实 account exposure calculation、real order notional evaluation、live order frequency runtime、loss / drawdown runtime。
- 不实现 circuit breaker runtime、no-trade state runtime、global trading lock 或 broker session state mutation。
- 不实现 circuit breaker command、stop trading command、emergency stop、automatic recovery command 或 production shutdown control。
- 不新增 live command、risk command surface、position management command、order form 或交易按钮。
- 不把 `LiveRiskGateBlockedEvidence`、paper risk blocker 或 paper exposure 升级为真实风控输入或 future live risk decision runtime。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `DASHBOARD_SMOKE=1 swift run Dashboard` | pass | 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=37; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`。 |
| `bash checks/automation-readiness.sh` | pass | MTP-88 stage audit input、contract、matrix、validation plan、latest summary、source / test anchors 和 Dashboard smoke anchors 均可机械定位；输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=37; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；184 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTPRO Workbench User-Facing Dashboard High-Fidelity v3 docs-only record

日期：2026-05-23

执行者：Codex（`@000 / AIE`）

目的：

- 将已通过 `@005 / ARC` 复审的 `MTPRO Workbench User-Facing Dashboard High-Fidelity v3` 落仓为设计层依据。
- 记录 Figma canonical `91:2`，承接 `MTPRO Workbench Business Dashboard Content Model v2` 草案。
- 明确 v3 是经过 macOS native desktop refinement 的 Workbench business dashboard 设计依据，不是 SwiftUI 实现稿、组件库、Live PRO Console、实盘操作台或 Linear execution 授权。

文件范围：

- `docs/design/mtpro-workbench-user-facing-dashboard-high-fidelity-v3.md`
- `docs/product/product-surface-map.md`
- `BLUEPRINT.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增设计层文档，记录 Figma canonical URL、主节点 `91:2`、12 个 `91:*` frame node-id、v3 设计定位、每页内容摘要、Business Dashboard Content Model v2 映射、对 Figma `85:*` 的修正、macOS native refinement 记录和 Forbidden UI Surface Checklist。
- 在 `docs/product/product-surface-map.md` 增加 `MTPRO Workbench User-Facing Dashboard High-Fidelity v3` 引用，明确它是设计层业务判断 dashboard 高保真关键页面依据，已经过 macOS native desktop refinement，不是 Live PRO Console、实盘操作台或 SwiftUI 实现授权。
- 在 `BLUEPRINT.md` 增加 v3 设计依据入口，不复制完整设计内容，不更新进度条，不授权 execution。
- 在 `docs/validation/latest-verification-summary.md` 记录 Figma canonical `91:2` 已通过 `@005 / ARC` 复审并完成 docs-only 落仓事实。

`@005 / ARC` 审查结论：

- 初审：需修改，问题为状态 pill 错位和 Future Gated 底部叠层。
- 复审：通过，P0 / P1 无。
- P2：hidden legacy layers 仍存在但均为 hidden，不进入最终截图，不阻塞落仓。

边界确认：

- 不修改 Figma。
- 不创建 Linear Project / Issue，不修改 Linear status，不推进 Todo。
- 不启动 `@002 / PAR`、Symphony 或 symphony-issue。
- 不运行 Graphify update。
- 不写业务代码。
- 不把 Future Live trading 写成当前 execution scope。
- 不把 Live PRO Console 写成当前可实现产品面。
- 不新增 trading button、order form、submit / cancel / replace、broker action、signed endpoint、account endpoint / listenKey、real account balance、broker position、OMS、`LiveExecutionAdapter`、real order state machine、reconnect / start live / stop live、live command 或 emergency stop 当前可执行动作。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | docs-only diff 无空白错误。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=37; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；184 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTPRO Live Risk Gate Contract v1 Stage Code Audit Report

日期：2026-05-23

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 将 `MTPRO Live Risk Gate Contract v1` 的 Project-level Stage Code Audit Report 落仓为 canonical audit 文档。
- 记录 `MTP-82` 至 `MTP-88` 全部 Linear `Done`、Linear Project state `completed`、PR / merge commit / GitHub `checks` evidence、validation evidence、MTP-87 临时 CI / readiness fallback 和 live risk boundary audit。
- 为后续独立 Root Docs Refresh Gate 提供 input；本轮不更新 Final Product Goal Progress 到 `8 / 9 (89%)`。

文件范围：

- `docs/audit/mtpro-live-risk-gate-contract-v1-stage-code-audit.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

关键证据：

- Linear Project ID：`645376a1-26eb-4be7-baec-f34e69a2413b`。
- Linear Project state：`completed`，`completedAt=2026-05-22T16:50:07.087Z`。
- Canonical issues：`MTP-82`、`MTP-83`、`MTP-84`、`MTP-85`、`MTP-86`、`MTP-87`、`MTP-88` 全部 `Done/type=completed`。
- Project 末端 PR：`MTP-88` PR #173，merge commit `50ea5a897c990a6ba54ba0049d156b088a77d64f`，GitHub required check `checks` 成功 run `https://github.com/atxinbao/MTPRO/actions/runs/26300102977/job/77422757483`。
- MTP-87 临时失败为 PR 过程中的 readiness exact-string anchor 缺失；后续 commit `effc4b6` 修复，PR #172 最终 checks 通过并 squash merge，merge commit `56e105f0855a182a93780a8beceaef9449d6db49`。

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear issue body 或 issue status。
- 不推进 Todo。
- 不启动 Symphony 或 `symphony-issue`。
- 不运行 Graphify update。
- 不写业务代码。
- 不实现 API key、secret storage、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、真实 live risk engine、real pre-trade allow / reject runtime、真实账户读取、broker position sync、margin、leverage、PnL、equity、circuit breaker command、stop trading command、emergency stop、risk command surface、order form、live command 或交易按钮。
- Root Docs Refresh Gate 仍为 pending；下一步只允许基于本报告做事实同步，不授权下一阶段 planning 或 execution。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | docs-only diff 无空白错误；新 Stage Code Audit Report 通过 intent-to-add 纳入检查范围。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=37; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；184 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

---

## 2026-05-28 — MTP-133 Account / Position / Balance Read-model-only Terminology Boundary

执行者：Codex

目的：

- 执行 Linear issue `MTP-133 Define account / position / balance read-model-only terminology and boundary`。
- 建立 L3.1 account / position / balance read-model-only terminology、source semantics boundary、evidence interpretation boundary、L3.1 / L3.2 handoff、forbidden capability baseline、first executable candidate non-authorization 和 validation anchors。
- 明确 MTP-133 是 terminology / contract / validation anchor 层，不实现 account / position / balance runtime。

更新内容：

- 新增 `docs/contracts/account-position-balance-read-model-only-contract.md`。
- 更新 `docs/domain/context.md`，新增 Account / Position / Balance Read-model-only Terms。
- 更新 `docs/validation/trading-validation-matrix.md`，新增 `TVM-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY` 和 MTP-133 issue backfill。
- 更新 `docs/validation/validation-plan.md`，新增 MTP-133 required validation 与禁止项。
- 更新 `docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，新增 MTP-133 mechanical anchors。
- 更新 `docs/validation/latest-verification-summary.md`，记录 MTP-133 当前 issue execution evidence。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 278 个 XCTest；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不推进 MTP-134。
- 不创建下一 Project / Issue。
- 不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 account / position / balance runtime、Live read-only runtime、private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、margin、leverage、buying power 或 real PnL。
- 不实现 signed endpoint、account endpoint / listenKey、private WebSocket、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。

## MTPRO Live Risk Gate Contract v1 Root Docs Refresh Gate closure

日期：2026-05-23

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 在 Stage Code Audit Report PR #175 合并后，关闭 `MTPRO Live Risk Gate Contract v1` 的 Root Docs Refresh Gate。
- 只同步已发生事实，把 Final Product Goal Progress 从 `7 / 9 (78%)` 更新为 `8 / 9 (89%)`。
- 记录 Live Risk Gate Contract 已完成 contract + blocked evidence，但不代表真实 live risk engine、真实账户风控、real pre-trade allow / reject runtime、risk command、stop command、emergency stop 或 production runtime 已实现。

Root docs refresh 逐项结论：

| 文档 | 结论 | 原因 |
| --- | --- | --- |
| `GOAL.md` | updated | Final Product Goal Progress 更新为 `8 / 9 (89%)`，并明确 Live Risk Gate 只完成 contract + blocked evidence。 |
| `BLUEPRINT.md` | updated | Live Risk Control 更新为 `Complete / contract + blocked evidence`，Future Incident Replay / Stop Controls 仍为 Future Gated。 |
| `environment.md` | no update needed | 本 Project 未新增 validation 入口、secret、broker credential、signed endpoint、account endpoint、listenKey、真实账户读取或网络必需验证。 |
| `architecture.md` | updated | 新增 LiveRiskGate read-model-only blocked evidence flow 和真实 live risk runtime / command 禁区。 |
| `docs/roadmap.md` | updated | Project Closure Count 更新为 `11 / 11`，Final Product Goal Progress 更新为 `8 / 9 (89%)`。 |
| `docs/validation/latest-verification-summary.md` | updated | 记录 Root Docs Refresh Gate closure、当前进度口径、Stage Code Audit Report 状态和 boundary evidence。 |
| `checks/automation-readiness.sh` | updated | Final Product Goal Progress readiness anchor 更新为 `8 / 9 (89%)`，并检查 Live Risk Gate audit closure。 |
| `docs/audit/mtpro-live-risk-gate-contract-v1-stage-code-audit.md` | updated | Root Docs Delta 从 pending input 更新为 closure evidence。 |
| `verification.md` | updated | 追加本 compact record。 |

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear issue body 或 issue status。
- 不推进 Todo。
- 不启动 Symphony 或 `symphony-issue`。
- 不运行 Graphify update。
- 不修改 Figma。
- 不写业务代码。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 API key、secret storage、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、真实 live risk engine、真实账户风控、real pre-trade allow / reject runtime、真实账户余额读取、broker position sync、margin、leverage、PnL、equity、circuit breaker command、stop trading command、emergency stop、risk command surface、order form、live command 或交易按钮。
- 下一阶段方向、目标、架构路线和优先级仍交给 Human + `@001 / PLN`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Root Docs Refresh Gate docs-only PR 创建前执行，通过。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=37; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；184 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTPRO Live Audit Incident Stop Boundary v1 planning record

日期：2026-05-23

执行者：Codex（`@000 / AIE`）

目的：

- 将 Human 确认的 `MTPRO Live Audit Incident Stop Boundary v1` planning draft 落仓为 docs-only Project Planning Record。
- 记录 Final Product Goal Slice #9 的写入 Linear 前计划摘要、issue order、dependencies、validation requirements、evidence requirements、first executable issue candidate、WIP=1 和边界。
- 明确该 planning record 不授权执行，不创建 Linear Project / Issue，不推进 Todo，不启动 `@002 / PAR`、Symphony 或 Graphify。

文件范围：

- `docs/planning/projects/mtpro-live-audit-incident-stop-boundary-v1-plan.md`
- `docs/planning/linear-draft-plan.md`
- `docs/validation/latest-verification-summary.md`
- `BLUEPRINT.md`
- `verification.md`

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear issue body 或 issue status。
- 不推进 Todo。
- 不启动 `@002 / PAR`、Symphony 或 `symphony-issue`。
- 不运行 Graphify update。
- 不修改 Figma。
- 不写业务代码。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不把 Future Live trading 写成当前 execution scope。
- 不把 Live PRO Console 写成当前可实现产品面。
- 不实现 incident replay runtime、emergency stop、shutdown、restore、production operations、broker action、signed endpoint、account endpoint / listenKey、OMS、real order state machine、`LiveExecutionAdapter`、交易按钮或 live command。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | docs-only diff 无空白错误；新 planning record 已通过 intent-to-add 纳入检查范围。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=37; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；184 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTP-89 Live Audit / Incident / Stop Terminology and Taxonomy

日期：2026-05-23

执行者：Codex（`@002 / PAR` supervised issue execution）

目的：

- 执行 Linear `MTP-89 定义 Live audit / incident / stop terminology 和 taxonomy`。
- 只定义 Future / gated terminology、future audit / incident / stop taxonomy、forbidden capability baseline、blocked evidence source anchors 和 validation anchors。
- 为 MTP-90 至 MTP-95 提供可复用 validation anchors，不启动后续 issue，不推进 MTP-90..MTP-95。

Preflight：

- Linear `MTP-89` 为唯一 `Todo`。
- `MTP-90` 至 `MTP-95` 仍为 `Backlog / non-executable`。
- `In Progress = 0`，`In Review = 0`，WIP=1 satisfied。
- Issue body 已作为唯一 execution contract 读取并执行。

文件范围：

- `Sources/Core/LiveAuditIncidentStopContract.swift`
- `Tests/CoreTests/CoreTests.swift`
- `docs/contracts/live-audit-incident-stop-contract.md`
- `docs/domain/context.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/validation-plan.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

关键证据：

- 新增 `LiveAuditIncidentStopTerm`、`FutureAuditIncidentStopTaxonomyTerm`、`LiveAuditIncidentStopFutureGate`、`LiveAuditIncidentStopForbiddenCapability`、`LiveAuditIncidentStopEvidenceKind` 和 `LiveAuditIncidentStopTerminologyBoundary`。
- 新增 anchors：`MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY`、`MTP-89-FUTURE-AUDIT-INCIDENT-STOP-TAXONOMY`、`MTP-89-BLOCKED-EVIDENCE-ONLY-FUTURE-GATES`、`MTP-89-NO-INCIDENT-REPLAY-OR-STOP-COMMAND`、`MTP-89-NO-LIVE-PRO-CONSOLE-SURFACE`、`MTP-89-LIVE-AUDIT-INCIDENT-STOP-VALIDATION` 和 `TVM-LIVE-AUDIT-INCIDENT-STOP`。
- Focused tests：`testLiveAuditIncidentStopTerminologyDefinesMTP89FutureOnlyTaxonomy`、`testLiveAuditIncidentStopTerminologyRejectsMTP89RuntimeCommandAndConsoleBypass` 和 `testLiveAuditIncidentStopTerminologyKeepsMTP89BlockedEvidenceFutureOnly`。
- `checks/automation-readiness.sh` 已机械检查 MTP-89 contract、domain context、validation matrix、validation plan、latest summary、Core source 和 focused test anchors。

边界确认：

- 不修改 Linear issue body 或 status。
- 不推进 MTP-90..MTP-95。
- 不启动 Symphony 或 `symphony-issue`。
- 不运行 Graphify update。
- 不修改 Figma。
- 不实现 API key、secret storage、signed endpoint、account endpoint、listenKey、broker action、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order state machine、real order submit / cancel / replace、execution report runtime、broker fill runtime、reconciliation runtime、audit trail runtime、incident replay runtime、stop control runtime、emergency stop command、shutdown command、restore command、production operations runtime、Live PRO Console、live command、order-level command UI、order form、trading button 或 Workbench / Dashboard 到 Live PRO Console 的升级。
- `.codex/*` 和 `graphify-out/*` 未进入 PR scope。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter LiveAuditIncidentStop` | pass | 3 个 MTP-89 focused Core tests 通过，0 failures。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `git diff --check` | pass | 对新增文件执行 intent-to-add 后检查通过。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=37; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；187 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTP-90 Live Audit Trail Future Gates

日期：2026-05-23

执行者：Codex（`@002 / PAR` supervised issue execution）

目的：

- 执行 Linear `MTP-90 定义 signal / order / risk decision / fill audit trail future gates 和 forbidden capability tests`。
- 只定义 signal、order、risk decision、fill audit trail future gates、forbidden capability tests、paper evidence no real audit fact upgrade 和 validation anchors。
- 不启动 MTP-91..MTP-95，不推进下一 issue。

Preflight：

- Linear `MTP-90` 为唯一 `In Progress` active issue。
- Linear `MTP-89` 为 `Done`。
- `MTP-91` 至 `MTP-95` 仍为 `Backlog / non-executable`。
- WIP=1 satisfied。
- Issue body 已作为唯一 execution contract 读取并执行。

文件范围：

- `Sources/Core/LiveAuditIncidentStopContract.swift`
- `Tests/CoreTests/CoreTests.swift`
- `docs/contracts/live-audit-incident-stop-contract.md`
- `docs/domain/context.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/validation-plan.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

关键证据：

- 新增 `LiveAuditTrailSubject`、`LiveAuditTrailFutureGate`、`LiveAuditTrailForbiddenCapability` 和 `LiveAuditTrailFutureGateBoundary`。
- 新增 anchors：`MTP-90-SIGNAL-ORDER-RISK-FILL-AUDIT-TRAIL-FUTURE-GATES`、`MTP-90-FORBIDDEN-EXECUTION-REPORT-BROKER-FILL-OMS-TESTS`、`MTP-90-NO-REAL-ORDER-STATE-MACHINE-OR-BROKER-ACTION`、`MTP-90-PAPER-EVIDENCE-NO-REAL-AUDIT-FACT-UPGRADE`、`MTP-90-LIVE-AUDIT-TRAIL-VALIDATION` 和 `TVM-LIVE-AUDIT-INCIDENT-STOP`。
- Focused tests：`testMTP90LiveAuditTrailFutureGatesDefineSignalOrderRiskDecisionFillBoundary`、`testMTP90LiveAuditTrailFutureGatesRejectExecutionReportBrokerFillOMSAndBrokerAction` 和 `testMTP90LiveAuditTrailFutureGatesKeepPaperEvidenceFromBecomingRealAuditFact`。
- `checks/automation-readiness.sh` 已机械检查 MTP-90 contract、domain context、validation matrix、validation plan、latest summary、Core source 和 focused test anchors。

边界确认：

- 不修改 Linear issue body 或 status。
- 不推进 MTP-91..MTP-95。
- 不启动 Symphony 或 `symphony-issue`。
- 不运行 Graphify update。
- 不修改 Figma。
- 不实现真实 audit trail runtime、execution report parser / ingestion、broker fill recorder、broker fill fact、OMS、real order state machine、broker reconciliation、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、live command、order-level command UI、order form 或 trading button。
- 不把 strategy signal、`PaperOrderIntent`、`PaperExecutionDecision`、`RiskBlockerEvidence`、`PaperSimulatedFillEvidence`、execution-control blocked evidence 或 risk-gate blocked evidence 升级为真实 audit fact。
- `.codex/*` 和 `graphify-out/*` 未进入 PR scope。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP90` | pass | 3 个 MTP-90 focused Core tests 通过，0 failures。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=37; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；190 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTP-91 Incident Replay Future Gates

日期：2026-05-23

执行者：Codex（`@002 / PAR` supervised issue execution）

目的：

- 执行 Linear `MTP-91 定义 incident replay future gates 和 forbidden capability tests`。
- 只定义 incident replay input source、replay scope、replay evidence、replay output future gates、forbidden capability tests 和 deterministic replay no production recovery anchors。
- 不启动 MTP-92..MTP-95，不推进下一 issue。

Preflight：

- Linear `MTP-91` 为唯一 `In Progress` active issue。
- Linear `MTP-89`、`MTP-90` 为 `Done`。
- `MTP-92` 至 `MTP-95` 仍为 `Backlog / non-executable`。
- WIP=1 satisfied。
- Issue body 已作为唯一 execution contract 读取并执行。

文件范围：

- `Sources/Core/LiveAuditIncidentStopContract.swift`
- `Tests/CoreTests/CoreTests.swift`
- `docs/contracts/live-audit-incident-stop-contract.md`
- `docs/domain/context.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/validation-plan.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

关键证据：

- 新增 `LiveIncidentReplayFutureGate`、`LiveIncidentReplayForbiddenCapability` 和 `LiveIncidentReplayFutureGateBoundary`。
- 新增 anchors：`MTP-91-INCIDENT-REPLAY-FUTURE-GATES`、`MTP-91-INCIDENT-REPLAY-INPUT-SOURCE-GATES`、`MTP-91-REPLAY-SCOPE-EVIDENCE-OUTPUT-GATES`、`MTP-91-FORBIDDEN-RECOVERY-BROKER-ACCOUNT-REPLAY-TESTS`、`MTP-91-DETERMINISTIC-REPLAY-NO-PRODUCTION-RECOVERY`、`MTP-91-INCIDENT-REPLAY-VALIDATION` 和 `TVM-LIVE-AUDIT-INCIDENT-STOP`。
- Focused tests：`testMTP91IncidentReplayFutureGatesDefineInputScopeEvidenceOutputBoundary`、`testMTP91IncidentReplayFutureGatesRejectRuntimeRecoveryBrokerAndAccountReplay` 和 `testMTP91IncidentReplayFutureGatesKeepCurrentReplayDeterministicEvidenceOnly`。
- `checks/automation-readiness.sh` 已机械检查 MTP-91 contract、domain context、validation matrix、validation plan、latest summary、Core source 和 focused test anchors。

边界确认：

- 不修改 Linear issue body 或 status。
- 不推进 MTP-92..MTP-95。
- 不启动 Symphony 或 `symphony-issue`。
- 不运行 Graphify update。
- 不修改 Figma。
- 不实现 incident replay runtime、production recovery runtime、auto restore / auto rollback runtime、broker replay runtime、account replay runtime、broker state reader、real account state reader、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order state machine、execution report ingestion、broker fill fact、audit trail runtime、production operations runtime、Live PRO Console、live command、order-level command UI、order form 或 trading button。
- 不把当前 `Event Log` / `Replay` 升级为生产事故回放、生产恢复、broker replay、account replay、auto restore、auto rollback 或 live runtime resume。
- `.codex/*` 和 `graphify-out/*` 未进入 PR scope。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP91` | pass | 3 个 MTP-91 focused Core tests 通过，0 failures。 |
| `bash checks/automation-readiness.sh` | pass | 第一次因历史 literal anchor `MTP-90 issue backfill` 漂移失败；恢复该 anchor 后输出 `MTPRO automation readiness checks passed.`。 |
| `git diff --check` | pass | 当前 diff whitespace 检查通过。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=37; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；193 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTP-92 Stop / Shutdown / Restore Future Gates

日期：2026-05-23

执行者：Codex（`@002 / PAR` supervised issue execution）

目的：

- 执行 Linear `MTP-92 定义 emergency stop / shutdown / restore future gates 和 forbidden capability tests`。
- 只定义 emergency stop、shutdown、restore future gates、forbidden capability tests、risk circuit breaker / no-trade separation anchors 和 deterministic Core evidence。
- 不启动 MTP-93..MTP-95，不推进下一 issue。

Preflight：

- Linear `MTP-92` 为唯一 `In Progress` active issue。
- Linear `MTP-89`、`MTP-90`、`MTP-91` 为 `Done`。
- `MTP-93` 至 `MTP-95` 仍为 `Backlog / non-executable`。
- WIP=1 satisfied。
- Issue body 已作为唯一 execution contract 读取并执行。

文件范围：

- `Sources/Core/LiveAuditIncidentStopContract.swift`
- `Tests/CoreTests/CoreTests.swift`
- `docs/contracts/live-audit-incident-stop-contract.md`
- `docs/domain/context.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/validation-plan.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

关键证据：

- 新增 `LiveStopShutdownRestoreFutureGate`、`LiveStopShutdownRestoreForbiddenCapability` 和 `LiveStopShutdownRestoreFutureGateBoundary`。
- 新增 anchors：`MTP-92-EMERGENCY-STOP-SHUTDOWN-RESTORE-FUTURE-GATES`、`MTP-92-FORBIDDEN-STOP-SHUTDOWN-RESTORE-CAPABILITY-TESTS`、`MTP-92-NO-LIVE-RISK-CIRCUIT-BREAKER-OR-NO-TRADE-UPGRADE`、`MTP-92-NO-BROKER-SESSION-MUTATION-OR-PRODUCTION-SHUTDOWN`、`MTP-92-STOP-SHUTDOWN-RESTORE-VALIDATION` 和 `TVM-LIVE-AUDIT-INCIDENT-STOP`。
- Focused tests：`testMTP92StopShutdownRestoreFutureGatesDefineFutureOnlyBoundary`、`testMTP92StopShutdownRestoreFutureGatesRejectCommandsBrokerMutationAndProductionOperations` 和 `testMTP92StopShutdownRestoreFutureGatesKeepRiskCircuitBreakerAndNoTradeSeparate`。
- `checks/automation-readiness.sh` 已机械检查 MTP-92 contract、domain context、validation matrix、validation plan、latest summary、Core source 和 focused test anchors。

边界确认：

- 不修改 Linear issue body 或 status。
- 不推进 MTP-93..MTP-95。
- 不启动 Symphony 或 `symphony-issue`。
- 不运行 Graphify update。
- 不修改 Figma。
- 不实现 emergency stop command、shutdown command、restore command、stop control runtime、production shutdown control、production operations runtime、global trading lock、broker session mutation、broker action、signed endpoint、account endpoint、listenKey、`LiveExecutionAdapter`、OMS、real order state machine、live risk engine、circuit breaker runtime、no-trade state runtime、restore decision runtime、live runtime resume、Live PRO Console、live command、order-level command UI、stop button、order form 或 trading button。
- 不把 `LiveCircuitBreakerNoTradeGateBoundary`、risk gate blocked evidence、circuit breaker 或 no-trade state 升级为当前 emergency stop、shutdown、restore、global trading lock、broker session mutation 或 production shutdown control。
- `.codex/*` 和 `graphify-out/*` 未进入 PR scope。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP92` | pass | 第二次运行通过 3 个 MTP-92 focused Core tests，0 failures；第一次仅因测试引用既有属性名错误失败，修正后通过。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=37; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；196 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTP-93 Blocked Evidence Incident / Stop Isolation

日期：2026-05-23

执行者：Codex（`@002 / PAR` supervised issue execution）

目的：

- 执行 Linear `MTP-93 定义 Live risk / execution blocked evidence 与 future incident / stop boundary 的隔离合同`。
- 只定义 `LiveExecutionControlBlockedEvidence`、`LiveRiskGateBlockedEvidence` 和 paper-only evidence 与 future incident / stop boundary 的隔离合同。
- 不启动 MTP-94 或 MTP-95，不推进下一 issue。

Preflight：

- Linear `MTP-93` 为唯一 `In Progress` active issue。
- Linear `MTP-89`、`MTP-90`、`MTP-91`、`MTP-92` 为 `Done`。
- `MTP-94` 和 `MTP-95` 仍为 `Backlog / non-executable`。
- WIP=1 satisfied。
- Issue body 已作为唯一 execution contract 读取并执行。

文件范围：

- `Sources/Core/LiveAuditIncidentStopContract.swift`
- `Tests/CoreTests/CoreTests.swift`
- `docs/contracts/live-audit-incident-stop-contract.md`
- `docs/domain/context.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/validation-plan.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

关键证据：

- 新增 `LiveBlockedEvidenceIncidentStopIsolationGate`、`LiveBlockedEvidenceIncidentStopForbiddenCapability` 和 `LiveBlockedEvidenceIncidentStopIsolationBoundary`。
- 新增 anchors：`MTP-93-LIVE-RISK-EXECUTION-BLOCKED-EVIDENCE-ISOLATION`、`MTP-93-NO-BLOCKED-EVIDENCE-TO-INCIDENT-OR-STOP-COMMAND-UPGRADE`、`MTP-93-PAPER-EVIDENCE-NO-INCIDENT-STOP-UPGRADE`、`MTP-93-FORBIDDEN-COMMAND-RUNTIME-UPGRADE-TESTS`、`MTP-93-BLOCKED-EVIDENCE-ISOLATION-VALIDATION` 和 `TVM-LIVE-AUDIT-INCIDENT-STOP`。
- Focused tests：`testMTP93BlockedEvidenceIsolationDefinesReadModelOnlyBoundary`、`testMTP93BlockedEvidenceIsolationRejectsCommandRuntimeAndConsoleUpgrade` 和 `testMTP93BlockedEvidenceIsolationKeepsPaperEvidenceAndReadModelsFromIncidentStopUpgrade`。
- `checks/automation-readiness.sh` 已机械检查 MTP-93 contract、domain context、validation matrix、validation plan、latest summary、Core source 和 focused test anchors。

边界确认：

- 不修改 Linear issue body 或 status。
- 不推进 MTP-94 或 MTP-95。
- 不启动 Symphony 或 `symphony-issue`。
- 不运行 Graphify update。
- 不修改 Figma。
- 不实现 incident command、stop command、shutdown command、restore command、incident replay runtime、execution runtime、live risk engine、production operations runtime、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order state machine、Live PRO Console、live command、order-level command UI、stop button、order form 或 trading button。
- 不把 `LiveExecutionControlBlockedEvidence`、`LiveRiskGateBlockedEvidence`、`PaperOrderIntent`、`PaperSimulatedFillEvidence`、`RiskBlockerEvidence` 或 `PortfolioExposureSnapshot` 升级为 incident / stop command、restore decision、production incident fact、broker fill fact、real account state 或 future live risk decision。
- `.codex/*` 和 `graphify-out/*` 未进入 PR scope。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP93` | pass | 3 个 MTP-93 focused Core tests 通过，0 failures。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=37; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；199 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTP-94 Live Incident / Stop Blocked Evidence

日期：2026-05-23

执行者：Codex（`@002 / PAR` supervised issue execution）

目的：

- 执行 Linear `MTP-94 新增 read-model-only LiveIncidentStopBlockedEvidence 或等价模型，并接入 Dashboard / Report / Event Timeline`。
- 只新增 audit trail、incident replay、emergency stop、shutdown 和 restore 的 read-model-only blocked evidence、deterministic fixture / snapshot 和只读展示面。
- 不启动 MTP-95，不推进下一 issue。

Preflight：

- Linear `MTP-94` 为唯一 `In Progress` active issue。
- Linear `MTP-89`、`MTP-90`、`MTP-91`、`MTP-92`、`MTP-93` 为 `Done`。
- `MTP-95` 仍为 `Backlog / non-executable`。
- WIP=1 satisfied。
- Issue body 已作为唯一 execution contract 读取并执行。

文件范围：

- `Sources/Core/LiveAuditIncidentStopContract.swift`
- `Sources/App/LiveIncidentStopBlockedEvidence.swift`
- `Sources/App/App.swift`
- `Sources/App/PaperWorkflowEvidenceExplorer.swift`
- `Sources/App/DashboardShell.swift`
- `Tests/CoreTests/CoreTests.swift`
- `Tests/AppTests/AppTests.swift`
- `docs/contracts/live-audit-incident-stop-contract.md`
- `docs/domain/context.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/validation-plan.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

关键证据：

- 新增 `LiveIncidentStopBlockedGate`、`LiveIncidentStopBlockedReason`、`LiveIncidentStopBlockedEvidenceItem` 和 `LiveIncidentStopBlockedEvidence`。
- 新增 `LiveIncidentStopBlockedEvidenceReadModel`、`LiveIncidentStopBlockedEvidenceViewModel` 和 5 条 Event Timeline live incident / stop blocked evidence items。
- Dashboard smoke 新增 `liveIncidentStopGates=5`，empty snapshot `timelineItems=42`。
- 新增 anchors：`MTP-94-LIVE-INCIDENT-STOP-BLOCKED-EVIDENCE`、`MTP-94-AUDIT-INCIDENT-STOP-BLOCKED-REASONS`、`MTP-94-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT`、`MTP-94-READ-MODEL-ONLY-NO-COMMAND-SURFACE`、`MTP-94-LIVE-INCIDENT-STOP-VALIDATION` 和 `TVM-LIVE-AUDIT-INCIDENT-STOP`。
- Focused tests：`testMTP94LiveIncidentStopBlockedEvidenceDefinesReadModelOnlySnapshot`、`testMTP94LiveIncidentStopBlockedEvidenceRejectsCommandRuntimeAndConsoleSurface`、`testMTP94LiveIncidentStopBlockedEvidenceReferencesPriorFutureGateBoundaries`、`testLiveIncidentStopBlockedEvidenceViewModelAggregatesMTP94ReadOnlySurface` 和 `testLiveIncidentStopEvidenceExplorerPreviewDefinesMTP94ReadOnlyTimelineItems`。
- `checks/automation-readiness.sh` 已机械检查 MTP-94 contract、domain context、validation matrix、validation plan、latest summary、Core/App source、Dashboard / Event Timeline wiring 和 focused test anchors。

边界确认：

- 不修改 Linear issue body 或 status。
- 不推进 MTP-95。
- 不启动 Symphony 或 `symphony-issue`。
- 不运行 Graphify update。
- 不修改 Figma。
- 不实现 audit trail runtime、incident replay runtime、stop control runtime、emergency stop command、shutdown command、restore command、production operations runtime、production shutdown control、broker session mutation、restore decision runtime、live runtime resume、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order state machine、execution runtime、live risk engine、audit service、broker replay、account replay 或 production recovery。
- 不把 Dashboard、Report、Workbench、Event Timeline 或 Evidence Explorer 升级为 Live PRO Console、operator workflow、command model、adapter status、runtime status 或 database schema browser。
- 不新增 live command、order-level command UI、stop button、order form、交易按钮或真实交易授权。
- `.codex/*` 和 `graphify-out/*` 未进入 PR scope。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP94` | pass | 5 个 MTP-94 focused Core / App tests 通过，0 failures。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `DASHBOARD_SMOKE=1 swift run Dashboard` | pass | Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；204 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## MTP-95 Live Audit Incident Stop Boundary stage closeout

日期：2026-05-23

执行者：Codex（`@002 / PAR` supervised issue execution）

目的：

- 执行 Linear `MTP-95 收口 validation matrix、automation readiness 和 stage audit input material`。
- 只收口 validation matrix、automation readiness anchors、forbidden capability evidence、read-model-only boundary evidence、Dashboard smoke evidence 和 Stage Code Audit 输入材料。
- 不输出最终 Stage Code Audit Report，不启动下一阶段，不推进下一 Project / Issue。

Preflight：

- Linear `MTP-95` 为唯一 `In Progress` active issue。
- Linear `MTP-89`、`MTP-90`、`MTP-91`、`MTP-92`、`MTP-93`、`MTP-94` 为 `Done`。
- WIP=1 satisfied。
- Issue body 已作为唯一 execution contract 读取并执行。

文件范围：

- `docs/audit/inputs/mtpro-live-audit-incident-stop-boundary-v1-stage-audit-input.md`
- `docs/contracts/live-audit-incident-stop-contract.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/validation-plan.md`
- `docs/validation/latest-verification-summary.md`
- `docs/automation/automation-readiness.md`
- `checks/automation-readiness.sh`
- `verification.md`

关键证据：

- 新增 `MTP-95-LIVE-AUDIT-INCIDENT-STOP-STAGE-AUDIT-INPUT` stage audit input material。
- 新增 `MTP-95-LIVE-AUDIT-INCIDENT-STOP-STAGE-CLOSEOUT`、`MTP-95-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-95-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-95-LIVE-AUDIT-INCIDENT-STOP-VALIDATION-EVIDENCE-CHAIN` 和 `MTP-95-AUTOMATION-READINESS-STAGE-CLOSEOUT` contract / validation anchors。
- Stage audit input 汇总 PR #178 至 #183 的 merge commit、GitHub required check 和 Live audit incident stop evidence chain，并保留当前 MTP-95 PR / merge commit 待 GitHub PR Automation 产生。
- Automation readiness 已机械检查 stage input、contract、matrix、validation plan、latest summary、Core/App source anchors、Core/App deterministic tests、Dashboard smoke `liveIncidentStopGates=5` 和 PR evidence chain。

边界确认：

- 不修改 Linear issue body 或 status。
- 不创建下一 Project / Issue，不推进下一阶段，不启动下一阶段 `symphony-issue`。
- 不运行 Graphify update。
- 不修改 production code。
- 不输出最终 Stage Code Audit Report。
- 不实现 audit trail runtime、incident replay runtime、broker replay runtime、account replay runtime、production recovery runtime、stop control runtime、emergency stop command、shutdown command、restore command、production operations runtime、production shutdown control、global trading lock、broker session mutation、restore decision runtime、live runtime resume、Live PRO Console、live command、order-level command UI、stop button、order form、trading button、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS 或 real order state machine。
- `.codex/*` 和 `graphify-out/*` 未进入 PR scope。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；204 个 XCTest 通过、0 failures，最终输出 `MTPRO checks passed.`。 |

## MTPRO Live Audit Incident Stop Boundary v1 Stage Code Audit Report

日期：2026-05-23

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 在 `MTP-89` 至 `MTP-95` 全部 Linear `Done` 且 Project 标记为 `Completed/type=completed` 后，落仓 canonical Stage Code Audit Report。
- 输出 `docs/audit/mtpro-live-audit-incident-stop-boundary-v1-stage-code-audit.md`。
- 更新 `docs/validation/latest-verification-summary.md`，指向 canonical Stage Code Audit Report。
- 本轮只做 Stage Code Audit Report 落仓，不执行 Root Docs Refresh Gate，不更新 Final Product Goal Progress。

关键证据：

- Linear Project：`MTPRO Live Audit Incident Stop Boundary v1`。
- Linear Project ID：`04cc5673-0eda-4ef1-aaa2-da55084be0ef`。
- Linear Project status：`Completed/type=completed`，state `completed`，`completedAt=2026-05-22T22:20:10.884Z`。
- Canonical issues：`MTP-89`、`MTP-90`、`MTP-91`、`MTP-92`、`MTP-93`、`MTP-94`、`MTP-95` 全部 `Done/type=completed`。
- PR evidence：#178、#179、#180、#181、#182、#183、#184 均已通过 GitHub required check `checks` 后 squash merge。
- Project 末端 merge commit：`fab605c24c9eb2a1381a484d930213baf8c38214`。
- Post-Issue Ledger：MTP-95 `git_pull_ff_only` passed，`graphify_update` passed，`graphify-out/*` 未提交。

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear issue body。
- 不推进任何 issue 到 `Todo`。
- 不启动 Symphony 或 `symphony-issue`。
- 不运行 Graphify update；Graphify evidence 只来自 Post-Issue Ledger。
- 不写业务代码。
- 不修改 root docs factual progress；Root Docs Refresh Gate 保持 pending。
- 不实现 audit trail runtime、incident replay runtime、broker replay runtime、account replay runtime、production recovery runtime、stop control runtime、emergency stop command、shutdown command、restore command、production operations runtime、Live PRO Console、live command、order form、stop button、trading button、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS 或 real order state machine。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Stage Code Audit Report docs-only PR 创建前执行；无 whitespace / patch error 输出。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；204 个 XCTest 通过、0 failures，最终输出 `MTPRO checks passed.`。 |

## MTPRO Live Audit Incident Stop Boundary v1 Root Docs Refresh Gate

日期：2026-05-23

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 基于 `docs/audit/mtpro-live-audit-incident-stop-boundary-v1-stage-code-audit.md` 关闭 Root Docs Refresh Gate。
- 只同步已发生事实，不创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 Symphony，不运行 Graphify update，不写业务代码。
- 更新 Current Foundation Progress 和 Final Product Goal Progress 的当前事实口径。

Root docs 判断：

| 文档 | 结果 | 原因 |
| --- | --- | --- |
| `GOAL.md` | updated | Final Product Goal Progress 从 `8 / 9 (89%)` 更新为 `9 / 9 (100%)`，并补充 Slice #9 的 contract + blocked evidence 边界。 |
| `BLUEPRINT.md` | updated | Final Product Goal Slice #9、Current / Future Boundary 和最近完成 construction scope 已同步 `MTPRO Live Audit Incident Stop Boundary v1` 完成事实。 |
| `environment.md` | no update needed | 本 Project 未新增 required validation、secret、broker credential、signed endpoint、account endpoint、listenKey、真实账户读取、网络必需验证或外部写能力。 |
| `architecture.md` | updated | Engineering Module Map / Capability Flow Map 已补充 `LiveIncidentStop` / `LiveIncidentStopBlockedEvidence` read-model-only 边界。 |
| `docs/roadmap.md` | updated | Completed Project Map、Project Closure Count、Final Product Goal Progress、Product Route 和 Live Route Gates 已同步 Slice #9 closure。 |
| `docs/validation/latest-verification-summary.md` | updated | 当前基线、canonical Stage Code Audit Report 引用和 Goal / Roadmap Progress Baseline 已同步 Root Docs Refresh Gate closure。 |
| `checks/automation-readiness.sh` | updated | progress anchor 更新为 `9 / 9 (100%)`，并加入 Live Audit Incident Stop audit report closure anchor。 |
| Stage Code Audit Report | updated | `Root Docs Delta` 更新为 closure 结果，`Root Docs Refresh Gate closure：closed`。 |

进度口径：

- Current Foundation Progress：`4 / 4 (100%)`。
- Final Product Goal Progress：`9 / 9 (100%)`。
- Project Closure Count：`12 / 12 (100%)`。
- 该进度只表示当前已批准、已执行、已 closure 的目标切片和 Project 证据口径，不把 Future Construction Zones 自动授权为下一阶段 execution。

边界确认：

- 不实现真实 Live trading、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order state machine、execution runtime、live risk engine、audit trail runtime、incident replay runtime、emergency stop、shutdown、restore、production operations、Live PRO Console、live command、order form、stop button 或交易按钮。
- 下一阶段方向、目标、架构路线和优先级仍交给 Human + `@001 / PLN`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Root Docs Refresh Gate docs-only PR 创建前执行；无 whitespace / patch error 输出。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；204 个 XCTest 通过、0 failures，最终输出 `MTPRO checks passed.`。 |

## MTPRO Reference Alignment & Product Gap Map v1

日期：2026-05-25

执行者：Codex

目的：

- 在 Final Product Goal Progress 达到 `9 / 9 (100%)` 后，对齐参考项目 `atxinbao/nautilus_trader`，识别 MTPRO 当前 Workbench baseline 与成熟交易系统参考之间的产品、架构、体验和发布差距。
- 补充 Product Surface Map、Engineering Capability Map、Maturity Gap Map 和 Non-authorization Boundary Map。
- 输出产品层 reference alignment / gap map，作为现有地图补充材料；本轮不生成下一阶段 Project Draft。

参考快照：

- Reference project：`https://github.com/atxinbao/nautilus_trader`。
- Clone path：`/tmp/mtpro-reference-nautilus`。
- Snapshot：`develop` commit `6e059dc Improve Blockchain snapshot fail-closed path`。
- 读取依据：`README.md`、`ROADMAP.md`、`ADAPTERS.md`、`RELEASES.md`、`docs/concepts/architecture.md`、`docs/concepts/backtesting.md`、`docs/concepts/execution.md`、`docs/concepts/live.md`、`docs/concepts/event_sourcing.md`、`examples/backtest/*` 和 `examples/live/*`。

文件范围：

- `docs/product/mtpro-reference-alignment-gap-map-v1.md`
- `docs/product/product-surface-map.md`
- `BLUEPRINT.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

关键结论：

- MTPRO v1 当前完成的是 local-first macOS Workbench 的 contract / evidence / design baseline，不是 NautilusTrader 级别的 production trading engine。
- NautilusTrader 的主要参考价值在 engine runtime、research / simulation / live parity、多 venue adapters、OMS / risk / execution、reconciliation、release operations 和 examples。
- MTPRO 的当前优势在 macOS native Workbench、business dashboard、read-model evidence、Paper-only controls、Future Live boundaries 和 Workbench / Live PRO Console 产品面分离。
- 当前重点是补现有地图，不急于推进下一阶段任务；`Workbench Productization`、`Release / Beta Readiness` 和 `Engine Parity Hardening` 只作为差距地图分区标签。
- `Future Live PRO Console` 仍必须等待新的 Human decision、独立 Project Definition 和 signed / account / broker / risk / ops gates。

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 `Todo`。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / `symphony-issue`。
- 不运行 Graphify update。
- 不修改 Figma。
- 不写业务代码。
- 不引入 NautilusTrader 作为 runtime dependency。
- 不复制 NautilusTrader 整仓代码。
- 不授权 Future Live trading、Live PRO Console、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、submit / cancel / replace、live risk engine、reconciliation runtime、incident replay runtime、emergency stop、shutdown、restore 或 production operations。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Reference alignment gap map docs-only PR 创建前执行；无 whitespace / patch error 输出。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 保持 read-model-only / workbenchReadModelOnly；204 个 XCTest 通过、0 failures，最终输出 `MTPRO checks passed.`。 |

## MTPRO Codebase Reference Gap Map v1

日期：2026-05-25

执行者：Codex

目的：

- 在 `MTPRO Reference Alignment & Product Gap Map v1` 的产品层对标基础上，分别阅读 MTPRO 与 `atxinbao/nautilus_trader` 代码，补充代码级差距地图。
- 明确 MTPRO 当前代码是 local-first SwiftPM macOS Workbench / evidence shell，参考项目代码是 production-grade event-driven trading engine。
- 将代码级差距归入 Workbench Productization、Data / Backtest Maturity、Runtime / Engine Parity、Release / Beta Readiness 和 Future Live PRO Console Boundary 五类地图。
- 本轮仍只补现有地图，不生成下一阶段 Project Draft，不授权执行。

代码读取范围：

- MTPRO：`Package.swift`、`checks/run.sh`、`Sources/Core/TradingKernel.swift`、`Sources/Core/EventLog.swift`、`Sources/Core/CommandsAndQueries.swift`、`Sources/Core/PaperOrderIntent.swift`、`Sources/Adapters/Adapters.swift`、`Sources/Persistence/Persistence.swift`、`Sources/Runtime/Runtime.swift`、`Sources/App/DashboardShell.swift`、`Sources/App/LiveIncidentStopBlockedEvidence.swift`、`Sources/Dashboard/DashboardApplication.swift`。
- Reference：`/tmp/mtpro-reference-nautilus` `develop` commit `6e059dc Improve Blockchain snapshot fail-closed path`；读取 `Cargo.toml`、`pyproject.toml`、`crates/backtest/src/engine.rs`、`nautilus_trader/backtest/node.py`、`nautilus_trader/system/kernel.py`、`nautilus_trader/live/node.py`、`crates/live/src/builder.rs`、`nautilus_trader/live/execution_client.py`、`nautilus_trader/execution/engine.pxd`、`nautilus_trader/execution/engine.pyx`、`nautilus_trader/live/execution_engine.py`、`nautilus_trader/risk/engine.pxd`、`nautilus_trader/risk/engine.pyx`、`nautilus_trader/portfolio/portfolio.pyx`、`nautilus_trader/persistence/catalog/parquet.py`、`crates/persistence/src/config.rs`、`nautilus_trader/trading/strategy.pxd`、`nautilus_trader/trading/strategy.pyx`。

文件范围：

- 新增 `docs/product/mtpro-codebase-reference-gap-map-v1.md`。
- 更新 `docs/product/mtpro-reference-alignment-gap-map-v1.md`，补充代码级地图引用。
- 更新 `docs/product/product-surface-map.md`，增加代码级 reference gap map 入口。
- 更新 `BLUEPRINT.md`，增加代码级地图来源和 Design Blueprint 引用。
- 更新 `docs/validation/latest-verification-summary.md`，记录代码级 reference gap map 当前事实。
- 更新 `verification.md`，追加本节。

关键结论：

- MTPRO 代码当前完成的是 Workbench / evidence / read-model / paper-only / blocked-evidence baseline，不是 reference project 那种完整交易引擎。
- `nautilus_trader` 参考价值主要在 kernel lifecycle、data / backtest maturity、adapters、execution / OMS、risk runtime、portfolio / accounting、reconciliation、release examples 和 package discipline。
- MTPRO 当前最需要补的是地图：Workbench productization、Data / Backtest maturity、Runtime / Engine parity、Release / Beta readiness 和 Future Live boundary，而不是直接推进下一阶段任务。
- Live execution、OMS、real account / broker position、signed/account/listenKey、live risk runtime、reconciliation runtime、incident replay runtime、emergency stop、shutdown、restore 和 Live PRO Console 仍属于 Future Construction Zones。

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 `Todo`。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / `symphony-issue`。
- 不运行 Graphify update。
- 不修改 Figma。
- 不写业务代码。
- 不引入 NautilusTrader 作为 runtime dependency。
- 不复制 NautilusTrader 整仓代码。
- 不授权 Future Live trading、Live PRO Console、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、submit / cancel / replace、live risk engine、reconciliation runtime、incident replay runtime、emergency stop、shutdown、restore 或 production operations。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 代码级 reference gap map docs-only edits 后执行；无 whitespace / patch error 输出。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 保持 read-model-only / workbenchReadModelOnly；204 个 XCTest 通过、0 failures，最终输出 `MTPRO checks passed.`。 |

## MTPRO Paper Trading Runtime Foundation Blueprint v1

日期：2026-05-25

执行者：Codex

目的：

- 将 `MTPRO Paper Trading Runtime Foundation Blueprint v1` 落仓为产品 / 架构层蓝图文档。
- 将 MTPRO 与 NautilusTrader 的代码级交易运行时差距收敛为 paper-only runtime foundation 地图。
- 吸收 `MTPRO Event-Driven Paper Trading Runtime v1` 计划中的非授权候选方向，但不生成 Linear Project Draft。

文件范围：

- 新增 `docs/product/mtpro-paper-trading-runtime-foundation-blueprint-v1.md`。
- 更新 `docs/product/product-surface-map.md`，增加 paper-only runtime foundation 地图引用。
- 更新 `BLUEPRINT.md`，增加该蓝图来源和 Trading Capability Blueprint 引用。
- 更新 `docs/validation/latest-verification-summary.md`，记录该蓝图已落仓且不授权 execution。
- 更新 `verification.md`，追加本节。

关键结论：

- 该蓝图只定义 paper / sandbox runtime foundation，不实现 Paper runtime。
- `Local Order Manager / paper lifecycle coordinator` 只协调本地 paper lifecycle，不是 OMS、broker router 或真实订单执行器。
- `cancelled locally` 只能由 session close / reset、local expiry 或 deterministic local rule 派生；Workbench UI 不提供单笔 paper order cancel button，也不得解释为真实 cancel command。
- Paper event 命名建议使用 `Paper*Local` / `Paper*Simulated` 前缀，只用于后续 contract / validation 可机械检查，不表示当前授权实现。
- `MTPRO Event-Driven Paper Trading Runtime v1` 只作为 Potential Next Project Candidate；若 Human 后续确认，仍需由 `@001 / PLN` 单独输出 Project Draft，并经 Linear 写入和 Parent Codex queue preflight 才能进入执行。

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 `Todo`。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / `symphony-issue`。
- 不运行 Graphify update。
- 不修改 Figma。
- 不写业务代码。
- 不实现 Paper runtime。
- 不引入 NautilusTrader 作为 runtime dependency。
- 不复制 NautilusTrader 整仓代码。
- 不授权 Future Live trading、Live PRO Console、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation runtime、live risk engine、trading button、live command、emergency stop、shutdown、restore 或 production operations。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Paper Trading Runtime Foundation Blueprint docs-only edits 后执行；无 whitespace / patch error 输出。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 保持 read-model-only / workbenchReadModelOnly；204 个 XCTest 通过、0 failures，最终输出 `MTPRO checks passed.`。 |

## MTPRO Event-Driven Paper Trading Runtime v1 planning record

日期：2026-05-25

执行者：Codex

目的：

- 将 `MTPRO Event-Driven Paper Trading Runtime v1` planning draft 落仓为 docs-only Project Planning Record。
- 承接 `MTPRO Paper Trading Runtime Foundation Blueprint v1`，把 paper-only runtime foundation 转成写入 Linear 前的 Project 级计划摘要。
- 保存 issue order、dependencies、validation requirements、evidence requirements、first executable issue candidate、WIP=1 / queue preflight rule、Linear write boundary 和 repository record boundary。

文件范围：

- 新增 `docs/planning/projects/mtpro-event-driven-paper-trading-runtime-v1-plan.md`。
- 更新 `docs/planning/linear-draft-plan.md`，增加 planning record 索引并切换当前 Project planning record 指向。
- 更新 `BLUEPRINT.md`，增加该 planning record 引用。
- 更新 `docs/validation/latest-verification-summary.md`，记录该 Project-level planning record 已落仓且不授权 execution。
- 更新 `verification.md`，追加本节。

关键结论：

- 该 planning record 只保存 Project 级计划摘要和格式门槛，不复制维护完整 Linear issue body。
- First executable issue candidate 为 `定义 TradingClock 和 paper runtime kernel boundary`，但该 issue 仍必须保持 `Backlog / non-executable`，不构成执行授权。
- 后续若 Human 确认写入 Linear，仍必须由 Parent Codex queue preflight 在 WIP=1、依赖满足、无 active conflict、execution contract 格式完整时推进唯一 eligible issue。
- 本次不是 Project closure，不更新 Final Product Goal Progress，不更新 `GOAL.md` 或 `docs/roadmap.md`。

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 `Todo`。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / `symphony-issue`。
- 不运行 Graphify update。
- 不修改 Figma。
- 不写业务代码。
- 不实现 Paper runtime。
- 不实现 signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation runtime、Live PRO Console、trading button 或 live command。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Event-Driven Paper Trading Runtime planning record docs-only edits 后执行；无 whitespace / patch error 输出。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 保持 read-model-only / workbenchReadModelOnly；204 个 XCTest 通过、0 failures，最终输出 `MTPRO checks passed.`。 |

## MTPRO Module Maturity Development Plan roadmap record

日期：2026-05-25

执行者：Codex

目的：

- 将 9 / 9 后的模块成熟度路线纳入项目开发计划。
- 基于 `MTPRO Reference Alignment & Product Gap Map v1`、`MTPRO Codebase Reference Gap Map v1`、`MTPRO Paper Trading Runtime Foundation Blueprint v1` 和 `MTPRO Event-Driven Paper Trading Runtime v1` planning record，明确 MTPRO 后续不是直接进入 Live PRO Console，而是先补自身模块成熟度。
- 把与参考项目 `atxinbao/nautilus_trader` 的差距拆成阶段化开发地图。

文件范围：

- 更新 `docs/roadmap.md`，新增 `Module Maturity Development Plan / 模块成熟度开发计划`。
- 更新 `BLUEPRINT.md`，增加该路线入口。
- 更新 `docs/validation/latest-verification-summary.md`，记录该路线已纳入开发地图且不授权 execution。
- 更新 `verification.md`，追加本节。

关键结论：

- Final Product Goal Progress `9 / 9 (100%)` 表示原定 contract / evidence / Workbench / Live boundary 切片完成，不表示 MTPRO 已达到 `nautilus_trader` 级别的 production trading engine 成熟度。
- 模块成熟度路线拆成七阶段：Event-Driven Paper Trading Runtime、Backtest / Paper Simulated Exchange Parity、Paper Account / Portfolio / Risk Runtime、Local Data Catalog / Scenario Replay、Workbench Productization / Beta Readiness、Live Read-Only Account Readiness、Live Execution / Risk / Reconciliation / PRO Console。
- 当前优先级仍是 Stage 1 `MTPRO Event-Driven Paper Trading Runtime v1`；Stage 1 完成前，不直接规划 Live PRO Console 或真实 signed / broker / OMS 能力。
- 该路线是开发地图，不是 Project closure，不更新 Final Product Goal Progress，不创建 Linear Project / Issue，不推进 `Todo`。

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 `Todo`。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / `symphony-issue`。
- 不运行 Graphify update。
- 不修改 Figma。
- 不写业务代码。
- 不实现 Paper runtime。
- 不实现 signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation runtime、Live PRO Console、trading button 或 live command。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Module Maturity Development Plan docs-only edits 后执行；无 whitespace / patch error 输出。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 保持 read-model-only / workbenchReadModelOnly；204 个 XCTest 通过、0 failures，最终输出 `MTPRO checks passed.`。 |

## MTP-96 TradingClock / Paper Runtime Kernel Boundary

日期：2026-05-25

执行者：Codex

目的：

- 建立 paper-only `TradingClock` 与 `PaperRuntimeKernelBoundary` 的 Core 合同。
- 明确 paper runtime kernel 的 deterministic 时间来源、session / command intake、event emission、replay 和 module boundary 不变量。
- 为后续 MTP-97 至 MTP-102 的 CommandBus / EventBus / MessageBus、Paper RiskEngine、paper lifecycle coordinator、simulated fill、paper account / portfolio projection 和 evidence closeout 提供基础 fixture / validation anchors。

文件范围：

- 新增 `Sources/Core/PaperRuntimeKernelBoundary.swift`。
- 更新 `Sources/Core/CoreError.swift`。
- 更新 `Tests/CoreTests/CoreTests.swift`，新增 MTP-96 focused tests。
- 新增 `docs/contracts/paper-runtime-kernel-contract.md`。
- 更新 `docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh`。
- 更新 `.codex/context-scan.json`、`.codex/context-question-1.json`、`.codex/operations-log.md` 和 `.codex/testing.md` 作为本地 handoff evidence，不进入 PR。

关键结论：

- `TradingClock` 只接受 deterministic fixture / replay tick，拒绝 wall clock；tick sequence 必须从 1 开始连续，replay tick 必须绑定本地 event log source sequence。
- `PaperRuntimeKernelBoundary` 只允许 paper / local / replay input，输出只允许 paper event envelope、replay result 和 paper projection trigger，event streams 固定为 `.paper` / `.replay`。
- `PaperRuntimeKernelBoundary` 不暴露 UI state、persistence schema 或 adapter object。
- forbidden capability flags 全部固定为 `false`，Codable 解码绕过会被拒绝。
- 本 issue 只定义 Core boundary，不实现 Runtime target 编排，不实现 CommandBus / EventBus / Paper RiskEngine / lifecycle coordinator / simulated fill / account projection。

边界确认：

- 不修改 Linear status。
- 不启动下一阶段 `symphony-issue`。
- 不读取 secrets / credentials。
- 不接 signed endpoint、account endpoint、listenKey。
- 不连接 broker，不执行 broker action。
- 不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、真实 submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、live command 或交易按钮。
- 不提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP96` | pass | 3 个 MTP-96 focused tests 通过，0 failures。 |
| `bash checks/automation-readiness.sh` | pass | MTP-96 contract / matrix / validation plan / domain context / latest summary / Core source / focused test anchors 均通过机械检查。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；Swift tests 207 个通过、0 failures；最终输出 `MTPRO checks passed.`。 |

## MTPRO Core Engine Architecture & Module Maturity Map v1

日期：2026-05-25

执行者：Codex

目的：

- 将 Human 确认的 Engine 级规划落仓为产品 / 架构层蓝图。
- 参考 Human 提供的 core engine data-flow 图和 `atxinbao/nautilus_trader` 的 engine / crate 组织，把 MTPRO 模块成熟度路线从零散模块表升级为 Engine 级架构地图。
- 明确后续 Project Draft 必须声明目标 Engine / Layer、target maturity level、current evidence、allowed scope、forbidden capabilities 和 validation anchors。

文件范围：

- 新增 `docs/product/mtpro-core-engine-architecture-module-maturity-map-v1.md`。
- 更新 `BLUEPRINT.md`，增加该 Engine map 入口和 Future Construction Zones 前的 Project Draft 对齐要求。
- 更新 `architecture.md`，增加 Core Engine Architecture Reference。
- 更新 `docs/roadmap.md`，把 Module Maturity Development Plan 绑定到 Engine map。
- 更新 `docs/product/product-surface-map.md`，增加产品 / 架构层 Engine map 引用。
- 更新 `docs/validation/latest-verification-summary.md`，记录该 Engine map 已落仓且不授权 execution。
- 更新 `verification.md`，追加本节。

关键结论：

- Core Engine 包含 Domain Model Foundation、System Kernel、Connectivity / Adapter Engine、Data Engine、Strategy Engine、Analysis / Research Engine、Simulation / Backtest Engine、Risk Engine、Execution Engine、Portfolio Engine、State & Persistence Engine 和 Workbench Interface。
- Future Live PRO Console 是独立 Future product surface，不是当前 Workbench 的自然延伸。
- `Strategy quoter` 和 `Strategy hedger` 属于 Strategy Engine 的 Strategy Instance，只能输出 paper intent / proposal，不得直连 Execution Client 或 broker。
- `MTPRO Event-Driven Paper Trading Runtime v1` 只能解释为 paper-only L1 起点，不等于完整 trading engine maturity。

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 `Todo`。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / `symphony-issue`。
- 不运行 Graphify update。
- 不修改 Figma。
- 不写业务代码。
- 不实现 Paper runtime。
- 不引入 NautilusTrader 作为 runtime dependency。
- 不复制 NautilusTrader 整仓代码。
- 不实现 signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation runtime、Live PRO Console、trading button 或 live command。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Core Engine Architecture & Module Maturity Map docs-only edits 后执行；无 whitespace / patch error 输出。 |
| `bash checks/run.sh` | pass | 串联 automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 保持 read-model-only / workbenchReadModelOnly；207 个 XCTest 通过、0 failures，最终输出 `MTPRO checks passed.`。 |

## MTP-97 CommandBus / EventBus / MessageBus Deterministic Routing

日期：2026-05-25

执行者：Codex

目的：

- 建立 paper runtime 内部 `CommandBus` / `EventBus` / `MessageBus` deterministic routing。
- 支持 paper session command、paper risk decision、paper lifecycle event 和 simulated fill event 的 deterministic route。
- 为 Event Log / Replay 提供可复现的 source、payload kind、stream、correlation 和 causation evidence。
- 保持 routing 只服务 paper-only runtime，不升级为 live command bus、signed request routing、broker action 或真实订单行为。

文件范围：

- 新增 `Sources/Core/PaperRuntimeBusRouting.swift`。
- 更新 `Sources/Core/EventLog.swift`，允许 `AppendOnlyEventLog.append` / `MessageBus.publish` 接收 deterministic envelope `id`，默认行为不变。
- 更新 `Sources/Core/CoreError.swift`，新增 paper runtime bus routing 错误边界。
- 更新 `Tests/CoreTests/CoreTests.swift`，新增 MTP-97 focused tests。
- 更新 `docs/contracts/paper-runtime-kernel-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh`。
- 更新 `.codex/context-scan.json`、`.codex/operations-log.md`、`.codex/testing.md` 和 `.codex/review-report.md` 作为本地 handoff evidence，不进入 PR。

关键结论：

- `PaperRuntimeCommandBus` 只把 paper-only route inputs 展开为 deterministic routed messages，不执行命令、不读取 adapter、不写 event log。
- `PaperRuntimeEventBus` 只把 routed messages 发布到既有 `MessageBus` / append-only Event Log。
- `PaperRuntimeMessageBusRouting.replayEvidence` 可从 replay result 重建 route evidence。
- route evidence 保留 deterministic envelope ID、event sequence、source、payload kind、stream、recordedAt、correlationID 和 causationID。
- `PaperRuntimeBusRoutingContract` 的 live / signed / broker / execution report / broker fill / reconciliation forbidden flags 全部固定为 `false`，Codable 绕过会被拒绝。

边界确认：

- 不修改 Linear status。
- 不启动下一阶段 `symphony-issue`。
- 不读取 secrets / credentials。
- 不接 signed endpoint、account endpoint、listenKey。
- 不连接 broker，不执行 broker action。
- 不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、真实 submit / cancel / replace、execution report、broker fill、reconciliation、Paper RiskEngine、paper lifecycle coordinator、paper account projection、Live PRO Console、live command 或交易按钮。
- 不提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP97` | pass | 3 个 MTP-97 focused tests 通过，0 failures。 |
| `bash checks/automation-readiness.sh` | pass | MTP-97 contract / matrix / validation plan / domain context / latest summary / Core source / focused test anchors 均通过机械检查。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；Swift tests 210 个通过、0 failures；最终输出 `MTPRO checks passed.`。 |

## MTP-98 Paper Pre-trade RiskEngine Runtime Path

日期：2026-05-25

执行者：Codex

目的：

- 建立 paper-only `PaperPreTradeRiskEngineRuntimePath`，对 `PaperActionProposal` 产生 accepted / rejected paper risk decision。
- 把 rejected paper risk decision 复用 MTP-97 routing 写入 append-only `MessageBus` / Event Log，并从 replay 重建 route evidence。
- 固定 paper account snapshot、paper exposure 和 deterministic paper risk rules 的本地 sandbox 边界，防止升级为 live risk engine、真实账户风控、broker rejection 或 future live risk decision。

文件范围：

- 新增 `Sources/Core/PaperPreTradeRiskEngine.swift`。
- 更新 `Sources/Core/CoreError.swift`，新增 paper pre-trade risk engine forbidden capability / mismatch 错误边界。
- 更新 `Sources/Core/PaperRuntimeBusRouting.swift` 注释，说明 MTP-98 paper-only risk decision 可进入既有 `.paperRiskDecision` route。
- 更新 `Tests/CoreTests/CoreTests.swift`，新增 MTP-98 focused tests。
- 更新 `docs/contracts/paper-runtime-kernel-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh`。
- 更新 `.codex/context-scan.json`、`.codex/operations-log.md` 和 `.codex/testing.md` 作为本地 handoff evidence，不进入 PR。

关键结论：

- `PaperPreTradeRiskEngineInput` 只接受 paper proposal、paper account snapshot、paper exposure、risk profile、paper risk rules 和正数 source proposal sequence。
- `PaperPreTradeRiskEngineDecision` 只输出 accepted / rejected paper risk decision；rejected decision 记录第一条 failed paper risk rule 和 `RiskBlockerEvidence`。
- `PaperPreTradeRiskEngineRuntimePath.evaluateAndPublish` 复用 `PaperRuntimeMessageBusRouting`，使 rejected decision 产生 `paperRiskEvaluationRequested` 和 `paperRiskBlocked` route evidence。
- `PaperPreTradeRiskEnginePublication` 要求 replay evidence 与 route evidence 完全一致。
- account snapshot、risk rule、input、decision 和 publication 的 Codable decode path 会回到 initializer 校验，防止 decode bypass。

边界确认：

- 不修改 Linear status。
- 不启动下一阶段 `symphony-issue`。
- 不读取 secrets / credentials。
- 不接 signed endpoint、account endpoint、listenKey。
- 不连接 broker，不执行 broker action。
- 不实现 live risk engine、real pre-trade allow / reject runtime、circuit breaker command、stop trading command、emergency stop、`LiveExecutionAdapter`、OMS、real order lifecycle、真实 submit / cancel / replace、execution report、broker fill、reconciliation、paper lifecycle coordinator、simulated fill / fee / slippage model、paper account projection、Live PRO Console、live command 或交易按钮。
- 不提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP98` | pass | 3 个 MTP-98 focused tests 通过，0 failures；覆盖 accepted / rejected deterministic decision、rejected Event Log / Replay evidence、live/account/broker decode bypass rejection。 |
| `bash checks/automation-readiness.sh` | pass | MTP-98 contract / matrix / validation plan / domain context / latest summary / Core source / focused test anchors 均通过机械检查。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；Swift tests 213 个通过、0 failures；最终输出 `MTPRO checks passed.`。 |

## MTP-99 Paper-only Lifecycle Coordinator / Local Order Lifecycle

日期：2026-05-25

执行者：Codex

目的：

- 建立 paper-only `PaperOrderLocalLifecycleCoordinator`，管理 accepted / rejected paper risk decision 的本地 order lifecycle transition。
- 固定 local lifecycle：`proposed`、`submittedLocal`、`acceptedLocal`、`rejectedByPaperRisk`、`cancelledLocal`、`expiredLocal`、`failedLocal`。
- 让每个 transition 通过 `PaperEvent.orderLocalLifecycleTransitionRecorded` 写入 `.paper` stream，并从 Event Log / Replay 重建 route evidence。
- 用 `PaperOrderSimulatedFillPrecondition` 串接 MTP-100 simulated fill 前置状态，但不实现 simulated fill / fee / slippage。

文件范围：

- 新增 `Sources/Core/PaperOrderLifecycleCoordinator.swift`。
- 更新 `Sources/Core/CoreError.swift`，新增 paper order local lifecycle forbidden capability / mismatch 错误边界。
- 更新 `Sources/Core/DomainEvents.swift`，新增 `PaperEvent.orderLocalLifecycleTransitionRecorded`。
- 更新 `Sources/Core/PaperRuntimeBusRouting.swift`，新增 `paperOrderLocalLifecycleTransition` payload kind 和 route classification。
- 更新 `Sources/Core/PaperSessionReplay.swift`、`Sources/Persistence/Persistence.swift` 和 `Sources/App/App.swift`，处理新增 paper event case 且不暴露新 schema / command surface。
- 更新 `Tests/CoreTests/CoreTests.swift`，新增 MTP-99 focused tests。
- 更新 `docs/contracts/paper-runtime-kernel-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh`。
- 更新 `.codex/context-scan.json`、`.codex/context-question-1.json`、`.codex/operations-log.md`、`.codex/testing.md` 和 `.codex/review-report.md` 作为本地 handoff evidence，不进入 PR。

关键结论：

- accepted paper risk decision 产生 `proposed -> submittedLocal -> acceptedLocal`。
- rejected paper risk decision 产生 `proposed -> rejectedByPaperRisk`。
- `cancelledLocal` 只能来自 session close / reset、local expiry 或 deterministic local rule。
- `acceptedLocal` 只是 simulated fill 前置状态，不是 exchange accepted、broker accepted 或真实执行授权。
- `PaperOrderLocalLifecyclePublication` 要求 route evidence 与 replay evidence 完全一致。

边界确认：

- 不修改 Linear status。
- 不启动下一阶段 `symphony-issue`。
- 不读取 secrets / credentials。
- 不接 signed endpoint、account endpoint、listenKey。
- 不连接 broker，不执行 broker action。
- 不实现 OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、execution report、broker fill、reconciliation、simulated fill / fee / slippage model、paper account projection、Live PRO Console、live command、order form、单笔 order cancel button、order-level command UI 或交易按钮。
- 不提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP99` | pass | 3 个 MTP-99 focused Core tests 通过，0 failures；覆盖 deterministic accepted / rejected lifecycle、transition event facts / replay evidence、simulated fill precondition 和 OMS / broker / real cancel / order-level command UI bypass rejection。 |
| `bash checks/automation-readiness.sh` | pass | MTP-99 contract / matrix / validation plan / domain context / latest summary / Core source / focused test anchors 均通过机械检查。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；Swift tests 216 个通过、0 failures；最终输出 `MTPRO checks passed.`。 |

## MTP-100 Simulated Fill / Fee / Slippage Deterministic Model

日期：2026-05-26

执行者：Codex

目的：

- 建立 paper-only simulated fill / fee / slippage deterministic model，避免 paper runtime 出现零摩擦假象。
- 让 simulated fill 输入显式包含 market snapshot、allowed paper order、MTP-99 accepted-local precondition 和 fill assumptions。
- 支持 full / partial simulated fill evidence，并记录 fee assumption、slippage assumption、fill price assumption 和 cost impact。
- 通过既有 MTP-97 `PaperRuntimeMessageBusRouting` 将 simulated fill result 写入 `.paper` Event Log，并从 replay 重建 partial / full fill facts。

文件范围：

- 更新 `Sources/Core/PaperSimulatedFillEvidence.swift`，新增 `PaperSimulatedFillMarketSnapshot`、`PaperSimulatedFillCompletion`、`PaperSimulatedFillPriceSource`、`PaperSimulatedFillEventLogBoundary`、`PaperSimulatedFillPublication`、`PaperSimulatedFillReplayPath` 和 MTP-100 fixtures。
- 更新 `Tests/CoreTests/CoreTests.swift`，新增 MTP-100 focused tests。
- 更新 `docs/contracts/paper-runtime-kernel-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh`。
- 更新 `.codex/context-scan.json`、`.codex/context-question-1.json`、`.codex/context-question-2.json`、`.codex/context-sufficiency.json`、`.codex/operations-log.md`、`.codex/testing.md` 和 `.codex/review-report.md` 作为本地 handoff evidence，不进入 PR。

关键结论：

- `PaperSimulatedFillMarketSnapshot` 只保存本地 fixture / replay bid、ask、last price 和 source anchor，不暴露 Adapter payload 或 live stream。
- `PaperSimulatedFillEvidence` 同时覆盖 full fill 和 partial fill；full remaining quantity 为 0，partial remaining quantity 大于 0。
- fee / slippage 复用 MTP-27 `ExecutionCostAssumptions.deterministicFixture`，不引入真实交易所费率表、真实 fee statement、dynamic slippage 或 execution optimizer。
- `PaperSimulatedFillEventLogBoundary` 只复用 MTP-97 routing 写入 `.paper` stream，不启动 Runtime actor，不新增 broker-like bus。
- `PaperSimulatedFillPublication` 要求 route evidence、replay evidence 和 replayed fills 完全一致。

边界确认：

- 不修改 Linear status。
- 不启动下一阶段 `symphony-issue`。
- 不读取 secrets / credentials。
- 不接 signed endpoint、account endpoint、listenKey。
- 不连接 broker，不执行 broker action。
- 不实现 paper account / portfolio / position projection v2、App / Dashboard surface、broker fill、execution report parser、真实 fee statement、真实成交质量分析、live reconciliation、real account update、OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、Live PRO Console、live command、order form 或交易按钮。
- 不提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP100` | pass | 3 个 MTP-100 focused Core tests 通过，0 failures；覆盖 deterministic full / partial cost evidence、simulated fill Event Log / Replay evidence、broker fill / execution report / reconciliation / real account update bypass rejection。 |
| `bash checks/automation-readiness.sh` | pass | MTP-100 contract / matrix / validation plan / domain context / latest summary / Core source / focused test anchors 均通过机械检查。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；Swift tests 219 个通过、0 failures；最终输出 `MTPRO checks passed.`。 |

## MTP-101 Paper Account / Portfolio / Position Projection v2

日期：2026-05-26

执行者：Codex

目的：

- 从 replayed simulated fill、fee 和 slippage evidence 推导 paper account、portfolio、position、exposure 和 paper PnL projection v2。
- 保持 projection 输入只来自 `.paper.simulatedFillRecorded` replay facts，不直接读取 risk decision、Runtime object、SQLite schema、adapter payload、真实账户或 broker state。
- 将 account / position / PnL snapshot 通过 Persistence runtime projection 和 App read model 暴露给 Report / Dashboard / Risk / Portfolio。

文件范围：

- 新增 `Sources/Core/PaperAccountPortfolioProjectionV2.swift`，定义 `PaperAccountProjectionSnapshot`、`PaperPositionProjectionSnapshot`、`PaperPortfolioPnLSummary`、`PaperAccountPortfolioProjectionV2Snapshot`、`PaperAccountPortfolioProjectionV2Path` 和 MTP-101 fixture。
- 更新 `Sources/Core/DomainEvents.swift` 和 `Sources/Core/PaperSessionReplay.swift`，新增 v2 portfolio projection event 和 replay summary support。
- 更新 `Sources/Persistence/Persistence.swift`，新增 paper account / position / PnL runtime projection 字段。
- 更新 `Sources/App/App.swift`、`Sources/App/DashboardShell.swift` 和 `Sources/App/PaperWorkflowEvidenceExplorer.swift`，让 Report / Dashboard / Risk / Portfolio 只通过 read model / ViewModel 消费 v2 snapshot。
- 更新 `Tests/CoreTests/CoreTests.swift` 和 `Tests/AppTests/AppTests.swift`，新增 MTP-101 focused tests。
- 更新 `docs/contracts/paper-runtime-kernel-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh`。
- 更新 `.codex/context-scan.json`、`.codex/structured-request.json`、`.codex/operations-log.md`、`.codex/testing.md` 和 `.codex/review-report.md` 作为本地 handoff evidence，不进入 PR。

关键结论：

- `PaperAccountPortfolioProjectionV2Path` 只消费 replay result 中的 `.paper.simulatedFillRecorded` facts。
- `PaperAccountProjectionSnapshot` 固定 cash、available paper balance、position market value 和 equity。
- `PaperPositionProjectionSnapshot` 固定 net quantity、average entry、last fill price、market value、cost basis 和 unrealized paper PnL。
- `PaperPortfolioPnLSummary` 固定 fee、slippage、cost impact、realized / unrealized / net paper PnL。
- Persistence / App / Dashboard 只消费 read model / ViewModel，不暴露 schema、Runtime object、adapter request 或命令面。

边界确认：

- 不修改 Linear status。
- 不启动下一阶段 `symphony-issue`。
- 不读取 secrets / credentials。
- 不接 signed endpoint、account endpoint、listenKey。
- 不连接 broker，不执行 broker action。
- 不实现真实账户余额读取、broker position sync、margin、leverage、real PnL、live risk runtime、real account update、OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、Live PRO Console、position command、live command、order form 或交易按钮。
- 不提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP101` | pass | 3 个 MTP-101 focused tests 通过，0 failures；覆盖 replayed simulated fill -> account / portfolio / position / exposure / PnL projection deterministic、Codable forbidden capability bypass rejection，以及 Report / Dashboard / Risk / Portfolio read model consumption。 |
| `bash checks/automation-readiness.sh` | pass | MTP-101 contract / matrix / validation plan / domain context / latest summary / Core/App source / focused test anchors 均通过机械检查。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；Swift tests 222 个通过、0 failures；最终输出 `MTPRO checks passed.`。 |

## MTP-102 Event Log / Replay / Report / Dashboard Evidence Stage Closeout

日期：2026-05-26

执行者：Codex

目的：

- 串联 MTP-96 至 MTP-101 已落地的 paper runtime kernel、bus routing、paper risk、local lifecycle、simulated fill、fee / slippage 和 paper account / portfolio / position projection v2 evidence。
- 将 risk -> local lifecycle -> simulated fill -> account portfolio projection 的 append-only replay chain 暴露给 Report / Dashboard / Event Timeline 只读 surfaces。
- 生成 Parent Codex Stage Code Audit 输入材料；不输出最终 Stage Code Audit Report，不推进下一 Project / Issue。

文件范围：

- 更新 `Sources/App/App.swift`，让 `PaperExecutionWorkflowEvidenceSummary` / `ReportViewModel` 汇总 local lifecycle transition IDs、paper risk decision IDs、paper order IDs、simulated fill IDs、account portfolio snapshot IDs、gross notional、fee、slippage、cost impact、paper account、position 和 paper PnL evidence。
- 更新 `Sources/App/PaperWorkflowEvidenceExplorer.swift`，将 `.paper.orderLocalLifecycleTransitionRecorded` 映射为 `Paper local lifecycle transition` Event Timeline item。
- 更新 `Sources/App/DashboardShell.swift`，在 Report metrics / details 和 Dashboard smoke 中输出 `paperRuntimeEvidence`、`paperWorkflowEvidence` 和 `paperPortfolioImpact` handles。
- 更新 `Tests/AppTests/AppTests.swift`，新增 `testMTP102PaperRuntimeEvidenceChainFeedsReportDashboardAndEventTimeline`。
- 新增 `docs/audit/inputs/mtpro-event-driven-paper-trading-runtime-v1-stage-audit-input.md`。
- 更新 `docs/contracts/paper-runtime-kernel-contract.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`。
- 更新 `.codex/*` 作为本地 handoff evidence，不进入 PR。

关键结论：

- MTP-102 evidence 全部来自 append-only Event Log / Replay 和 read model / ViewModel。
- Report / Dashboard / Event Timeline 可以展示 local lifecycle、simulated fill、fee / slippage / cost impact、account portfolio snapshot 和 paper PnL evidence，但不提供 command surface。
- Stage audit input 只准备 Parent Codex 审计材料，不替代最终 Stage Code Audit Report。

边界确认：

- 不修改 Linear status。
- 不启动下一阶段 `symphony-issue`。
- 不读取 secrets / credentials。
- 不接 signed endpoint、account endpoint、listenKey。
- 不连接 broker，不执行 broker action。
- 不实现 final Stage Code Audit Report、Project closure、Root Docs Refresh Gate、OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、execution report、broker fill、reconciliation、real account update、Live PRO Console、live command、order form、position command、stop button 或交易按钮。
- 不提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP102` | pass | 1 个 App focused test 通过，0 failures；覆盖 risk -> local lifecycle -> simulated fill -> account portfolio projection deterministic replay chain、Report / Dashboard / Event Timeline read-model-only evidence 和 no live / broker / trading authorization flags。 |
| `bash checks/automation-readiness.sh` | pass | MTP-102 stage audit input、contract、matrix、validation plan、latest summary、source / test anchors 和 Dashboard smoke handles 均通过机械检查，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；Swift tests 223 个通过、0 failures；最终输出 `MTPRO checks passed.`。 |

## MTPRO Event-Driven Paper Trading Runtime v1 Project Closure / Stage Code Audit / Root Docs Refresh Gate

日期：2026-05-26

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 在 `MTP-96` 至 `MTP-102` 全部 Done、对应 PR 全部 merge 且 GitHub required check `checks` 全部 success 后，关闭 `MTPRO Event-Driven Paper Trading Runtime v1`。
- 落仓 canonical Stage Code Audit Report：`docs/audit/mtpro-event-driven-paper-trading-runtime-v1-stage-code-audit.md`。
- 执行 Root Docs Refresh Gate，只同步已发生事实，不决定下一阶段方向。

Project closure evidence：

- Linear Project status：`Completed` / `type=completed`。
- `completedAt=2026-05-25T18:25:12.000Z`。
- Canonical issues：`MTP-96`、`MTP-97`、`MTP-98`、`MTP-99`、`MTP-100`、`MTP-101`、`MTP-102` 全部 `Done`。
- Active queue：`Todo=0`、`In Progress=0`、`In Review=0`，WIP=1 satisfied。
- Stage Code Audit PR：#198，merge commit `40d3ac8906f1e6a0f2d671ffd2d686f6789a78d7`，GitHub `checks` success run `https://github.com/atxinbao/MTPRO/actions/runs/26414607799/job/77756238531`。

Issue evidence chain：

| Issue | PR | Merge commit | Required check |
| --- | --- | --- | --- |
| `MTP-96` | #190 | `fa2e0ef2d4457a093ef796d66b933068a9bd9bac` | `checks` success：`https://github.com/atxinbao/MTPRO/actions/runs/26404774215/job/77725406407` |
| `MTP-97` | #192 | `1936791faf8484fda072ccfef03dc20c88572cd6` | `checks` success：`https://github.com/atxinbao/MTPRO/actions/runs/26406391227/job/77730618874` |
| `MTP-98` | #193 | `1123faef15a52b0e1d40254e5650f4d85c77c8a9` | `checks` success：`https://github.com/atxinbao/MTPRO/actions/runs/26407878500/job/77735463504` |
| `MTP-99` | #194 | `1700c21b1c5794c1ab6a70a527d5c5a86fcf10a3` | `checks` success：`https://github.com/atxinbao/MTPRO/actions/runs/26408949657/job/77738863221` |
| `MTP-100` | #195 | `bd45a98d73b7422dded902e56a0e95374dd5729c` | `checks` success：`https://github.com/atxinbao/MTPRO/actions/runs/26411644898/job/77747183669` |
| `MTP-101` | #196 | `18a715851852dd67d3deb33564c111c2d3fcf63a` | `checks` success：`https://github.com/atxinbao/MTPRO/actions/runs/26412976178/job/77751276011` |
| `MTP-102` | #197 | `55122cc1170b5a0ac29207b1ff4b604e00e7510d` | `checks` success：`https://github.com/atxinbao/MTPRO/actions/runs/26414177091/job/77754931506` |

Root Docs Refresh Gate：

| 文档 | 结果 | 原因 |
| --- | --- | --- |
| `GOAL.md` | updated | 同步 `L1 Paper Runtime` 本阶段闭环已完成；Final Product Goal Progress 保持 `9 / 9 (100%)`。 |
| `BLUEPRINT.md` | updated | 把 `MTPRO Event-Driven Paper Trading Runtime v1` 从 planning / candidate 事实刷新为已完成 Project，并保留 future gated 边界。 |
| `environment.md` | no update needed | 未新增 validation 入口、secret、broker credential、signed endpoint、account endpoint、listenKey、真实账户读取或网络必需验证。 |
| `architecture.md` | updated | 同步 L1 Paper Runtime 的 TradingClock、routing、paper risk、local lifecycle、simulated fill、paper portfolio projection 和 read-model-only evidence chain。 |
| `docs/roadmap.md` | updated | Stage 1 Event-Driven Paper Trading Runtime 更新为 Completed；Project Closure Count 更新为 `13 / 13`。 |
| `docs/validation/latest-verification-summary.md` | updated | 同步最近完成 Project、Stage Code Audit Report、Project closure evidence、validation baseline 和 Root Docs Refresh Gate closure。 |
| `docs/automation/automation-readiness.md` / `checks/automation-readiness.sh` | updated | 新增 Stage Code Audit Report mechanical anchor。 |
| `verification.md` | updated | 追加本 compact record。 |

当前进度口径：

```text
Project Closure Count: 13 / 13 (100%)
Current Foundation Progress: 4 / 4 (100%)
Final Product Goal Progress: 9 / 9 (100%)
```

L1 Paper Runtime maturity statement：

- TradingClock / paper runtime kernel、paper-only routing、Paper Pre-trade RiskEngine、paper-only local lifecycle、simulated fill / fee / slippage、paper account / portfolio / position projection v2、Event Log / Replay / Report / Dashboard / Event Timeline evidence 已完成本阶段闭环。
- 该成熟度结论不是 Live trading completion，不表示 broker / OMS、signed endpoint、account endpoint / listenKey、real order lifecycle、Live PRO Console、trading button 或 live command 已实现或获授权。

边界确认：

- 不创建下一 Project / Issue。
- 不修改 Linear queue 推进下一阶段。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify。
- 不修改 Figma。
- 不写业务代码。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不授权 signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。

## MTPRO Data Catalog / Scenario Replay v1 planning record

日期：2026-05-26

执行者：Codex

目的：

- 将 Human 确认的 `MTPRO Data Catalog / Scenario Replay v1` planning draft 落仓为 docs-only Project Planning Record。
- 记录 Target Engines、Target maturity、Project goal、scope、non-goals、Issue 4 / Issue 5 拆分判断、issue order、dependencies、validation requirements、evidence requirements、first executable issue candidate、WIP=1、Linear write boundary、repository record boundary 和 Parent Codex queue preflight rule。
- 更新 planning index、latest verification summary 和 `BLUEPRINT.md` 的轻量引用。

文件范围：

- 新增 `docs/planning/projects/mtpro-data-catalog-scenario-replay-v1-plan.md`。
- 更新 `docs/planning/linear-draft-plan.md`，增加 planning record 索引并切换当前 Project planning record 指向。
- 更新 `docs/validation/latest-verification-summary.md`，记录该 planning record 已落仓但不授权 implementation。
- 更新 `BLUEPRINT.md`，增加该 planning record 引用和当前 handoff 状态。
- 更新 `verification.md`，追加本节。

关键结论：

- `MTPRO Data Catalog / Scenario Replay v1` 的 Target Engines 为 Data Engine、State & Persistence Engine 和 Workbench Interface。
- Target maturity 为 `L1.5 -> L2 prerequisite`，只表示为后续 `Simulated Exchange / Backtest Parity v1`、Workbench beta demo path 和 report reproducibility 建立 local-first、deterministic、versioned scenario replay 数据地基。
- Issue 4 replay window / cursor / checksum / freshness evidence 与 Issue 5 data quality gates / report input versioning 已明确拆分，避免单个 PR 同时扩张 Data Engine、Persistence 和 Report surface。
- 该 planning record 只保存 Project 级计划摘要和格式门槛，不复制维护完整 Linear issue body 或完整 candidate issue 正文。

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / `symphony-issue`。
- 不运行 Graphify update。
- 不写业务代码。
- 不修改 Figma。
- 不实现 Data Catalog。
- 不实现 Scenario Replay。
- 不实现 Simulated Exchange / Backtest Parity。
- 不实现 signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position、Live PRO Console、trading button 或 live command。
- 不提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Data Catalog / Scenario Replay planning record docs-only edits 后执行；新 planning record 已通过 intent-to-add 纳入检查范围，无 whitespace / patch error 输出。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 保持 read-model-only / workbenchReadModelOnly；223 个 XCTest 通过、0 failures，最终输出 `MTPRO checks passed.`。 |
## MTP-103 Data Catalog / Scenario Replay terminology and boundary

日期：2026-05-26

执行者：Codex

目的：

- 完成 Linear issue `MTP-103 Define Data Catalog / Scenario Replay terminology and boundary`。
- 定义 local data catalog / scenario replay terminology、Data Engine / State & Persistence Engine / Workbench Interface target engine boundary、local-first deterministic versioned boundary、forbidden capability baseline、source docs anchors 和 validation anchors。
- 保持当前 issue 在术语和边界层，不实现 manifest parser、fixture data、replay cursor、report input versioning、production data platform、large-scale ingestion pipeline、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、Graphify 或 Figma 变更。

文件范围：

- 新增 `Sources/Core/DataCatalogScenarioReplayBoundary.swift`。
- 更新 `Sources/Core/CoreError.swift`，新增 Data Catalog / Scenario Replay contract mismatch 和 forbidden capability error case。
- 更新 `Tests/CoreTests/CoreTests.swift`，新增 3 个 MTP-103 focused Core tests。
- 新增 `docs/contracts/data-catalog-scenario-replay-contract.md`。
- 更新 `docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh`。
- 更新本 append-only `verification.md`。

关键证据：

- `DataCatalogScenarioReplayBoundary.deterministicFixture` 固定 MTP-103 terminology、target engines、boundary principles、forbidden capabilities、allowed evidence kinds、source docs anchors 和 validation anchors。
- `DataCatalogScenarioReplayBoundary` 保持 `isLocalFirst`、`isDeterministic`、`isVersioned` 和 `exposesReadModelOnlySurface` 为 true。
- `DataCatalogScenarioReplayBoundary` 对 manifest parser、fixture data、replay cursor、report input versioning、Simulated Exchange / Backtest Parity runtime、secret、signed endpoint、account endpoint、listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、live runtime、live command、trading button、production data platform、large-scale ingestion pipeline、real network download、Graphify update 和 Figma change 的 flags 全部为 false，并通过初始化和 Codable 解码拒绝绕过。
- `TVM-DATA-CATALOG-SCENARIO-REPLAY` 已回填到 trading validation matrix。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP103` | pass | 执行 3 个 Core tests，0 failures；覆盖 terminology / boundary anchors、forbidden capability bypass rejection、Codable decode bypass rejection 和 local-first read-model-only target engine boundary。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-103 contract、domain context、validation plan、matrix、latest summary、Core source 和 focused tests anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 226 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`，最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 Linear status。
- 不启动 Symphony / Graphify。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 manifest parser、fixture data、replay cursor、report input versioning、production data platform、large-scale ingestion pipeline、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、real account / broker position read、live runtime、live command、trading button 或 Live PRO Console。

---

## 2026-05-26 — MTP-104 Scenario Manifest / Scenario ID / Dataset Version Contract

执行者：Codex

目的：

- 完成 Linear issue `MTP-104 Add scenario manifest / scenario id / dataset version contract`。
- 定义 scenario manifest 最小字段、scenario id / dataset version stable identity、single-symbol / single-timeframe first scenario manifest、deterministic serialization / equality evidence 和 manifest forbidden capability boundary。
- 保持当前 issue 在 Core contract 层，不实现 manifest file parser、fixture data、replay cursor、report input versioning runtime、production dataset registry、large-scale ingestion pipeline、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、order command、Graphify 或 Figma 变更。

文件范围：

- 新增 `Sources/Core/ScenarioManifest.swift`。
- 更新 `Tests/CoreTests/CoreTests.swift`，新增 3 个 MTP-104 focused Core tests。
- 更新 `docs/contracts/data-catalog-scenario-replay-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh`。
- 更新本 append-only `verification.md`。

关键证据：

- `ScenarioID` 和 `DatasetVersion` 复用 `Identifier` 非空校验，但用独立类型表达本地 scenario replay 输入身份，避免混用 database primary key、runtime job id、broker order id、production dataset registry 或 cloud data lake version。
- `ScenarioManifest.deterministicFixture` 固定 `scenarioID=mtp-104-btcusdt-1m-first-scenario`、`datasetVersion=dataset-v1`、`symbol=BTCUSDT`、`timeframe=1m`、`sourceAnchor=MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS` 和 `scope=single-symbol / single-timeframe`。
- `ScenarioManifestDeterministicSerialization` 固定 canonical field order：`scenarioID`、`datasetVersion`、`symbol`、`timeframe`、`sourceAnchor`、`scope`，并生成 stable `sourceIdentity`。
- `ScenarioManifest` 对 database schema exposure、adapter request exposure、secret、signed endpoint、account endpoint、listenKey、broker、order command、live runtime、production dataset registry、real network download、multi-symbol catalog 和 multi-timeframe catalog flags 全部保持 false，并通过初始化和 Codable 解码拒绝绕过。
- `TVM-DATA-CATALOG-SCENARIO-REPLAY` 已回填 MTP-104 issue evidence。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP104` | pass | 执行 3 个 Core tests，0 failures；覆盖 manifest 最小字段、scenario id / dataset version stable identity、single-symbol / single-timeframe scope、deterministic serialization / equality evidence、forbidden capability bypass rejection 和 Codable decode bypass rejection。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-104 contract、domain context、validation plan、matrix、latest summary、Core source 和 focused test anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 229 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`，最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 Linear status。
- 不启动 Symphony / Graphify。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 manifest file parser、fixture data、replay cursor、report input versioning runtime、multi-symbol / multi-timeframe catalog、production dataset registry、production data platform、large-scale ingestion pipeline、真实历史下载器、database schema exposure、adapter request exposure、signed endpoint、account endpoint / listenKey、secret、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、real account / broker position read、live runtime、order command、live command、trading button 或 Live PRO Console。

---

## 2026-05-26 — MTP-105 Single-Symbol / Single-Timeframe Deterministic Scenario Fixture

执行者：Codex

目的：

- 完成 Linear issue `MTP-105 Add single-symbol / single-timeframe deterministic scenario fixture`。
- 基于 MTP-104 manifest 建立 first deterministic scenario fixture，限定 single symbol、single timeframe、fixed window 和 fixed record order。
- 定义 fixture version、source anchor、public-read-only local fixture relationship 和 deterministic summary / checksum preimage 前置结构。
- 保持当前 issue 不实现 MTP-106 replay cursor、final checksum evidence、freshness evidence、data quality gate、report input versioning runtime 或任何 live / broker / signed capability。

文件范围：

- 新增 `Sources/Core/ScenarioFixture.swift`。
- 更新 `Tests/CoreTests/CoreTests.swift`，新增 4 个 MTP-105 focused Core tests。
- 更新 `docs/contracts/data-catalog-scenario-replay-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh`。
- 更新本 append-only `verification.md`。

关键证据：

- `DeterministicScenarioFixture.deterministicFixture` 复用 `ScenarioManifest.deterministicFixture`，固定 `fixture-v1`、BTCUSDT / 1m、source anchor `MTP-105-SINGLE-SYMBOL-SINGLE-TIMEFRAME-FIXTURE` 和 source relationship anchors。
- Fixture records 固定为 3 条 local `MarketBar`：`1704067200...1704067260`、`1704067260...1704067320`、`1704067320...1704067380`，record sequence 为 `1,2,3`，interval start 严格升序。
- `ScenarioFixtureDeterministicSummary` 固定 record count、ordered starts、record order identity、canonical record summary、checksum preimage 和 MTP-104 source identity，并保持 `checksumEvidenceDeferredToMTP106 == true`。
- Fixture required validation 不依赖真实网络；real network download、production ingestion pipeline、cloud data lake、adapter request exposure、secret、signed endpoint、account endpoint、listenKey、broker、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、live command、trading button、multi-symbol 和 multi-timeframe flags 全部为 false，并通过初始化和 Codable 解码拒绝绕过。
- `TVM-DATA-CATALOG-SCENARIO-REPLAY` 已回填 MTP-105 issue evidence。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP105` | pass | 执行 4 个 Core tests，0 failures；覆盖 first scenario records、fixture version / source anchor、fixed window / record order、deterministic summary pre-structure、forbidden capability bypass rejection 和 Codable decode bypass rejection。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-105 contract、domain context、validation plan、matrix、latest summary、Core source 和 focused test anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 233 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`，最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 Linear status。
- 不启动 Symphony / Graphify。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 manifest file parser、replay cursor、final checksum evidence、freshness evidence runtime、data quality gate、report input versioning runtime、multi-symbol / multi-timeframe catalog、production dataset registry、production data platform、cloud data lake、large-scale ingestion pipeline、真实历史下载器、database schema exposure、adapter request exposure、signed endpoint、account endpoint / listenKey、secret、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、real account / broker position read、live runtime、order command、live command、trading button 或 Live PRO Console。

---

## 2026-05-26 — MTP-106 Replay Window / Cursor / Checksum / Freshness Evidence

执行者：Codex

目的：

- 完成 Linear issue `MTP-106 Add replay window / cursor / checksum / freshness evidence`。
- 基于 MTP-104 manifest 和 MTP-105 deterministic fixture 建立 local scenario replay 的 replay window、cursor summary、checksum / parity evidence 和 fixture freshness evidence。
- 输出可被 MTP-107 data quality gates 消费的稳定 `dataQualityGateInputIdentity`，但不实现 data quality gate runtime 或 report input versioning runtime。

文件范围：

- 新增 `Sources/Core/ScenarioReplayEvidence.swift`。
- 更新 `Tests/CoreTests/CoreTests.swift`，新增 4 个 MTP-106 focused Core tests。
- 更新 `docs/contracts/data-catalog-scenario-replay-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh`。
- 更新本 append-only `verification.md`。

关键证据：

- `ScenarioReplayWindow` 复用 MTP-105 deterministic fixture，固定 replay window `1704067200...1704067380`、record sequence `1,2,3`、ordered starts 和 record order identity。
- `ScenarioReplayCursor` 只表达本地 fixture record progress；默认 next sequence 为 `1`，completed sequence 为 `4`，Codable round-trip 后保持相等，并可按 sequence 稳定比较。
- `ScenarioReplayChecksumEvidence` 从 MTP-105 canonical checksum preimage 计算 final checksum `fnv1a64:3c6cd4ff13cd4062`，并拒绝 checksum drift。
- `ScenarioReplayFreshnessEvidence` 固定 local fixture freshness policy、evaluatedAt `1704067500`、age `120s` 和 status `fresh`，并拒绝 production retention / network / archive bypass。
- `ScenarioReplayEvidence` 保持 required validation network dependency、real network download、production retention engine、production data platform、database schema exposure、adapter request exposure、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、report input versioning runtime、data quality gate runtime、live runtime、live command 和 trading button flags 全部为 false。
- `TVM-DATA-CATALOG-SCENARIO-REPLAY` 已回填 MTP-106 issue evidence。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP106` | pass | 执行 4 个 Core tests，0 failures；覆盖 replay window deterministic、cursor 可复现 / 可编码 / 可比较、checksum / freshness evidence 稳定、drift rejection、forbidden capability bypass rejection 和 forbidden text absence。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-106 contract、domain context、validation plan、matrix、latest summary、Core source 和 focused test anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 237 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`，最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 Linear status。
- 不启动 Symphony / Graphify。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 manifest file parser、data quality gate runtime、report input versioning runtime、multi-symbol / multi-timeframe catalog、production dataset registry、production data platform、cloud data lake、large-scale ingestion pipeline、真实历史下载器、production scheduler、production retention cleanup、cloud archive、storage tiering、database schema exposure、adapter request exposure、signed endpoint、account endpoint / listenKey、secret、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、real account / broker position read、live runtime、order command、live command、trading button 或 Live PRO Console。

---

## 2026-05-26 — MTP-107 Data Quality Gates / Report Input Versioning

执行者：Codex

目的：

- 完成 Linear issue `MTP-107 Add data quality gates and report input versioning`。
- 基于 MTP-106 replay evidence 定义 scenario replay data quality gates 和 stable report input versioning。
- 让 Report / Backtest / future Simulated Exchange 能追溯 scenario id、dataset version、fixture version、replay window、checksum、freshness status 和 quality verdict，但不实现 Simulated Exchange / Backtest Parity runtime。

文件范围：

- 新增 `Sources/Core/ScenarioDataQualityReportInput.swift`。
- 更新 `Tests/CoreTests/CoreTests.swift`，新增 4 个 MTP-107 focused Core tests。
- 更新 `docs/contracts/data-catalog-scenario-replay-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh`。
- 更新本 append-only `verification.md`。

关键证据：

- `ScenarioDataQualityGateKind` 固定 record order、window coverage、checksum match、freshness status、missing data、duplicate data 六个最小 gate。
- `ScenarioDataQualityGateEvaluation` 默认消费 `ScenarioReplayEvidence.deterministicFixture`，默认全部 gates `passed` 且整体 `qualityVerdict == accepted`。
- bad record order、checksum mismatch、missing data、duplicate data 会产生 `qualityVerdict == rejected`；stale freshness 会产生 `qualityVerdict == marked`；expired freshness 会产生 `qualityVerdict == rejected`。
- `ScenarioReportInputVersion` 固定 scenario id、dataset version、fixture version、symbol、timeframe、replay window、checksum、freshness status、quality verdict、quality summary 和 canonical field order。
- `ScenarioDataQualityReportInputEvidence` 把 MTP-106 replay evidence、MTP-107 quality evaluation 和 report input version 绑定到同一 deterministic identity，并保持 `reportReproducibilityEvidenceHeld == true`。
- required validation network dependency、production data platform、production data observability、automatic download、automatic repair、broker / account reconciliation、Simulated Exchange / Backtest Parity implementation、database schema exposure、adapter request exposure、Runtime object read、secret、signed endpoint、account endpoint、listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、live runtime、live command 和 trading button flags 全部为 false，并通过初始化和 Codable 解码拒绝绕过。
- `TVM-DATA-CATALOG-SCENARIO-REPLAY` 已回填 MTP-107 issue evidence。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP107` | pass | 执行 4 个 Core tests，0 failures；覆盖 gate taxonomy、accepted verdict、report input version tracing、bad fixture / checksum mismatch / missing / duplicate data rejection、stale marking、expired rejection、forbidden capability bypass rejection 和 Codable decode bypass rejection。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-107 contract、domain context、validation plan、matrix、latest summary、Core source 和 focused test anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 241 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`，最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 Linear status。
- 不启动 Symphony / Graphify。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 manifest file parser、production data quality platform、production data observability、automatic download、automatic repair、broker / account reconciliation、Simulated Exchange / Backtest Parity runtime、multi-symbol / multi-timeframe catalog、production dataset registry、production data platform、cloud data lake、large-scale ingestion pipeline、真实历史下载器、production scheduler、production retention cleanup、cloud archive、storage tiering、database schema exposure、adapter request exposure、Runtime object read、signed endpoint、account endpoint / listenKey、secret、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、real account / broker position read、live runtime、order command、live command、trading button 或 Live PRO Console。

---

## 2026-05-26 — MTP-108 Workbench / Report / Events Scenario Replay Evidence Surface

执行者：Codex

目的：

- 完成 Linear issue `MTP-108 Add Workbench / Report / Events read-model evidence surface`。
- 把 MTP-106 scenario replay evidence 与 MTP-107 quality gate / report input versioning evidence 接入 App 层 read-model-only surface。
- 让 Report、Workbench 和 Events 能展示 scenario id、dataset version、fixture version、replay window、checksum、freshness status、quality verdict、report input version identity 和 quality gate timeline，但不新增 command surface、query language、Runtime / Adapter / Persistence schema、Live command、broker action 或交易按钮。

文件范围：

- 新增 `Sources/App/ScenarioReplayEvidenceSurface.swift`。
- 更新 `Sources/App/App.swift`、`Sources/App/DashboardShell.swift` 和 `Sources/App/PaperWorkflowEvidenceExplorer.swift`。
- 更新 `Tests/AppTests/AppTests.swift`，新增 `testMTP108ScenarioReplayEvidenceFeedsReportWorkbenchAndEventsReadOnly`，并调整已有 Workbench / Event Timeline regression expectations。
- 更新 `docs/contracts/data-catalog-scenario-replay-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh`。
- 更新本 append-only `verification.md`。

关键证据：

- `ScenarioReplayEvidenceReadModel` / `ScenarioReplayEvidenceViewModel` 只复制 stable fields：scenario id、dataset version、fixture version、symbol / timeframe、replay window、cursor、checksum、freshness status、quality verdict、report input version identity、drill-down entry 和 timeline entries。
- `ReportViewModel` 输出 scenario replay evidence count、scenario ids、dataset / fixture versions、replay windows、checksums、freshness statuses、quality verdicts、report input version identities、drill-down entries、timeline count、quality gate timeline count 和 read-model-only boundary flags。
- `DashboardShellWorkbenchSnapshot` 新增 scenario replay summary / drill-down metrics；Dashboard smoke 新增 `scenarioReplayEvidence` 和 `scenarioQualityGates` handles。
- `PaperWorkflowEvidenceExplorer` 新增 `scenario replay evidence` section，输出 replay window、cursor、checksum、freshness 和六个 quality gate timeline rows；full deterministic fixture timeline count 从 60 增至 70。
- required validation network dependency、production data platform / observability、automatic download / repair、broker / account reconciliation、Simulated Exchange / Backtest Parity implementation、database schema exposure、adapter request exposure、Runtime object read、secret、signed endpoint、account endpoint、listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、live runtime、command surface、order-level command、query language、live command、trading button、live trading authorization、broker action 和 trading execution authorization flags 全部保持 false。
- `TVM-DATA-CATALOG-SCENARIO-REPLAY` 已回填 MTP-108 issue evidence。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP108` | pass | 执行 1 个 App test，0 failures；覆盖 Report、Workbench、Events、Dashboard smoke、Codable stable snapshot、read-model-only boundary、no command surface、no query language、no trading button、no live command 和 no broker action。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-108 contract、domain context、validation plan、matrix、latest summary、App source、Dashboard / Events source 和 focused test anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 242 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`，最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 Linear status。
- 不启动 Symphony / Graphify。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 manifest parser、Runtime replay job、Adapter request、Persistence schema、database console、query language、command model、multi-symbol / multi-timeframe production catalog、production dataset registry、production data platform、cloud data lake、large-scale ingestion pipeline、真实历史下载器、production scheduler、production retention cleanup、cloud archive、storage tiering、schema inspector、Runtime inspector、signed endpoint、account endpoint / listenKey、secret、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、real account / broker position read、live runtime、order command、live command、trading button 或 Live PRO Console。
---

## 2026-05-26 — MTP-109 Data Catalog / Scenario Replay stage closeout

执行者：Codex

目的：

- 完成 Linear issue `MTP-109 Close validation matrix / automation readiness / stage audit input`。
- 收口 `MTPRO Data Catalog / Scenario Replay v1` 的 validation matrix、automation readiness anchors、stage audit input material、Project evidence chain 和 forbidden capability evidence。
- 准备 Parent Codex 后续输出 Stage Code Audit Report 的输入材料，但不输出最终 Stage Code Audit Report。

文件范围：

- 新增 `docs/audit/inputs/mtpro-data-catalog-scenario-replay-v1-stage-audit-input.md`。
- 更新 `docs/contracts/data-catalog-scenario-replay-contract.md`，新增 MTP-109 closeout / stage audit input / no final audit / validation evidence chain / forbidden capability / automation readiness anchors。
- 更新 `docs/validation/trading-validation-matrix.md`，补齐 `TVM-DATA-CATALOG-SCENARIO-REPLAY` MTP-109 issue backfill 和阶段收口说明。
- 更新 `docs/validation/validation-plan.md`，新增 MTP-109 Validation Docs / Stage Audit Input Validation。
- 更新 `docs/validation/latest-verification-summary.md`，记录 MTP-109 当前 issue execution evidence 和本地验证结果。
- 更新 `docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，增加 Data Catalog / Scenario Replay stage audit input readiness anchor 和机械检查。
- 更新本 append-only `verification.md`。

关键证据：

- Stage audit input 汇总 PR #201 至 #206 的 issue / PR evidence、merge commit、GitHub required check URL 和当前 MTP-109 PR 占位。
- `MTP-109-DATA-CATALOG-SCENARIO-REPLAY-VALIDATION-EVIDENCE-CHAIN` 覆盖 MTP-103 terminology / boundary、MTP-104 manifest identity、MTP-105 deterministic fixture、MTP-106 replay evidence、MTP-107 quality gates / report input versioning、MTP-108 Workbench / Report / Events read-model evidence。
- `MTP-109-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN` 确认 no manifest parser、no Runtime replay job、no production data platform、no automatic download / repair、no Simulated Exchange / Backtest Parity runtime、no schema / adapter / Runtime object exposure、no signed endpoint、no account endpoint / listenKey、no broker、no `LiveExecutionAdapter`、no OMS、no real order lifecycle、no live runtime、no live command、no trading button、no Graphify update、no Figma modification 和 no unauthorized Linear mutation。
- MTP-109 明确不创建 `docs/audit/mtpro-data-catalog-scenario-replay-v1-stage-code-audit.md`，最终 Stage Code Audit Report 仍归 Parent Codex。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 首次运行发现 stage input 缺少 literal `PR #206`；修正文案后重跑通过，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 通过 `git diff --check`、automation readiness、Dashboard build、Dashboard smoke 和 242 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`，最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 Linear status。
- 不启动 Symphony / Graphify。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不输出最终 Stage Code Audit Report。
- 不创建下一 Project / Issue，不推进下一阶段。
- 不实现 manifest parser、Runtime replay job、production data platform、production data observability、automatic download、automatic repair、broker / account reconciliation、Simulated Exchange / Backtest Parity runtime、multi-symbol / multi-timeframe production catalog、database schema exposure、adapter request exposure、Runtime object read、signed endpoint、account endpoint / listenKey、secret、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、real account / broker position read、live runtime、live command、trading button 或 Live PRO Console。

---

## 2026-05-26 — MTPRO Data Catalog / Scenario Replay Project closure root docs refresh

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 完成 `MTPRO Data Catalog / Scenario Replay v1` 的 Project closure 后 root docs refresh gate。
- 同步 `MTP-103` 至 `MTP-109` 全部 Done、PR #201 至 #207 全部 merged、Stage Code Audit Report 已落仓和 Linear Project `Completed/type=completed` 的已发生事实。
- 新增 Engine Maturity Roadmap 口径：`L1 Paper Runtime` Done、`L1.5 Data Catalog / Scenario Replay` Done、`L2 Simulated Exchange / Backtest Parity` Next candidate、`L2+ Workbench Beta Readiness` Future、`L3 Live Read-only Readiness` Future Gated、`L4 Live Production` Future Gated。
- 保持旧的 Final Product Goal Progress `9 / 9 (100%)` 不变。

文件范围：

- 更新 `GOAL.md`、`BLUEPRINT.md`、`architecture.md`、`docs/roadmap.md` 和 `docs/validation/latest-verification-summary.md`，同步 L1.5 closure、Project Closure Count `14 / 14 (100%)`、Engine Maturity Roadmap Progress `2 / 4 (50%)`、current maturity statement 和 next recommended maturity slice。
- 更新 `docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，新增 Data Catalog / Scenario Replay stage code audit report anchor 和 roadmap progress mechanical checks。
- 更新本 append-only `verification.md`。

关键证据：

- `docs/audit/mtpro-data-catalog-scenario-replay-v1-stage-code-audit.md` 已记录 Project goal achieved、Linear Project Completed evidence、MTP-103..MTP-109 issue / PR / merge / checks evidence、Engine Map Alignment、Scenario Replay Evidence Consistency、Boundary Audit、Root Docs Delta input 和 forbidden capability audit。
- Stage Code Audit PR #208 已通过 GitHub required check `checks` 并 squash merge，merge commit 为 `7cf641cd7124476d11f568289f87b153e92c80f9`，check run 为 `https://github.com/atxinbao/MTPRO/actions/runs/26424535064/job/77785448327`。
- Root Docs Refresh Gate 只同步已发生事实，不创建下一 Project / Issue，不推进下一阶段，不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma，不写业务代码。

当前成熟度：

- Engine Maturity Roadmap Progress：`2 / 4 (50%)`。
- Current maturity statement：`L1.5 Data Catalog / Scenario Replay complete`。
- Next recommended maturity slice：`L2 Simulated Exchange / Backtest Parity v1`。
- L3 Live Read-only Readiness 和 L4 Live Production 仍为 Future Gated，不计入当前 progress denominator。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Root Docs Refresh Gate 文档补丁完成后执行，无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 Data Catalog stage code audit report anchor、Engine Maturity Roadmap Progress、latest summary closure facts 和 forbidden boundary anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 242 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3`，最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改旧 `Final Product Goal Progress: 9 / 9 (100%)`。
- 不创建下一 Project / Issue。
- 不推进 Linear queue。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-27 — MTP-123 reproducible beta acceptance checklist / script

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-123 Add reproducible beta acceptance checklist / script`。
- 提供 operator 可复现的 local macOS Workbench beta acceptance workflow，覆盖本地环境、Dashboard smoke、demo scenario、Report / Dashboard / Events acceptance path、failure triage 和 boundary evidence。
- 复用 `bash checks/run.sh` 和现有 readiness pattern，不替代 CI，不进入 production ops，不运行 Graphify，不修改 Figma。

实现摘要：

- 新增 `checks/workbench-beta-acceptance.sh`，薄编排 `uname -s`、`swift --version`、`swift package resolve`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `bash checks/run.sh`。
- 脚本校验稳定 Dashboard smoke handles：`sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario`、`betaAcceptancePaths=1`、`betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario`、`betaAcceptanceTrace=5` 和 blocked live evidence。
- 新增 `docs/validation/workbench-beta-acceptance-checklist.md`，记录 operator checklist、local commands / expected outputs、operator reproducibility evidence、failure triage hints 和 forbidden boundary。
- 更新 `docs/contracts/workbench-beta-readiness-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，接入 MTP-123 anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash -n checks/workbench-beta-acceptance.sh` | pass | shell syntax check 无输出。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-123 contract、domain context、checklist、validation plan、matrix、latest summary、automation readiness 和 script anchors。 |
| `bash checks/workbench-beta-acceptance.sh` | pass | 输出 Swift 6.3 toolchain；`swift package resolve` 成功；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=64; scenarioReplayEvidence=1; scenarioQualityGates=6; simulatedParityEvidence=1; defaultDemoState=default demo; defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario; betaFirstRunFallbacks=3; betaAcceptancePaths=1; betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario; betaAcceptanceTrace=5; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；内部 `bash checks/run.sh` 通过 automation readiness、Dashboard build、Dashboard smoke 和 267 个 XCTest，最终输出 `MTPRO checks passed.`。 |
| `git diff --check` | pass | MTP-123 diff 无 whitespace / patch error 输出。 |
| `bash checks/run.sh` | pass | 更新 validation ledger 后最终重跑；通过 automation readiness、Dashboard build、Dashboard smoke 和 267 个 XCTest；Dashboard smoke 继续输出 `betaAcceptancePaths=1`、`betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario`、`betaAcceptanceTrace=5`、`readModelOnly=true` 和 `workbenchReadModelOnly=true`；最终输出 `MTPRO checks passed.`。 |

Operator evidence：

- `.codex/beta-acceptance/20260526T230034Z/summary.log`
- `.codex/beta-acceptance/20260526T230034Z/uname.log`
- `.codex/beta-acceptance/20260526T230034Z/swift-version.log`
- `.codex/beta-acceptance/20260526T230034Z/swift-package-resolve.log`
- `.codex/beta-acceptance/20260526T230034Z/dashboard-smoke.log`
- `.codex/beta-acceptance/20260526T230034Z/mtpro-checks.log`

边界确认：

- 不新增 engine core capability、Runtime replay job、App read model、Dashboard behavior 或 stage audit input。
- 不运行 Graphify，不修改 Figma，不创建 release package、notarized artifact、App Store build、auto-update channel、production deployment 或 cloud operations workflow。
- 不读取 API key、secret、account endpoint、listenKey、broker credential 或 production config。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-27 — MTP-119 local launch / install / environment verification path

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-119 Add local launch / install / environment verification path`。
- 定义 Workbench beta 的本地 environment verification、SwiftPM local install / run notes、Dashboard launch command / runbook、Dashboard smoke expectation、reproducible launch evidence 和 troubleshooting boundary。
- 明确 local launch / install path 是 beta acceptance evidence，不是 production release pipeline、notarization、App Store distribution、auto-update、production deployment、cloud operations 或 live readiness。

实现摘要：

- 更新 `docs/contracts/workbench-beta-readiness-contract.md`，新增 `MTP-119-LOCAL-LAUNCH-INSTALL-ENVIRONMENT-PATH`、`MTP-119-LOCAL-ENVIRONMENT-VERIFICATION`、`MTP-119-LOCAL-INSTALL-RUN-NOTES`、`MTP-119-LAUNCH-COMMAND-RUNBOOK`、`MTP-119-DASHBOARD-SMOKE-EXPECTATION`、`MTP-119-REPRODUCIBLE-LAUNCH-EVIDENCE`、`MTP-119-TROUBLESHOOTING-BOUNDARY` 和 `MTP-119-LOCAL-LAUNCH-VALIDATION` anchors。
- 更新 `docs/domain/context.md`，新增 MTP-119 local launch / install shared language，固定 local install 只表示 SwiftPM dependency resolution 和本地 `.build` artifact。
- 更新 `docs/validation/macos-build-run-loop.md`，记录 `swift package resolve`、`swift build --product Dashboard`、`swift run Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `bash checks/run.sh` 的本地 runbook。
- 更新 `docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `docs/automation/automation-readiness.md`，把 MTP-119 接入 validation / readiness spine。
- 更新 `checks/automation-readiness.sh`，机械检查 MTP-119 contract、domain context、macOS run-loop、validation plan、matrix、latest summary 和 automation readiness anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `uname -s && swift --version && DASHBOARD_SMOKE=1 swift run Dashboard` | pass | `uname -s` 输出 `Darwin`；Swift 为 Apple Swift 6.3；Dashboard product build 成功；smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; simulatedParityEvidence=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；一次 exact-string 缺口修正后通过 MTP-119 mechanical anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 261 个 XCTest；最终执行 261 tests、0 failures，并输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 `Sources/` 或 `Tests/`。
- 不新增 Dashboard smoke handle、App read model、Core / Runtime / Dashboard behavior 或 engine core capability。
- 不创建 production installer、release package、notarized artifact、App Store build、auto-update channel、production deployment 或 cloud operations workflow。
- 不新增 stage audit input；Project stage closeout 仍归属 `MTP-125`。
- 不运行 Graphify。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-26 — MTPRO Simulated Exchange / Backtest Parity v1 planning record

执行者：Codex

目的：

- 将 Human 确认的 `MTPRO Simulated Exchange / Backtest Parity v1` Project Draft 落仓为 docs-only planning record。
- 记录 Target Engines、Target maturity、Project goal、scope、non-goals、issue order、dependencies、validation requirements、evidence requirements、first executable issue candidate、WIP=1、Linear write boundary 和 repository record boundary。
- 为后续 Linear 写入和 Parent Codex queue preflight 提供 Project-level planning record；不授权执行。

文件范围：

- 新增 `docs/planning/projects/mtpro-simulated-exchange-backtest-parity-v1-plan.md`。
- 更新 `docs/planning/linear-draft-plan.md`，增加 planning record 索引并把当前 planning record 指向 `MTPRO Simulated Exchange / Backtest Parity v1`。
- 更新 `docs/validation/latest-verification-summary.md`，记录该 Project-level planning record 已落仓，且不属于 Project closure。
- 更新 `BLUEPRINT.md`，增加该 planning record 的蓝图入口。
- 更新本 append-only `verification.md`。

关键证据：

- planning record 明确 `Target maturity: L2 Backtest / Simulation Parity`。
- planning record 覆盖 8 个候选 issue 摘要：terminology / boundary、shared backtest-paper order semantics、scenario replay deterministic matching、market / limit simulated execution、partial fill / latency / fee / slippage parity、portfolio projection parity、Report / Dashboard / Events evidence surface、validation / readiness / audit input。
- planning record 明确仓库不复制维护完整 Linear issue body，后续 issue scope、Codex instructions、validation、boundary 和 PR requirements 以 Linear issue body 为准。
- latest summary 明确该 planning record 不更新 `Final Product Goal Progress`，不更新 `Engine Maturity Roadmap Progress`，后续执行必须经 Linear 写入和 Parent Codex queue preflight。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 无 whitespace error。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build / smoke 和 242 个 XCTest；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不写业务代码。
- 不修改 Figma。
- 不实现 Simulated Exchange。
- 不实现 Backtest Parity。
- 不更新 `Final Product Goal Progress`。
- 不更新 `Engine Maturity Roadmap Progress`。
- 不实现 signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-26 — MTP-110 Simulated Exchange / Backtest Parity terminology and boundary

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-110 Define simulated exchange / backtest parity terminology and boundary`。
- 定义 L2 `MTPRO Simulated Exchange / Backtest Parity v1` 的 terminology、target engine boundary、L1 Paper Runtime + L1.5 Data Catalog / Scenario Replay handoff boundary、forbidden capability baseline 和 validation anchors。
- 保持 contract-first，只建立 deterministic boundary fixture、docs anchors、validation matrix anchor 和 focused tests；不实现 runtime。

文件范围：

- 新增 `Sources/Core/SimulatedExchangeBacktestParityBoundary.swift`。
- 更新 `Sources/Core/CoreError.swift`，增加 simulated exchange / backtest parity contract mismatch 和 forbidden capability error。
- 更新 `Tests/CoreTests/CoreTests.swift`，新增 MTP-110 focused tests。
- 新增 `docs/contracts/simulated-exchange-backtest-parity-contract.md`。
- 更新 `docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh`。
- 更新本 append-only `verification.md`。

关键证据：

- `SimulatedExchangeBacktestParityBoundary` 固定 `simulated exchange`、`backtest parity`、`matching model`、`fill model`、`latency model`、`fee / slippage parity`、`portfolio projection parity`、`scenario replay integration`、`deterministic simulation` 和 `shared backtest-paper order semantics`。
- Target Engines 固定为 Simulation / Backtest Engine、Execution Engine（paper-only / simulated）、Portfolio Engine、Data Engine、State & Persistence Engine 和 Workbench Interface。
- Validation anchors 为 `MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-TERMINOLOGY`、`MTP-110-TARGET-ENGINE-RESPONSIBILITY-BOUNDARY`、`MTP-110-L1-L15-L2-HANDOFF-BOUNDARY`、`MTP-110-FORBIDDEN-CAPABILITY-BASELINE`、`MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-VALIDATION` 和 `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`。
- Forbidden flags 全部保持 false：matching runtime、order execution runtime、portfolio projection runtime、UI implementation、signed endpoint、account endpoint、listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、trading button、emergency stop / shutdown / restore、Graphify update 和 Figma change。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP110` | pass | 执行 3 个 Core tests，0 failures，验证 terminology / boundary anchors、runtime/live forbidden bypass rejection、Codable decode bypass rejection 和 L1 / L1.5 / L2 deterministic handoff boundary。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-110 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 245 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3`，最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 Linear status。
- 不创建下一 Project / Issue。
- 不推进下一 issue。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 matching runtime、order execution runtime、portfolio projection runtime、UI implementation、signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-26 — MTP-111 Shared backtest-paper order semantics contract

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-111 Add shared backtest-paper order semantics contract`。
- 定义 backtest 与 paper runtime 共用的 paper-only / simulated order input、simulated order state、simulated event kind 和 paper lifecycle / backtest replay alignment contract。
- 保持 contract-first，只建立 deterministic Core value fixture、docs anchors、validation matrix anchor 和 focused tests；不实现 matching、execution runtime、portfolio projection 或 UI。

文件范围：

- 新增 `Sources/Core/BacktestPaperSharedOrderSemantics.swift`。
- 更新 `Tests/CoreTests/CoreTests.swift`，新增 MTP-111 focused tests。
- 更新 `docs/contracts/simulated-exchange-backtest-parity-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh`。
- 更新本 append-only `verification.md`。

关键证据：

- `BacktestPaperSharedOrderSemanticsContract` 固定 paper order intent 与 backtest replay order input 的共享字段：input id、order id、source paper order intent id、proposal id、session id、scenario id、dataset version、fixture version、symbol、timeframe、side、quantity、reference price、notional amount、source risk decision sequence、source replay sequence 和 recorded at。
- Shared simulated order states 固定为 `intent recorded`、`submitted simulated`、`accepted simulated`、`rejected simulated`、`expired simulated`、`cancelled local only`、`failed local only`、`filled simulated` 和 `partially filled simulated`。
- Lifecycle / replay alignment 固定 `PaperOrderLifecycleState`、`PaperOrderLocalLifecycleState` 和 `PaperSimulatedFillCompletion` 到 shared simulated states 的映射，并把 scenario id / dataset version / fixture version 绑定到 L1.5 scenario replay identity。
- `BacktestPaperSharedOrderInput` 从既有 `PaperOrderIntent` 复制稳定字段，并绑定 `DeterministicScenarioFixture`；初始化和 Codable 解码拒绝 real command、signed/account/listenKey、broker、OMS、execution report、broker fill、reconciliation、live command 和 trading button 绕过。
- Validation anchors 为 `MTP-111-SHARED-BACKTEST-PAPER-ORDER-FIELDS`、`MTP-111-SIMULATED-ORDER-STATE-SEMANTICS`、`MTP-111-PAPER-LIFECYCLE-BACKTEST-REPLAY-ALIGNMENT`、`MTP-111-NO-REAL-ORDER-COMMAND-UPGRADE`、`MTP-111-SHARED-ORDER-SEMANTICS-VALIDATION` 和 `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP111` | pass | 执行 3 个 Core tests，0 failures，验证 shared fields / states / anchors、paper intent 到 scenario replay input 对齐、state / event mapping、forbidden capability bypass rejection 和 Codable decode bypass rejection。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-111 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 248 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3`，最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 Linear status。
- 不创建下一 Project / Issue。
- 不推进下一 issue。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 matching runtime、order execution runtime、portfolio projection runtime、Report / Dashboard / Events evidence surface、UI implementation、order form、command model、signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、order-level command UI、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-26 — MTP-112 Scenario replay deterministic matching model

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-112 Add scenario replay deterministic matching model`。
- 基于 MTP-106 scenario replay evidence 和 MTP-111 shared order input 建立 deterministic matching model 的 Core value 闭环。
- 保持 deterministic first：相同 scenario id / dataset version / fixture version / replay window / cursor / shared order input 必须输出相同 simulated exchange matching event。

文件范围：

- 新增 `Sources/Core/ScenarioReplayDeterministicMatching.swift`。
- 更新 `Tests/CoreTests/CoreTests.swift`，新增 MTP-112 focused tests。
- 更新 `docs/contracts/simulated-exchange-backtest-parity-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh`。
- 更新本 append-only `verification.md`。

关键证据：

- `ScenarioReplayDeterministicMatchingContract` 固定 ordering rules、output kinds、validation anchors 和 forbidden capability baseline。
- `ScenarioReplayDeterministicMatchingInput` 绑定 `BacktestPaperSharedOrderInput.deterministicFixture`、MTP-106 replay window / cursor / checksum / freshness evidence 和 MTP-105 fixture record sequence `2`。
- `ScenarioReplayMatchingMarketState` 要求 cursor `nextRecordSequence` 与 market record sequence 相等，避免环境状态或真实行情绕过本地 replay。
- `ScenarioReplayDeterministicMatchingModel.match` 输出 `ScenarioReplayDeterministicMatchingOutput`，其中 `ScenarioReplaySimulatedExchangeEvent` 固定 event kind `simulated exchange order matched`、shared state `filled simulated`、shared event kind `simulated order filled`、matched price `42120.70` 和 matched quantity `0.5`。
- Deterministic result identity 固定为 `mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|cursor=2|record=2|order=paper-order-intent-allowed|price=42120700000|quantity=500000`。
- Validation anchors 为 `MTP-112-SCENARIO-REPLAY-MATCHING-INPUT`、`MTP-112-DETERMINISTIC-MATCHING-ORDERING`、`MTP-112-SIMULATED-EXCHANGE-MATCHING-EVENT`、`MTP-112-REPEATABLE-MATCHING-OUTPUT`、`MTP-112-NO-NETWORK-BROKER-LIVE`、`MTP-112-SCENARIO-REPLAY-MATCHING-VALIDATION` 和 `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP112` | pass | 执行 3 个 Core tests，0 failures，验证 input / output anchors、repeatable output identity、Codable round-trip、forbidden capability bypass rejection 和 cursor / record mismatch rejection。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-112 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 251 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3`，最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 Linear status。
- 不创建下一 Project / Issue。
- 不推进下一 issue。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现真实 matching runtime、market / limit execution runtime、partial fill / latency / fee / slippage parity、portfolio projection runtime、Report / Dashboard / Events evidence surface、UI implementation、order form、command model、Runtime replay job、database console、signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、order-level command UI、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-26 — MTP-113 Market / limit order simulated execution semantics

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-113 Add market / limit order simulated execution semantics`。
- 基于 MTP-112 deterministic matching output 和 MTP-111 shared order input 建立 market / limit order 的最小 simulated execution 语义。
- 保持 deterministic first：相同 scenario id / dataset version / fixture version / replay window / cursor / shared order input / order type / limit price / initial state 必须输出相同 full fill、reject 或 expire evidence。

文件范围：

- 新增 `Sources/Core/MarketLimitSimulatedExecutionSemantics.swift`。
- 更新 `Tests/CoreTests/CoreTests.swift`，新增 MTP-113 focused tests。
- 更新 `docs/contracts/simulated-exchange-backtest-parity-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh`。
- 更新本 append-only `verification.md`。

关键证据：

- `MarketLimitSimulatedExecutionContract` 固定 order types、outcomes、execution rules、validation anchors 和 forbidden capability baseline。
- `MarketLimitSimulatedExecutionInput` 绑定 MTP-112 deterministic matching input 和 MTP-111 shared order input；market order 拒绝 limit price，limit order 要求 explicit limit price。
- `MarketLimitSimulatedExecutionModel.execute` 输出 market full fill、buy limit full fill、buy limit expire 和 rejected initial state evidence。
- `MarketLimitSimulatedExecutionEvent` 固定 `full fill simulated` -> `filled simulated` / `simulated order filled`，`rejected simulated` -> `rejected simulated` / `simulated order rejected`，`expired simulated` -> `expired simulated` / `simulated order expired`。
- Limit expire deterministic result identity 固定为 `mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|cursor=2|record=2|order=paper-order-intent-allowed|orderType=limit order simulated execution|limit=42100000000|initialState=accepted simulated|outcome=expired simulated|matchedPrice=42120700000|filled=0|remaining=500000`。
- Validation anchors 为 `MTP-113-MARKET-ORDER-SIMULATED-EXECUTION`、`MTP-113-LIMIT-ORDER-SIMULATED-EXECUTION`、`MTP-113-FULL-FILL-REJECT-EXPIRE-SEMANTICS`、`MTP-113-DETERMINISTIC-EXECUTION-REPLAY`、`MTP-113-NO-REAL-ORDER-LIVE-COMMAND`、`MTP-113-MARKET-LIMIT-SIMULATED-EXECUTION-VALIDATION` 和 `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP113` | pass | 执行 3 个 Core tests，0 failures，验证 market / limit semantics anchors、market full fill、limit full fill、limit expire、reject evidence、deterministic replay identity、Codable round-trip 和 forbidden capability rejection。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-113 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 254 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3`，最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 Linear status。
- 不创建下一 Project / Issue。
- 不推进下一 issue。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 stop / OCO / advanced order types、真实 order execution runtime、matching runtime、partial fill、latency、fee / slippage parity、portfolio projection runtime、Report / Dashboard / Events evidence surface、UI implementation、order form、command model、Runtime replay job、database console、signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、order-level command UI、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-26 — MTP-113 continuation handoff evidence

执行者：Codex

目的：

- 记录 `MTP-113` ready-for-review PR handoff 后的 continuation 状态，避免后续 agent 重复排查 GitHub / Symphony 状态。
- 保持 append-only evidence chain；不修改 Linear status，不绕过 GitHub required checks。

观察：

- PR `https://github.com/atxinbao/MTPRO/pull/214` 已创建为 ready-for-review，PR body 包含 `Fixes MTP-113`。
- Squash auto-merge 已启用。
- GitHub repository ruleset `protect-main` 要求 `checks` status check；截至 continuation turn #3，PR head `2bc09c0f827144513a800c886fde98fe43718ea0` 没有 status contexts，也没有 check runs。
- 已尝试 empty synchronize commit、close / reopen PR、重新启用 auto-merge；GitHub 仍报告 `mergeStateStatus=BLOCKED` 且 `statusCheckRollup=[]`。
- `.codex/symphony-issue-handoff.json` 已通过 Symphony `handoff_marker_for_test` parser，返回 `{:ready, marker}`；该文件不进入 PR。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `gh pr view 214 --json url,state,isDraft,mergeStateStatus,autoMergeRequest,mergedAt,statusCheckRollup,headRefOid` | pass | PR open、not draft、auto-merge enabled、`mergeStateStatus=BLOCKED`、`statusCheckRollup=[]`。 |
| `gh api repos/atxinbao/MTPRO/rulesets/16463304` | pass | `protect-main` ruleset 要求 GitHub Actions integration `15368` 的 `checks` required status check。 |
| `mix run -e 'SymphonyElixir.Orchestrator.handoff_marker_for_test(...)'` | pass | 本地 handoff marker 被 Symphony parser 判定为 `{:ready, marker}`。 |

边界确认：

- 不修改 Linear status。
- 不直接 merge PR。
- 不创建或绕过 required status check。
- 不提交 `.codex/*` 或 `graphify-out/*`。

---

## 2026-05-26 — MTP-114 partial fill / latency / fee / slippage parity evidence

执行者：Codex

目的：

- 完成 `MTP-114` Add partial fill / latency / fee / slippage parity 的当前 issue scope。
- 保持 MTP-114 只输出 deterministic simulated exchange event / report evidence，不扩大到 portfolio projection、Report / Dashboard / Events surface、broker fill、execution report、reconciliation 或 live readiness。

实现摘要：

- 新增 `Sources/Core/PartialFillLatencyFeeSlippageParity.swift`。
- `PartialFillLatencyFeeSlippageParityContract` 固定 MTP-114 rules、fill completions、validation anchors 和 forbidden capability baseline。
- `PartialFillLatencyFeeSlippageParityInput` 复用 MTP-113 market / limit simulated execution input，绑定 deterministic available liquidity、MTP-114 latency assumption、liquidity role 和 MTP-27 fixed cost assumptions。
- `PartialFillLatencyFeeSlippageParityModel.evaluate` 复用 MTP-113 full-fill source output；partial fixture 使用 available liquidity `0.25` 输出 `partial` / `partially filled simulated` / `simulated order partially filled`，filled `0.25`、remaining `0.25`；full fixture 使用 available liquidity `0.5` 输出 `full` / `filled simulated` / `simulated order filled`，remaining `0`。
- Latency fixture 固定 replay record sequence `2 -> 3` 和 `250ms`，不使用 wall clock、randomness 或外部网络。
- Fee / slippage parity 复用 MTP-27 fixed assumptions `mtp-27-fixed-cost-assumptions`，taker fee `5 bps`、slippage `1.5 bps`、rounding scale `8`，并用 `ExecutionCostParity.verify` 证明 Backtest / Paper cost estimates 一致。
- Partial deterministic report identity 固定为 `mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|cursor=2|record=2|order=paper-order-intent-allowed|orderType=market order simulated execution|limit=none|initialState=accepted simulated|availableLiquidity=250000|latencyAssumption=mtp-114-deterministic-latency-assumption|latencySource=2|latencyOutput=3|liquidityRole=taker|costAssumption=mtp-27-fixed-cost-assumptions|fill=partial|latencyMs=25000000000|latencyRecord=3|filled=250000|remaining=250000|fee=526508750|slippage=157952625|totalCost=684461375`。
- 更新 `docs/contracts/simulated-exchange-backtest-parity-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh` 的 MTP-114 anchors / evidence chain。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP114` | pass | 执行 3 个 Core tests，0 failures，验证 contract anchors、partial fill evidence、full fill evidence、latency evidence、fee / slippage parity、deterministic identity、Codable round-trip 和 forbidden capability rejection。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-114 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 257 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`，最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 Linear status。
- 不创建下一 Project / Issue。
- 不推进下一 issue。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现完整交易所费率表、动态滑点模型、真实流动性消耗、执行成本优化、portfolio projection runtime、Report / Dashboard / Events evidence surface、UI implementation、order form、command model、Runtime replay job、database console、signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、order-level command UI、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-26 — MTP-115 simulated exchange portfolio projection parity evidence

执行者：Codex

目的：

- 完成 `MTP-115` Add simulated exchange events to portfolio projection parity 的当前 issue scope。
- 保持 MTP-115 只输出 deterministic simulated exchange event -> backtest / paper portfolio projection parity value evidence，不扩大到 portfolio runtime、Report / Dashboard / Events surface、真实账户、broker position、margin、leverage、broker reconciliation 或 live command。

实现摘要：

- 新增 `Sources/Core/SimulatedExchangePortfolioProjectionParity.swift`。
- `SimulatedExchangePortfolioProjectionParityContract` 固定 MTP-115 rules、projection modes、validation anchors 和 forbidden capability baseline。
- `SimulatedExchangePortfolioProjectionParityInput` 消费 MTP-114 `PartialFillLatencyFeeSlippageParityReportEvidence`，绑定 MTP-107 `ScenarioReportInputVersion` 和 source replay sequence `3`。
- `SimulatedExchangePortfolioProjectionParityModel.project` 用同一个 simulated exchange parity event 生成 backtest / paper projection，并用 `parityComparableIdentity` 证明两侧 quantity、cash、PnL 和 exposure 一致。
- 默认 partial fixture 固定 net quantity `0.25`、matched price `42120.70`、gross exposure `10530.175`、cash `39462.98038625`、equity `49993.15538625`、net simulated PnL `-6.84461375`。
- Full fixture 固定 net quantity `0.5`、gross exposure `21060.35`、cash `28925.9607725`、net simulated PnL `-13.6892275`。
- 更新 `docs/contracts/simulated-exchange-backtest-parity-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh` 的 MTP-115 anchors / evidence chain。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP115` | pass | 执行 3 个 Core tests，0 failures，验证 contract anchors、report input / replay evidence、backtest / paper projection parity、position / cash / PnL / exposure numeric summary、full / partial fixtures、Codable round-trip 和 forbidden capability rejection。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-115 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 260 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`，最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 Linear status。
- 不创建下一 Project / Issue。
- 不推进下一 issue。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 portfolio projection runtime、Report / Dashboard / Events evidence surface、UI implementation、order form、command model、Runtime replay job、database console、signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、database schema read、Runtime object read、Live PRO Console、order-level command UI、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-27 — MTP-116 Report / Dashboard / Events parity evidence surface

执行者：Codex

目的：

- 完成 `MTP-116` Add Report / Dashboard / Events parity evidence surface 的当前 issue scope。
- 保持 MTP-116 只复制 MTP-112 至 MTP-115 deterministic simulated exchange parity facts 到 App read model，不扩大到 matching runtime、order execution runtime、portfolio projection runtime、signed endpoint、account endpoint / listenKey、broker、Live PRO Console、live command、order-level command UI 或交易按钮。

实现摘要：

- 新增 `Sources/App/SimulatedExchangeParityEvidenceSurface.swift`。
- `SimulatedExchangeParityEvidenceReadModel` / `SimulatedExchangeParityEvidenceViewModel` 汇总 scenario id、dataset / fixture version、replay window、matching result、partial / full / reject / expire outcomes、latency、fee / slippage、portfolio projection parity、report input version identity 和 source replay sequence。
- `ReportViewModel` 新增 simulated exchange parity evidence fields，并保持 no schema / no runtime / no adapter / no command / no trading authorization boundary。
- `DashboardShellSnapshot` 新增 Report metric `Sim parity`、Workbench `Simulated Exchange Parity` details 和 Dashboard smoke `simulatedParityEvidence` handle。
- `PaperWorkflowEvidenceExplorerViewModel` 新增 `simulated exchange parity evidence` section，输出 scenario、matching、fill summary、reject / expire、latency / cost、portfolio parity、report input / replay consistency timeline rows。
- 更新 `docs/contracts/simulated-exchange-backtest-parity-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh` 的 MTP-116 anchors / evidence chain。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests.testMTP116SimulatedExchangeParityReadModelFeedsReportDashboardAndEvents` | pass | 执行 1 个 App test，0 failures，验证 Report / Dashboard / Events read-model-only parity surface、deterministic fields、timeline section、Dashboard smoke `simulatedParityEvidence=1` 和 forbidden capability boundary。 |
| `swift test --filter AppTests` | pass | 执行 30 个 App tests，0 failures，验证 App / Dashboard / Events snapshots 和 Codable round-trip。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-116 contract、matrix、validation plan、domain context、latest summary、App source、Dashboard / Events source 和 focused test anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 261 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; simulatedParityEvidence=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`，最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 Linear status。
- 不创建下一 Project / Issue。
- 不推进下一 issue。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 matching runtime、order execution runtime、portfolio projection runtime、UI implementation、order form、command model、Runtime replay job、database console、signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、database schema read、Runtime object read、Live PRO Console、order-level command UI、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-27 — MTP-117 validation matrix / automation readiness / stage audit input closeout

执行者：Codex

目的：

- 完成 `MTP-117` Close validation matrix / automation readiness / stage audit input 的当前 issue scope。
- 将 Simulated Exchange / Backtest Parity v1 的 MTP-110 至 MTP-116 evidence chain 收口到 validation matrix、automation readiness 和 stage-audit-input 材料。
- 保持 MTP-117 只产出 Stage Code Audit input，不输出最终 Stage Code Audit Report，不修改 Linear status，不运行 Graphify / Figma，不扩大到 live trading、signed/account endpoint、broker、OMS、order-level command UI 或真实交易动作。

实现摘要：

- 更新 `docs/contracts/simulated-exchange-backtest-parity-contract.md`，新增 `MTP-117-SIMULATED-EXCHANGE-BACKTEST-PARITY-STAGE-CLOSEOUT`、`MTP-117-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-117-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-117-SIMULATED-EXCHANGE-BACKTEST-PARITY-STAGE-AUDIT-INPUT`、`MTP-117-SIMULATED-EXCHANGE-BACKTEST-PARITY-VALIDATION-EVIDENCE-CHAIN`、`MTP-117-FORBIDDEN-LIVE-CAPABILITY-EVIDENCE-CHAIN`、`MTP-117-L2-PARITY-EVIDENCE-COMPLETE` 和 `MTP-117-AUTOMATION-READINESS-STAGE-CLOSEOUT` anchors。
- 新增 `docs/audit/inputs/mtpro-simulated-exchange-backtest-parity-v1-stage-audit-input.md`，记录 Linear queue、PR #211 至 PR #217 merge evidence、local validation、forbidden live capability boundary 和 Root Docs Delta input。
- 更新 `docs/validation/trading-validation-matrix.md`、`docs/validation/validation-plan.md`、`docs/validation/latest-verification-summary.md` 和 `docs/automation/automation-readiness.md`，把 MTP-117 closeout 接入现有 validation / readiness spine。
- 更新 `checks/automation-readiness.sh`，用 exact-string anchors 机械检查 MTP-117 contract、matrix、latest summary、stage-audit-input、readiness doc、forbidden live capability evidence、Graphify/Figma/Linear mutation non-goals 和 Dashboard smoke `simulatedParityEvidence=0` handle。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；覆盖 MTP-117 closeout anchors、stage audit input anchors、PR evidence anchors、forbidden live capability anchors、Graphify / Figma / Linear mutation non-goal anchors 和 Dashboard smoke handle。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 261 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; simulatedParityEvidence=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`，最终执行 261 tests、0 failures，并输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 Linear status。
- 不创建下一 Project / Issue。
- 不推进下一 issue。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不输出最终 Stage Code Audit Report；只输出 `docs/audit/inputs/mtpro-simulated-exchange-backtest-parity-v1-stage-audit-input.md` 作为 audit input。
- 不实现 live trading、signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、database schema read、Runtime object read、Live PRO Console、order-level command UI、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-27 — MTPRO Simulated Exchange / Backtest Parity v1 Stage Code Audit Report

执行者：Codex

目的：

- 完成 `MTPRO Simulated Exchange / Backtest Parity v1` 的 Project closure Stage Code Audit Report 落仓。
- 汇总 `MTP-110` 至 `MTP-117` 的 Linear / PR / required check / merge commit / validation evidence chain。
- 保持本轮只做 docs/checks-only stage audit，不写业务 runtime，不创建下一 Project / Issue，不启动 Graphify 或 Figma。

实现摘要：

- 新增 `docs/audit/mtpro-simulated-exchange-backtest-parity-v1-stage-code-audit.md`。
- 更新 `docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，新增 Simulated Exchange / Backtest Parity stage code audit report anchor。
- Stage Code Audit Report 记录 Linear Project `Completed/type=completed`、`completedAt=2026-05-26T16:37:03.216Z`、PR #211 至 #218 evidence chain、Engine map alignment、L2 maturity statement、deterministic matching / simulated execution / cost parity / portfolio parity evidence、forbidden capability audit、Known CI Boundary 和 Root Docs Delta input。

验证：

| 命令 / evidence | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Stage Code Audit docs/checks-only diff 无 whitespace / patch error 输出。 |
| `swift package clean && swift test --filter PersistenceTests.testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant` | pass | 清理 SwiftPM 缓存后 focused PersistenceTests 单测通过；前一次 local `xctest` signal 11 未形成业务代码缺陷。 |
| `bash checks/run.sh` | pass | Stage Code Audit 分支通过 automation readiness、Dashboard build、Dashboard smoke 和 261 个 XCTest，最终输出 `MTPRO checks passed.`。 |
| PR #219 `checks` | pass | GitHub required check run `https://github.com/atxinbao/MTPRO/actions/runs/26463215187/job/77916434547` 成功。 |
| PR #219 merge | pass | Squash merge commit `4ca2904592b5e13d32caac1ffbcb0ea0c4a19a58`。 |

边界确认：

- 不创建下一 Project / Issue。
- 不推进下一 issue。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-27 — MTPRO Simulated Exchange / Backtest Parity Project closure root docs refresh

执行者：Codex

目的：

- 完成 `MTPRO Simulated Exchange / Backtest Parity v1` 的 Root Docs Refresh Gate。
- 只同步已发生事实：`MTP-110` 至 `MTP-117` 全部 Done、Stage Code Audit Report 已落仓、L2 Simulated Exchange / Backtest Parity 本阶段闭环完成。
- 保持旧 `Final Product Goal Progress: 9 / 9 (100%)` 不变，并把 Engine Maturity Roadmap Progress 更新为 `3 / 4 (75%)`。

实现摘要：

- 更新 `GOAL.md`、`BLUEPRINT.md`、`architecture.md`、`docs/roadmap.md` 和 `docs/validation/latest-verification-summary.md`，同步 `L2 Simulated Exchange / Backtest Parity complete`、`Next recommended maturity slice: L2+ Workbench Beta Readiness v1`、Project Closure Count `15 / 15 (100%)` 和 Stage Code Audit PR #219 evidence。
- 更新 `docs/audit/mtpro-simulated-exchange-backtest-parity-v1-stage-code-audit.md`，把 Root Docs Refresh Gate 从 pending 更新为 closed。
- 更新 `docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，新增 root docs refresh 机械 anchor，检查 `3 / 4 (75%)`、L2 complete 和 L2+ next candidate。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 L2 closure root docs anchors。 |
| `git diff --check` | pass | Root Docs Refresh docs/checks-only diff 无 whitespace / patch error 输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 261 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; simulatedParityEvidence=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`，最终执行 261 tests、0 failures，并输出 `MTPRO checks passed.`。 |

边界确认：

- 不创建下一 Project / Issue。
- 不推进下一 issue。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不修改 Figma。
- 不写业务 runtime。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- L3 / L4 仍为 Future Gated，不计入当前 progress denominator。
- 不把 Live read-only 或 Live production 写成当前 execution scope。
- 不授权 signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-27 — MTPRO Workbench Beta Readiness v1 docs-only planning record

执行者：Codex

目的：

- 将 Human 确认的 `MTPRO Workbench Beta Readiness v1` planning draft 落仓为 docs-only Project Planning Record。
- 只记录 L2+ Workbench Beta Readiness 的 Project 级计划摘要、issue order、dependencies、validation requirements、evidence requirements、first executable issue candidate、WIP=1 / queue preflight rule、Linear write boundary 和 repository record boundary。
- 明确该 planning record 不授权执行，不创建 Linear Project / Issue，不推进 Todo，不启动 `@002 / PAR`、Symphony 或 Graphify，不实现 Workbench Beta Readiness 或任何真实交易能力。

实现摘要：

- 新增 `docs/planning/projects/mtpro-workbench-beta-readiness-v1-plan.md`，记录 `MTPRO Workbench Beta Readiness v1` 的 target engines / layers、target maturity `L2+ Workbench Beta Readiness`、baseline、scope、non-goals、8 个候选 issue 摘要、dependencies、validation / evidence requirements 和 queue preflight boundary。
- 更新 `docs/planning/linear-draft-plan.md`，把 `MTPRO Simulated Exchange / Backtest Parity v1` 标记为已完成并新增 `MTPRO Workbench Beta Readiness v1` 当前 docs-only / non-executable planning record 入口。
- 轻量更新 `BLUEPRINT.md` 和 `docs/validation/latest-verification-summary.md`，增加 Workbench Beta Readiness planning record 引用，并明确不更新 `Final Product Goal Progress` 或 `Engine Maturity Roadmap Progress`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | docs-only planning diff 无 whitespace / patch error 输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 261 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; simulatedParityEvidence=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`，最终执行 261 tests、0 failures，并输出 `MTPRO checks passed.`。 |

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不写业务代码。
- 不修改 Figma。
- 不实现 Workbench Beta Readiness。
- 不新增 engine core capability。
- 不实现 production release、notarization、App Store distribution、auto-update 或 production operations。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-27 — MTP-118 Workbench beta readiness contract and acceptance boundary

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-118 Define Workbench beta readiness contract and acceptance boundary`。
- 只定义 Workbench beta readiness contract、acceptance boundary、local-only beta demo path、L1 / L1.5 / L2 / L2+ handoff boundary、forbidden capability baseline 和 first executable candidate non-authorization。
- 明确 L2+ Workbench Beta Readiness 是 local macOS Workbench demo / acceptance path，不是 production release 或 live readiness。

实现摘要：

- 新增 `docs/contracts/workbench-beta-readiness-contract.md`，建立 `MTP-118-WORKBENCH-BETA-READINESS-TERMINOLOGY`、`MTP-118-BETA-ACCEPTANCE-BOUNDARY`、`MTP-118-LOCAL-ONLY-BETA-DEMO-PATH`、`MTP-118-L1-L15-L2-L2PLUS-HANDOFF`、`MTP-118-FORBIDDEN-CAPABILITY-BASELINE`、`MTP-118-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`、`MTP-118-WORKBENCH-BETA-READINESS-VALIDATION` 和 `TVM-WORKBENCH-BETA-READINESS` anchors。
- 更新 `docs/domain/context.md`，新增 Workbench Beta Readiness Terms。
- 更新 `docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md` 和 `docs/automation/automation-readiness.md`，把 MTP-118 接入 validation / readiness spine。
- 更新 `checks/automation-readiness.sh`，机械检查 MTP-118 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、planning record 和 forbidden capability boundary strings。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-118 contract / matrix / validation / domain / latest summary / automation readiness anchors。 |
| `git diff --check` | pass | 无 whitespace / patch error 输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 261 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; simulatedParityEvidence=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`，最终执行 261 tests、0 failures，并输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 `Sources/` 或 `Tests/`。
- 不实现 install / run 逻辑。
- 不新增 engine core capability。
- 不创建 release package。
- 不实现 production release、notarization、App Store distribution、auto-update 或 production operations。
- 不启动下一 issue，不推进 MTP-119。
- 不启动新的 Project。
- 不运行 Graphify。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
---

## 2026-05-27 — MTP-120 Workbench beta demo scenario selection and fixture wiring

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-120 Add demo scenario selection and fixture wiring`。
- 固定 Workbench beta demo scenario、dataset version 和 fixture version。
- 复用本地 deterministic L1.5 Scenario Replay evidence 与 L2 Simulated Exchange / Backtest Parity evidence，输出 checksum / freshness / relationship evidence。
- 保持 local-only / read-model handoff boundary，不新增网络下载、production data platform、Runtime replay job、Workbench first-run state、Report / Dashboard / Events acceptance path 或任何 live / broker / signed / account / OMS / trading capability。

实现摘要：

- 新增 `Sources/Core/WorkbenchBetaDemoScenario.swift`，定义 `WorkbenchBetaDemoScenarioSelection` 和 `WorkbenchBetaDemoFixtureEvidence`。
- `WorkbenchBetaDemoScenarioSelection` 固定 `mtp-104-btcusdt-1m-first-scenario`、`dataset-v1`、`fixture-v1`、`BTCUSDT` / `1m` 和 MTP-120 validation anchors。
- `WorkbenchBetaDemoFixtureEvidence` 复用 `ScenarioDataQualityReportInputEvidence.deterministicFixture` 与 `SimulatedExchangePortfolioProjectionParityFixture.deterministicEvidence()`，固定 checksum `fnv1a64:3c6cd4ff13cd4062`、freshness `fresh`、quality `accepted`、report input version identity 和 L1.5 / L2 relationship summary。
- 更新 `Tests/CoreTests/CoreTests.swift`，新增 3 个 MTP-120 focused Core tests，覆盖 deterministic selection、fixture wiring、Codable round-trip、scenario mismatch rejection 和 forbidden capability bypass rejection。
- 更新 `docs/contracts/workbench-beta-readiness-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，接入 MTP-120 anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP120` | first run failed | 3 focused tests build completed；`testMTP120WorkbenchBetaDemoFixtureRoundTripsAndRejectsBypass` 暴露 synthesized Codable decoding 会绕过 top-level fixture flags。 |
| `swift test --filter MTP120` | pass | 3 focused Core tests, 0 failures；验证 demo selection、fixture wiring、checksum / freshness、L1.5 / L2 relationship、Codable round-trip 和 bypass rejection。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-120 contract、domain context、validation plan、matrix、latest summary、automation readiness、Core source 和 focused tests anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 264 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; simulatedParityEvidence=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；最终执行 264 tests、0 failures，并输出 `MTPRO checks passed.`。 |

边界确认：

- 不新增 fixture records、大规模 ingestion、automatic downloader、production data platform、production dataset registry 或 Runtime replay scheduler。
- 不提前实现 Workbench first-run state、Report / Dashboard / Events acceptance path、Dashboard smoke handle、App read model、Runtime / Dashboard behavior 或 stage audit input。
- 不读取 secret，不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
- 不运行 Graphify，不修改 Figma，不修改 Linear status，不推进下一 issue。

---

## 2026-05-27 — MTP-121 Workbench first-run / default demo state

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-121 Add Workbench first-run / default demo state`。
- 让 Workbench 本地启动后默认进入可理解的 beta demo state。
- 只通过 App Read Model / ViewModel 和 Dashboard smoke 展示 local beta evidence，不暴露 database schema、Runtime object、adapter request 或交易命令。
- 保持 MTP-121 只消费 MTP-120 deterministic fixture wiring，不提前实现 MTP-122 Report / Dashboard / Events acceptance path 或 stage audit input。

实现摘要：

- 新增 `Sources/App/WorkbenchBetaFirstRunState.swift`，定义 `WorkbenchBetaFirstRunReadModel`、`WorkbenchBetaFirstRunViewModel`、`WorkbenchBetaFirstRunEvidenceSummary` 和 `WorkbenchBetaFirstRunFallbackState`。
- 将 `DashboardReadModel` / `DashboardViewModel` 扩展为消费 `workbenchBetaFirstRun` read model，默认状态固定为 `default demo`。
- 更新 `Sources/App/DashboardShell.swift`，在 Dashboard smoke 中输出 `defaultDemoState=default demo`、`defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario`、`betaFirstRunFallbacks=3`、`scenarioReplayEvidence=1` 和 `simulatedParityEvidence=1`。
- 更新 `Sources/Dashboard/DashboardApplication.swift`，让本地 Dashboard smoke / launch snapshot 使用 `DashboardViewModel.defaultWorkbenchBetaDemo`。
- 更新 `Tests/AppTests/AppTests.swift`，新增 2 个 MTP-121 focused App tests，覆盖 default selected scenario、read-model-only Dashboard state、empty / loading / error fallback、first-run evidence summary、Dashboard smoke handles 和 forbidden capability flags。
- 更新 `docs/contracts/workbench-beta-readiness-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，接入 MTP-121 anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP121` | pass | 2 个 App tests、0 failures；验证 first-run default demo state、fallback states、read-model-only boundary 和 forbidden capability flags。 |
| `DASHBOARD_SMOKE=1 swift run Dashboard` | pass | Dashboard product build 成功；smoke 输出 `scenarioReplayEvidence=1`、`simulatedParityEvidence=1`、`defaultDemoState=default demo`、`defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario`、`betaFirstRunFallbacks=3`、`readModelOnly=true` 和 `workbenchReadModelOnly=true`。 |
| `git diff --check` | pass | MTP-121 diff 无 whitespace / patch error 输出。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-121 contract、domain context、validation plan、matrix、latest summary、automation readiness、App source、Dashboard source 和 focused tests anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 266 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=59; scenarioReplayEvidence=1; scenarioQualityGates=6; simulatedParityEvidence=1; defaultDemoState=default demo; defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario; betaFirstRunFallbacks=3; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；最终执行 266 tests、0 failures，并输出 `MTPRO checks passed.`。 |

边界确认：

- 不重设计 UI，不新增完整页面 redesign。
- 不新增 engine core capability。
- 不暴露 database schema，不引入 Runtime object inspector，不暴露 adapter request。
- 不提前实现 MTP-122 Report / Dashboard / Events acceptance path。
- 不新增 stage audit input。
- 不实现 production release、notarization、App Store distribution、auto-update 或 production operations。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进 MTP-122。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-27 — MTP-122 Report / Dashboard / Events beta acceptance path

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-122 Add Report / Dashboard / Events beta acceptance path`。
- 把 MTP-120 deterministic demo fixture 和 MTP-121 first-run default demo state 串成 Report summary、Dashboard panels 和 Events trace 的同一 beta acceptance path。
- 只通过 App Read Model / ViewModel 和 Dashboard smoke 展示 acceptance evidence，不暴露 database schema、Runtime object、Adapter request 或交易命令。
- 保持 MTP-122 不新增 Runtime replay job、engine capability、stage audit input、Live PRO Console、trading button 或 live command。

实现摘要：

- 新增 `Sources/App/WorkbenchBetaAcceptancePath.swift`，定义 `WorkbenchBetaAcceptancePathReadModel`、`WorkbenchBetaAcceptancePathViewModel`、acceptance item 和 trace item。
- 将 `DashboardReadModel` / `DashboardViewModel` 扩展为消费 `workbenchBetaAcceptancePath`，并从 `ReportReadModel` + `WorkbenchBetaFirstRunReadModel.defaultDemo` 生成 default beta acceptance path。
- 更新 `Sources/App/PaperWorkflowEvidenceExplorer.swift`，新增 `workbench beta acceptance path` timeline section，输出 Report summary、Scenario Replay evidence、Simulated Exchange / Backtest Parity evidence、Portfolio evidence 和 boundary summary 五条 trace rows。
- 更新 `Sources/App/DashboardShell.swift`，在 Workbench snapshot 和 Dashboard smoke 中输出 `betaAcceptancePaths=1`、`betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario` 和 `betaAcceptanceTrace=5`。
- 更新 `Tests/AppTests/AppTests.swift`，新增 MTP-122 focused App test，覆盖 same demo scenario、Report summary、Dashboard panels、Events trace、portfolio evidence、validation anchors 和 forbidden capability flags。
- 更新 `docs/contracts/workbench-beta-readiness-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，接入 MTP-122 anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP122` | first run failed | App target compile failed；`WorkbenchBetaAcceptancePath.swift` 的 Swift string interpolation separator 被错误转义。已修正并重跑。 |
| `swift test --filter MTP122` | second run failed | 1 focused App test 编译并运行；expected portfolio evidence id 使用旧字面量。已修正为 `mtp-115-simulated-exchange-portfolio-projection-parity-portfolio-parity`。 |
| `swift test --filter MTP122` | pass | 1 个 App test、0 failures；验证 Report summary、Dashboard panels、Events trace、same demo scenario、portfolio evidence 和 forbidden capability flags。 |
| `swift test --filter AppTests` | pass | 33 个 App tests、0 failures；验证 MTP-122 未破坏既有 App read-model-only surfaces。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-122 contract、domain context、validation plan、matrix、latest summary、automation readiness、App source 和 focused tests anchors。 |
| `DASHBOARD_SMOKE=1 swift run Dashboard` | pass | Dashboard product build 成功；smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=64; scenarioReplayEvidence=1; scenarioQualityGates=6; simulatedParityEvidence=1; defaultDemoState=default demo; defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario; betaFirstRunFallbacks=3; betaAcceptancePaths=1; betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario; betaAcceptanceTrace=5; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 |
| `git diff --check` | pass | MTP-122 diff 无 whitespace / patch error 输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 267 个 XCTest；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不新增 engine core capability、Runtime replay job、matching runtime、order execution runtime、portfolio projection runtime 或 production report engine。
- 不暴露 database schema、Runtime object inspector、Adapter request、Core object inspector 或 query surface。
- 不新增 stage audit input。
- 不运行 Graphify，不修改 Figma，不修改 Linear status，不推进 MTP-123。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
---

## 2026-05-27 — MTP-124 Docs index and operator guide

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-124 Add docs index and operator guide`。
- 让 Human / operator 能按正式文档完成 local Workbench beta 的环境确认、启动、demo、验收和边界理解。
- 保持 MTP-124 只服务 local macOS Workbench beta，不写 marketing landing page、Live PRO Console docs、production deployment guide、notarization / App Store / auto-update guide。
- 不授权下一阶段执行，不运行 Graphify，不修改 Figma。

实现摘要：

- 新增 `docs/index.md`，作为 root docs、Workbench Beta Readiness docs、operator guide、demo workflow guide、acceptance checklist 和 required validation 的中文文档入口。
- 新增 `docs/validation/workbench-beta-operator-guide.md`，记录 operator quick path、manual runbook、expected smoke handles、known limitations、forbidden capabilities、troubleshooting pointers 和 evidence handoff。
- 新增 `docs/validation/workbench-beta-demo-workflow-guide.md`，串联 MTP-119 local launch / install、MTP-120 deterministic fixture、MTP-121 first-run default demo state、MTP-122 Report / Dashboard / Events acceptance path 和 MTP-123 reproducible checklist / script。
- 更新 `docs/contracts/workbench-beta-readiness-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，接入 MTP-124 anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-124 docs index、operator guide、demo workflow guide、contract、domain context、validation plan、matrix、latest summary 和 automation readiness anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 267 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=64; scenarioReplayEvidence=1; scenarioQualityGates=6; simulatedParityEvidence=1; defaultDemoState=default demo; defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario; betaFirstRunFallbacks=3; betaAcceptancePaths=1; betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario; betaAcceptanceTrace=5; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；最终执行 267 tests、0 failures，并输出 `MTPRO checks passed.`。 |

边界确认：

- 不新增 production code、engine core capability、Runtime replay job、App read model、Dashboard behavior 或 stage audit input。
- 不创建 production release、notarization、App Store distribution、auto-update、production deployment 或 cloud operations。
- 不运行 Graphify，不修改 Figma，不修改 Linear status，不推进 MTP-125。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 signed endpoint、account endpoint / listenKey、API key / secret read、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-27 — MTPRO Live Readiness Roadmap v1 / L3.0 planning candidate docs-only record

执行者：Codex

目的：

- 将 Human 确认的 L3 细分路线写入仓库文档。
- 将 `L3.0 Live Read-only Readiness Boundary` 推进到 docs-only planning candidate。
- 保持旧 `Engine Maturity Roadmap Progress: 4 / 4 (100%)` 不变，不继续扩旧分母。

实现摘要：

- 新增 `docs/product/mtpro-live-readiness-roadmap-v1.md`，记录 `L3.0 Live Read-only Readiness Boundary`、`L3.1 Account / Position / Balance Read-model-only`、`L3.2 Private Stream / Account Snapshot Simulation Gate`、`L3.3 Live Monitoring Read-only Console v2` 和 `L4 Live Production / Trading Commands`。
- 新增 `docs/planning/projects/mtpro-live-read-only-readiness-boundary-v1-plan.md`，记录 L3.0 Project-level planning candidate、Target Engines / Layers、Target maturity、scope、non-goals、issue order、dependencies、validation requirements、evidence requirements、first executable issue candidate、WIP=1、Linear write boundary、repository record boundary 和 Parent Codex queue preflight rule。
- 更新 `GOAL.md`、`BLUEPRINT.md`、`docs/roadmap.md`、`architecture.md`、`docs/product/mtpro-core-engine-architecture-module-maturity-map-v1.md`、`docs/planning/linear-draft-plan.md` 和 `docs/validation/latest-verification-summary.md`，增加 Live Readiness Roadmap 和 L3.0 planning candidate 引用。

边界确认：

- 本记录不是 Project closure。
- 不更新 `Final Product Goal Progress`。
- 不更新旧 `Engine Maturity Roadmap Progress`。
- 不创建 Linear Project / Issue，不修改 Linear status，不推进 Todo。
- 不启动 `@002 / PAR`，不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不实现 Live read-only runtime、signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-27 — MTPRO Workbench Beta Readiness v1 Stage Code Audit

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 在 `MTP-118` 至 `MTP-125` 全部 Linear `Done`、PR merged、GitHub required check `checks` success 后，执行 Project closure 的 Stage Code Audit。
- 确认 Linear Project `MTPRO Workbench Beta Readiness v1` status 为 `Completed/type=completed`，`completedAt=2026-05-27T00:24:29.670Z`。
- 落仓完整 Project audit report，记录 issue / PR / merge / checks evidence、validation、Root Docs Delta input 和 forbidden capability audit。

Evidence：

| 项 | 结果 | 证据 |
| --- | --- | --- |
| Stage Code Audit Report | pass | `docs/audit/mtpro-workbench-beta-readiness-v1-stage-code-audit.md` 已落仓。 |
| Stage Code Audit PR | pass | PR #230 `docs: add Workbench beta stage code audit` 已通过 `checks` 并 squash merge。 |
| Stage Code Audit merge commit | pass | `8ee5d0ab2ffa6e7d3916b72f5ed7834cedefdca8`。 |
| Stage Code Audit check | pass | `checks` success：`https://github.com/atxinbao/MTPRO/actions/runs/26484007770/job/77987369062`。 |
| Local main | pass | Stage Code Audit merge 后 fast-forward 到 `8ee5d0ab2ffa6e7d3916b72f5ed7834cedefdca8`。 |
| `git diff --check` | pass | Stage Code Audit docs-only diff 无 whitespace error。 |
| `bash checks/run.sh` | local runner blocker | 本地 run 两次均通过 automation readiness、Dashboard build、Dashboard smoke、AdaptersTests、AppTests 和多数 CoreTests 后，在 macOS XCTest Core / PersistenceTests startup 附近触发已知 signal 11；该问题已知可在 main 复现，不是 docs-only audit PR 引入。GitHub required `checks` 为 merge gate，PR #230 已成功。 |

边界确认：

- 本轮只做 Stage Code Audit Report，不写业务 runtime。
- 不创建下一 Project / Issue，不推进 Todo，不启动 Symphony / symphony-issue。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 production release、notarization、App Store distribution、auto-update、production operations。
- 不实现 signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-27 — MTPRO Workbench Beta Readiness v1 Root Docs Refresh Gate closure

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 在 Stage Code Audit PR #230 merge 后，关闭 `MTPRO Workbench Beta Readiness v1` 的 Root Docs Refresh Gate。
- 同步已发生事实：`L2+ Workbench Beta Readiness complete`，Engine Maturity Roadmap Progress `4 / 4 (100%)`，Project Closure Count `16 / 16 (100%)`。
- 保留 `Final Product Goal Progress: 9 / 9 (100%)`。

Root Docs Refresh Gate 更新：

| 文件 | 结果 | 说明 |
| --- | --- | --- |
| `GOAL.md` | updated | Engine Maturity Roadmap Progress 更新为 `4 / 4 (100%)`，current maturity statement 更新为 `L2+ Workbench Beta Readiness complete`。 |
| `BLUEPRINT.md` | updated | 同步 Workbench Beta Readiness Project closure 和 Stage Code Audit Report evidence；明确 L3 / L4 Future Gated。 |
| `environment.md` | updated | 记录 local launch / install / environment verification 只代表 local beta acceptance path。 |
| `architecture.md` | updated | 同步 L2+ Workbench beta acceptance read-model evidence chain，不授权 production / live scope。 |
| `docs/roadmap.md` | updated | Project Closure Count `16 / 16`，Engine Maturity Roadmap Progress `4 / 4`，L2+ Done，L3 / L4 Future Gated。 |
| `docs/automation/automation-readiness.md` | updated | 新增 Workbench Beta Readiness stage code audit report 和 root docs refresh anchors。 |
| `checks/automation-readiness.sh` | updated | 机械检查 Workbench Beta Stage Code Audit、Root Docs Refresh 和 4 / 4 progress anchors。 |
| `docs/validation/latest-verification-summary.md` | updated | 最近完成 Project、Stage Code Audit PR #230 evidence、Project closure evidence、maturity statement 和 boundary evidence 已同步。 |
| `docs/audit/mtpro-workbench-beta-readiness-v1-stage-code-audit.md` | updated | Root Docs Refresh Gate closure 标记为 closed。 |

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Root Docs Refresh Gate docs/checks-only diff 无 whitespace error。 |
| `bash checks/run.sh` | local runner blocker | 本地通过 automation readiness、Dashboard build、Dashboard smoke、AdaptersTests、AppTests 和大部分 Core / Persistence tests 后，xctest 在 Core / Persistence 交界处返回已知 macOS signal 11；该问题此前已确认可在 main 复现，不是 docs/checks-only 变更引入。GitHub required `checks` 仍是最终 merge gate。 |

边界确认：

- Root Docs Refresh Gate 只同步已发生事实，不创建下一 Project / Issue，不推进 Todo。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma，不写业务 runtime。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不把 Live read-only 或 Live production 写成当前 execution scope。
- 不授权 production release、notarization、App Store distribution、auto-update、production operations、signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-27 — MTP-125 Workbench Beta Readiness validation / automation / stage audit input closeout

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-125 Close automation readiness / validation evidence / stage audit input`。
- 收口 `MTPRO Workbench Beta Readiness v1` 的 validation matrix、automation readiness、MTP-118 至 MTP-124 Project evidence chain、forbidden capability evidence 和 Stage Code Audit 输入材料。
- 只准备 Parent Codex Stage Code Audit input material；不输出最终 Stage Code Audit Report，不修改 Linear status，不推进下一阶段。

实现摘要：

- 新增 `docs/audit/inputs/mtpro-workbench-beta-readiness-v1-stage-audit-input.md`，记录 Linear queue evidence、PR #222 至 #228 evidence、merge commit、required check、Workbench Beta Readiness validation evidence chain、forbidden capability evidence chain、read-model-only boundary evidence、automation readiness evidence、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- 更新 `docs/contracts/workbench-beta-readiness-contract.md`，新增 MTP-125 closeout、stage audit input material、no final Stage Code Audit、validation evidence chain、forbidden capability evidence chain 和 automation readiness anchors。
- 更新 `docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，接入 MTP-125 validation / readiness anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | first run failed | Stage audit input 缺少 `MTP-125-STAGE-AUDIT-INPUT-MATERIAL` exact anchor；已补入并重跑。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-125 stage audit input、contract、matrix、validation plan、latest summary、automation readiness、PR evidence 和 Dashboard smoke anchors。 |
| `git diff --check` | pass | MTP-125 diff 无 whitespace / patch error 输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 267 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=64; scenarioReplayEvidence=1; scenarioQualityGates=6; simulatedParityEvidence=1; defaultDemoState=default demo; defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario; betaFirstRunFallbacks=3; betaAcceptancePaths=1; betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario; betaAcceptanceTrace=5; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；最终执行 267 tests、0 failures，并输出 `MTPRO checks passed.`。 |

边界确认：

- 不输出最终 Stage Code Audit Report；最终报告仍由 Parent Codex 在 Project 全部 Done 且 Linear Project `Completed` 后单独输出。
- 不修改 Linear status、不创建 Linear Project / Issue、不启动 `@002 / PAR`、不启动 Symphony / symphony-issue、不推进下一阶段。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。
- 不新增 production code、engine core capability、Runtime replay job、App read model、Dashboard behavior、production release、notarization、App Store distribution、auto-update、production deployment 或 cloud operations。
- 不实现 signed endpoint、account endpoint / listenKey、API key / secret read、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-27 — MTP-126 Live read-only readiness terminology / boundary contract

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-126 Define Live read-only readiness terminology and boundary`。
- 定义 `Live read-only readiness`、`target engine layer`、`L3.0 -> L3.1 -> L3.2 -> L3.3` handoff、forbidden capability baseline 和 first executable candidate non-authorization 术语。
- 只建立 terminology / boundary / validation anchors；不实现 endpoint、secret、adapter、account read model、UI 或 live runtime。

实现摘要：

- 新增 `docs/contracts/live-read-only-readiness-boundary-contract.md`，记录 `MTP-126-LIVE-READ-ONLY-READINESS-TERMINOLOGY`、`MTP-126-TARGET-ENGINE-LAYER-BOUNDARY`、`MTP-126-L30-L31-L32-L33-HANDOFF`、`MTP-126-FORBIDDEN-CAPABILITY-BASELINE`、`MTP-126-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION` 和 `MTP-126-LIVE-READ-ONLY-READINESS-VALIDATION`。
- 更新 `docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，将 MTP-126 terminology、boundary、TVM 和 readiness exact anchors 纳入本地机械检查。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-126 contract、domain terms、validation plan、trading matrix、latest summary 和 automation readiness anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 267 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=64; scenarioReplayEvidence=1; scenarioQualityGates=6; simulatedParityEvidence=1; defaultDemoState=default demo; defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario; betaFirstRunFallbacks=3; betaAcceptancePaths=1; betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario; betaAcceptanceTrace=5; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；最终执行 267 tests、0 failures，并输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 Linear status、不创建 Linear Project / Issue、不启动 `@002 / PAR`、不启动 Symphony / symphony-issue、不推进 MTP-127。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。
- 不新增 Swift production code、Runtime job、App read model、Dashboard UI、endpoint、secret、adapter、account read model 或 live runtime。
- 不实现 signed endpoint、account endpoint / listenKey、API key / secret read、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-27 — MTP-127 Credential / secret policy and endpoint capability taxonomy

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-127 Define credential / secret policy and endpoint capability taxonomy`。
- 定义 L3.0 credential / secret policy future gate、endpoint capability taxonomy、public read-only / private endpoint isolation 和 forbidden capability tests。
- 只建立 Core deterministic fixture、focused tests、contract / domain / validation / automation anchors；不实现 secret、endpoint、adapter、runtime、UI 或交易能力。

实现摘要：

- 在 `Sources/Core/LiveTradingBoundary.swift` 新增 `LiveReadOnlyCredentialPolicyTerm`、`LiveReadOnlyEndpointCapabilityTaxonomy`、`LiveReadOnlyCredentialEndpointFutureGate`、`LiveReadOnlyCredentialEndpointEvidenceKind` 和 `LiveReadOnlyCredentialEndpointTaxonomyBoundary`。
- 在 `Tests/CoreTests/CoreTests.swift` 新增 `testLiveReadOnlyCredentialEndpointTaxonomyDefinesMTP127FutureGates` 和 `testLiveReadOnlyCredentialEndpointTaxonomyRejectsSecretEndpointAndBrokerBypass`。
- 更新 `docs/contracts/live-read-only-readiness-boundary-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，接入 MTP-127 exact anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter LiveReadOnlyCredentialEndpointTaxonomy` | first run failed | TDD 红灯：`LiveReadOnlyCredentialEndpointTaxonomyBoundary` 和相关 enum 尚未实现；随后补 Core contract。 |
| `swift test --filter LiveReadOnlyCredentialEndpointTaxonomy` | pass | 2 tests、0 failures；覆盖 MTP-127 future gates、endpoint taxonomy、public read-only 唯一 allowed capability、forbidden flags 和 Codable bypass rejection。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-127 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、Core fixture 和 focused test anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 269 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=64; scenarioReplayEvidence=1; scenarioQualityGates=6; simulatedParityEvidence=1; defaultDemoState=default demo; defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario; betaFirstRunFallbacks=3; betaAcceptancePaths=1; betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario; betaAcceptanceTrace=5; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不读取本地 secret，不实现 API key / secret storage，不新增 env / keychain / config secret path。
- 不实现 signed request、signed endpoint、account endpoint、listenKey、private WebSocket、account snapshot runtime 或 private read runtime。
- 不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`，不执行 broker action。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
- 不修改 Linear status、不创建 Linear Project / Issue、不推进 MTP-128。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

---

## 2026-05-27 — MTP-128 Adapter capability matrix for read-only readiness

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-128 Define adapter capability matrix for read-only readiness`。
- 定义 L3.0 adapter capability matrix、public read-only adapter / future private gate isolation 和 forbidden adapter capability tests。
- 只建立 Core deterministic fixture、focused tests、contract / domain / validation / automation anchors；不实现 adapter runtime、broker connection、signed/account endpoint 或交易能力。

实现摘要：

- 在 `Sources/Core/LiveTradingBoundary.swift` 新增 `LiveReadOnlyAdapterCapabilityMatrixEntry`、`LiveReadOnlyAdapterCapabilityFutureGate`、`LiveReadOnlyAdapterCapabilityEvidenceKind` 和 `LiveReadOnlyAdapterCapabilityMatrixBoundary`。
- 在 `Tests/CoreTests/CoreTests.swift` 新增 `testLiveReadOnlyAdapterCapabilityMatrixDefinesMTP128ReadOnlyBoundary` 和 `testLiveReadOnlyAdapterCapabilityMatrixRejectsWriteAndExecutionAdapterBypass`。
- 更新 `docs/contracts/live-read-only-readiness-boundary-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，接入 MTP-128 exact anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter LiveReadOnlyAdapterCapabilityMatrix` | pass | 2 tests、0 failures；覆盖 MTP-128 adapter capability matrix、public market data 唯一 allowed capability、future private account read-only gated capability、forbidden adapter flags 和 Codable bypass rejection。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-128 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、Core fixture 和 focused test anchors。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 271 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=64; scenarioReplayEvidence=1; scenarioQualityGates=6; simulatedParityEvidence=1; defaultDemoState=default demo; defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario; betaFirstRunFallbacks=3; betaAcceptancePaths=1; betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario; betaAcceptanceTrace=5; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不创建 broker adapter、exchange execution adapter 或 `LiveExecutionAdapter`。
- 不把 public adapter 升级为 execution adapter。
- 不实现 signed endpoint、account endpoint / listenKey、private account read runtime、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不实现 real account / broker position / margin / leverage runtime。
- 不修改 Linear status、不创建 Linear Project / Issue、不推进 MTP-129。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

---

## 2026-05-27 — MTP-129 Account / position / balance read-model-only future gates

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-129 Define account / position / balance read-model-only future gates`。
- 定义 L3.1 所需 account / position / balance read-model-only future gates、source identity、snapshot freshness、evidence identity 和 Workbench / Dashboard ViewModel boundary。
- 只建立 Core deterministic fixture、focused tests、contract / domain / validation / automation anchors；不实现真实账户读取、read model runtime、broker position sync、private endpoint 或交易能力。

实现摘要：

- 在 `Sources/Core/LiveTradingBoundary.swift` 新增 `LiveReadOnlyAccountPositionBalanceFutureGate`、`LiveReadOnlyAccountPositionBalanceSourceIdentity`、`LiveReadOnlyAccountPositionBalanceFreshnessBoundary`、`LiveReadOnlyAccountPositionBalanceEvidenceKind`、`LiveReadOnlyAccountPositionBalanceForbiddenInterpretation` 和 `LiveReadOnlyAccountPositionBalanceFutureGateBoundary`。
- 在 `Tests/CoreTests/CoreTests.swift` 新增 `testLiveReadOnlyAccountPositionBalanceFutureGatesDefineMTP129Boundary` 和 `testLiveReadOnlyAccountPositionBalanceFutureGatesRejectRealAccountAndFixtureBypass`。
- 更新 `docs/contracts/live-read-only-readiness-boundary-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，接入 MTP-129 exact anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter LiveReadOnlyAccountPositionBalance` | pass | 2 tests、0 failures；覆盖 MTP-129 account / position / balance future gates、source identity、snapshot freshness、evidence identity、forbidden account-data interpretation flags 和 Codable bypass rejection。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-129 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、Core fixture 和 focused test anchors。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 273 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=64; scenarioReplayEvidence=1; scenarioQualityGates=6; simulatedParityEvidence=1; defaultDemoState=default demo; defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario; betaFirstRunFallbacks=3; betaAcceptancePaths=1; betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario; betaAcceptanceTrace=5; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不实现 account / position / balance read model runtime。
- 不读取 real account，不同步 broker position，不读取 real account balance、margin、leverage 或 real PnL。
- 不实现 signed endpoint、account endpoint / listenKey、private WebSocket、account snapshot runtime 或 private read runtime。
- 不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、trading button 或 live command。
- 不把 paper portfolio、simulated fill、fixture evidence、Report read model 或 Dashboard ViewModel 解释为真实 account / position / balance data。
- 不修改 Linear status、不创建 Linear Project / Issue、不推进 MTP-130。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

---

## 2026-05-27 — MTP-130 Private stream / account snapshot simulation gate input material

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-130 Define private stream / account snapshot simulation gate input material`。
- 定义后续 L3.2 所需 private stream / account snapshot simulation gate input material、future fixture requirements、listenKey forbidden tests 和 simulation gate / live stream isolation。
- 只建立 Core deterministic fixture、focused tests、contract / domain / validation / automation anchors；不实现 listenKey、private WebSocket、account snapshot runtime、private stream runtime、signed/account endpoint、broker adapter 或交易能力。

实现摘要：

- 在 `Sources/Core/LiveTradingBoundary.swift` 新增 `LiveReadOnlyPrivateStreamAccountSnapshotSimulationInputMaterial`、`LiveReadOnlyPrivateStreamAccountSnapshotFutureFixtureRequirement`、`LiveReadOnlyPrivateStreamAccountSnapshotForbiddenCapability`、`LiveReadOnlyPrivateStreamAccountSnapshotEvidenceKind` 和 `LiveReadOnlyPrivateStreamAccountSnapshotSimulationGateBoundary`。
- 在 `Tests/CoreTests/CoreTests.swift` 新增 `testLiveReadOnlyPrivateStreamAccountSnapshotDefinesMTP130SimulationGateInput` 和 `testLiveReadOnlyPrivateStreamAccountSnapshotRejectsListenKeyAndRuntimeBypass`。
- 更新 `docs/contracts/live-read-only-readiness-boundary-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，接入 MTP-130 exact anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter LiveReadOnlyPrivateStreamAccountSnapshot` | pass | 2 tests、0 failures；覆盖 MTP-130 private stream / account snapshot simulation gate input material、future fixture requirements、listenKey forbidden flags、simulation gate / live stream isolation 和 Codable bypass rejection。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-130 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、Core fixture 和 focused test anchors。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 275 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=64; scenarioReplayEvidence=1; scenarioQualityGates=6; simulatedParityEvidence=1; defaultDemoState=default demo; defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario; betaFirstRunFallbacks=3; betaAcceptancePaths=1; betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario; betaAcceptanceTrace=5; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不创建 listenKey，不执行 listenKey keepalive。
- 不连接 private WebSocket，不实现 private stream runtime。
- 不运行 account snapshot runtime，不读取 real account 或 consumes real account payload。
- 不调用 signed endpoint、account endpoint / listenKey。
- 不同步 broker position，不读取 margin / leverage。
- 不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS 或 real order write。
- 不把 simulation gate input material 写成 live private stream implementation。
- 不把 fixture account snapshot 写成真实 account snapshot。
- 不新增 Live PRO Console、trading button 或 live command。
- 不修改 Linear status、不创建 Linear Project / Issue、不推进 MTP-131。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

---

## 2026-05-27 — MTP-131 Workbench Live readiness read-model-only boundary

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-131 Define Workbench Live readiness read-model-only boundary`。
- 定义 Workbench / Dashboard / Report / Event Timeline 可展示的 Live readiness read-model-only UI boundary、ReadModel / ViewModel input boundary、forbidden UI surface、detail / audit route 和 L3.1 / L3.2 / L3.3 handoff。
- 只建立 Core deterministic fixture、App read model / ViewModel、Dashboard shell / Event Timeline read-only evidence、focused tests、contract / domain / validation / automation anchors；不实现 API key input、broker connect、account connect、Live PRO Console、trading button、live command、order form、signed/account/listenKey endpoint、Runtime object、database schema、adapter request 或真实订单能力。

实现摘要：

- 在 `Sources/Core/LiveTradingBoundary.swift` 新增 `LiveReadOnlyWorkbenchBoundarySurface`、`LiveReadOnlyWorkbenchInputBoundary`、`LiveReadOnlyWorkbenchForbiddenUISurface`、`LiveReadOnlyWorkbenchDetailAuditRoute`、`LiveReadOnlyWorkbenchHandoffTarget`、`LiveReadOnlyWorkbenchEvidenceKind` 和 `LiveReadOnlyWorkbenchReadModelBoundary`。
- 新增 `Sources/App/LiveReadOnlyWorkbenchBoundary.swift`，提供 `LiveReadOnlyWorkbenchBoundaryReadModel` 和 `LiveReadOnlyWorkbenchBoundaryViewModel`。
- 更新 `Sources/App/App.swift`、`Sources/App/DashboardShell.swift` 和 `Sources/App/PaperWorkflowEvidenceExplorer.swift`，把 MTP-131 read-model-only boundary 接入 Report / Dashboard / Workbench / Event Timeline。
- 在 `Tests/CoreTests/CoreTests.swift` 新增 `testLiveReadOnlyWorkbenchReadModelBoundaryDefinesMTP131Surface` 和 `testLiveReadOnlyWorkbenchReadModelBoundaryRejectsForbiddenUISurfaceBypass`。
- 在 `Tests/AppTests/AppTests.swift` 新增 `testLiveReadOnlyWorkbenchBoundaryViewModelAggregatesMTP131ReadOnlySurface`，并更新 Dashboard shell、Report snapshot 和 Evidence Explorer integration assertions。
- 更新 `docs/contracts/live-read-only-readiness-boundary-contract.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，接入 MTP-131 exact anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter LiveReadOnlyWorkbench` | pass | 3 tests、0 failures；覆盖 MTP-131 Core fixture、forbidden UI flags、Codable bypass rejection 和 App ViewModel aggregation。 |
| `swift test --filter AppTests/testLiveReadOnlyWorkbenchBoundaryViewModelAggregatesMTP131ReadOnlySurface` | pass | 1 test、0 failures；覆盖 App read-model-only ViewModel surface 和禁止 command / endpoint / adapter / runtime flags。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-131 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、Core fixture、App read model / ViewModel、Dashboard shell、Event Timeline 和 focused test anchors。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 278 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=65; scenarioReplayEvidence=1; scenarioQualityGates=6; simulatedParityEvidence=1; defaultDemoState=default demo; defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario; betaFirstRunFallbacks=3; betaAcceptancePaths=1; betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario; betaAcceptanceTrace=5; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveReadOnlyWorkbenchBoundary=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不新增 API key input、secret storage、local secret read 或 credential provider。
- 不新增 broker connect、account connect、Live PRO Console、trading button、live command 或 order form。
- 不调用 signed endpoint、account endpoint / listenKey，不创建 private WebSocket。
- 不读取 real account balance、broker position、margin、leverage、real PnL 或 account payload。
- 不暴露 Runtime object、database schema、Persistence schema、ORM model 或 adapter request。
- 不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS 或 real order lifecycle。
- 不提交、取消或替换真实订单，不授权 broker action 或 production operation。
- 不修改 Linear status、不创建 Linear Project / Issue、不推进 MTP-132。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

---

## 2026-05-27 — MTP-132 Live Read-only Readiness stage closeout input

执行者：Codex

目的：

- 执行 Linear live-read 中唯一 active issue `MTP-132 Close validation matrix / automation readiness / stage audit input`。
- 收口 `MTPRO Live Read-only Readiness Boundary v1` 的 validation matrix、automation readiness anchors、forbidden capability evidence chain、read-model-only boundary evidence 和 Stage Code Audit 输入材料。
- 只准备 Parent Codex 后续 Stage Code Audit Report 的输入材料；不输出最终 Stage Code Audit Report，不修改 Linear status，不运行 Graphify，不修改 Figma，不授权下一阶段或 live runtime。

实现摘要：

- 新增 `docs/audit/inputs/mtpro-live-read-only-readiness-boundary-v1-stage-audit-input.md`，汇总 MTP-126 至 MTP-131 的 PR / checks evidence、L3.0 validation evidence chain、forbidden capability evidence、read-model-only boundary evidence、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- 更新 `docs/contracts/live-read-only-readiness-boundary-contract.md`，新增 MTP-132 stage closeout、stage audit input material、no final Stage Code Audit、validation evidence chain、forbidden capability evidence chain 和 automation readiness stage closeout anchors。
- 更新 `docs/validation/trading-validation-matrix.md`、`docs/validation/validation-plan.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，接入 MTP-132 exact anchors 和 mechanical readiness gate。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；机械检查 MTP-132 stage audit input、contract、matrix、validation plan、latest summary、automation readiness doc、MTP-126 至 MTP-131 anchors、PR evidence 和 Dashboard smoke handles。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 278 个 XCTest；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=65; scenarioReplayEvidence=1; scenarioQualityGates=6; simulatedParityEvidence=1; defaultDemoState=default demo; defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario; betaFirstRunFallbacks=3; betaAcceptancePaths=1; betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario; betaAcceptanceTrace=5; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveReadOnlyWorkbenchBoundary=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不输出最终 Stage Code Audit Report；最终报告仍由 Parent Codex 在 Project 全部 Done 且 Linear Project `Completed` 后单独输出。
- 不修改 Linear status、不创建 Linear Project / Issue、不启动 `@002 / PAR`、不启动 Symphony / symphony-issue、不推进下一阶段。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。
- 不新增 production code、不新增 Live read-only runtime、不新增 account / position / balance runtime、不新增 private stream runtime、不新增 Dashboard command surface。
- 不实现 API key / secret storage，不读取本地 secret，不新增 env / keychain / config secret path。
- 不接 signed endpoint、account endpoint、listenKey、private WebSocket、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、real PnL、Live Monitoring Console v2 runtime、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。

---

## 2026-05-28 — MTPRO Live Read-only Readiness Boundary v1 Project Closure / Stage Code Audit / Root Docs Refresh Gate

执行者：Codex（`@002 / PAR`）

目的：

- 完成 `MTPRO Live Read-only Readiness Boundary v1` Project closure。
- 固化 MTP-126 至 MTP-132 的 PR / merge / checks evidence chain。
- 落仓 Stage Code Audit Report，并执行 Root Docs Refresh Gate。
- 只同步已发生事实：`L3.0 Live Read-only Readiness Boundary complete`、Project Closure Count、Stage Code Audit evidence、Root Docs Refresh Gate evidence 和边界事实。

Project / issue evidence：

| Issue | PR | Merge commit | Required check |
| --- | --- | --- | --- |
| MTP-126 | #234 | `a2a7bf59f8dbccf0f4ec23b0dc53253ebf19d654` | `checks` success: `https://github.com/atxinbao/MTPRO/actions/runs/26494168992/job/78018287376` |
| MTP-127 | #235 | `b101989e766c864edae3ea84d306f8b22be797d7` | `checks` success: `https://github.com/atxinbao/MTPRO/actions/runs/26501735905/job/78043651703` |
| MTP-128 | #236 | `c3b93254b592099287e29ba1f7cf5de25ccc8bb3` | `checks` success: `https://github.com/atxinbao/MTPRO/actions/runs/26509160542/job/78069249264` |
| MTP-129 | #237 | `19eaa4e9715319ecd0d843a2e71e795b433aee2a` | `checks` success: `https://github.com/atxinbao/MTPRO/actions/runs/26512993370/job/78082139238` |
| MTP-130 | #238 | `a5d7b0c4b80f188a529d3bad8ed1fa8a0475fb12` | `checks` success: `https://github.com/atxinbao/MTPRO/actions/runs/26515047655/job/78089706999` |
| MTP-131 | #239 | `4412fd9270d5333825d69062db4a51c8c18cd6ac` | `checks` success: `https://github.com/atxinbao/MTPRO/actions/runs/26518731599/job/78103297704` |
| MTP-132 | #240 | `80b8b674ccfbbbfb9d3ecd8a57a343cf20c0fc7c` | `checks` success: `https://github.com/atxinbao/MTPRO/actions/runs/26520265788/job/78108965737` |

Closure evidence：

- Linear Project status：`Completed/type=completed`。
- Linear Project `completedAt`：`2026-05-27T15:18:46.875Z`。
- Stage Code Audit Report：`docs/audit/mtpro-live-read-only-readiness-boundary-v1-stage-code-audit.md`。
- Stage Code Audit PR：#241。
- Stage Code Audit merge commit：`e7bd3bb90807fabf21c91008c9000b517b25ae4d`。
- Stage Code Audit required check：`checks` success, `https://github.com/atxinbao/MTPRO/actions/runs/26521055453/job/78111900502`。
- Root Docs Refresh Gate：当前分支同步 `GOAL.md`、`BLUEPRINT.md`、`environment.md`、`architecture.md`、`docs/roadmap.md`、`docs/product/mtpro-live-readiness-roadmap-v1.md`、`docs/automation/automation-readiness.md`、`checks/automation-readiness.sh`、`docs/validation/latest-verification-summary.md`、Stage Code Audit Report 和本 append-only verification entry。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；mechanical anchors 已覆盖 L3.0 stage code audit report、root docs refresh anchor、Project Closure Count `17 / 17` 和 maturity statement `L3.0 Live Read-only Readiness Boundary complete`。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 278 个 XCTest；Dashboard smoke 输出 `liveReadOnlyWorkbenchBoundary=5`，最终输出 `MTPRO checks passed.`。 |

成熟度结论：

- Current Foundation Progress 保持 `4 / 4 (100%)`。
- Final Product Goal Progress 保持 `9 / 9 (100%)`。
- Engine Maturity Roadmap Progress 保持 `4 / 4 (100%)`，不扩大旧分母。
- Current maturity statement：`L3.0 Live Read-only Readiness Boundary complete`。
- Next maturity planning candidate：`L3.1 Account / Position / Balance Read-model-only`，仍为 Future Gated / non-executable。

边界确认：

- 不创建下一 Linear Project / Issue。
- 不推进下一 issue 到 `Todo`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 production release、notarization、App Store distribution、auto-update 或 production operations。
- 不实现 signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。

---

## 2026-05-28 — MTPRO Live Readiness Roadmap L3.4 Strategy / Trader Instance Candidate Docs Update

执行者：Codex

目的：

- 将 `L3.4 Strategy / Trader Instance Readiness v1` 写入 Live Readiness 路线。
- 明确 L3.4 只是 Future Gated / Planning Candidate，不改变当前 next candidate `L3.1 Account / Position / Balance Read-model-only`。
- 明确 L3.4 只记录 L4 前的 Strategy / Trader structural readiness gap，不授权任何 execution。

更新内容：

- 更新 `docs/product/mtpro-live-readiness-roadmap-v1.md`，在 L3.3 与 L4 之间新增 `L3.4 Strategy / Trader Instance Readiness v1`。
- 更新 `docs/product/mtpro-core-engine-architecture-module-maturity-map-v1.md`，把 L3.4 映射到 Strategy Engine、Portfolio Engine、Risk Engine 和 Evidence Read Model Layer。
- 更新 `docs/roadmap.md`、`BLUEPRINT.md`、`GOAL.md`、`architecture.md`、`docs/automation/automation-readiness.md` 和 `docs/validation/latest-verification-summary.md` 的路线引用。
- 不更新 `Final Product Goal Progress`，不扩大旧 `Engine Maturity Roadmap Progress: 4 / 4 (100%)` 分母。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 无输出。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 278 个 XCTest；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify，不修改 Figma。
- 不实现 Strategy / Trader runtime。
- 不实现 signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
- 不允许 Strategy Instance 直接调用 Execution Client，不允许输出 broker command。

## 2026-05-28 — MTPRO L3.4 Core Engine Map Consistency Repair

执行者：Codex

目的：

- 修复 `docs/product/mtpro-core-engine-architecture-module-maturity-map-v1.md` 与已合并 L3.4 roadmap / root docs 的一致性。
- 将 `L3.0 Live Read-only Readiness Boundary` 在 Core Engine map 中标记为 Done / not counted in old denominator。
- 将 `L3.4 Strategy / Trader Instance Readiness v1` 补入 Core Engine map 的 L3 细分路线和 Strategy Engine 下一步目标。

更新内容：

- 更新 `docs/product/mtpro-core-engine-architecture-module-maturity-map-v1.md`。
- 不修改 `Final Product Goal Progress`。
- 不修改旧 `Engine Maturity Roadmap Progress: 4 / 4 (100%)` 分母。
- 不创建 Linear Project / Issue，不推进 Todo，不授权 implementation。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 无输出。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 278 个 XCTest；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify，不修改 Figma。
- 不实现 Strategy / Trader runtime。
- 不实现 signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
- 不允许 Strategy Instance 直接调用 Execution Client，不允许输出 broker command。

---

## 2026-05-28 — MTPRO Account / Position / Balance Read-model-only v1 Planning Record

执行者：Codex

目的：

- 将 `MTPRO Account / Position / Balance Read-model-only v1` 写入 docs-only Project Planning Record。
- 明确该记录只规划 L3.1 account / position / balance read-model-only evidence、snapshot identity、source / freshness、fixture contract、forbidden real account tests 和 Workbench / Report / Events 只读 evidence surface。
- 明确该记录不是 Project closure，不创建 Linear Project / Issue，不推进 Todo，不授权 implementation。

更新内容：

- 新增 `docs/planning/projects/mtpro-account-position-balance-read-model-only-v1-plan.md`。
- 更新 `docs/planning/linear-draft-plan.md` 的 planning record index 和当前 planning record 指向。
- 更新 `docs/validation/latest-verification-summary.md` 的 current planning record 和 planning record 入口。
- 更新 `BLUEPRINT.md` 的来源引用。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 278 个 XCTest；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify，不修改 Figma。
- 不写业务代码。
- 不实现 Account / Position / Balance runtime。
- 不实现 Live read-only runtime。
- 不实现 signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、real PnL、Live PRO Console、trading button、live command 或 order form。
- 不提交 `.codex/*` 或 `graphify-out/*`。

---

## 2026-05-28 — MTP-134 Account Snapshot Identity / Freshness Evidence

执行者：Codex

目的：

- 执行 Linear issue `MTP-134 Define account snapshot identity and source / freshness evidence`。
- 建立 account snapshot identity、account evidence id、source identity、observedAt、source watermark、freshness evidence、stale / missing / blocked account evidence、adapter capability bypass guard 和 account snapshot not runtime anchors。
- 明确 MTP-134 是 evidence identity / freshness boundary 层，不实现 account snapshot runtime，不调用 account endpoint，不创建 listenKey。

更新内容：

- 更新 `docs/contracts/account-position-balance-read-model-only-contract.md`，新增 MTP-134 account snapshot identity / source freshness evidence anchors。
- 更新 `docs/domain/context.md`，新增 MTP-134 account snapshot identity shared language。
- 更新 `docs/validation/trading-validation-matrix.md`，新增 MTP-134 issue backfill。
- 更新 `docs/validation/validation-plan.md`，新增 MTP-134 required validation 与禁止项。
- 更新 `docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，新增 MTP-134 mechanical anchors。
- 更新 `docs/validation/latest-verification-summary.md`，记录 MTP-134 当前 issue execution evidence。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 278 个 XCTest；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不推进 MTP-135。
- 不创建下一 Project / Issue。
- 不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 account snapshot runtime、Live read-only runtime、private stream runtime 或 account endpoint runtime。
- 不调用 account endpoint，不创建 listenKey，不读取 secret，不连接 private WebSocket。
- 不读取真实账户余额、margin、leverage、buying power 或 real PnL。
- 不新增 secret storage、credential provider、signed request、signed endpoint、broker connection、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button、live command 或 order form。

---

## 2026-05-28 — MTP-135 Position Snapshot Identity / Exposure Evidence

执行者：Codex

目的：

- 执行 Linear issue `MTP-135 Define position snapshot identity and exposure evidence`。
- 建立 position snapshot identity、position evidence id、source identity、symbol / side / quantity、exposure evidence、scenario version、paper / simulated / future real position isolation、stale / blocked / simulated evidence 和 forbidden broker position interpretation anchors。
- 明确 MTP-135 是 read-model-only position evidence 层，不同步 broker position，不读取 real position / margin / leverage。

更新内容：

- 更新 `docs/contracts/account-position-balance-read-model-only-contract.md`，新增 MTP-135 position snapshot identity / exposure evidence anchors。
- 更新 `docs/domain/context.md`，新增 MTP-135 position snapshot identity shared language。
- 更新 `docs/validation/trading-validation-matrix.md`，新增 MTP-135 issue backfill。
- 更新 `docs/validation/validation-plan.md`，新增 MTP-135 required validation 与禁止项。
- 更新 `docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，新增 MTP-135 mechanical anchors。
- 更新 `docs/validation/latest-verification-summary.md`，记录 MTP-135 当前 issue execution evidence。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 278 个 XCTest；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不推进 MTP-136。
- 不创建下一 Project / Issue。
- 不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不同步 broker position。
- 不读取 real position、margin、leverage、real account balance、broker portfolio 或 real PnL。
- 不实现 broker adapter、account endpoint、listenKey、private stream、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button、live command 或 order form。
- 不把 paper portfolio projection、simulated fill 或 simulated exchange exposure 升级为 real position、broker fill、execution report 或 reconciliation。

---

## 2026-05-28 — MTP-136 Balance Snapshot Identity / Paper-vs-real Boundary

执行者：Codex

目的：

- 执行 Linear issue `MTP-136 Define balance snapshot identity and paper-vs-real interpretation boundary`。
- 建立 balance snapshot identity、balance evidence id、balance source identity、balance kind、paper cash、paper equity、simulated balance、fixture balance、future-gated real balance、paper-vs-real interpretation boundary、real PnL / margin / leverage / buying power forbidden baseline 和 balance stale / blocked evidence anchors。
- 明确 MTP-136 是 read-model-only balance evidence 层，不读取真实账户余额，不实现 real PnL runtime，不读取 margin、leverage 或 buying power。

更新内容：

- 更新 `docs/contracts/account-position-balance-read-model-only-contract.md`，新增 MTP-136 balance snapshot identity / paper-vs-real boundary anchors。
- 更新 `docs/domain/context.md`，新增 MTP-136 balance snapshot identity shared language。
- 更新 `docs/validation/trading-validation-matrix.md`，新增 MTP-136 issue backfill。
- 更新 `docs/validation/validation-plan.md`，新增 MTP-136 required validation 与禁止项。
- 更新 `docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，新增 MTP-136 mechanical anchors。
- 更新 `docs/validation/latest-verification-summary.md`，记录 MTP-136 当前 issue execution evidence。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 278 个 XCTest；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不推进 MTP-137。
- 不创建下一 Project / Issue。
- 不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不读取真实账户余额。
- 不实现 real PnL runtime。
- 不读取 margin、leverage、buying power 或 broker cash statement。
- 不接 signed endpoint、account endpoint、listenKey、private stream 或 private WebSocket runtime。
- 不连接 broker，不实现 account snapshot runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button、live command 或 order form。

---

## 2026-05-28 — MTP-137 Account / Position / Balance Fixture / Forbidden Real Account Tests

执行者：Codex

目的：

- 执行 Linear issue `MTP-137 Define account / position / balance fixture and forbidden real account tests`。
- 建立 account / position / balance deterministic local fixture shape、fixture version、checksum、freshness、source identity、forbidden real account tests、fixture-to-read-model mapping isolation 和 real account payload isolation。
- 明确 MTP-137 fixture 只能作为 read-model-only local evidence，不是真实账户 fixture importer，不导入 broker payload，不调用 account endpoint 或 listenKey。

更新内容：

- 更新 `Sources/Core/LiveTradingBoundary.swift`，新增 `AccountPositionBalanceReadModelOnlyFixtureContract`、`AccountPositionBalanceReadModelOnlyFixtureRecord` 和 `AccountPositionBalanceReadModelOnlyForbiddenCapability`。
- 更新 `Tests/CoreTests/CoreTests.swift`，新增 deterministic fixture contract、forbidden real account bypass 和 payload / schema / runtime mapping isolation tests。
- 更新 `docs/contracts/account-position-balance-read-model-only-contract.md`，新增 MTP-137 fixture / forbidden real account tests anchors。
- 更新 `docs/domain/context.md`，新增 MTP-137 fixture shared language。
- 更新 `docs/validation/trading-validation-matrix.md`，新增 MTP-137 issue backfill。
- 更新 `docs/validation/validation-plan.md`，新增 MTP-137 required validation 与禁止项。
- 更新 `docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，新增 MTP-137 mechanical anchors。
- 更新 `docs/validation/latest-verification-summary.md`，记录 MTP-137 当前 issue execution evidence。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AccountPositionBalanceReadModelOnlyFixture` | pass | 3 tests, 0 failures。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 281 个 XCTest；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不推进 MTP-138。
- 不创建下一 Project / Issue。
- 不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现真实账户 fixture importer。
- 不导入 broker payload。
- 不调用 signed endpoint、account endpoint 或 listenKey。
- 不连接 private WebSocket。
- 不实现 account snapshot runtime。
- 不实现 broker adapter、`LiveExecutionAdapter`、OMS 或 real order lifecycle。
- 不读取真实账户、broker position、real PnL、margin 或 leverage。
- 不暴露 payload、schema、Runtime object、adapter request 或 account endpoint response。
- 不新增 App surface、不新增 Dashboard smoke handle；Workbench / Report / Events surface 仍归属 MTP-138。

---

## 2026-05-28 — MTP-138 Account / Position / Balance Workbench / Report / Events Read-model-only Surface

执行者：Codex

目的：

- 执行 Linear issue `MTP-138 Add Workbench / Report / Events read-model-only evidence surface`。
- 将 MTP-137 deterministic fixture evidence 接入 App 层 ReadModel / ViewModel。
- 在 Workbench、Report 和 Event Timeline 展示 account / position / balance read-model-only evidence，并保留 no live / broker / signed / account / OMS / trading command boundary。

更新内容：

- 新增 `Sources/App/AccountPositionBalanceReadModelOnlySurface.swift`，定义 `AccountPositionBalanceReadModelOnlySurfaceReadModel`、`AccountPositionBalanceReadModelOnlySurfaceViewModel` 和 `AccountPositionBalanceReadModelOnlySurfaceTraceItem`。
- 更新 `Sources/App/App.swift`，将 APB surface 接入 `ReportReadModel`、`ReportViewModel` 和 `DashboardViewModel` read-model-only source chain。
- 更新 `Sources/App/PaperWorkflowEvidenceExplorer.swift`，新增 `accountPositionBalanceReadModelOnlySurface` section、coverage flag 和三条 APB timeline items。
- 更新 `Sources/App/DashboardShell.swift`，新增 Workbench APB metrics / details、Report APB details 和 Dashboard smoke `accountPositionBalanceEvidence=3` handle。
- 更新 `Tests/AppTests/AppTests.swift`，新增 MTP-138 ViewModel focused tests，并更新 DashboardShell、Report、Event Timeline 和 read-model projection assertions。
- 更新 `docs/contracts/account-position-balance-read-model-only-contract.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/validation-plan.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh`，新增 MTP-138 anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AccountPositionBalanceReadModelOnlySurface` | pass | 1 test, 0 failures。 |
| `swift test --filter 'AccountPositionBalanceReadModelOnlySurface|PaperWorkflowEvidenceExplorerTimelineSnapshotAggregatesReadModelOnlyEvidence|DashboardViewModelStateSnapshotIsCodableAndDeterministic|DashboardShellSnapshotBindsViewModelSectionsForReadOnlyMacOSShell|DashboardShellWorkbenchSnapshotBindsControlsObservabilityAndExplorerReadOnly|EmptyResearchWorkbench'` | pass | 5 tests, 0 failures。 |
| `swift test --filter ReadModelProjectionMapsAllDashboardSections` | pass | 1 test, 0 failures。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 282 个 XCTest；Dashboard smoke 输出包含 `accountPositionBalanceEvidence=3`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不推进 MTP-139。
- 不创建下一 Project / Issue。
- 不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 account / position / balance runtime。
- 不读取真实账户、broker position、real PnL、margin 或 leverage。
- 不调用 signed endpoint、account endpoint 或 listenKey。
- 不连接 private WebSocket。
- 不实现 account snapshot runtime。
- 不实现 broker adapter、`LiveExecutionAdapter`、OMS 或 real order lifecycle。
- 不暴露 account endpoint payload、broker payload、schema、Runtime object、adapter request 或 broker state。
- 不新增 API key input、secret storage、broker connect、account connect、Live PRO Console、trading button、live command 或 order form。

---

## 2026-05-28 — MTP-139 Account / Position / Balance Validation Matrix / Automation Readiness / Stage Audit Input

执行者：Codex

目的：

- 执行 Linear issue `MTP-139 Close validation matrix / automation readiness / stage audit input`。
- 收口 `MTPRO Account / Position / Balance Read-model-only v1` 的 validation matrix、automation readiness anchors、forbidden capability evidence chain、read-model-only boundary evidence 和 Stage Code Audit 输入材料。
- 明确当前 issue 只准备 Parent Codex closure 输入，不输出最终 Stage Code Audit Report，不设置 Linear Project `Completed`，不创建下一 Project / Issue。

更新内容：

- 新增 `docs/audit/inputs/mtpro-account-position-balance-read-model-only-v1-stage-audit-input.md`，汇总 MTP-133 至 MTP-138 的 PR / merge / checks evidence、APB validation evidence chain、forbidden capability evidence chain、read-model-only boundary evidence、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- 更新 `docs/contracts/account-position-balance-read-model-only-contract.md`，新增 MTP-139 stage closeout、stage audit input material、no final Stage Code Audit、validation evidence chain、forbidden capability evidence chain、automation readiness stage closeout 和 validation anchors。
- 更新 `docs/domain/context.md`，新增 MTP-139 stage closeout shared language。
- 更新 `docs/validation/trading-validation-matrix.md`，新增 `TVM-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY` MTP-139 issue backfill 和阶段收口表。
- 更新 `docs/validation/validation-plan.md`，新增 MTP-139 required validation 与禁止项。
- 更新 `docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，新增 MTP-139 stage audit input anchor 与 mechanical checks。
- 更新 `docs/validation/latest-verification-summary.md`，记录 MTP-139 当前 issue execution evidence。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 282 个 XCTest；Dashboard smoke 输出包含 `accountPositionBalanceEvidence=3`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不输出最终 Stage Code Audit Report。
- 不创建 `docs/audit/mtpro-account-position-balance-read-model-only-v1-stage-code-audit.md`。
- 不设置 Linear Project `Completed`，不写 Root Docs Refresh Gate。
- 不创建下一 Project / Issue，不推进下一阶段，不启动下一阶段 `symphony-issue`。
- 不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 account / position / balance runtime。
- 不读取真实账户、broker position、real PnL、margin 或 leverage。
- 不调用 signed endpoint、account endpoint 或 listenKey。
- 不连接 private WebSocket。
- 不实现 account snapshot runtime。
- 不实现 broker adapter、`LiveExecutionAdapter`、OMS 或 real order lifecycle。
- 不新增 API key input、secret storage、broker connect、account connect、Live PRO Console、trading button、live command 或 order form。

---

## 2026-05-28 — Account / Position / Balance Read-model-only Stage Code Audit Report

执行者：Parent Codex Automation Supervision（@002 / PAR）

目的：

- 在 `MTP-133` 至 `MTP-139` 全部 Linear `Done/type=completed` 且 Linear Project `MTPRO Account / Position / Balance Read-model-only v1` 已设置为 `Completed/type=completed` 后，输出独立 Stage Code Audit Report。
- 固化 PR #245 至 PR #251 的 required check / merge evidence、Project closure evidence、read-model-only boundary、forbidden capability audit 和 Root Docs Delta input。
- 明确 Root Docs Refresh Gate 仍需后续独立 PR 关闭，不启动下一 Project / Issue。

更新内容：

- 新增 `docs/audit/mtpro-account-position-balance-read-model-only-v1-stage-code-audit.md`。
- 更新 `docs/automation/automation-readiness.md`，新增 Account / Position / Balance stage code audit report anchor。
- 更新 `checks/automation-readiness.sh`，新增 Stage Code Audit Report file / content mechanical checks。

Project closure evidence：

- Linear Project ID：`c1838a71-afbe-4f55-977c-f192a07b2e41`。
- Linear Project status：`Completed/type=completed`。
- Linear Project completedAt：`2026-05-28T13:34:31.374Z`。
- Canonical issues：`MTP-133`、`MTP-134`、`MTP-135`、`MTP-136`、`MTP-137`、`MTP-138`、`MTP-139` 全部 `Done/type=completed`。
- Terminal Project merge point：PR #251 merge commit `c41a83387ef53cba8c2eda3b1f951eb4273291ed`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 无输出。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 282 个 XCTest；Dashboard smoke 输出包含 `accountPositionBalanceEvidence=3`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不创建下一 Project / Issue，不推进 `Todo`，不启动下一阶段 `symphony-issue`。
- 不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 account / position / balance runtime、account snapshot runtime、private WebSocket runtime 或 real account read。
- 不调用 signed endpoint、account endpoint 或 listenKey。
- 不实现 broker adapter、exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real PnL、margin 或 leverage。
- 不新增 API key input、secret storage、broker connect、account connect、Live PRO Console、trading button、live command 或 order form。
- Root Docs Refresh Gate 仍为 pending，必须由后续独立 closure PR 同步已发生事实。

---

## 2026-05-28 — Account / Position / Balance Read-model-only Root Docs Refresh Gate

执行者：Parent Codex Automation Supervision（@002 / PAR）

目的：

- 在 Stage Code Audit PR #252 merge 后，关闭 `MTPRO Account / Position / Balance Read-model-only v1` 的 Root Docs Refresh Gate。
- 只同步已发生事实：`L3.1 Account / Position / Balance Read-model-only complete`、Project Closure Count `18 / 18 (100%)`、Stage Code Audit evidence、Root Docs Refresh validation evidence 和边界事实。
- 保持旧 `Final Product Goal Progress: 9 / 9 (100%)` 和旧 `Engine Maturity Roadmap Progress: 4 / 4 (100%)` 不变，不扩大旧 denominator。

Root Docs Refresh Gate 更新：

- `GOAL.md`：同步 L3.1 APB read-model-only evidence chain 已完成，下一 candidate 改为 L3.2 Future Gated。
- `BLUEPRINT.md`：同步最近完成 construction scope、Live Readiness Roadmap handoff 和 Future Gated 边界。
- `environment.md`：补充 L3.1 APB environment / secret / runtime boundary。
- `architecture.md`：补充 Evidence Read Model Layer 和 Domain + Adapter Boundary Layer 的 L3.1 APB evidence chain。
- `docs/roadmap.md`：Project Closure Count 更新为 `18 / 18 (100%)`，当前 maturity statement 更新为 `L3.1 Account / Position / Balance Read-model-only complete`。
- `docs/product/mtpro-live-readiness-roadmap-v1.md`：L3.1 标记为 Done / not counted in old denominator，L3.2 保持 Future Gated planning candidate。
- `docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`：新增 Root Docs Refresh mechanical anchors。
- `docs/validation/latest-verification-summary.md` 和 `verification.md`：追加 closure evidence。
- `docs/audit/mtpro-account-position-balance-read-model-only-v1-stage-code-audit.md`：Root Docs Refresh Gate 标记为 closed。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Root Docs Refresh docs/checks-only diff 无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；mechanical anchors 已覆盖 L3.1 APB Root Docs Refresh、Project Closure Count `18 / 18`、current maturity statement 和 forbidden scope。 |
| `bash checks/run.sh` | pass | Dashboard smoke 输出 `accountPositionBalanceEvidence=3`；Swift 测试 `282 tests, 0 failures`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不创建下一 Project / Issue，不推进 `Todo`，不启动下一阶段 `symphony-issue`。
- 不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 private stream runtime、account snapshot runtime、account / position / balance runtime 或 real account read。
- 不调用 signed endpoint、account endpoint 或 listenKey。
- 不实现 broker adapter、exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real PnL、margin 或 leverage。
- 不新增 API key input、secret storage、broker connect、account connect、Live PRO Console、trading button、live command 或 order form。

---

## 2026-05-29 — Private Stream / Account Snapshot Simulation Gate Docs-only Planning Record

执行者：Codex

目的：

- 将 Human 确认的 `MTPRO Private Stream / Account Snapshot Simulation Gate v1` planning draft 落仓为 docs-only planning record。
- 只记录 L3.2 Project 级计划摘要、issue order、dependencies、validation requirements、evidence requirements、first executable issue candidate、WIP=1、Linear write boundary 和 repository record boundary。
- 明确该 planning record 不是 Project closure，不更新 `Final Product Goal Progress`，不更新旧 `Engine Maturity Roadmap Progress`，不授权 implementation。

更新内容：

- 新增 `docs/planning/projects/mtpro-private-stream-account-snapshot-simulation-gate-v1-plan.md`。
- 更新 `docs/planning/linear-draft-plan.md`，将 `MTPRO Account / Position / Balance Read-model-only v1` 标记为已完成，并新增当前 L3.2 docs-only planning record / non-executable 入口。
- 更新 `docs/validation/latest-verification-summary.md`，记录 L3.2 Project-level planning record 已落仓且仍需 Linear 写入和 Parent Codex queue preflight 后才可执行。
- 更新 `BLUEPRINT.md`，只增加 planning record 引用，不复制完整 issue body，不更新进度条，不授权 execution。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 无输出；包含新 planning record 的 whitespace 检查。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 282 个 XCTest；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear status，不推进 Todo。
- 不启动 `@002 / PAR`、Symphony 或 `symphony-issue`。
- 不运行 Graphify，不修改 Figma。
- 不写业务代码，不实现 Private Stream runtime、Account Snapshot runtime 或 Live read-only runtime。
- 不实现 signed endpoint、account endpoint / listenKey、private WebSocket runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、real PnL、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。
- 不提交 `.codex/*` 或 `graphify-out/*`。

---

## 2026-05-29 — MTP-140 Private Stream / Account Snapshot Simulation Gate Terminology and Boundary

执行者：Codex

目的：

- 定义 `MTPRO Private Stream / Account Snapshot Simulation Gate v1` 的首个 executable issue：L3.2 private stream / account snapshot simulation gate terminology、fixture / simulated / future real private stream boundary、L3.1 APB read-model-only evidence relationship、forbidden capability baseline 和 first executable candidate non-authorization。
- 保持当前 scope 为 terminology / contract / validation anchor 层，不实现 private stream runtime、account snapshot runtime、listenKey、signed/account endpoint、broker adapter、Live PRO Console 或 UI command。

更新内容：

- 新增 `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md`。
- 更新 `docs/domain/context.md`，新增 Private Stream / Account Snapshot Simulation Gate shared language。
- 更新 `docs/validation/trading-validation-matrix.md`，新增 `TVM-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE` 和 MTP-140 issue backfill。
- 更新 `docs/validation/validation-plan.md`，新增 MTP-140 required validation。
- 更新 `docs/validation/latest-verification-summary.md`，记录 MTP-140 current issue evidence。
- 更新 `docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，新增 MTP-140 readiness anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 282 个 XCTest；Dashboard smoke 输出包含 `timelineItems=68`、`accountPositionBalanceEvidence=3` 和 `liveReadOnlyWorkbenchBoundary=5`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard behavior。
- 不创建 listenKey，不执行 listenKey keepalive。
- 不连接 private WebSocket，不实现 private stream runtime。
- 不实现 account snapshot runtime 或 account / position / balance runtime。
- 不调用 signed endpoint 或 account endpoint。
- 不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL。
- 不实现 broker adapter、exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 API key input、secret storage、broker connect、account connect、Live PRO Console、trading button、live command 或 order form。
- 不运行 Graphify，不修改 Figma。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

---

## 2026-05-30 — MTP-147 Live Monitoring Read-only Console v2 Terminology / Boundary

执行者：Codex

目的：

- 定义 `L3.3 Live Monitoring Read-only Console v2` 的 terminology / boundary contract。
- 固定 monitoring evidence 只能来自 L3.0 Live Read-only Readiness、L3.1 Account / Position / Balance Read-model-only 和 L3.2 Private Stream / Account Snapshot Simulation Gate 的 read-model-only / fixture / simulated / future-gated evidence。
- 固定 Workbench / Report / Events 后续只能消费 Read Model / ViewModel，不授权 runtime connection、endpoint、broker、Live PRO Console 或 live command。

更新内容：

- 新增 `docs/contracts/live-monitoring-read-only-console-v2-contract.md`，包含 `MTP-147-LIVE-MONITORING-READ-ONLY-CONSOLE-V2-TERMINOLOGY`、`MTP-147-MONITORING-EVIDENCE-SOURCE-BOUNDARY`、`MTP-147-READ-MODEL-VIEWMODEL-CONSUMPTION-BOUNDARY`、`MTP-147-L33-HANDOFF-BOUNDARY`、`MTP-147-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`、`MTP-147-FORBIDDEN-CAPABILITY-BASELINE` 和 `MTP-147-LIVE-MONITORING-READ-ONLY-CONSOLE-V2-VALIDATION`。
- 更新 `docs/domain/context.md`，新增 Live Monitoring Read-only Console v2 shared language。
- 更新 `docs/validation/trading-validation-matrix.md`，新增 `TVM-LIVE-MONITORING-READ-ONLY-CONSOLE-V2` 和 MTP-147 issue backfill。
- 更新 `docs/validation/validation-plan.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，补齐 MTP-147 validation 与 mechanical anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；MTP-147 contract、domain、matrix、validation plan、latest summary、automation readiness doc 和 planning anchor 均通过机械检查。 |
| `bash checks/run.sh` | pass | 通过 `git diff --check`、automation readiness、Dashboard build、Dashboard smoke 和 `swift test`；Dashboard smoke 输出包含 `readModelOnly=true`、`workbenchReadModelOnly=true`、`privateStreamSimulationGateEvidence=4`、`liveReadOnlyWorkbenchBoundary=5`、`liveMonitoringHealth=blocked`；293 个 XCTest，0 failures；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard smoke handle、不新增 App read model、不新增 Core / Runtime / Dashboard behavior、不新增 stage audit input。
- 不实现 monitoring evidence surface；MTP-152 才能接入 Workbench / Report / Events read-model-only surface。
- 不实现 live readiness runtime、Live Monitoring runtime、private WebSocket runtime、private stream runtime 或 account snapshot runtime。
- 不接 signed endpoint、account endpoint / listenKey，不创建 listenKey，不执行 listenKey keepalive。
- 不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL。
- 不实现 broker adapter、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore command。
- 不运行 Graphify，不修改 Figma。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

---

## 2026-05-30 — Live Monitoring Read-only Console v2 Docs-only Planning Record

执行者：Codex

目的：

- 将 Human 确认的 `MTPRO Live Monitoring Read-only Console v2` planning draft 落仓为 docs-only Project Planning Record。
- 记录 L3.3 Project name、Target maturity、Target Engines / Layers、goal、scope、non-goals、issue order、dependencies、validation requirements、evidence requirements、first executable issue candidate、WIP=1 / queue preflight rule、Linear write boundary 和 repository record boundary。
- 明确该 planning record 不是 Project closure，不更新 `Final Product Goal Progress`，不更新旧 `Engine Maturity Roadmap Progress`，不授权 implementation。

更新内容：

- 新增 `docs/planning/projects/mtpro-live-monitoring-read-only-console-v2-plan.md`。
- 更新 `docs/planning/linear-draft-plan.md`，新增 L3.3 docs-only planning record / non-executable 入口，并将当前 planning record 指向 L3.3。
- 更新 `docs/validation/latest-verification-summary.md`，记录 L3.3 Project-level planning record 已落仓且仍需 Linear 写入和 Parent Codex queue preflight 后才可执行。
- 更新 `BLUEPRINT.md`，只增加 L3.3 planning record 引用，不复制完整 issue body，不更新进度条，不授权 execution。
- 追加本验证记录。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | docs-only planning record diff 无 whitespace error。 |
| `bash checks/run.sh` | pass | 通过项目完整 checks；该 planning record 不写业务代码、不创建 Linear、不推进 Todo。 |

边界确认：

- 不创建 Linear Project / Issue，不修改 Linear status，不推进 Todo。
- 不启动 `@002 / PAR`，不启动 Symphony / symphony-issue。
- 不运行 Graphify，不修改 Figma。
- 不写业务代码，不实现 Live Monitoring runtime、Live readiness runtime 或 Live PRO Console。
- 不实现 signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、real PnL、trading button、live command、order form、emergency stop、shutdown 或 restore。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

---

## 2026-05-30 — MTP-146 Private Stream / Account Snapshot Simulation Gate Stage Closeout

执行者：Codex

目的：

- 收口 `MTPRO Private Stream / Account Snapshot Simulation Gate v1` 的 validation matrix、automation readiness anchors、forbidden capability evidence chain、read-model-only boundary evidence 和 Stage Code Audit 输入材料。
- 汇总 MTP-140 至 MTP-145 的 PR evidence、merge commit、required check、validation evidence、Dashboard smoke 和 forbidden capability boundary。
- 明确当前 issue 只准备 stage audit input material，不输出最终 Stage Code Audit Report，不授权下一阶段或 runtime 能力。

更新内容：

- 新增 `docs/audit/inputs/mtpro-private-stream-account-snapshot-simulation-gate-v1-stage-audit-input.md`，记录 Linear queue evidence、PR #255 至 #260 evidence、validation evidence chain、forbidden capability evidence、read-model-only boundary、automation readiness evidence、known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- 更新 `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md`，新增 MTP-146 stage closeout、stage audit input material、no final Stage Code Audit、validation evidence chain、forbidden capability evidence chain、read-model-only boundary evidence、automation readiness stage closeout 和 validation anchors。
- 更新 `docs/validation/trading-validation-matrix.md`，新增 MTP-146 issue backfill 和 Private Stream / Account Snapshot 阶段收口说明。
- 更新 `docs/validation/validation-plan.md`，新增 MTP-146 required validation、验收要求和禁止项。
- 更新 `docs/validation/latest-verification-summary.md`，记录 MTP-146 current issue evidence、validation anchors、forbidden capability boundary 和本地验证结果。
- 更新 `docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，新增 MTP-146 stage audit input anchor 与 mechanical closeout checks。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 `git diff --check`、automation readiness、Dashboard build、Dashboard smoke 和 293 个 XCTest；Dashboard smoke 输出包含 `privateStreamSimulationGateEvidence=4`、`timelineItems=72` 和 `liveReadOnlyWorkbenchBoundary=5`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不修改 production code，不新增 Swift tests，不新增 Core / App business capability。
- 不输出最终 Stage Code Audit Report，不创建下一 Project / Issue，不推进下一阶段，不启动下一阶段 `symphony-issue`。
- 不创建 listenKey，不执行 listenKey keepalive。
- 不连接 private WebSocket，不实现 private stream runtime。
- 不调用 signed endpoint 或 account endpoint。
- 不实现 account snapshot runtime、Live read-only runtime 或真实账户读取。
- 不读取真实账户、真实余额、真实持仓、broker position、margin、leverage 或 real PnL。
- 不暴露 account endpoint payload、real account payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema 或 broker state。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、command surface 或 order-level command。
- 不运行 Graphify，不修改 Figma。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

---

## 2026-05-30 — MTPRO Private Stream / Account Snapshot Simulation Gate v1 Project Closure / Stage Code Audit / Root Docs Refresh Gate

执行者：Codex

目的：

- 完成 `MTPRO Private Stream / Account Snapshot Simulation Gate v1` 的 @002 / PAR Project closure。
- 确认 Linear Project `Completed/type=completed`、MTP-140 至 MTP-146 全部 Done、PR #255 至 #261 required check evidence、root main fast-forward evidence 和 post-issue ledger evidence。
- 落仓 Stage Code Audit Report，并执行 Root Docs Refresh Gate。
- 只同步已发生事实：`L3.2 Private Stream / Account Snapshot Simulation Gate complete`、Project Closure Count `19 / 19 (100%)`、Stage Code Audit evidence、Root Docs Refresh validation evidence 和边界事实。

证据：

- Linear Project：`MTPRO Private Stream / Account Snapshot Simulation Gate v1`。
- Linear Project ID：`f93e42bc-3cf7-48c1-b4ad-4a7364e28693`。
- Linear Project status：`Completed/type=completed`，`completedAt=2026-05-29T20:21:02.281Z`。
- Issues：`MTP-140`、`MTP-141`、`MTP-142`、`MTP-143`、`MTP-144`、`MTP-145`、`MTP-146` 全部 `Done/type=completed`。
- Project 末端 PR：#261。
- PR #261 merge commit：`ae69ecb9d73d2af7b22e9d45770d43c2a691414d`。
- PR #261 required check：`checks` success，`https://github.com/atxinbao/MTPRO/actions/runs/26659457988/job/78578013730`。
- Root main / origin/main / HEAD 已 fast-forward 到 `ae69ecb9d73d2af7b22e9d45770d43c2a691414d`。
- Post-Issue Ledger：MTP-146 ledger 记录 root fast-forward；ledger hook 自动执行 `graphify update .`，输出仍为 ignored `graphify-out/*`，未提交到 Git。

Root Docs Refresh Gate 更新：

- `GOAL.md`：同步 L3.2 Private Stream / Account Snapshot Simulation Gate evidence chain 已完成，下一 candidate 改为 L3.3 Future Gated。
- `BLUEPRINT.md`：同步最近完成 construction scope、Stage Code Audit Report 引用和 handoff 状态。
- `environment.md`：同步 L3.2 未新增 secret、private endpoint、broker credential、production operations 或新 validation entry。
- `architecture.md`：同步 L3.2 evidence chain 沿 contract / deterministic fixture -> App read model / ViewModel -> Dashboard / Report / Event Timeline 流动。
- `docs/roadmap.md`：Project Closure Count 更新为 `19 / 19 (100%)`，当前 maturity statement 更新为 `L3.2 Private Stream / Account Snapshot Simulation Gate complete`。
- `docs/product/mtpro-live-readiness-roadmap-v1.md`：L3.2 标记为 Done / not counted in old denominator，L3.3 保持 Future Gated planning candidate。
- `docs/validation/latest-verification-summary.md`：同步最近完成 Project、Stage Code Audit Report、Project closure evidence、validation baseline 和 Root Docs Refresh Gate closure。
- `docs/automation/automation-readiness.md` 与 `checks/automation-readiness.sh`：新增 L3.2 Stage Code Audit Report 和 Root Docs Refresh mechanical anchors。
- `docs/audit/mtpro-private-stream-account-snapshot-simulation-gate-v1-stage-code-audit.md`：新增 canonical Stage Code Audit Report，并标记 Root Docs Refresh Gate：closed。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Root Docs Refresh Gate docs-only diff 无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；mechanical anchors 已覆盖 L3.2 Stage Code Audit Report、Root Docs Refresh、Project Closure Count `19 / 19` 和 current maturity statement。 |
| `bash checks/run.sh` | pass | 通过 `git diff --check`、automation readiness、Dashboard build、Dashboard smoke 和 293 个 XCTest；Dashboard smoke 输出包含 `privateStreamSimulationGateEvidence=4`、`timelineItems=72` 和 `liveReadOnlyWorkbenchBoundary=5`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不创建下一 Project / Issue。
- 不推进 `Todo`。
- 不启动 Symphony / `symphony-issue`。
- 不手动运行 Graphify update；MTP-146 post-issue ledger hook 的 `graphify update .` 只生成 ignored `graphify-out/*`，未提交。
- 不修改 Figma。
- 不写业务 runtime。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不授权 L3.3 / L3.4 / L4 execution。
- 不实现 signed endpoint、account endpoint / listenKey、private WebSocket runtime、private stream runtime、account snapshot runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、real PnL、Live PRO Console、trading button、live command 或 order form。

---

## 2026-05-30 — MTP-145 Workbench / Report / Events Read-model-only Simulation Gate Evidence Surface

执行者：Codex

目的：

- 把 MTP-141 至 MTP-144 已完成的 deterministic Core evidence 接入 App 层 Workbench / Report / Events read-model-only surface。
- 固定 `PrivateStreamSimulationGateEvidenceSurfaceReadModel`、`PrivateStreamSimulationGateEvidenceSurfaceViewModel` 和 `PrivateStreamSimulationGateEvidenceTraceItem`，确保 source identity、snapshot input、update fixture、freshness evidence 与 Event Timeline trace 只作为 simulation gate evidence 展示。
- 阻断 API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、signed/account endpoint、listenKey、private stream runtime、account snapshot runtime、Runtime object、adapter request、schema、account payload 和 broker state 暴露。

更新内容：

- 新增 `Sources/App/PrivateStreamSimulationGateEvidenceSurface.swift`，提供 MTP-145 App read model、view model、freshness row view model 和 Event Timeline trace item。
- 更新 `Sources/App/App.swift`，将 MTP-145 surface 接入 `ReportReadModel`、`ReportViewModel` 和 `DashboardViewModel` source chain。
- 更新 `Sources/App/PaperWorkflowEvidenceExplorer.swift`，新增 `privateStreamSimulationGateEvidenceSurface` section 和四条 read-model-only timeline items。
- 更新 `Sources/App/DashboardShell.swift`，新增 Workbench / Report metrics、details 和 Dashboard smoke handle `privateStreamSimulationGateEvidence=4`。
- 更新 `Tests/AppTests/AppTests.swift`，新增 focused App test 并回填 timeline / snapshot count baseline。
- 更新 contract、validation plan、trading validation matrix、latest verification summary、automation readiness doc 和 `checks/automation-readiness.sh` 的 MTP-145 anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter PrivateStreamSimulationGateEvidenceSurface` | pass | 执行 1 test，0 failures；覆盖 Report / Workbench / Events surface、forbidden UI/runtime flags、Dashboard smoke handle 和 Codable deterministic snapshot。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 293 个 XCTest；Dashboard smoke 输出包含 `privateStreamSimulationGateEvidence=4`、`timelineItems=72` 和 `liveReadOnlyWorkbenchBoundary=5`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不新增或修改 Core semantics；只消费 MTP-141 至 MTP-144 deterministic Core evidence。
- 不新增 Adapters、Persistence、Runtime、broker / exchange adapter implementation、secret / credential / endpoint code。
- 不创建 listenKey，不执行 listenKey keepalive。
- 不连接 private WebSocket，不实现 private stream runtime。
- 不调用 signed endpoint 或 account endpoint。
- 不实现 account snapshot runtime、freshness runtime 或任何真实账户读取。
- 不读取真实账户、真实余额、真实持仓、broker position、margin、leverage 或 real PnL。
- 不暴露 account endpoint payload、real account payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema 或 broker state。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、command surface 或 order-level command。
- 不运行 Graphify，不修改 Figma。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。
- 不推进 MTP-141，不输出 stage audit input；Project stage closeout 仍归属 MTP-146。

---

## 2026-05-29 — MTP-141 Simulated Private Account Event Source Identity

执行者：Codex

目的：

- 定义 `simulated private account event` 的 source identity、fixture source、scenario linkage、dataset / fixture version、checksum / freshness linkage 和 forbidden live stream boundary。
- 确保后续 account snapshot / balance / position update 只能从本地模拟输入进入，不从 signed endpoint、account endpoint / listenKey、private WebSocket、broker payload 或 adapter request 进入。

更新内容：

- 在 `Sources/Core/LiveTradingBoundary.swift` 新增 `SimulatedPrivateAccountEventSourceIdentityContract`、`SimulatedPrivateAccountEventSourceIdentityRecord`、`SimulatedPrivateAccountEventSourceKind` 和 `SimulatedPrivateAccountEventSourceForbiddenCapability`。
- 在 `Tests/CoreTests/CoreTests.swift` 新增 MTP-141 focused tests：deterministic source identity / checksum / freshness 验证，以及 forbidden live stream source / adapter capability matrix bypass 验证。
- 更新 `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md`，新增 MTP-141 source identity、fixture scenario version checksum freshness linkage、future real private stream label gate、forbidden live stream source tests、adapter capability matrix bypass guard 和 validation anchors。
- 更新 `docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/validation-plan.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，补齐 MTP-141 evidence chain 与 mechanical anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter SimulatedPrivateAccountEventSourceIdentity` | pass | 2 tests，0 failures；覆盖 deterministic source identity 和 forbidden live source bypass。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 284 个 XCTest；Dashboard smoke 输出包含 `timelineItems=68`、`accountPositionBalanceEvidence=3` 和 `liveReadOnlyWorkbenchBoundary=5`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不创建 listenKey，不执行 listenKey keepalive。
- 不连接 private WebSocket，不实现 private stream runtime。
- 不调用 signed endpoint 或 account endpoint。
- 不实现 account snapshot runtime 或 simulated account snapshot input contract；MTP-142 才能深化 snapshot input shape。
- 不读取真实 account payload 或 broker payload。
- 不暴露 Adapter request、SQLite / DuckDB schema 或 Runtime object。
- 不绕过 adapter capability matrix。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 Live PRO Console、trading button、live command、order form、account connect 或 broker connect。
- 不运行 Graphify，不修改 Figma。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

---

## 2026-05-31 — MTPRO Live Monitoring Read-only Console v2 Project Closure / Stage Code Audit

执行者：Codex

目的：

- 收口 `MTPRO Live Monitoring Read-only Console v2` 的 Parent Codex Project closure、Stage Code Audit Report 和 Root Docs Refresh Gate。
- 同步已完成事实：`MTP-147` 至 `MTP-153` 全部 Linear `Done/type=completed`，Linear Project 为 `Completed/type=completed`，`completedAt=2026-05-30T17:30:30.417Z`。
- 将当前成熟度结论更新为 `L3.3 Live Monitoring Read-only Console v2 complete`，Project Closure Count 更新为 `20 / 20 (100%)`，并保留 `L3.4 Strategy / Trader Instance Readiness v1` 为 Future Gated / planning candidate。

更新内容：

- 新增 `docs/audit/mtpro-live-monitoring-read-only-console-v2-stage-code-audit.md`，记录 PR #264、#265、#266、#267、#268、#269、#270、merge commits、GitHub `checks` evidence、Linear Project completion evidence、forbidden capability audit、validation 和 Root Docs Delta input。
- 更新 `GOAL.md`、`BLUEPRINT.md`、`architecture.md`、`docs/roadmap.md`、`docs/product/mtpro-live-readiness-roadmap-v1.md` 和 `docs/validation/latest-verification-summary.md`，只同步 L3.3 已发生闭环事实，不授权下一阶段。
- 更新 `docs/automation/automation-readiness.md` 与 `checks/automation-readiness.sh`，新增 Live Monitoring Read-only Console v2 stage code audit report anchor、root docs refresh anchor 和 mechanical gate。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；L3.3 Stage Code Audit Report、Root Docs Refresh、Project Closure Count `20 / 20 (100%)` 和 mechanical boundary anchors 均可检索。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 302 个 XCTest；Dashboard smoke 输出包含 `liveMonitoringReadOnlyConsoleV2Surface=4`、`readModelOnly=true` 和 `workbenchReadModelOnly=true`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不创建下一 Linear Project / Issue。
- 不推进任何 issue 到 `Todo`。
- 不启动 Symphony。
- 不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。
- 不写 Live Monitoring runtime、live readiness runtime、private stream runtime、account snapshot runtime 或 broker / OMS runtime。
- 不授权 signed endpoint、account endpoint / listenKey、private WebSocket runtime、broker adapter、`LiveExecutionAdapter`、Live PRO Console、trading button、live command、order form、stop、shutdown 或 restore。

---

## 2026-05-30 — MTP-144 Simulated Account Snapshot Freshness Evidence

执行者：Codex

目的：

- 定义 `simulated account snapshot freshness evidence` 的 deterministic Core contract，固定 fresh / stale / blocked / missing 四种本地 fixture evidence。
- 串联 MTP-141 source identity、MTP-142 simulated account snapshot input 与 MTP-143 update fixture checksum，确保 freshness evidence 只作为 read-model-only evidence 和 checksum evidence，不升级为真实 account endpoint、private stream runtime、account snapshot runtime 或 broker state。

更新内容：

- 在 `Sources/Core/LiveTradingBoundary.swift` 新增 `SimulatedAccountSnapshotFreshnessEvidenceContract`、`SimulatedAccountSnapshotFreshnessEvidenceItem`、`SimulatedAccountSnapshotFreshnessEvidenceStatus` 和 `SimulatedAccountSnapshotFreshnessEvidenceForbiddenCapability`。
- 在 `Tests/CoreTests/CoreTests.swift` 新增 MTP-144 focused tests：deterministic freshness states、endpoint/runtime/broker bypass 拒绝，以及 payload/schema/runtime exposure 拒绝。
- 更新 `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md`，新增 MTP-144 freshness / stale / blocked / missing evidence、MTP-141 / MTP-142 / MTP-143 freshness checksum boundary、forbidden endpoint/runtime tests、payload/schema/runtime non-exposure tests 和 validation anchors。
- 更新 `docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/validation-plan.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，补齐 MTP-144 evidence chain 与 mechanical anchors。

验证锚点：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --stat` | pass | 接管前 MTP-144 workspace 只有子 worker 留下的 focused test 草稿；后续只在 MTP-144 allowed scope 内产生 Core / focused test / docs / validation anchor diff。 |
| `swift test --filter SimulatedAccountSnapshotFreshnessEvidence` | pass | 3 tests，0 failures；覆盖 deterministic fresh / stale / blocked / missing states、MTP-141 / MTP-142 / MTP-143 linkage、forbidden endpoint/runtime/broker bypass 和 payload/schema/runtime non-exposure。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 292 个 XCTest；Dashboard smoke 输出包含 `timelineItems=68`、`accountPositionBalanceEvidence=3` 和 `liveReadOnlyWorkbenchBoundary=5`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不创建 listenKey，不执行 listenKey keepalive。
- 不连接 private WebSocket，不实现 private stream runtime。
- 不调用 signed endpoint 或 account endpoint。
- 不实现 account snapshot runtime、freshness runtime 或 Workbench / Report / Events surface。
- 不读取真实账户、真实余额、真实持仓、broker position、margin、leverage 或 real PnL。
- 不暴露 account endpoint payload、real account payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema 或 broker state。
- 不把 fresh / stale / blocked / missing evidence 解释为真实账户健康、broker connectivity、production incident、OMS reject 或 live monitoring runtime。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 Live PRO Console、trading button、live command、order form、account connect 或 broker connect。
- 不运行 Graphify，不修改 Figma。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

## 2026-05-29 — MTP-143 Simulated Account Snapshot Update Fixture

执行者：Codex

目的：

- 定义 `simulated account snapshot update fixture` 的 deterministic Core contract，固定 account snapshot event fixture、balance update fixture 和 position update fixture 的 fixture-only update semantics。
- 串联 MTP-141 source identity 与 MTP-142 simulated account snapshot input，确保 update fixture 只作为 read-model-only evidence 和 checksum evidence，不升级为真实账户更新、broker position sync、execution report、broker fill、reconciliation 或 real PnL。

更新内容：

- 在 `Sources/Core/LiveTradingBoundary.swift` 新增 `SimulatedAccountSnapshotUpdateFixture`、`SimulatedAccountSnapshotUpdateFixtureRecord`、`SimulatedAccountSnapshotUpdateFixtureKind`、`SimulatedAccountSnapshotUpdateInterpretationBoundary` 和 `SimulatedAccountSnapshotUpdateFixtureForbiddenCapability`。
- 在 `Tests/CoreTests/CoreTests.swift` 新增 MTP-143 focused tests：deterministic update fixture contract，以及 real account / broker position / margin / leverage / real PnL / execution report / broker fill / UI command bypass 拒绝。
- 更新 `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md`，新增 MTP-143 update fixture semantics、MTP-141 / MTP-142 linkage checksum boundary、balance / position update read-model-only boundary、update fixture interpretation isolation tests 和 validation anchors。
- 更新 `docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/validation-plan.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，补齐 MTP-143 evidence chain 与 mechanical anchors。

验证锚点：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --stat` | pass | 接管前 MTP-143 workspace diff 为空；后续只在 MTP-143 allowed scope 内产生 Core / focused test / docs / validation anchor diff。 |
| `swift test --filter SimulatedAccountSnapshotUpdateFixture` | pass | 2 tests，0 failures；覆盖 deterministic update fixture、MTP-141 / MTP-142 linkage、read-model-only boundary 和 forbidden real account / broker / PnL bypass。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 289 个 XCTest；Dashboard smoke 输出包含 `timelineItems=68`、`accountPositionBalanceEvidence=3` 和 `liveReadOnlyWorkbenchBoundary=5`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不创建 listenKey，不执行 listenKey keepalive。
- 不连接 private WebSocket，不实现 private stream runtime。
- 不调用 signed endpoint 或 account endpoint。
- 不实现 account snapshot runtime、freshness runtime 或 Workbench / Report / Events surface。
- 不读取真实账户、真实余额、真实持仓、broker position、margin、leverage 或 real PnL。
- 不暴露 account endpoint payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema。
- 不把 balance update fixture 或 position update fixture 解释为真实余额更新、真实持仓更新、broker position sync、execution report、broker fill 或 reconciliation。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 Live PRO Console、trading button、live command、order form、account connect 或 broker connect。
- 不运行 Graphify，不修改 Figma。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

---

## 2026-05-31 — MTPRO Strategy / Trader Instance Readiness Planning Record

执行者：Codex

目的：

- 将 Human 确认的 `MTPRO Strategy / Trader Instance Readiness v1` planning draft 落仓为 docs-only Project Planning Record。
- 记录 L3.4 Strategy / Trader structural readiness 的 Project 级计划摘要、issue order、dependencies、validation requirements、evidence requirements、first executable issue candidate、WIP=1、Linear write boundary、Repository record boundary 和 Parent Codex queue preflight rule。
- 同步 planning index、latest verification summary 和 automation readiness anchors，明确仓库不复制维护完整 Linear issue body，完整 issue execution contract 后续以 Linear issue body 为准。

更新内容：

- 新增 `docs/planning/projects/mtpro-strategy-trader-instance-readiness-v1-plan.md`。
- 更新 `docs/planning/linear-draft-plan.md`，将 L3.3 `MTPRO Live Monitoring Read-only Console v2` 标记为已完成，并把当前 planning record 指向 L3.4。
- 更新 `docs/validation/latest-verification-summary.md`，记录 L3.4 planning record 已落仓但未写入 Linear、不授权执行。
- 更新 `checks/automation-readiness.sh`，加入 L3.4 planning record、边界和 no-execution anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 无输出。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 302 个 XCTest；Dashboard smoke 输出包含 `liveMonitoringReadOnlyConsoleV2Surface=4`、`readModelOnly=true` 和 `workbenchReadModelOnly=true`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不创建 Linear Project。
- 不创建 Linear Issues。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify。
- 不修改 Figma。
- 不写业务代码。
- 不实现 Strategy runtime、Trader runtime、Execution Client、broker command、OMS、Live PRO Console、trading button、live command 或 order form。
- 不授权 signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position、margin、leverage 或 real PnL。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

---

## 2026-05-29 — MTP-142 Simulated Account Snapshot Input Contract

执行者：Codex

目的：

- 定义 `simulated account snapshot input` 的 deterministic input contract，固定 snapshot id、MTP-141 source identity、observedAt、source watermark、freshness status、missing / blocked state、fixture version、checksum 和 deterministic replay linkage。
- 确保 fixture-to-read-model mapping 只暴露稳定 read model fields，并通过 focused tests 阻断 signed/account endpoint、listenKey、private WebSocket、runtime、real account payload、broker payload、schema、Adapter request 和 UI command bypass。

更新内容：

- 在 `Sources/Core/LiveTradingBoundary.swift` 新增 `SimulatedAccountSnapshotInputContract`、`SimulatedAccountSnapshotInputRecord`、`SimulatedAccountSnapshotInputState` 和 `SimulatedAccountSnapshotInputForbiddenCapability`。
- 在 `Tests/CoreTests/CoreTests.swift` 新增 MTP-142 focused tests：deterministic snapshot input contract、endpoint/runtime/payload bypass 拒绝，以及 payload/schema/runtime mapping 拒绝。
- 更新 `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md`，新增 MTP-142 snapshot input shape、snapshot id / source / observedAt / freshness / state、fixture version / checksum / deterministic replay linkage、fixture-to-read-model mapping boundary、account payload isolation tests 和 validation anchors。
- 更新 `docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/validation-plan.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`，补齐 MTP-142 evidence chain 与 mechanical anchors。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter SimulatedAccountSnapshotInput` | pass | 3 tests，0 failures；覆盖 deterministic input、forbidden endpoint/runtime/payload bypass 和 fixture-to-read-model mapping boundary。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`。 |
| `git diff --check` | pass | 无输出。 |
| `bash checks/run.sh` | pass | 通过 automation readiness、Dashboard build、Dashboard smoke 和 287 个 XCTest；Dashboard smoke 输出包含 `timelineItems=68`、`accountPositionBalanceEvidence=3` 和 `liveReadOnlyWorkbenchBoundary=5`；最终输出 `MTPRO checks passed.`。 |

边界确认：

- 不创建 listenKey，不执行 listenKey keepalive。
- 不连接 private WebSocket，不实现 private stream runtime。
- 不调用 signed endpoint 或 account endpoint。
- 不实现 account snapshot runtime、balance / position update fixture semantics、freshness runtime 或 Workbench / Report / Events surface。
- 不读取真实账户、真实余额、margin、leverage 或 real PnL。
- 不暴露 account endpoint payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema。
- 不绕过 fixture-to-read-model mapping boundary。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 Live PRO Console、trading button、live command、order form、account connect 或 broker connect。
- 不运行 Graphify，不修改 Figma。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

## 2026-06-01 — MTP-183 Target module physical layout migration contract

执行者：Codex

范围：

- 为 `MTP-183 Define target module physical layout and SwiftPM migration contract` 落仓 contract-first migration evidence。
- 新增 `docs/contracts/target-module-physical-layout-source-migration-contract.md`，固定 target physical layout、current SwiftPM snapshot、SwiftPM migration contract、old-to-new source map、compatibility shell policy、import direction guard、tests placement 和 validation anchors。
- 更新 `docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh`，建立 MTP-183 mechanical anchors。

边界：

- 未移动 `Sources` 文件。
- 未修改 `Package.swift` target graph。
- 未写业务代码。
- 未启动 Symphony / symphony-issue，未运行 Graphify，未修改 Figma。
- 不授权 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、signed endpoint、account endpoint / listenKey、private WebSocket runtime、broker adapter、real order lifecycle、Live PRO Console、trading button、live command 或 order form。

验证：

- `git diff --check`：pass，无输出。
- `bash checks/automation-readiness.sh`：pass，输出 `MTPRO automation readiness checks passed.`。
- `bash checks/run.sh`：pass，通过 `git diff --check`、automation readiness、Dashboard build、Dashboard smoke 和 303 个 XCTest；Dashboard smoke 输出包含 `timelineItems=82`、`scenarioReplayEvidence=1`、`scenarioQualityGates=6`、`simulatedParityEvidence=1`、`accountPositionBalanceEvidence=3`、`privateStreamSimulationGateEvidence=4`、`liveMonitoringReadOnlyConsoleV2Surface=4`、`strategyTraderReadinessSurface=6` 和 `liveReadOnlyWorkbenchBoundary=5`；最终输出 `MTPRO checks passed.`。

## 2026-06-01 — MTP-185 DataClient / DataEngine physical migration

执行者：Codex

范围：

- 将 Binance public read-only client、batch replay boundary、replay metadata、freshness 和 deterministic parity 从 `Sources/Adapters/` 迁入 `Sources/DataClient/Binance/PublicMarketData/`。
- 将 Data Catalog / Scenario Replay、Scenario Manifest、Scenario Fixture、Scenario Replay Evidence 和 deterministic matching 从 `Sources/Core/` 迁入 `Sources/DataEngine/ScenarioReplay/`。
- 将 Scenario Data Quality / Report Input 迁入 `Sources/DataEngine/DataQuality/`。
- 将 public market data ingest workflow 从 `Sources/Runtime/Runtime.swift` 迁入 `Sources/DataEngine/Ingest/MarketDataIngestReplayProjectionWorkflow.swift`。
- 调整 `Package.swift`，让现有 `Adapters`、`Core` 和 `Runtime` target 继续作为 compatibility envelope 编译目标目录 source roots，不新增 SwiftPM target、product 或 dependency。
- 更新 architecture/domain/validation/automation/latest summary/readiness anchors，记录 MTP-185 moved files、compatibility envelope、public read-only guard、DataEngine boundary guard 和 remaining compatibility shell。

边界：

- 未新增 SwiftPM target、product 或 dependency，未做 target graph split。
- 未实现 signed endpoint、account endpoint、listenKey、private WebSocket runtime、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、完整 streaming DataEngine runtime、Live PRO Console、trading button、live command 或 order form。
- 未迁移 Cache、Database、Strategies、Trader、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard，除保持现有 target buildability 的最小 import compatibility 外未扩大 scope。
- 未启动 Symphony / symphony-issue，未运行 Graphify，未修改 Figma。
- `.codex/*`、`.build/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `swift test --filter AdaptersTests`：pass，26 tests，0 failures。
- `swift test --filter RuntimeTests/testMarketDataIngestReplayProjectionWorkflowUsesMockTransportAndStableSnapshots`：pass，1 test，0 failures。
- `swift test --filter CoreTests/testMTP103DataCatalogScenarioReplayDefinesTerminologyAndBoundaryAnchors`：pass，1 test，0 failures。
- `swift test --filter CoreTests/testMTP107ScenarioDataQualityGatesDefineTaxonomyAndDeterministicVerdict`：pass，1 test，0 failures。
- `git diff --check`：pass，无输出。
- `bash checks/automation-readiness.sh`：pass，输出 `MTPRO automation readiness checks passed.`。
- `bash checks/run.sh`：pass，通过 `git diff --check`、automation readiness、Dashboard build、Dashboard smoke 和 303 个 XCTest；Dashboard smoke 输出包含 `timelineItems=82`、`scenarioReplayEvidence=1`、`scenarioQualityGates=6`、`simulatedParityEvidence=1`、`accountPositionBalanceEvidence=3`、`privateStreamSimulationGateEvidence=4`、`liveMonitoringReadOnlyConsoleV2Surface=4`、`strategyTraderReadinessSurface=6` 和 `liveReadOnlyWorkbenchBoundary=5`；最终输出 `MTPRO checks passed.`。

## 2026-06-01 — MTP-184 DomainModel / MessageBus physical migration

执行者：Codex

范围：

- 将 `Sources/Core/MarketPrimitives.swift`、`Sources/Core/MarketDataModels.swift` 和 `Sources/Core/CoreBaseline.swift` 迁入 `Sources/DomainModel/`。
- 将 `Sources/Core/DomainEvents.swift`、`Sources/Core/CommandsAndQueries.swift`、`Sources/Core/EventLog.swift` 和 `Sources/Core/PaperRuntimeBusRouting.swift` 迁入 `Sources/MessageBus/`。
- 调整 `Package.swift`，让现有 `Core` target 继续编译 `Core`、`DomainModel` 和 `MessageBus` source roots，并显式排除其他 target 目录。
- 更新 architecture/domain/validation/automation/latest summary/readiness anchors，记录 MTP-184 moved files、compatibility envelope、no behavior change boundary 和 forbidden higher-module migration。

边界：

- 未新增 SwiftPM target、product 或 dependency，未做 target graph split。
- 未迁移 DataClient、DataEngine、Cache、Database、Strategies、Trader、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard。
- 未实现 runtime MessageBus、Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker / live / order capability、signed endpoint、account endpoint / listenKey、private WebSocket runtime、Live PRO Console、trading button、live command 或 order form。
- 未启动 Symphony / symphony-issue，未运行 Graphify，未修改 Figma。
- `.codex/*`、`.build/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `swift test --filter CoreTests`：pass，216 tests，0 failures。
- `git diff --check`：pass，无输出。
- `bash checks/automation-readiness.sh`：pass，输出 `MTPRO automation readiness checks passed.`。
- `bash checks/run.sh`：pass，通过 `git diff --check`、automation readiness、Dashboard build、Dashboard smoke 和 303 个 XCTest；Dashboard smoke 输出包含 `timelineItems=82`、`scenarioReplayEvidence=1`、`scenarioQualityGates=6`、`simulatedParityEvidence=1`、`accountPositionBalanceEvidence=3`、`privateStreamSimulationGateEvidence=4`、`liveMonitoringReadOnlyConsoleV2Surface=4`、`strategyTraderReadinessSurface=6` 和 `liveReadOnlyWorkbenchBoundary=5`；最终输出 `MTPRO checks passed.`。

## 2026-06-02 — MTPRO Target Module Physical Layout / Source Migration v1 Root Docs Refresh Gate

执行者：Codex

范围：

- 基于已合并的 Stage Code Audit Report `docs/audit/mtpro-target-module-physical-layout-source-migration-v1-stage-code-audit.md` 执行 Root Docs Refresh Gate。
- 只同步已发生事实：`Target Module Physical Layout / Source Migration before L4 complete`、Project Closure Count `23 / 23 (100%)`、Stage Code Audit PR #314 evidence、Project closure evidence、validation baseline 和边界事实。
- 更新 `GOAL.md`、`BLUEPRINT.md`、`architecture.md`、`docs/roadmap.md`、`docs/product/mtpro-live-readiness-roadmap-v1.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md`、`docs/audit/mtpro-target-module-physical-layout-source-migration-v1-stage-code-audit.md` 和 `checks/automation-readiness.sh`。

边界：

- 不创建下一 Project / Issue，不推进 `Todo`。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不新增 SwiftPM target、product 或 dependency，不做 SwiftPM target graph split。
- 不实现 Strategy runtime、Trader runtime、Portfolio runtime、RiskEngine runtime、ExecutionEngine runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker adapter、signed endpoint、account endpoint / listenKey、private stream runtime、account snapshot runtime、Live PRO Console、trading button、live command 或 order form。
- `.codex/*`、`.build/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass，无输出。
- `bash checks/automation-readiness.sh`：pass，输出 `MTPRO automation readiness checks passed.`。
- `bash checks/run.sh`：pass，通过 automation readiness、Dashboard build、Dashboard smoke 和 306 个 XCTest；Dashboard smoke 输出包含 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`timelineItems=82`、`strategyTraderReadinessSurface=6` 和 `liveMonitoringReadOnlyConsoleV2Surface=4`；最终输出 `MTPRO checks passed.`。

## 2026-06-02 — MTPRO Trader-Owned Strategies Layout Correction v1 docs-only planning record

执行者：Codex

范围：

- 将 Human 确认的 `MTPRO Trader-Owned Strategies Layout Correction v1` planning draft 落仓为 docs-only Project Planning Record。
- 新增 `docs/planning/projects/mtpro-trader-owned-strategies-layout-correction-v1-plan.md`，记录 Project name、Target maturity、Target Engines / Modules、goal、scope、non-goals、milestones、corrected issue order、corrected dependencies、validation requirements、evidence requirements、first executable issue candidate、WIP=1、Linear write boundary 和 repository record boundary。
- 更新 `docs/planning/linear-draft-plan.md`，把 `MTPRO Target Module Physical Layout / Source Migration v1` 标记为已完成，并新增当前 Trader-owned strategy layout correction docs-only / non-executable planning record 入口。
- 更新 `docs/validation/latest-verification-summary.md`，记录该 Project-level planning record 已落仓，且这不是 Project closure，不更新 `Final Product Goal Progress`，不更新旧 `Engine Maturity Roadmap Progress`。
- 更新 `BLUEPRINT.md`，只增加 planning record 引用，不复制完整 issue body，不更新进度条，不授权 execution。

边界：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify。
- 不修改 Figma。
- 不移动 production source。
- 不修改 `Package.swift`。
- 不拆 SwiftPM target graph。
- 不写业务代码。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass，无输出。
- `bash checks/run.sh`：pass，通过项目完整 checks；该 planning record 不写业务代码、不创建 Linear、不推进 Todo。

## 2026-06-02 — MTPRO Trader EMA Strategy Layout Consolidation v1 docs-only planning record

执行者：Codex

范围：

- 将 Human 确认的 `MTPRO Trader EMA Strategy Layout Consolidation v1` planning draft 落仓为 docs-only Project Planning Record。
- 新增 `docs/planning/projects/mtpro-trader-ema-strategy-layout-consolidation-v1-plan.md`，记录 Project name、Target maturity、Target Engines / Modules、goal、scope、non-goals、corrected issue order、dependencies、validation requirements、evidence requirements、first executable issue candidate、WIP=1、Linear write boundary 和 repository record boundary。
- 更新 `docs/planning/linear-draft-plan.md`，把 `MTPRO Trader-Owned Strategies Layout Correction v1` 标记为已完成，并新增当前 EMA-only strategy layout consolidation docs-only / non-executable planning record 入口。
- 更新 `docs/validation/latest-verification-summary.md`，记录该 Project-level planning record 已落仓，且这不是 Project closure，不更新 `Final Product Goal Progress`，不更新旧 `Engine Maturity Roadmap Progress`。
- 更新 `BLUEPRINT.md`，只增加 planning record 引用，不复制完整 issue body，不更新进度条，不授权 execution。

边界：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify。
- 不修改 Figma。
- 不移动 production source。
- 不修改 `Package.swift`。
- 不拆 SwiftPM target graph。
- 不写业务代码。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass，无输出。
- `bash checks/run.sh`：pass，通过项目完整 checks；该 planning record 不写业务代码、不创建 Linear、不推进 Todo。

## 2026-06-02 — Symphony / Graphify service retirement

执行者：Codex

范围：

- 删除 MTPRO 当前自动化流程中的 Symphony / Graphify 服务依赖。
- 删除 `.graphifyignore`。
- 删除 `docs/automation/graphify-resource-graph-scope.md`。
- 删除 `docs/automation/symphony-issue-workflow-template.md`。
- 删除本地生成目录 `graphify-out/`。
- 更新 `README.md`、`AGENTS.md`、`BLUEPRINT.md`、`environment.md`、`docs/roadmap.md`、`docs/planning/project-role-map.md`、`docs/automation/*`、`.github/pull_request_template.md` 和 `checks/automation-readiness.sh`，把当前执行链收敛为 Parent Codex queue preflight、Codex Execution Agent、GitHub PR Automation、Post-Issue Ledger 和 Linear evidence。
- `checks/automation-readiness.sh` 增加 retired path 缺席检查，防止 `.graphifyignore`、`graphify-out/`、Graphify scope 文档或 Symphony workflow template 被重新引入。

边界：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify。
- 不修改 Figma。
- 不写业务代码。
- 不移动 production source。
- 不修改 `Package.swift`。
- 不拆 SwiftPM target graph。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。

验证：

- `ps aux | rg -i "symphony|graphify"`：pass，未发现运行中的 Symphony / Graphify 服务进程。
- `find . -maxdepth 3 \( -name ".graphifyignore" -o -name "graphify-out" -o -name "*symphony-issue-workflow-template*" -o -name "*graphify-resource-graph-scope*" \) -print`：pass，无输出。
- `git diff --check`：pass，无输出。
- `bash checks/automation-readiness.sh`：pass，输出 `MTPRO automation readiness checks passed.`。
- `bash checks/run.sh`：pass，Dashboard smoke 正常，308 个 XCTest / 0 failures，最终输出 `MTPRO checks passed.`。

## 2026-06-03 — MTPRO Trader EMA Strategy Layout Consolidation v1 Root Docs Refresh Gate

执行者：Codex

范围：

- 同步 `MTPRO Trader EMA Strategy Layout Consolidation v1` 已发生的 Project closure 事实。
- 记录 Linear Project `Completed/type=completed`，`completedAt=2026-06-02T16:18:43.202Z`。
- 记录 MTP-198 至 MTP-204 全部 Done / completed，末端 issue PR #334 merge commit `36bd4fe6389e16837137c42afe3ef8d8ef5e5121`，required check `checks` SUCCESS。
- 记录 Stage Code Audit PR #335 merge commit `b0f9f4f6adb47194ff643a5ddc548b5f2c72cfd2`，required check `checks` SUCCESS。
- 更新 `GOAL.md`、`BLUEPRINT.md`、`architecture.md`、`docs/roadmap.md` 和 `docs/validation/latest-verification-summary.md`，把当前成熟度结论同步为 `Trader EMA Strategy Layout Consolidation before L4 complete`。
- Project Closure Count 从 `24 / 24 (100%)` 更新为 `25 / 25 (100%)`；Final Product Goal Progress 保持 `9 / 9 (100%)`；Engine Maturity Roadmap Progress 保持 `4 / 4 (100%)`。

边界：

- 不创建下一 Linear Project / Issue。
- 不推进下一 Todo。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify。
- 不运行 code-index。
- 不修改 Figma。
- 不写业务代码。
- 不移动 production source。
- 不修改 `Package.swift`。
- 不拆 SwiftPM target graph。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass，无输出。
- `bash checks/automation-readiness.sh`：pass，输出 `MTPRO automation readiness checks passed.`。
- `bash checks/run.sh`：pass，通过 automation readiness、Dashboard build、Dashboard smoke 和完整 XCTest，最终输出 `MTPRO checks passed.`。

## 2026-06-03 — Root Architecture / Environment Authority Compression

执行者：Codex

范围：

- 将 `docs/architecture.md` 提升并迁移为根目录 `architecture.md`。
- 将 `docs/environment.md` 提升并迁移为根目录 `environment.md`。
- 在 `architecture.md` 中补充当前架构流：`DataClient/<venue>` 负责从交易所 / venue 输入 public read-only 数据，`DataEngine` 将外部数据整理为内部事实、replay、quality 和 read-model 输入，`Trader/Strategies/EMA` 只产生 signal / proposal / evidence，`Trader/Coordination` 串联 account、portfolio、risk、execution context，`ExecutionEngine` 管内部 paper / simulated lifecycle，`ExecutionClient` 仅保留为未来“把订单发出去”的外部执行适配器 future gate。
- 在 `architecture.md` 中补充当前源码模块地形、依赖方向和 forbidden path taxonomy，明确 active concrete strategy only `EMA`，canonical active strategy path only `Sources/Trader/Strategies/EMA/`，binding / adapter 语义归入 `Sources/Trader/Coordination/RiskBinding/`。
- 更新 `environment.md`，明确它是根目录高权重承接文档，维护本地环境、验证入口、外部系统能力矩阵、secret / local state boundary 和 automation boundary。
- 更新 root docs、planning docs、audit docs、validation docs 和 reference docs 中对 `architecture.md` / `environment.md` 的引用。
- 更新 source-document anchor 字符串和对应测试预期，使既有 evidence contract 指向根目录 `architecture.md`。
- 更新 `checks/automation-readiness.sh`，要求根目录 `architecture.md` / `environment.md` 存在，旧 `docs/architecture.md` / `docs/environment.md` 不再存在，并校验新的 DataClient / DataEngine / ExecutionClient / Trader architecture anchors。

边界：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify。
- 不运行 code-index。
- 不修改 Figma。
- 不写业务 runtime。
- 不移动 production source。
- 不修改 `Package.swift`。
- 不拆 SwiftPM target graph。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass，无输出。
- `bash checks/automation-readiness.sh`：pass，输出 `MTPRO automation readiness checks passed.`。
- `bash checks/run.sh`：pass，Dashboard smoke 正常，309 个 XCTest / 0 failures，最终输出 `MTPRO checks passed.`。

备注：

- SwiftPM 当前仍输出 `Invalid Exclude .../Sources/Strategies: File not found.` warning；这是已退休 `Sources/Strategies` 目录仍被 `Package.swift` exclude 引用导致的非阻断 warning。本轮按边界不修改 `Package.swift`，建议后续单独收口。

## 2026-06-03 — MTPRO Trader Accounts / Coordination Compatibility Consolidation v1 docs-only planning record

执行者：Codex

范围：

- 将 Human 确认的 `MTPRO Trader Accounts / Coordination Compatibility Consolidation v1` planning draft 落仓为 docs-only Project Planning Record。
- 新增 `docs/planning/projects/mtpro-trader-accounts-coordination-compatibility-consolidation-v1-plan.md`。
- 更新 `docs/planning/linear-draft-plan.md`，把 `MTPRO Trader EMA Strategy Layout Consolidation v1` 标记为已完成，并新增当前 Trader Accounts / Coordination compatibility consolidation docs-only / non-executable planning record 入口。
- 更新 `docs/validation/latest-verification-summary.md`，记录该 Project-level planning record 已落仓，且这不是 Project closure，不更新 `Project Closure Count`、`Final Product Goal Progress` 或旧 `Engine Maturity Roadmap Progress`。
- 更新 `BLUEPRINT.md`，只增加 planning record 引用，不复制完整 issue body，不更新进度条，不授权 execution。

边界：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify。
- 不运行 code-index。
- 不修改 Figma。
- 不新增或移动 production source。
- 不修改 `Package.swift`。
- 不拆 SwiftPM target graph。
- 不实现 Trader runtime、Strategy runtime、Live runtime、`ExecutionClient` implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass，无输出。
- `bash checks/automation-readiness.sh`：pass，输出 `MTPRO automation readiness checks passed.`。
- `bash checks/run.sh`：pass，通过 automation readiness、Dashboard build、Dashboard smoke 和完整 XCTest；Dashboard smoke 正常，309 个 XCTest / 0 failures，最终输出 `MTPRO checks passed.`。

备注：

- `bash checks/run.sh` 仍输出已知 SwiftPM warning：`Invalid Exclude .../Sources/Strategies: File not found.`。这是已退休 `Sources/Strategies` 目录仍被 `Package.swift` exclude 引用导致的非阻断 warning，也是本次新 planning record 后续 Issue 5 的计划 cleanup 对象；本轮按 docs-only 边界不修改 `Package.swift`。

## 2026-06-03 — MTPRO Trader Accounts / Coordination Compatibility Consolidation v1 Project closure

执行者：Parent Codex / Codex

范围：

- 完成 `MTPRO Trader Accounts / Coordination Compatibility Consolidation v1` Project closure flow 的 docs-only Stage Code Audit 和 Root Docs Refresh Gate。
- 新增 `docs/audit/mtpro-trader-accounts-coordination-compatibility-consolidation-v1-stage-code-audit.md`。
- 汇总 `MTP-205` 至 `MTP-211` 的 issue / PR / merge / required check evidence。
- 同步 `GOAL.md`、`BLUEPRINT.md`、`docs/roadmap.md`、`docs/product/mtpro-live-readiness-roadmap-v1.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 中的已完成事实。
- 当前权威口径为 `Trader = Accounts + Strategies/EMA + Coordination`。
- `Sources/Trader/Accounts` 只表达 account identity、source identity 和 future real account gate。
- 当前 active concrete strategy only `EMA`，canonical active path only `Sources/Trader/Strategies/EMA/`。
- `Sources/Trader/Coordination/RiskBinding` 只表达 coordination / binding boundary。
- Project Closure Count 更新为 `26 / 26 (100%)`；Final Product Goal Progress 保持 `9 / 9 (100%)`；Engine Maturity Roadmap Progress 保持 `4 / 4 (100%)`。

边界：

- 不创建下一 Linear Project / Issue。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify。
- 不修改 Figma。
- 不写业务 runtime。
- 不拆 SwiftPM target graph。
- 不实现 Trader runtime、Strategy runtime、Live runtime。
- 不读取真实账户。
- 不接 signed endpoint、account endpoint / listenKey 或 private WebSocket runtime。
- 不实现 ExecutionClient implementation、OMS、broker gateway、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass，无输出。
- `bash checks/automation-readiness.sh`：pass，输出 `MTPRO automation readiness checks passed.`。
- `bash checks/run.sh`：pass，通过 automation readiness、Dashboard build、Dashboard smoke 和完整 XCTest；Dashboard smoke 正常，315 个 XCTest / 0 failures，最终输出 `MTPRO checks passed.`。

备注：

- Linear Project final `Completed/type=completed` status 按 closure flow 在本 Stage Code Audit / Root Docs Refresh PR 合并且 GitHub required check `checks` 成功后设置。

## 2026-06-03 — MTPRO Persistence Validation Repair v1 docs-only planning record

执行者：Codex

范围：

- 将 Human 确认的 `MTPRO Persistence Validation Repair v1` planning draft 落仓为 docs-only Project Planning Record。
- 新增 `docs/planning/projects/mtpro-persistence-validation-repair-v1-plan.md`。
- 更新 `docs/planning/linear-draft-plan.md`，把 `MTPRO Trader Accounts / Coordination Compatibility Consolidation v1` 标记为已完成，并新增当前 Persistence repair docs-only / non-executable planning record 入口。
- 更新 `docs/validation/latest-verification-summary.md`，记录当前 `main` 存在 PersistenceTests `xctest` signal 11 validation blocker。
- 更新 `BLUEPRINT.md`，只增加 repair planning record 引用，不复制完整 issue body，不更新进度条，不授权 execution。

已知 validation blocker：

```text
PersistenceTests/testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant
-> xctest signal 11
```

该 blocker 是本 repair Project 的目标修复对象。本 docs-only planning PR 不要求 `bash checks/run.sh` 通过；如 GitHub required check `checks` 因同一 blocker 失败，不解释为 planning record 内容错误。

边界：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify update。
- 不修改 Figma。
- 不修复 production code。
- 不修改 Persistence implementation。
- 不修改 `Tests/PersistenceTests` 行为。
- 不移动 `Sources` 文件。
- 不修改 `Package.swift` target graph。
- 不拆 SwiftPM target graph。
- 不修改 architecture module layout。
- 不实现 Trader runtime、Strategy runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation 或 L4 implementation。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass，无输出。
- `bash checks/automation-readiness.sh`：pass，输出 `MTPRO automation readiness checks passed.`。
- `bash checks/run.sh`：不要求通过；当前已知 blocker 正是本 Project 要修复的问题。

## 2026-06-04 — MTPRO Persistence Validation Repair v1 Project closure

执行者：Parent Codex / Codex

范围：

- 完成 `MTPRO Persistence Validation Repair v1` Project closure flow 的 docs-only Stage Code Audit 和 Root Docs Refresh Gate。
- 新增 `docs/audit/mtpro-persistence-validation-repair-v1-stage-code-audit.md`。
- 汇总 `MTP-213` 至 `MTP-215` 的 issue / PR / merge / required check evidence。
- 明确 `MTP-212` 为 Duplicate / non-canonical，指向 `MTP-213`，不进入 closure count。
- 原 `PersistenceTests/testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant -> xctest signal 11` 在 clean build 当前 main 未复现。
- MTP-214 没有做无根据 production repair。
- MTP-215 已恢复完整 validation baseline。
- Project Closure Count 更新为 `27 / 27 (100%)`；Final Product Goal Progress 保持 `9 / 9 (100%)`；Engine Maturity Roadmap Progress 保持 `4 / 4 (100%)`。

边界：

- 不创建下一 Linear Project / Issue。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify 或 code-index。
- 不修改 Figma。
- 不修改 Persistence implementation。
- 不修改 `Tests/PersistenceTests` 行为。
- 不移动 production source。
- 不修改 `Package.swift`。
- 不拆 SwiftPM target graph。
- 不修改 architecture module layout。
- 不实现 Trader runtime、Strategy runtime、Live runtime。
- 不接 signed endpoint、account endpoint / listenKey 或 private WebSocket runtime。
- 不实现 ExecutionClient implementation、OMS、broker gateway、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass，无输出。
- `bash checks/automation-readiness.sh`：pass，输出 `MTPRO automation readiness checks passed.`。
- `swift package clean`：pass，清理 stale SwiftPM / XCTest build cache；清理后 focused Persistence test 通过。
- `bash checks/run.sh`：pass，通过 automation readiness、Dashboard build、Dashboard smoke 和完整 XCTest；Dashboard smoke 正常，315 个 XCTest / 0 failures，最终输出 `MTPRO checks passed.`。

## 2026-06-04 — MTPRO SwiftPM Target Graph Module Split v1 docs-only planning record

执行者：Codex

范围：

- 将 Human 确认的 `MTPRO SwiftPM Target Graph Module Split v1` planning draft 落仓为 docs-only Project Planning Record。
- 新增 `docs/planning/projects/mtpro-swiftpm-target-graph-module-split-v1-plan.md`。
- 更新 `docs/planning/linear-draft-plan.md`，新增当前 SwiftPM target graph module split docs-only / non-executable planning record 入口。
- 更新 `docs/validation/latest-verification-summary.md`，记录该 Project-level planning record 已落仓，且这不是 Project closure，不更新 `Project Closure Count`、`Final Product Goal Progress` 或旧 `Engine Maturity Roadmap Progress`。
- 更新 `BLUEPRINT.md`，只增加 planning record 引用，不复制完整 issue body，不更新进度条，不授权 execution。

边界：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify / code-index。
- 不修改 Figma。
- 不写业务代码。
- 不移动 `Sources` 文件。
- 不修改 `Package.swift` target graph。
- 不拆 SwiftPM target graph。
- 不修改 architecture module layout。
- 不实现 Trader runtime、Strategy runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- 不推进 L4。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass，无输出。
- `bash checks/run.sh`：pass，通过 automation readiness、Dashboard build、Dashboard smoke 和完整 XCTest；Dashboard smoke 正常，315 个 XCTest / 0 failures，最终输出 `MTPRO checks passed.`。

## 2026-06-04 — MTPRO SwiftPM Target Graph Module Split v1 Project closure

执行者：Parent Codex / Codex

范围：

- 完成 `MTPRO SwiftPM Target Graph Module Split v1` Project closure flow 的 Stage Code Audit 和 Root Docs Refresh Gate。
- 确认 Linear Project `Completed/type=completed`，completedAt `2026-06-03T23:42:28.499Z`。
- 新增 `docs/audit/mtpro-swiftpm-target-graph-module-split-v1-stage-code-audit.md`。
- 汇总 `MTP-216` 至 `MTP-223` 的 issue / PR / merge / required check / Linear Done evidence。
- 确认末端 issue PR #359 merge commit `785c26d0d0dd4db835fbb5a340cb18359a40e52b`。
- 确认 Stage Code Audit PR #360 merge commit `abb8c99dd3ec733a595082ee33461bdb84b6bba9`。
- Project Closure Count 更新为 `28 / 28 (100%)`；Final Product Goal Progress 保持 `9 / 9 (100%)`；Engine Maturity Roadmap Progress 保持 `4 / 4 (100%)`。
- 当前成熟度结论更新为 `SwiftPM Target Graph Module Split before L4 complete`。

边界：

- 不创建下一 Linear Project / Issue。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify 或 code-index。
- 不修改 Figma。
- 不实现 Strategy runtime、Trader runtime 或 Live runtime。
- 不实现 ExecutionClient implementation、OMS implementation 或 broker gateway。
- 不接 signed endpoint、account endpoint / listenKey 或 private WebSocket runtime。
- 不实现 real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- 不授权 L4 capability。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass，无输出。
- `bash checks/automation-readiness.sh`：pass，输出 `MTPRO automation readiness checks passed.`。
- `bash checks/run.sh`：pass，通过 automation readiness、Dashboard build、Dashboard smoke 和完整 XCTest；Dashboard smoke 正常，325 个 XCTest / 0 failures，最终输出 `MTPRO checks passed.`。

## 2026-06-04 — MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration v1 docs-only planning record

执行者：Codex

范围：

- 将 Human 确认的 `MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration v1` planning draft 落仓为 docs-only Project Planning Record。
- 新增 `docs/planning/projects/mtpro-targetgraph-anchor-retirement-real-module-source-root-migration-v1-plan.md`。
- 更新 `docs/planning/linear-draft-plan.md`，把 `MTPRO SwiftPM Target Graph Module Split v1` 标记为已完成 historical planning evidence，并新增当前 TargetGraph anchor retirement docs-only / non-executable planning record 入口。
- 更新 `docs/validation/latest-verification-summary.md`，记录该 Project-level planning record 已落仓，且这不是 Project closure，不更新 `Project Closure Count`、`Final Product Goal Progress` 或旧 `Engine Maturity Roadmap Progress`。
- 更新 `BLUEPRINT.md`，只增加 planning record 引用，不复制完整 issue body，不更新进度条，不授权 execution。

边界：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify / code-index。
- 不修改 Figma。
- 不写业务代码。
- 不移动 `Sources` 文件。
- 不修改 `Package.swift` target graph。
- 不拆 SwiftPM target graph。
- 不修改 architecture module layout。
- 不实现 Trader runtime、Strategy runtime、Live runtime、`ExecutionClient` implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- 不推进 L4。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass，无输出。
- `bash checks/run.sh`：pass，通过 automation readiness、Dashboard build、Dashboard smoke 和完整 XCTest；Dashboard smoke 正常，325 个 XCTest / 0 failures，最终输出 `MTPRO checks passed.`。

## 2026-06-04 — MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration v1 Project closure

执行者：Parent Codex / Codex

范围：

- 完成 `MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration v1` Project closure flow 的 Stage Code Audit 和 Root Docs Refresh Gate。
- 确认 Linear Project `Completed/type=completed`，completedAt `2026-06-04T15:17:36.000Z`。
- 新增 `docs/audit/mtpro-targetgraph-anchor-retirement-real-module-source-root-migration-v1-stage-code-audit.md`。
- 汇总 `MTP-224` 至 `MTP-232` 的 issue / PR / merge / required check / Linear Done evidence。
- 确认末端 issue PR #371 merge commit `75ed77309d4a84eb8fbea6b6127dff37e2636d78`。
- 确认 Stage Code Audit PR #372 merge commit `5feacecfe1df3bd4e5f3627fb4cbac38a1753afb`。
- Project Closure Count 更新为 `29 / 29 (100%)`；Final Product Goal Progress 保持 `9 / 9 (100%)`；Engine Maturity Roadmap Progress 保持 `4 / 4 (100%)`。
- 当前成熟度结论更新为 `TargetGraph Anchor Retirement / Real Module Source Root Migration before L4 complete`。

边界：

- 不创建下一 Linear Project / Issue。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify 或 code-index。
- 不修改 Figma。
- 不实现 Strategy runtime、Trader runtime 或 Live runtime。
- 不实现 ExecutionClient implementation、OMS implementation 或 broker gateway。
- 不接 signed endpoint、account endpoint / listenKey 或 private WebSocket runtime。
- 不实现 real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- 不授权 L4 capability。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass，无输出。
- `bash checks/automation-readiness.sh`：pass，输出 `MTPRO automation readiness checks passed.`。
- `bash checks/run.sh`：pass，通过 automation readiness、Dashboard build、Dashboard smoke 和完整 XCTest；Dashboard smoke 正常，331 个 XCTest / 0 failures，最终输出 `MTPRO checks passed.`。

## 2026-06-05 — AppCompatibility compatibility export cleanup

执行者：Codex

范围：

- 删除 `App` SwiftPM product / target。
- 删除 `Sources/AppCompatibility/AppCompatibility.swift`，并移除空的 `Sources/AppCompatibility` 目录。
- `Tests/AppTests/AppTests.swift` 从 `import App` 改为直接 `import Dashboard`。
- `WorkbenchTargetBoundary` 的 compatibility envelope 从 `App` 更新为 `retired`。
- 更新 root docs / architecture docs / validation docs / automation readiness anchors，明确 `App` product / target、`Sources/AppCompatibility`、`Workbench` product / target 和 `Sources/Workbench/` 已退休，当前 UI dependency direction 只保留 `Dashboard -> Core / Persistence read-model exports only`。
- 更新 `checks/automation-readiness.sh`，机械验证 `App` product / target、`Sources/AppCompatibility` 和 `import App` 不再回流。

边界：

- 不实现 Strategy runtime、Trader runtime 或 Live runtime。
- 不实现 ExecutionClient implementation、OMS implementation 或 broker gateway。
- 不接 signed endpoint、account endpoint / listenKey 或 private WebSocket runtime。
- 不实现 real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- 不推进 L4。
- 不启动 Symphony，不运行 Graphify / code-index，不修改 Figma。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass，无输出。
- `bash checks/automation-readiness.sh`：pass，输出 `MTPRO automation readiness checks passed.`。
- `bash checks/run.sh`：pass，通过 automation readiness、Dashboard build、Dashboard smoke 和完整 XCTest；Dashboard smoke 正常，331 个 XCTest / 0 failures，最终输出 `MTPRO checks passed.`。

## 2026-06-05 — MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1 docs-only planning record

执行者：Codex

范围：

- 将 Human 确认的 `MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1` planning draft 落仓为 docs-only Project Planning Record。
- 新增 `docs/planning/projects/mtpro-architecture-graph-completion-review-l4-readiness-planning-v1-plan.md`。
- 更新 `docs/planning/linear-draft-plan.md`，新增当前 docs-only / non-executable planning record 入口，并把 `MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration v1` 改为 completed historical planning evidence。
- 更新 `docs/validation/latest-verification-summary.md`，记录该 Project-level planning record 已落仓，且这不是 Project closure，不更新 `Project Closure Count`、`Final Product Goal Progress` 或旧 `Engine Maturity Roadmap Progress`。
- 更新 `BLUEPRINT.md`，只增加 planning record 引用，不复制完整 issue body，不更新进度条，不授权 execution。

边界：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify / code-index。
- 不修改 Figma。
- 不写业务代码。
- 不修改 `Package.swift`。
- 不移动 `Sources`。
- 不拆 SwiftPM target graph。
- 不执行 `TargetGraph` 命名清理。
- 不实现 Trader runtime、Strategy runtime、Live runtime、`ExecutionClient` implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- 不推进 L4。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass，无输出。
- `bash checks/run.sh`：pass，通过 automation readiness、Dashboard build、Dashboard smoke 和完整 XCTest；Dashboard smoke 正常，331 个 XCTest / 0 failures，最终输出 `MTPRO checks passed.`。

## 2026-06-05 — GH-376 Architecture completion review baseline

执行者：Codex

GitHub Issue：[#376](https://github.com/atxinbao/MTPRO/issues/376)

范围：

- 创建 GitHub fallback queue milestone：`MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1`。
- 创建 GitHub canonical issues #376 至 #382，全部初始为 `backlog` / `non-executable`。
- 通过 queue preview 后，仅将 #376 标记为唯一 active issue。
- 新增 `docs/audit/inputs/mtpro-architecture-graph-completion-review-l4-readiness-v1-gh-376-baseline.md`，记录 architecture completion review baseline 和 evidence inventory。

边界：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 GitHub #377 至 #382。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify / code-index。
- 不修改 Figma。
- 不写业务代码。
- 不修改 `Package.swift`。
- 不移动 `Sources`。
- 不拆 SwiftPM target graph。
- 不实现 Trader runtime、Strategy runtime、Live runtime、`ExecutionClient` implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- 不推进 L4。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass。
- `bash checks/run.sh`：pass；Dashboard smoke 保持 read-model-only evidence surface，`331` 个 XCTest / `0` failures，最终 `MTPRO checks passed.`。

## 2026-06-05 — GH-377 Real module roots versus compatibility envelopes audit

执行者：Codex

GitHub Issue：[#377](https://github.com/atxinbao/MTPRO/issues/377)

范围：

- 新增 `docs/audit/inputs/mtpro-architecture-graph-completion-review-l4-readiness-v1-gh-377-compatibility-envelope-audit.md`。
- 审计 architecture graph targets、real module source roots、module-local `TargetGraph` boundary anchors、future gates 和 retained compatibility envelopes。
- 明确 `Core`、`Adapters`、`Persistence`、`Runtime` 仍是 compatibility envelope，不等同于最终 architecture module ownership 完成。

边界：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 GitHub #378 至 #382。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify / code-index。
- 不修改 Figma。
- 不写业务代码。
- 不修改 `Package.swift`。
- 不移动 `Sources`。
- 不拆 SwiftPM target graph。
- 不实现 Trader runtime、Strategy runtime、Live runtime、`ExecutionClient` implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- 不推进 L4。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass。
- `bash checks/run.sh`：pass；Dashboard smoke 保持 read-model-only evidence surface，`331` 个 XCTest / `0` failures，最终 `MTPRO checks passed.`。

## 2026-06-05 — GH-378 Data / foundation graph alignment review

执行者：Codex

GitHub Issue：[#378](https://github.com/atxinbao/MTPRO/issues/378)

范围：

- 新增 `docs/audit/inputs/mtpro-architecture-graph-completion-review-l4-readiness-v1-gh-378-data-foundation-graph-review.md`。
- 复核 `DataClient`、`DataEngine`、`MessageBus`、`Cache`、`Database` 的 architecture graph alignment。
- 记录 public read-only data path、read-model state surface、durable facts / projection boundary 和 remaining compatibility envelope debt。

边界：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 GitHub #379 至 #382。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify / code-index。
- 不修改 Figma。
- 不写业务代码。
- 不修改 `Package.swift`。
- 不移动 `Sources`。
- 不拆 SwiftPM target graph。
- 不实现 endpoint、Trader runtime、Strategy runtime、Live runtime、`ExecutionClient` implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- 不推进 L4。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass。
- `bash checks/run.sh`：pass；Dashboard smoke 保持 read-model-only evidence surface，`331` 个 XCTest / `0` failures，最终 `MTPRO checks passed.`。

## 2026-06-05 — GH-379 Trader / execution future gate review

执行者：Codex

GitHub Issue：[#379](https://github.com/atxinbao/MTPRO/issues/379)

范围：

- 新增 `docs/audit/inputs/mtpro-architecture-graph-completion-review-l4-readiness-v1-gh-379-trader-execution-future-gates-review.md`。
- 复核 `Trader = Accounts + Strategies/EMA + Coordination`。
- 复核 `Portfolio`、`RiskEngine`、`ExecutionEngine` 和 `ExecutionClient` future gate / no-direct-execution 边界。
- 明确 `ExecutionClient` 是 future-gated outgoing adapter contract，不是 broker implementation。

边界：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 GitHub #380 至 #382。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify / code-index。
- 不修改 Figma。
- 不写业务代码。
- 不修改 `Package.swift`。
- 不移动 `Sources`。
- 不拆 SwiftPM target graph。
- 不实现 Trader runtime、Strategy runtime、Live runtime、`ExecutionClient` implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- 不推进 L4。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

验证：

- `git diff --check`：pass。
- `bash checks/run.sh`：pass；Dashboard smoke 保持 read-model-only evidence surface，`331` 个 XCTest / `0` failures，最终 `MTPRO checks passed.`。
## 2026-06-05 - GH-380 Dashboard Retired Paths Review

- Project: `MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1`
- Queue item: GH-380 `Review Dashboard read-model-only boundary and retired Workbench / AppCompatibility paths`
- Scope: docs-only review input for the active `Dashboard read-model-only boundary` and retired `Workbench` / `AppCompatibility` active source paths.
- Evidence: `docs/audit/inputs/mtpro-architecture-graph-completion-review-l4-readiness-v1-gh-380-dashboard-retired-paths-review.md`
- Boundary:
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No Package.swift change, no source movement, no SwiftPM target graph split.
- Validation:
  - `git diff --check`: pass
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true` and legacy smoke key `workbenchReadModelOnly=true`; 331 XCTest / 0 failures; final output `MTPRO checks passed.`
## 2026-06-05 - GH-381 L4 Readiness Gate

- Project: `MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1`
- Queue item: GH-381 `Define L4 readiness gate, blockers and allowed planning scope`
- Scope: docs-only L4 readiness gate, blocker and allowed planning scope based on GH-376 through GH-380 evidence.
- Evidence: `docs/audit/inputs/mtpro-architecture-graph-completion-review-l4-readiness-v1-gh-381-l4-readiness-gate.md`
- Boundary:
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No Package.swift change, no source movement, no SwiftPM target graph split.
- Validation:
  - `git diff --check`: pass
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true`; 331 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-05 - Architecture Graph Completion Review / L4 Readiness Planning Closure

- Project: `MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1`
- Queue backend: GitHub fallback milestone / issues because Linear connector was unavailable.
- Scope: final Project closure Stage Code Audit and root docs refresh for GH-376 through GH-382.
- Evidence: `docs/audit/mtpro-architecture-graph-completion-review-l4-readiness-planning-v1-stage-code-audit.md`
- Boundary:
  - No next Project / Issue created or promoted.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No Package.swift change, no source movement, no SwiftPM target graph split.
- Validation:
  - `git diff --check`: pass
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true`; 331 XCTest / 0 failures; final output `MTPRO checks passed.`
## 2026-06-05 - GH-382 Validation Matrix / Planning Evidence / L4 Readiness Handoff

- Project: `MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1`
- Queue item: GH-382 `Close validation matrix / planning evidence / L4 readiness handoff`
- Scope: docs-only issue-level handoff input summarizing GH-376 through GH-381 evidence and L4 planning-only gate.
- Evidence: `docs/audit/inputs/mtpro-architecture-graph-completion-review-l4-readiness-v1-gh-382-validation-handoff.md`
- Boundary:
  - No final Stage Code Audit Report in this issue.
  - No next Project / Issue created or promoted.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No Package.swift change, no source movement, no SwiftPM target graph split.
- Validation:
  - `git diff --check`: pass
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true`; 331 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-05 - GH-391 Real Target Source Ownership / Core Envelope Retirement Contract

- Project: `MTPRO Real Target Source Ownership Validation / Core Envelope Retirement v1`
- Queue item: GH-391 `Define real target ownership and dependency direction contract`
- Scope: contract-first definition of real target source ownership, retained `Core` / `Adapters` / `Persistence` / `Runtime` compatibility envelopes, future real target smoke-test expectations, and `Trader -> ExecutionEngine` dependency correction blocker.
- Evidence: `docs/contracts/real-target-source-ownership-core-envelope-retirement-contract.md`
- Boundary:
  - No Package.swift change.
  - No source movement.
  - No SwiftPM target graph split.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No Symphony / Graphify / code-index / Figma.
- Validation:
  - `git diff --check`: pass
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true`; 331 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - GH-392 Trader / ExecutionEngine dependency correction

- Project: `MTPRO Real Target Source Ownership Validation / Core Envelope Retirement v1`
- Queue item: GH-392 `Remove direct Trader to ExecutionEngine target dependency`
- Scope:
  - Removed direct `Trader -> ExecutionEngine` target dependency from `Package.swift`.
  - Removed `import ExecutionEngine` and `executionEngineBoundary` from `Sources/Trader/TargetGraph/TraderTargetBoundary.swift`.
  - Added tests and automation anchors proving Trader no longer directly depends on ExecutionEngine.
  - Updated architecture / target graph contract wording so historical MTP-220 dependency remains before-state evidence only.
- Boundary:
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
  - No Symphony / Graphify / code-index / Figma.
- Validation:
  - `swift test --filter TargetGraphTests`: pass; 17 tests / 0 failures.
  - `git diff --check`: pass
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true`; 332 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - GH-393 Foundation real target smoke tests

- Project: `MTPRO Real Target Source Ownership Validation / Core Envelope Retirement v1`
- Queue item: GH-393 `Add real target smoke tests for foundation targets`
- Scope:
  - Added `Sources/DomainModel/FoundationTargetOwnership.swift`.
  - Added `Sources/MessageBus/FoundationMessageStream.swift`.
  - Added `Sources/Database/FoundationDatabaseCheckpoint.swift`.
  - Updated `Package.swift` so `DomainModel`, `MessageBus` and `Database` compile those real smoke APIs while compatibility envelopes exclude the new files.
  - Added `testGH393FoundationTargetsExposeRealAPIsBeyondBoundaryAnchors`.
- Boundary:
  - No full DomainModel / MessageBus / Database implementation migration.
  - Retained `Core` / `Persistence` / `Runtime` compatibility envelopes.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
  - No Symphony / Graphify / code-index / Figma.
- Validation:
  - `swift test --filter TargetGraphTests/testGH393FoundationTargetsExposeRealAPIsBeyondBoundaryAnchors`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests`: pass; 18 tests / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true`; 333 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - GH-394 DomainModel / MessageBus implementation ownership

- Project: `MTPRO Real Target Source Ownership Validation / Core Envelope Retirement v1`
- Queue item: GH-394 `Migrate DomainModel and MessageBus implementation ownership out of Core`
- Scope:
  - Moved `DomainModel` foundational implementation ownership into the `DomainModel` target: `CoreBaseline.swift`, `MarketPrimitives.swift`, `MarketDataModels.swift`, `DomainModelContractError.swift` and `FoundationTargetOwnership.swift`.
  - Moved neutral append-only journal ownership into the `MessageBus` target through `MessageBusAppendOnlyJournal.swift`.
  - Preserved `Core` as a compatibility envelope through `DomainModelCompatibilityImport.swift`; old `import Core` callers keep access to `DomainModel` public values, but `Core` is no longer the primary owner for `Sources/DomainModel`, and foundation value object validation errors are owned by `DomainModelContractError`.
  - Left rich MessageBus paper / downstream routing payload in the `Core` compatibility envelope for later issue-level migration.
  - Added `testGH394DomainModelAndMessageBusOwnRealImplementationSource`.
- Boundary:
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real account read / real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
  - No Symphony / Graphify / code-index / Figma.
- Validation:
  - `swift build --target DomainModel`: pass.
  - `swift build --target MessageBus`: pass.
  - `swift build --target Core`: pass.
  - `swift test --filter TargetGraphTests/testGH394DomainModelAndMessageBusOwnRealImplementationSource`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests`: pass; 19 tests / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true`; 334 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - GH-395 Data target real smoke tests

- Project: `MTPRO Real Target Source Ownership Validation / Core Envelope Retirement v1`
- Queue item: GH-395 `Add real target smoke tests for data targets`
- Scope:
  - Added `Sources/DataClient/DataClientReadOnlyMarketDataSource.swift`.
  - Added `Sources/Cache/CacheReadModelSnapshot.swift`.
  - Added `Sources/DataEngine/DataEngineReadOnlyReplayPlan.swift`.
  - Updated `Package.swift` so `DataClient`, `Cache` and `DataEngine` compile those real smoke APIs while `Core`, `Adapters` and `Runtime` compatibility envelopes exclude the new files.
  - Added `testGH395DataTargetsExposeRealAPIsBeyondBoundaryAnchors`.
- Boundary:
  - No full DataClient adapter / DataEngine ingest-replay-quality / Cache market-data implementation migration.
  - Retained `Adapters` / `Core` / `Runtime` compatibility envelopes.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real account read / real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
  - No Symphony / Graphify / code-index / Figma.
- Validation:
  - `swift build --target DataClient`: pass.
  - `swift build --target Cache`: pass.
  - `swift build --target DataEngine`: pass.
  - `swift test --filter TargetGraphTests/testGH395DataTargetsExposeRealAPIsBeyondBoundaryAnchors`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests`: pass; 20 tests / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true`; 335 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - GH-396 Data target implementation ownership

- Project: `MTPRO Real Target Source Ownership Validation / Core Envelope Retirement v1`
- Queue item: GH-396 `Migrate DataClient / DataEngine / Cache implementation ownership out of Core / Adapters / Runtime`
- Scope:
  - Moved Binance public read-only implementation ownership into `DataClient` target via `Sources/DataClient/Binance/PublicMarketData/`.
  - Reduced `Adapters` to a `DataClient` compatibility re-export through `Sources/DataClient/AdaptersCompatibility.swift`.
  - Moved market-data cache and order-book read-model ownership into `Cache` target via `Sources/Cache/MarketData/`.
  - Added `Sources/Cache/MarketData/CacheContractError.swift` so Cache no longer depends on `CoreError`.
  - Added `Sources/Core/MarketDataCacheCoreReplayCompatibility.swift` to keep legacy `EventEnvelope` replay helper in the `Core` compatibility envelope.
  - Updated target boundary anchors and TargetGraph tests for DataClient / Cache ownership and explicit DataEngine retained envelope.
- Boundary:
  - DataEngine `ScenarioReplay` and `DataQuality` remain in `Core` compatibility envelope.
  - DataEngine `Ingest` remains in `Runtime` compatibility envelope.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real account read / real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
  - No Symphony / Graphify / code-index / Figma.
- Validation:
  - `swift build --target DataClient`: pass.
  - `swift build --target Cache`: pass.
  - `swift build --target DataEngine`: pass.
  - `swift build --target Core`: pass.
  - `swift test --filter TargetGraphTests/testGH396DataClientAndCacheOwnImplementationSourceWhileDataEngineEnvelopeIsExplicit`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests`: pass; 21 tests / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true`; 336 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - GH-397 Trader / Portfolio / Risk / Execution real target smoke tests

- Project: `MTPRO Real Target Source Ownership Validation / Core Envelope Retirement v1`
- Queue item: GH-397 `Add real target smoke tests for Trader / Portfolio / Risk / Execution boundaries`
- Scope:
  - Added GH-397 validation anchors to `TraderStrategies`, `Trader`, `Portfolio`, `RiskEngine`, `ExecutionClient` and `ExecutionEngine` target boundary files.
  - Added `testGH397TraderPortfolioRiskExecutionTargetsExposeUsableBoundaryAPIs`.
  - Updated architecture / contract / automation readiness docs for the Trader / Portfolio / Risk / Execution real target smoke baseline.
- Boundary:
  - No Trader / Portfolio / Risk / Execution implementation ownership migration.
  - Retained `Core` compatibility envelope.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real account read / real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
  - No Symphony / Graphify / code-index / Figma.
- Validation:
  - `swift test --filter TargetGraphTests/testGH397TraderPortfolioRiskExecutionTargetsExposeUsableBoundaryAPIs`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests`: pass; 22 tests / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true`; 337 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - GH-398 Trader / Portfolio / Risk / Execution implementation ownership

- Project: `MTPRO Real Target Source Ownership Validation / Core Envelope Retirement v1`
- Queue item: GH-398 `Migrate Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient implementation ownership`
- Scope:
  - Migrated partial Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient implementation ownership.
  - Moved strategy signal / paper action proposal shared contracts to `MessageBus`.
  - Preserved `Trader = Accounts + Strategies/EMA + Coordination`.
  - Preserved `ExecutionClient` as future gate / protocol boundary only.
- Boundary:
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No L4 implementation.

## 2026-06-06 - GH-399 Dashboard read-model-only naming cleanup

- Project: `MTPRO Real Target Source Ownership Validation / Core Envelope Retirement v1`
- Queue item: GH-399 `Clean Dashboard Workbench naming residue`
- Scope:
  - Retired active Workbench naming residue from Dashboard source.
  - Standardized active UI surface as `Dashboard read-model-only boundary`.
  - Preserved retired Workbench / AppCompatibility as historical wording only.
- Boundary:
  - No Workbench / AppCompatibility active module restoration.
  - No Live PRO Console / trading button / live command / order form.
  - No Runtime object / Adapter request / schema / account payload / broker payload read.

## 2026-06-06 - GH-400 unsafe construct allowed-path validation

- Project: `MTPRO Real Target Source Ownership Validation / Core Envelope Retirement v1`
- Queue item: GH-400 `Add try! and preconditionFailure allowed-path validation`
- Scope:
  - Added TargetGraphTests allowed-path validation for `try!` and `preconditionFailure`.
  - Allowed deterministic fixture / evidence / future-gate / read-model-only / paper-simulated boundary use only.
- Boundary:
  - No production behavior change.
  - No expansion of unsafe constructs into runtime-facing path.
  - No L4 implementation.

## 2026-06-06 - GH-401 Core envelope retirement matrix / stage audit input

- Project: `MTPRO Real Target Source Ownership Validation / Core Envelope Retirement v1`
- Queue item: GH-401 `Close Core envelope retirement matrix / stage audit input`
- Scope:
  - Added `docs/audit/inputs/mtpro-real-target-source-ownership-core-envelope-retirement-v1-stage-audit-input.md`.
  - Added `GH-401-CORE-ENVELOPE-RETIREMENT-MATRIX`.
  - Added retained compatibility envelope and L4 blocker summary.
  - Updated `docs/contracts/real-target-source-ownership-core-envelope-retirement-contract.md`, `docs/automation/automation-readiness.md`, `docs/validation/latest-verification-summary.md`, `verification.md` and `checks/automation-readiness.sh`.
- Boundary:
  - Stage audit input only; no final Stage Code Audit Report.
  - No next Project / Issue creation.
  - No L4 implementation.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Symphony / Graphify / code-index / Figma.
- Validation:
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true`; 339 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - MTPRO Real Target Source Ownership Validation / Core Envelope Retirement v1 Project closure

- Project: `MTPRO Real Target Source Ownership Validation / Core Envelope Retirement v1`
- Queue: GitHub fallback milestone #2, GH-391 through GH-401.
- Scope:
  - Completed final Project closure Stage Code Audit and root docs refresh for GH-391 through GH-401.
  - Added canonical Stage Code Audit Report at `docs/audit/mtpro-real-target-source-ownership-core-envelope-retirement-v1-stage-code-audit.md`.
  - Synced root docs to current maturity statement `Real Target Source Ownership / Core Envelope Retirement before L4 complete`.
  - Updated Project Closure Count to `31 / 31 (100%)` while keeping Final Product Goal Progress `9 / 9 (100%)` and Engine Maturity Roadmap Progress `4 / 4 (100%)`.
  - Recorded PR #402 through PR #412 evidence, real target ownership validation, direct Trader -> ExecutionEngine dependency removal, real target smoke tests, ownership migration, Dashboard naming cleanup, unsafe construct allowed-path validation and Core envelope retirement matrix.
- Evidence:
  - GitHub Issues GH-391 through GH-401 are closed / done.
  - PR #402 through PR #412 were merged with required check `checks` SUCCESS.
  - Stage Code Audit Report: `docs/audit/mtpro-real-target-source-ownership-core-envelope-retirement-v1-stage-code-audit.md`.
  - `Core`, `Adapters`, `Persistence` and `Runtime` remain retained compatibility envelopes and are explicitly tracked.
- Boundary:
  - No next Project / Issue creation.
  - No Todo promotion.
  - No Symphony / symphony-issue.
  - No Graphify / code-index.
  - No Figma change.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
- Validation:
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke normal; 339 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - GH-413 Core envelope retirement contract

- Project: `MTPRO Core Envelope Retirement / Real Module Ownership Completion v1`
- Queue item: GH-413 `Define Core envelope retirement contract and real ownership acceptance criteria`
- Scope:
  - Added the second-round Core envelope retirement / real module ownership completion contract.
  - Defined real module ownership acceptance criteria for `MessageBus`, `DataEngine`, `Database`, `Portfolio`, `RiskEngine`, `ExecutionEngine`, `ExecutionClient`, `Trader`, `Dashboard`, and retained compatibility envelopes.
  - Distinguished real module source roots, module-local `TargetGraph` boundary anchors, retained compatibility envelopes, and future gates.
  - Added GH-413 readiness anchors to `architecture.md`, `docs/automation/automation-readiness.md`, `docs/validation/latest-verification-summary.md`, `verification.md`, and `checks/automation-readiness.sh`.
- Boundary:
  - No `Package.swift` change.
  - No `Sources` move.
  - No production behavior change.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
  - No Symphony / Graphify / code-index / Figma.
- Validation:
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 339 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - GH-414 MessageBus neutral query / replay ownership

- Project: `MTPRO Core Envelope Retirement / Real Module Ownership Completion v1`
- Queue item: GH-414 `Move remaining MessageBus implementation ownership out of Core`
- Scope:
  - Moved neutral `MarketDataQuery` ownership into the `MessageBus` target.
  - Added `EventReplayContract.swift` so `EventStreamID`, `EventSequenceRange` and `EventReplayCommand` are directly owned by `MessageBus`.
  - Updated `Package.swift` so `MessageBus` compiles `MarketDataQuery.swift` and `EventReplayContract.swift`, while `Core` excludes those neutral files.
  - Added `testGH414MessageBusOwnsNeutralQueryAndReplayContracts`.
  - Documented that rich MessageBus paper / runtime / downstream payload remains an explicit `Core` compatibility envelope debt.
- Boundary:
  - No reverse `MessageBus` dependency on DataEngine / Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient / Dashboard.
  - No migration of rich paper runtime routing payload into `MessageBus`.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
  - No Symphony / Graphify / code-index / Figma.
- Validation:
  - `swift build --target MessageBus`: pass.
  - `swift test --filter TargetGraphTests/testGH414MessageBusOwnsNeutralQueryAndReplayContracts`: pass; 1 test / 0 failures.
  - `swift build --target Core`: pass.
  - `swift test --filter TargetGraphTests`: pass; 25 tests / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 340 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - GH-415 DataEngine ScenarioReplay / DataQuality ownership

- Project: `MTPRO Core Envelope Retirement / Real Module Ownership Completion v1`
- Queue item: GH-415 `Move DataEngine ScenarioReplay / DataQuality ownership out of Core`
- Scope:
  - Moved primary `ScenarioReplay` ownership into the `DataEngine` target: `DataCatalogScenarioReplayBoundary.swift`, `ScenarioFixture.swift`, `ScenarioManifest.swift` and `ScenarioReplayEvidence.swift`.
  - Moved `DataQuality` ownership into the `DataEngine` target through `ScenarioDataQualityReportInput.swift`.
  - Kept `ScenarioReplayDeterministicMatching.swift` in the `Core` compatibility envelope because it still couples simulated exchange / shared order semantics.
  - Kept `DataEngine/Ingest` in the `Runtime` compatibility envelope because it still coordinates DataClient / Persistence workflow.
  - Updated `DataEngineTargetBoundary`, TargetGraph tests, architecture / contract / automation anchors and readiness guards.
- Boundary:
  - No streaming DataEngine runtime.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real account read / real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
  - No Symphony / Graphify / code-index / Figma.
- Validation:
- `swift build --target DataEngine`: pass.
- `swift build --target Core`: pass.
- `swift test --filter TargetGraphTests/testGH396DataClientAndCacheOwnImplementationSourceWhileDataEngineEnvelopeIsExplicit`: pass; 1 test / 0 failures.
- `swift test --filter TargetGraphTests`: pass; 25 tests / 0 failures.
- `git diff --check`: pass.
- `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
- `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 340 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - GH-417 RiskEngine paper pre-trade ownership

- Project: `MTPRO Core Envelope Retirement / Real Module Ownership Completion v1`
- Queue item: GH-417 `Move RiskEngine paper pre-trade ownership out of Core`
- Scope:
  - Moved pure `PaperPreTradeRiskEngine` decision ownership into the real `RiskEngine` target.
  - Kept MessageBus / EventLog publish and replay support in `Sources/Core/RiskEnginePaperPreTradeRuntimeBridge.swift` as an explicit Core compatibility bridge.
  - Updated `RiskEngineTargetBoundary`, TargetGraph tests, architecture / contract / automation anchors and readiness guards.
- Boundary:
  - No live risk runtime.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
  - No Symphony / Graphify / code-index / Figma.
- Validation:
- `swift build --target RiskEngine`: pass.
- `swift build --target Core`: pass.
- `swift test --filter TargetGraphTests/testGH398TraderPortfolioRiskExecutionTargetsOwnRealSourceWithoutRuntimeDrift`: pass; 1 test / 0 failures.
- `swift test --filter TargetGraphTests`: pass; 25 tests / 0 failures.
- `git diff --check`: pass.
- `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
- `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 340 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - GH-416 Portfolio paper projection update ownership

- Project: `MTPRO Core Envelope Retirement / Real Module Ownership Completion v1`
- Queue item: GH-416 `Move Portfolio paper projection and parity ownership out of Core`
- Scope:
  - Moved eligible `PaperPortfolioProjectionUpdate.swift` ownership into the real `Portfolio` target.
  - Added `Sources/Core/PortfolioProjectionCompatibility.swift` as the only Core compatibility bridge for `portfolioEvent` and the simulated-fill convenience initializer.
  - Kept `PaperAccountPortfolioProjectionV2.swift` and `SimulatedExchangePortfolioProjectionParity.swift` in the Core compatibility envelope because they still couple replay / simulated exchange / event evidence.
  - Updated `PortfolioTargetBoundary`, TargetGraph tests, architecture / contract / automation anchors and readiness guards.
- Boundary:
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real account read / real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
  - No Symphony / Graphify / code-index / Figma.
- Validation:
- `swift build --target Portfolio`: pass.
- `swift build --target Core`: pass.
- `swift test --filter TargetGraphTests/testGH398TraderPortfolioRiskExecutionTargetsOwnRealSourceWithoutRuntimeDrift`: pass; 1 test / 0 failures.
- `swift test --filter TargetGraphTests`: pass; 25 tests / 0 failures.
- `git diff --check`: pass.
- `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
- `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 340 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - GH-418 ExecutionEngine paper / simulated boundary ownership

- Project: `MTPRO Core Envelope Retirement / Real Module Ownership Completion v1`
- Queue item: GH-418 `Move ExecutionEngine paper lifecycle / simulated exchange ownership out of Core`
- Scope:
  - Moved eligible paper / simulated execution boundary ownership into the real `ExecutionEngine` target.
  - `ExecutionEngine` now directly compiles `PaperExecutionWorkflowContract.swift`, `PaperRuntimeKernelBoundary.swift`, `PaperSessionLocalControlCommand.swift` and `SimulatedExchangeBacktestParityBoundary.swift`.
  - Kept `PaperOrderIntent`, paper execution decision / event log, session lifecycle / replay, shared order semantics, simulated fill evidence and fee / slippage parity bridge in the `Core` compatibility envelope because those files still couple Trader / RiskBinding, MessageBus / EventLog, ScenarioReplay or compatibility export surfaces.
  - Updated `ExecutionEngineTargetBoundary`, TargetGraph tests, architecture / contract / automation anchors and readiness guards.
- Boundary:
  - No live execution runtime.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
  - No Symphony / Graphify / code-index / Figma.
- Validation:
  - `swift build --target ExecutionEngine`: pass.
  - `swift build --target Core`: pass.
  - `swift test --filter TargetGraphTests/testGH398TraderPortfolioRiskExecutionTargetsOwnRealSourceWithoutRuntimeDrift`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests`: pass; 25 tests / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 340 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - GH-419 Database / Persistence / Runtime ownership matrix

- Project: `MTPRO Core Envelope Retirement / Real Module Ownership Completion v1`
- Queue item: GH-419 `Clean Database / Persistence / Runtime ownership boundary`
- Scope:
  - Added `Sources/Database/DatabaseRuntimeOwnershipMatrix.swift` and compiled it from the real `Database` target.
  - Defined the current ownership matrix: `Database` owns durable boundary vocabulary / ownership evidence, `Persistence` remains the SQLite / DuckDB projection adapter compatibility envelope, and `Runtime` remains the replay projection / ingest workflow composition envelope.
  - Kept `Sources/Database/Projections/SQLite/Persistence.swift` and `Sources/Database/Projections/DuckDB/DuckDBAnalyticalProjectionAdapter.swift` in `Persistence` because they still consume `Core` rich event / paper / risk / portfolio payloads.
  - Kept `Sources/Database/ReplayProjection/` and `Sources/DataEngine/Ingest/` in `Runtime` because they still coordinate compatibility-envelope workflow.
  - Updated `DatabaseTargetBoundary`, TargetGraph tests, architecture / contract / automation anchors and readiness guards.
- Boundary:
  - No SQLite / DuckDB schema exposure to Dashboard.
  - No Runtime object / Adapter request / account payload / broker payload / broker state exposure.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
  - No Symphony / Graphify / code-index / Figma.
- Validation:
  - `swift build --target Database`: pass.
  - `swift test --filter TargetGraphTests/testGH419DatabasePersistenceRuntimeOwnershipMatrixIsExplicit`: pass; 1 test / 0 failures.
  - `swift build --target Persistence`: pass.
  - `swift build --target Runtime`: pass.
  - `swift test --filter TargetGraphTests`: pass; 26 tests / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 341 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - GH-420 Dashboard active source naming cleanup

- Project: `MTPRO Core Envelope Retirement / Real Module Ownership Completion v1`
- Queue item: GH-420 `Clean Dashboard read-model-only imports and Workbench naming residue`
- Scope:
  - Standardized active `Sources/Dashboard/` source wording to `Dashboard read-model-only boundary`.
  - Added `LiveReadOnlyDashboardReadModelBoundary` and `dashboardReadModelOnlyBoundaryHeld` as the Dashboard-facing alias over the historical MTP-131 Core contract.
  - Updated `LiveReadOnlyDashboardBoundaryReadModel` to consume `Core.LiveReadOnlyDashboardReadModelBoundary`.
  - Updated current beta acceptance evidence id to `mtp-122-dashboard-beta-acceptance-path`.
  - Added `DashboardTargetBoundary.gh420` and `testGH420DashboardActiveSourceUsesDashboardReadModelOnlyNaming`.
- Boundary:
  - No Workbench / AppCompatibility active module restoration.
  - Historical Workbench contract wording remains only in Core / historical docs evidence.
  - No Runtime object access / Adapter request / Database schema exposure.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
  - No Symphony / Graphify / code-index / Figma.
- Validation:
  - `swift build --target Dashboard`: pass.
  - `swift test --filter TargetGraphTests/testGH420DashboardActiveSourceUsesDashboardReadModelOnlyNaming`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests`: pass; 27 tests / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 342 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - GH-421 all architecture targets real API smoke coverage

- Project: `MTPRO Core Envelope Retirement / Real Module Ownership Completion v1`
- Queue item: GH-421 `Add comprehensive real target smoke tests`
- Scope:
  - Added `testGH421AllArchitectureTargetsExposeIndependentRealAPISmokeCoverage`.
  - Built one deterministic architecture chain across `DomainModel`, `MessageBus`, `Database`, `DataClient`, `DataEngine`, `Cache`, `TraderStrategies`, `Trader`, `Portfolio`, `RiskEngine`, `ExecutionClient`, `ExecutionEngine` and `Dashboard`.
  - Proved the targets expose usable public APIs beyond `Package.swift` strings or `TargetGraph` boundary anchors.
  - Kept `EMA` as the only active concrete strategy.
  - Kept `ExecutionClient` as future gate / protocol boundary only and Dashboard as read-model-only boundary.
- Boundary:
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
  - No Symphony / Graphify / code-index / Figma.
- Validation:
  - `swift test --filter TargetGraphTests/testGH421AllArchitectureTargetsExposeIndependentRealAPISmokeCoverage`: pass; 1 test / 0 failures.
- `swift test --filter TargetGraphTests`: pass; 28 tests / 0 failures.
- `git diff --check`: pass.
- `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
- `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 343 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - GH-422 Core envelope retirement matrix / L4 readiness closeout

- Project: `MTPRO Core Envelope Retirement / Real Module Ownership Completion v1`
- Queue item: GH-422 `Close Core envelope retirement matrix and L4 readiness blocker review`
- Scope:
  - Added `docs/audit/inputs/mtpro-core-envelope-retirement-real-module-ownership-completion-v1-stage-audit-input.md`.
  - Summarized GH-413 through GH-422 evidence chain.
  - Listed completed ownership moves for MessageBus, DataEngine, Portfolio, RiskEngine, ExecutionEngine, Dashboard and all-target smoke coverage.
  - Listed retained compatibility envelopes: `Core`, `Adapters`, `Persistence`, `Runtime`.
  - Listed L4 readiness blockers and no runtime / live / broker guard.
- Boundary:
  - No final Stage Code Audit Report in this issue.
  - No next Project / Issue creation.
  - No L4 advancement.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No Symphony / Graphify / code-index / Figma.
- Validation:
  - `swift test --filter TargetGraphTests`: pass; 28 tests / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 343 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-06 - MTPRO Core Envelope Retirement / Real Module Ownership Completion v1 Project closure

- Project: `MTPRO Core Envelope Retirement / Real Module Ownership Completion v1`
- Closure flow:
  - Added final Stage Code Audit Report at `docs/audit/mtpro-core-envelope-retirement-real-module-ownership-completion-v1-stage-code-audit.md`.
  - Synchronized root docs to `Core Envelope Retirement / Real Module Ownership Completion before L4 complete`.
  - Updated Project Closure Count to `32 / 32 (100%)`.
  - Preserved `Final Product Goal Progress: 9 / 9 (100%)` and `Engine Maturity Roadmap Progress: 4 / 4 (100%)`.
- Evidence:
  - GitHub Issues `#413` through `#422` are closed / done.
  - PR `#424` through `#432` and PR `#438` were merged with required check `checks` success.
  - Latest issue merge commit before this closure branch: `e8c7f897f352847c27b38f73e3080aebefc2427c`.
- Boundary:
  - No next Project / Issue creation.
  - No next Todo promotion.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
- Validation:
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 343 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - Core envelope completion post-audit hardening addendum

- Project: `MTPRO Core Envelope Retirement / Real Module Ownership Completion v1`
- Scope:
  - Added post-audit hardening evidence for GH-433 through GH-437 and GH-445 to the existing Stage Code Audit chain.
  - Treated GH-433 through GH-437 and GH-445 as follow-up hardening inside the already completed Project, not as a new Project Closure Count item.
  - Updated root docs to show the hardening addendum without authorizing L4 execution.
- Evidence:
  - GH-433 PR #440 merged at `4182f932227b94e867da1bf967f0c380827abf66`: CI sqlite / Swift preflight hardening.
  - GH-434 PR #441 merged at `02db38e63cb9f875ec2391c6cdc58980d11d0d81`: deterministic value object force-try guard.
  - GH-435 PR #442 merged at `dff4f145592016c825c8f0935dbe4f365dc172bf`: Binance public transport actor isolation.
  - GH-436 PR #443 merged at `deb40b32f3971d69be0d60c8ddd9a85e9637bd55`: precise boundary guard coverage.
  - GH-437 PR #444 merged at `f8828c3d52f46f2eb3b8c843b0e01a27460bf7b7`: Swift style configuration.
  - GH-445 PR #446 merged at `d5a8bfd43d94c64ed8fbfd15bf8c6067f4c78dfa`: remaining deterministic default try-bang constructors retired into named constant / factory paths.
- Boundary:
  - No Project Closure Count increase; remains `32 / 32 (100%)`.
  - No next Project / Issue creation.
  - No next Todo promotion.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
- Validation:
  - `swift test --filter TargetGraphTests/testGH445DeterministicDefaultsUseNamedFactoriesInsteadOfTryBang`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests/testGH400TryBangAndPreconditionFailureStayInAllowedPaths`: pass; 1 test / 0 failures.
  - scoped implementation grep for `try!` in `Sources/DataEngine/ScenarioReplay`, `Sources/DataEngine/DataQuality` and `Sources/Core/DashboardBetaDemoScenario.swift`: pass; no scoped implementation `try!` violations.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 348 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - Core envelope completion final post-hardening closure audit

- Project: `MTPRO Core Envelope Retirement / Real Module Ownership Completion v1`
- Scope:
  - Closed the final residual hardening gap after PR #446 by recording PR #448 in the same post-audit evidence chain.
  - Synchronized Stage Code Audit, latest verification, root docs and automation readiness anchors to the final post-hardening state.
  - Kept the addendum inside the already completed Project; this did not create a new Project, issue, Todo or L4 authorization.
- Evidence:
  - PR #448 `[codex] Retire simulated parity try-bang defaults` merged at `2b78f27a8e2b04ba348d2fc90259c96b9a088aff`.
  - Required check `checks` succeeded: `https://github.com/atxinbao/MTPRO/actions/runs/27072028309/job/79902898510`.
  - Root main evidence after sync: `main == origin/main == 2b78f27a8e2b04ba348d2fc90259c96b9a088aff`.
  - Final hardening audit: production executable `try!` = 0; remaining `rg -n "try!" Sources` hits are comments explaining deterministic replacement paths.
  - Final hardening audit: `rg -n "@unchecked Sendable" Sources` = 0.
  - GitHub active-state audit: `gh issue list --state open` = `[]`; `gh pr list --state open` = `[]`.
- Boundary:
  - No Project Closure Count increase; remains `32 / 32 (100%)`.
  - No next Project / Issue creation.
  - No next Todo promotion.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
- Validation:
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 348 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-450 CI reproducibility hardening

- Issue: GH-450 `Harden CI Swift and sqlite reproducibility contract`
- Scope:
  - Documented the current runner-pinned Swift 6.3.x baseline in `docs/automation/ci-reproducibility.md`.
  - Kept `.github/workflows/checks.yml` on `ubuntu-24.04` and made the Swift 6.3.x policy explicit through workflow env and the `Verify runner-pinned Swift toolchain` step.
  - Kept sqlite dev headers explicit through `libsqlite3-dev`.
  - Strengthened `checks/run.sh` so local validation rejects Swift versions older than 6.3 before any SwiftPM build / run / test.
  - Kept formatter configuration out of required checks; `checks/run.sh` and `.github/workflows/checks.yml` do not invoke `swift-format` / `swiftformat`.
  - Added automation-readiness anchors for the CI runner, Swift version regex, sqlite headers, local Swift gate, formatter boundary and non-authorization boundary.
- Boundary:
  - No Linear Project / Issue creation.
  - No next Todo promotion.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No Trader runtime / Strategy runtime / Live runtime.
  - No ExecutionClient implementation / OMS / broker gateway.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No real order lifecycle / submit / cancel / replace / execution report / broker fill / reconciliation.
  - No Live PRO Console / trading button / live command / order form.
  - No L4 implementation.
- Validation:
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 348 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-452 L4 live production command contract

- Issue: GH-452 `L4: 01/21 Define L4 live production command contract and acceptance matrix`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #452 was OPEN with `mtpro / backlog / non-executable`; no open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #452 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/l4-live-production-command-contract.md`.
  - Added `Sources/ExecutionClient/FutureGate/L4LiveProductionCommandContract.swift`.
  - Added `TargetGraphTests` coverage for disabled production defaults, acceptance matrix coverage and production bypass rejection.
  - Backfilled `TVM-L4-LIVE-PRODUCTION-COMMANDS`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No secret value read or print.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No ExecutionClient adapter implementation.
  - No OMS implementation.
  - No RiskEngine live runtime.
  - No production endpoint or production trading.
  - No real submit / cancel / replace.
  - No execution report / broker fill production ingestion.
  - No reconciliation production runtime.
  - No Live PRO Console command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter TargetGraphTests/testGH452L4LiveProductionCommandContractDefinesDisabledProductionMatrix`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests/testGH452L4LiveProductionCommandContractRejectsProductionBypass`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests/testGH400TryBangAndPreconditionFailureStayInAllowedPaths`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 350 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-453 L4 credential environment gate

- Issue: GH-453 `L4: 02/21 Define credential / environment / sandbox / production gate`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #453 was OPEN with `mtpro / backlog / non-executable`; #452 was CLOSED with `done`; no open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #453 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/l4-credential-environment-gate-contract.md`.
  - Added `Sources/ExecutionClient/FutureGate/L4CredentialEnvironmentGateContract.swift`.
  - Added `TargetGraphTests` coverage for credential source identity, sandbox-only gate, production cutover blocker, local / CI validation rules and secret / production bypass rejection.
  - Backfilled `TVM-L4-CREDENTIAL-ENVIRONMENT-GATE`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No real API key / secret read, storage, print or repository commit.
  - No API-key header construction or request signature generation.
  - No signed endpoint / account endpoint / listenKey / private WebSocket runtime.
  - No sandbox or production network connection.
  - No ExecutionClient adapter implementation.
  - No OMS implementation.
  - No production endpoint or production trading.
  - No real submit / cancel / replace.
  - No execution report / broker fill production ingestion.
  - No reconciliation production runtime.
  - No Live PRO Console command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter TargetGraphTests/testGH453L4CredentialEnvironmentGateDefinesSandboxOnlyContract`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests/testGH453L4CredentialEnvironmentGateRejectsSecretAndProductionDefault`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 352 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-454 L4 signed endpoint and private stream boundary

- Issue: GH-454 `L4: 03/21 Define signed endpoint and private stream runtime boundary`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #454 was OPEN with `mtpro / backlog / non-executable`; #452 and #453 were CLOSED with `done`; no open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #454 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/l4-signed-endpoint-private-stream-boundary-contract.md`.
  - Added `Sources/ExecutionClient/FutureGate/L4SignedEndpointPrivateStreamBoundaryContract.swift`.
  - Added `TargetGraphTests` coverage for signed read-only / private stream / command runtime separation, signed request capability taxonomy, private lifecycle gates, source identities and forbidden endpoint path rejection.
  - Backfilled `TVM-L4-SIGNED-ENDPOINT-PRIVATE-STREAM-BOUNDARY`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No real API key / secret read, storage, print or repository commit.
  - No API-key header construction or request signature generation.
  - No signed endpoint / account endpoint call.
  - No listenKey create / keep-alive / close.
  - No private WebSocket open / reconnect.
  - No real account snapshot read or real private event consumption.
  - No ExecutionClient adapter implementation.
  - No OMS implementation.
  - No command runtime.
  - No production endpoint or production trading.
  - No real submit / cancel / replace.
  - No execution report / broker fill production ingestion.
  - No reconciliation production runtime.
  - No Live PRO Console command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter TargetGraphTests/testGH454L4SignedEndpointPrivateStreamBoundarySeparatesRuntimeKinds`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests/testGH454L4SignedEndpointPrivateStreamBoundaryRejectsEndpointRuntimeBypass`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 354 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-455 L4 signed account read-only runtime

- Issue: GH-455 `L4: 04/21 Implement signed account read-only runtime behind disabled production gate`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #455 was OPEN with `mtpro / backlog / non-executable`; #454 was CLOSED with `done`; no open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #455 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/l4-signed-account-read-only-runtime-contract.md`.
  - Added `Sources/ExecutionClient/FutureGate/L4SignedAccountReadOnlyRuntime.swift`.
  - Added `TargetGraphTests` coverage for the disabled default gate, deterministic sandbox fixture account evidence and forbidden production secret / raw signed payload bypass rejection.
  - Backfilled `TVM-L4-SIGNED-ACCOUNT-READ-ONLY-RUNTIME`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No real API key / secret read, storage, print or repository commit.
  - No API-key header construction or request signature generation.
  - No signed endpoint / account endpoint call.
  - No network connection.
  - No raw signed payload exposure.
  - No private WebSocket runtime.
  - No ExecutionClient adapter implementation.
  - No OMS implementation.
  - No command runtime.
  - No production endpoint or production trading.
  - No real submit / cancel / replace.
  - No execution report / broker fill production ingestion.
  - No reconciliation production runtime.
  - No Live PRO Console command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter TargetGraphTests/testGH455SignedAccountReadOnlyRuntimeDefaultsDisabledAndReturnsCanonicalEvidence`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests/testGH455SignedAccountReadOnlyRuntimeRejectsProductionSecretAndPayloadBypass`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 356 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-456 L4 private stream account snapshot read-only runtime

- Issue: GH-456 `L4: 05/21 Implement private stream / account snapshot read-only runtime`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #456 was OPEN with `mtpro / backlog / non-executable`; #455 was CLOSED with `done`; no open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #456 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/l4-private-stream-account-snapshot-read-only-runtime-contract.md`.
  - Added `Sources/ExecutionClient/FutureGate/L4PrivateStreamAccountSnapshotReadOnlyRuntime.swift`.
  - Added `TargetGraphTests` coverage for private stream source identity, freshness coverage, account snapshot read-model update, disabled default gate and listenKey / raw payload / command bypass rejection.
  - Backfilled `TVM-L4-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-READ-ONLY-RUNTIME`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No real API key / secret read, storage, print or repository commit.
  - No API-key header construction or request signature generation.
  - No signed endpoint / account endpoint call.
  - No listenKey create / keep-alive / close.
  - No private WebSocket open / reconnect.
  - No real private event consumption.
  - No raw private payload, account endpoint payload, broker payload, broker state or Dashboard raw payload exposure.
  - No ExecutionClient adapter implementation.
  - No OMS implementation.
  - No command runtime.
  - No production endpoint or production trading.
  - No real submit / cancel / replace.
  - No execution report / broker fill production ingestion.
  - No reconciliation production runtime.
  - No Live PRO Console command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter TargetGraphTests/testGH456PrivateStreamAccountSnapshotReadOnlyRuntimeProducesFreshnessEvidence`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests/testGH456PrivateStreamAccountSnapshotReadOnlyRuntimeRejectsListenKeyPayloadAndCommandBypass`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 358 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-457 L4 live account read-model mapping

- Issue: GH-457 `L4: 06/21 Add live account / position / balance / margin read-model mapping`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #457 was OPEN with `mtpro / backlog / non-executable`; #455 and #456 were CLOSED with `done`; no open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #457 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/l4-live-account-read-model-mapping-contract.md`.
  - Added `Sources/ExecutionClient/FutureGate/L4LiveAccountReadModelMapping.swift`.
  - Added `TargetGraphTests` coverage for account / position / balance / margin read-model mapping, source / freshness / evidence identity preservation, fixture / sandbox vs future real account interpretation separation and forbidden raw payload / broker / runtime / schema bypass rejection.
  - Backfilled `TVM-L4-LIVE-ACCOUNT-READ-MODEL-MAPPING`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No real API key / secret read, storage, print or repository commit.
  - No API-key header construction or request signature generation.
  - No signed endpoint / account endpoint call.
  - No listenKey create / keep-alive / close.
  - No private WebSocket open / reconnect.
  - No Runtime object, Adapter request or schema exposure.
  - No raw account payload, raw private payload, account endpoint payload, broker payload, broker state or Dashboard raw payload exposure.
  - No real PnL runtime, margin / leverage runtime or real account read.
  - No ExecutionClient adapter implementation.
  - No OMS implementation.
  - No command runtime.
  - No production endpoint or production trading.
  - No real submit / cancel / replace.
  - No execution report / broker fill production ingestion.
  - No reconciliation production runtime.
  - No Live PRO Console command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter TargetGraphTests/testGH457LiveAccountReadModelMappingMapsAPBMarginEvidenceReadOnly`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests/testGH457LiveAccountReadModelMappingRejectsRawPayloadBrokerStateAndRuntimeBypass`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 360 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-458 L4 ExecutionClient venue adapter contract

- Issue: GH-458 `L4: 07/21 Define ExecutionClient venue adapter contract`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #458 was OPEN with `mtpro / backlog / non-executable`; #452 and #457 were CLOSED with `done`; no open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #458 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/l4-executionclient-venue-adapter-contract.md`.
  - Added `Sources/ExecutionClient/FutureGate/L4ExecutionClientVenueAdapterContract.swift`.
  - Added `TargetGraphTests` coverage for ExecutionClient external venue adapter contract, ExecutionEngine internal lifecycle coordinator boundary, sandbox / production venue gate split and no direct Trader / Strategy to ExecutionClient rule.
  - Backfilled `TVM-L4-EXECUTIONCLIENT-VENUE-ADAPTER-CONTRACT`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No real API key / secret read, storage, print or repository commit.
  - No API-key header construction or request signature generation.
  - No signed endpoint / account endpoint call.
  - No listenKey create / keep-alive / close.
  - No private WebSocket open / reconnect.
  - No direct Trader / Strategy to ExecutionClient path.
  - No broker gateway implementation.
  - No sandbox submit / cancel / replace runtime.
  - No production venue, production endpoint or production trading.
  - No real submit / cancel / replace.
  - No execution report runtime parser or broker fill parser implementation.
  - No OMS implementation.
  - No reconciliation runtime.
  - No Live PRO Console command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter TargetGraphTests/testGH458ExecutionClientVenueAdapterContractDefinesEngineClientBoundary`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests/testGH458ExecutionClientVenueAdapterContractRejectsDirectAccessAndRuntimeBypass`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 362 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-459 L4 ExecutionClient sandbox submit cancel replace

- Issue: GH-459 `L4: 08/21 Implement ExecutionClient sandbox submit / cancel / replace`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #459 was OPEN with `mtpro / backlog / non-executable`; #458 was CLOSED with `done`; no open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #459 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/l4-executionclient-sandbox-submit-cancel-replace-contract.md`.
  - Added `Sources/ExecutionClient/FutureGate/L4ExecutionClientSandboxVenueAdapter.swift`.
  - Added `TargetGraphTests` coverage for sandbox-only submit / cancel / replace request envelopes, deterministic command evidence, production disabled gate and forbidden production / signed / broker bypass rejection.
  - Backfilled `TVM-L4-EXECUTIONCLIENT-SANDBOX-SUBMIT-CANCEL-REPLACE`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No real API key / secret read, storage, print or repository commit.
  - No API-key header construction or request signature generation.
  - No signed endpoint / account endpoint call.
  - No listenKey create / keep-alive / close.
  - No private WebSocket open / reconnect.
  - No broker gateway touch.
  - No production venue, production endpoint or production trading.
  - No real submit / cancel / replace.
  - No execution report runtime parser or broker fill parser implementation.
  - No OMS implementation.
  - No reconciliation runtime.
  - No Live PRO Console command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter TargetGraphTests/testGH459ExecutionClientSandboxVenueAdapterProducesDeterministicCommandEvidence`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests/testGH459ExecutionClientSandboxVenueAdapterRejectsProductionAndBrokerBypass`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 364 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-460 L4 execution report / broker fill parser

- Issue: GH-460 `L4: 09/21 Add execution report / broker fill parser for sandbox`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #460 was OPEN with `mtpro / backlog / non-executable`; #459 was CLOSED with `done`; no open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #460 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/l4-execution-report-broker-fill-parser-contract.md`.
  - Added `Sources/ExecutionClient/FutureGate/L4ExecutionClientSandboxReportParser.swift`.
  - Added `TargetGraphTests` coverage for sandbox-only execution report / broker fill parser, fill / partial fill / reject / cancel acknowledgement coverage, replayable audit evidence, production parser disabled and raw Dashboard payload rejection.
  - Backfilled `TVM-L4-EXECUTION-REPORT-BROKER-FILL-PARSER`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No real API key / secret read, storage, print or repository commit.
  - No API-key header construction or request signature generation.
  - No signed endpoint / account endpoint call.
  - No listenKey create / keep-alive / close.
  - No private WebSocket open / reconnect.
  - No production raw payload parsing.
  - No raw payload exposure to Dashboard / Report / Events.
  - No broker gateway touch.
  - No real execution report ingestion or real broker fill record.
  - No OMS state transition.
  - No reconciliation runtime.
  - No Live PRO Console command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter TargetGraphTests/testGH460ExecutionClientSandboxReportParserProducesReplayableAuditEvidence`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests/testGH460ExecutionClientSandboxReportParserRejectsProductionRawPayloadAndDashboardBypass`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 366 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-461 L4 OMS order lifecycle contract

- Issue: GH-461 `L4: 10/21 Define OMS order lifecycle state machine`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #461 was OPEN with `mtpro / backlog / non-executable`; #458 and #460 were CLOSED with `done`; no open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #461 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/l4-oms-order-lifecycle-contract.md`.
  - Added `Sources/ExecutionEngine/OMSFutureGate/L4OMSOrderLifecycleContract.swift`.
  - Added `TargetGraphTests` coverage for OMS lifecycle state machine, local order / broker report relationship, illegal transition evidence, rollback / incident evidence and ExecutionEngine / ExecutionClient / Portfolio boundary.
  - Backfilled `TVM-L4-OMS-ORDER-LIFECYCLE-CONTRACT`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No real API key / secret read, storage, print or repository commit.
  - No API-key header construction or request signature generation.
  - No signed endpoint / account endpoint call.
  - No listenKey create / keep-alive / close.
  - No private WebSocket open / reconnect.
  - No production order manager.
  - No real order submission.
  - No production broker report consumption.
  - No broker gateway touch.
  - No real order state store write.
  - No Portfolio mutation.
  - No reconciliation runtime.
  - No Live PRO Console command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter TargetGraphTests/testGH461OMSOrderLifecycleContractDefinesStateMachineAndBoundaries`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests/testGH461OMSOrderLifecycleContractRejectsIllegalTransitionAndBypass`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 368 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-462 L4 OMS local order transition evidence

- Issue: GH-462 `L4: 11/21 Implement OMS local order state transition evidence`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #462 was OPEN with `mtpro / backlog / non-executable`; #461 was CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #462 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/l4-oms-local-order-transition-evidence-contract.md`.
  - Added `Sources/ExecutionEngine/OMSFutureGate/L4OMSLocalOrderTransitionEvidence.swift`.
  - Added `TargetGraphTests` coverage for deterministic sandbox local order state records, GH-461 allowed local transition evidence, fill / cancel / reject lifecycle paths, illegal transition rejection and broker-independent local state evidence.
  - Backfilled `TVM-L4-OMS-LOCAL-ORDER-TRANSITION-EVIDENCE`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No real API key / secret read, storage, print or repository commit.
  - No API-key header construction or request signature generation.
  - No signed endpoint / account endpoint call.
  - No listenKey create / keep-alive / close.
  - No private WebSocket open / reconnect.
  - No production OMS.
  - No real order submission.
  - No production broker report consumption.
  - No broker gateway touch.
  - No real order state store write.
  - No Portfolio mutation.
  - No reconciliation runtime.
  - No Live PRO Console command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter TargetGraphTests/testGH462OMSLocalOrderTransitionEvidenceBuildsDeterministicSandboxLifecycle`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests/testGH462OMSLocalOrderTransitionEvidenceRejectsIllegalTransitionAndRuntimeBypass`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 370 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-463 L4 ExecutionEngine -> ExecutionClient sandbox path

- Issue: GH-463 `L4: 12/21 Wire ExecutionEngine -> ExecutionClient sandbox path`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #463 was OPEN with `mtpro / backlog / non-executable`; #459, #461 and #462 were CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #463 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/l4-executionengine-executionclient-sandbox-path-contract.md`.
  - Added `Sources/ExecutionEngine/OMSFutureGate/L4ExecutionEngineSandboxPathEvidence.swift`.
  - Added `TargetGraphTests` coverage for RiskEngine-approved proposal, ExecutionEngine handoff, GH-459 sandbox ExecutionClient request / response, GH-462 local transition evidence link, command / response / execution event evidence and direct access rejection.
  - Backfilled `TVM-L4-EXECUTIONENGINE-EXECUTIONCLIENT-SANDBOX-PATH`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No real API key / secret read, storage, print or repository commit.
  - No API-key header construction or request signature generation.
  - No signed endpoint / account endpoint call.
  - No listenKey create / keep-alive / close.
  - No private WebSocket open / reconnect.
  - No production execution.
  - No production OMS.
  - No real order submission.
  - No production broker report consumption.
  - No broker gateway touch.
  - No real order state store write.
  - No Portfolio mutation.
  - No reconciliation runtime.
  - No Live PRO Console command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter TargetGraphTests/testGH463ExecutionEngineSandboxPathWiresRiskApprovedCommandEvidence`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests/testGH463ExecutionEngineSandboxPathRejectsDirectAccessAndBoundaryBypass`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 372 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-464 L4 Live RiskEngine pre-trade gate

- Issue: GH-464 `L4: 13/21 Add live RiskEngine pre-trade allow / reject runtime`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #464 was OPEN with `mtpro / backlog / non-executable`; #457 and #461 were CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #464 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/l4-live-riskengine-pre-trade-gate-contract.md`.
  - Added `Sources/RiskEngine/LiveGate/L4LiveRiskPreTradeGate.swift`.
  - Added `TargetGraphTests` coverage for APB / margin read-model input, order proposal risk input, allow / reject / blocked / incident stop decision evidence, command path RiskEngine required and forbidden runtime / bypass rejection.
  - Backfilled `TVM-L4-LIVE-RISKENGINE-PRE-TRADE-GATE`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No real API key / secret read, storage, print or repository commit.
  - No API-key header construction or request signature generation.
  - No signed endpoint / account endpoint call.
  - No listenKey create / keep-alive / close.
  - No private WebSocket open / reconnect.
  - No RiskEngine -> ExecutionClient dependency.
  - No production trading.
  - No real order submission.
  - No production broker report consumption.
  - No broker gateway touch.
  - No real order state store write.
  - No Portfolio mutation.
  - No reconciliation runtime.
  - No Live PRO Console command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter TargetGraphTests/testGH464LiveRiskPreTradeGateProducesAllowRejectBlockedIncidentEvidence`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests/testGH464LiveRiskPreTradeGateRejectsBypassAndForbiddenRuntime`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 374 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-465 L4 kill switch / incident shutdown gate

- Issue: GH-465 `L4: 14/21 Add kill switch / incident stop / command shutdown gate`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #465 was OPEN with `mtpro / backlog / non-executable`; #464 was CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #465 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/l4-kill-switch-incident-shutdown-gate-contract.md`.
  - Added `Sources/RiskEngine/LiveGate/L4KillSwitchIncidentShutdownGate.swift`.
  - Added `TargetGraphTests` coverage for incident stop source identity, submit / cancel / replace shutdown rules, Dashboard / audit explainable shutdown evidence, no automatic recovery boundary and forbidden runtime / bypass rejection.
  - Backfilled `TVM-L4-KILL-SWITCH-INCIDENT-SHUTDOWN-GATE`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No real API key / secret read, storage, print or repository commit.
  - No production operations runbook.
  - No real emergency broker API.
  - No signed endpoint / account endpoint call.
  - No listenKey create / keep-alive / close.
  - No private WebSocket open / reconnect.
  - No RiskEngine -> ExecutionClient dependency.
  - No production trading.
  - No real order submission / cancellation / replacement.
  - No production broker report consumption.
  - No broker gateway touch.
  - No real order state store write.
  - No Portfolio mutation.
  - No reconciliation runtime.
  - No automatic recovery.
  - No Live PRO Console command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter TargetGraphTests/testGH465KillSwitchIncidentShutdownGateBlocksAllCommandsAndDefinesRecoveryBoundary`: pass; 1 test / 0 failures.
  - `swift test --filter TargetGraphTests/testGH465KillSwitchIncidentShutdownGateRejectsAutoRecoveryAndCommandBypass`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 376 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-466 L4 OMS / broker / portfolio reconciliation evidence

- Issue: GH-466 `L4: 15/21 Add reconciliation between OMS / broker report / portfolio projection`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #466 was OPEN with `mtpro / backlog / non-executable`; dependencies #460, #462 and #463 were CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #466 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/l4-oms-broker-portfolio-reconciliation-contract.md`.
  - Added `Sources/ExecutionEngine/OMSFutureGate/L4OMSBrokerPortfolioReconciliationEvidence.swift`.
  - Added `TargetGraphTests` coverage for GH-460 parser evidence, GH-462 local transition evidence, GH-463 sandbox path evidence, field matrix, matched / mismatched / stale / missing status coverage, partial fill / cancel / reject paths and projection no broker payload.
  - Backfilled `TVM-L4-OMS-BROKER-PORTFOLIO-RECONCILIATION`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No real API key / secret read, storage, print or repository commit.
  - No real broker account read.
  - No production broker report consumption.
  - No raw broker payload read.
  - No real PnL calculation.
  - No Portfolio runtime mutation.
  - No reconciliation runtime enablement.
  - No repair command.
  - No ExecutionClient call.
  - No broker gateway touch.
  - No production trading.
  - No Live PRO Console command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter 'TargetGraphTests/testGH466'`: pass; 2 tests / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 378 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-467 L4 audit trail / incident replay evidence

- Issue: GH-467 `L4: 16/21 Add audit trail / incident replay evidence`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #467 was OPEN with `mtpro / backlog / non-executable`; dependency #466 was CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #467 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/l4-audit-trail-incident-replay-contract.md`.
  - Added `Sources/ExecutionEngine/OMSFutureGate/L4AuditTrailIncidentReplayEvidence.swift`.
  - Added `TargetGraphTests` coverage for command intent, risk decision, execution request, broker report, OMS transition, reconciliation outcome, append-only sequence, deterministic replay, secret / raw payload exclusion and production replay bypass rejection.
  - Backfilled `TVM-L4-AUDIT-TRAIL-INCIDENT-REPLAY`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No real API key / secret read, storage, print or repository commit.
  - No external audit upload.
  - No production incident ops.
  - No production broker replay.
  - No secret capture.
  - No raw broker payload capture.
  - No mutable audit trail.
  - No repair command.
  - No ExecutionClient call.
  - No broker gateway touch.
  - No production trading.
  - No Live PRO Console command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter 'TargetGraphTests/testGH467'`: pass; 2 tests / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 380 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-468 L4 Dashboard / Live PRO Console command split

- Issue: GH-468 `L4: 17/21 Add Dashboard / Live PRO Console read-only-to-command split`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #468 was OPEN with `mtpro / backlog / non-executable`; dependencies #464, #465, #466 and #467 were CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #468 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/l4-dashboard-livepro-command-split-contract.md`.
  - Added `Sources/Dashboard/FutureLiveProConsole/L4DashboardCommandSplit.swift`.
  - Added `AppTests` coverage for Dashboard read-model-only preservation, future Live PRO Console command gate state, read-only / armed / blocked / incident state coverage, command UI default invisible / disabled, and Dashboard command / production bypass rejection.
  - Backfilled `TVM-L4-DASHBOARD-LIVEPRO-COMMAND-SPLIT`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No real API key / secret read, storage, print or repository commit.
  - No guarded UI implementation.
  - No Dashboard submit / cancel / replace.
  - No trading button.
  - No order form.
  - No production command.
  - No RiskEngine bypass.
  - No OMS bypass.
  - No broker gateway touch.
  - No signed endpoint call.
  - No real order submission / cancellation / replacement.
- Validation:
  - `swift test --filter 'AppTests/testGH468'`: pass; 2 tests / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 382 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-469 L4 Guarded command UI surface

- Issue: GH-469 `L4: 18/21 Add guarded submit / cancel / replace UI surface`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #469 was OPEN with `mtpro / backlog / non-executable`; dependency #468 was CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #469 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/l4-guarded-command-ui-surface-contract.md`.
  - Added `Sources/Dashboard/FutureLiveProConsole/L4GuardedCommandUISurface.swift`.
  - Added `AppTests` coverage for Live PRO Console guarded submit / cancel / replace controls, sandbox-only availability, confirmation / blocked / incident / audit evidence, and production / Dashboard / missing evidence bypass rejection.
  - Backfilled `TVM-L4-GUARDED-COMMAND-UI-SURFACE`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No real API key / secret read, storage, print or repository commit.
  - No Dashboard command surface.
  - No production command.
  - No broker gateway touch.
  - No signed endpoint call.
  - No order form.
  - No trading button.
  - No RiskEngine bypass.
  - No OMS bypass.
  - No ExecutionEngine sandbox evidence bypass.
  - No real order submission / cancellation / replacement.
- Validation:
  - `swift test --filter 'AppTests/testGH469'`: pass; 2 tests / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 384 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-470 L4 sandbox validation matrix closeout

- Issue: GH-470 `L4: 19/21 Close L4 sandbox validation matrix`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #470 was OPEN with `mtpro / backlog / non-executable`; dependencies #463, #464, #465, #466, #467 and #469 were CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #470 was promoted to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/audit/inputs/mtpro-l4-live-production-trading-commands-v1-gh-470-sandbox-validation-closeout.md`.
  - Backfilled `TVM-L4-SANDBOX-VALIDATION-MATRIX-CLOSEOUT`, validation plan, domain language, latest summary and automation readiness anchors.
  - Closed read / risk / execution / OMS / reconciliation / audit / UI gate matrix coverage for GH-452 through GH-469.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No production cutover definition.
  - No final Stage Code Audit Report.
  - No next Project / Issue creation.
  - No production command.
  - No real API key / secret read, storage, print or repository commit.
  - No raw broker payload exposure.
  - No broker gateway touch.
  - No signed endpoint call.
  - No order form.
  - No trading button.
  - No real order submission / cancellation / replacement.
- Validation:
  - Focused XCTest: not applicable; docs-only matrix closeout.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 384 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-471 L4 production cutover gate and no-default-real-trading policy

- Issue: GH-471 `L4: 20/21 Define production cutover gate and no-default-real-trading policy`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #471 was OPEN with `mtpro / backlog / non-executable`; dependency #470 was CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #471 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `Sources/ExecutionClient/FutureGate/L4ProductionCutoverGatePolicy.swift`.
  - Added `docs/contracts/l4-production-cutover-no-default-real-trading-policy.md`.
  - Added TargetGraph focused coverage for future production cutover gate, Human acceptance criteria and no-default-real-trading policy.
  - Backfilled `TVM-L4-PRODUCTION-CUTOVER-GATE`, validation plan, domain language, latest summary and automation readiness anchors.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No production cutover execution.
  - No production endpoint connection.
  - No real API key / secret read, storage, print or repository commit.
  - No signed endpoint call.
  - No broker gateway enablement.
  - No Dashboard command bypass.
  - No Live PRO Console production command.
  - No order form.
  - No trading button.
  - No real order submission / cancellation / replacement.
- Validation:
  - `swift test --filter 'GH471'`: pass; 2 tests / 0 failures.
  - `git diff --check`: pass.
- `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
- `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 386 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1 Root Docs Refresh Gate

- Project: `MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1`
- Queue:
  - GitHub fallback queue used because this stage did not use Linear.
  - GH-503 through GH-510 are all closed and carry `done`.
  - PR #511 through PR #519 are all merged and carried required check `checks` SUCCESS.
  - Closure PR #519 merge commit before this Root Docs Refresh PR: `f37707579499391c0d7d93009c797dbfc3440885`.
- Stage Code Audit:
  - Canonical report: `docs/audit/mtpro-production-cutover-readiness-real-broker-enablement-gate-v1-stage-code-audit.md`.
  - Report covers credential / secret policy gate、production environment isolation gate、broker / venue capability matrix、manual approval / operator confirmation gate、incident stop / rollback / no-trade state gate、capital / risk / order notional / exposure limit gate、dry-run proof / shadow mode / no-default-production-trading evidence、final readiness matrix、automation readiness and forbidden capability audit.
- Root Docs Refresh:
  - Updated `GOAL.md`, `BLUEPRINT.md`, `docs/roadmap.md`, `docs/validation/latest-verification-summary.md`, `verification.md`, `docs/automation/automation-readiness.md` and `checks/automation-readiness.sh`.
  - Project Closure Count moves to `34 / 34 (100%)`.
  - Current maturity statement becomes `Production Cutover Readiness / Real Broker Enablement Gate complete with no-default-production-trading policy and no real broker authorization`.
  - Final Product Goal Progress remains `9 / 9 (100%)`.
  - Engine Maturity Roadmap Progress remains `4 / 4 (100%)`.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No `.codex/*`, `.build/*` or `graphify-out/*` submitted.
  - No next Project / Issue creation or promotion.
  - No production trading authorization.
  - No real broker authorization.
  - No real order authorization.
  - No real API key / secret read, storage, print or repository commit.
  - No production endpoint connection.
  - No signed endpoint / account endpoint / listenKey.
  - No broker adapter / LiveExecutionAdapter.
  - No production OMS.
  - No real order submission / cancellation / replacement.
  - No broker fill / reconciliation runtime.
  - No Live PRO Console production command.
  - No live command, order form or trading button.
- Validation:
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 404 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-521 Release v0.1.0 Binance EMA runtime contract

- Issue: GH-521 `Define release v0.1.0 Binance EMA runtime contract and acceptance matrix`
- Queue:
  - GitHub fallback queue used because this release stage is not using Linear.
  - WIP=1 preflight passed before implementation: #521 was OPEN with `mtpro / backlog / non-executable`; no upstream blocker; no open PR; no open issue carried `todo`, `in-progress` or `in-review`.
  - #521 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/release-v0.1.0-binance-ema-runtime-contract.md`.
  - Backfilled `TVM-RELEASE-V010-BINANCE-EMA-RUNTIME` in `docs/validation/trading-validation-matrix.md`.
  - Added GH-521 validation anchors in `docs/validation/validation-plan.md`, `docs/domain/context.md`, `docs/automation/automation-readiness.md`, `docs/validation/latest-verification-summary.md` and `checks/automation-readiness.d/l4-boundary.sh`.
  - Fixed release v0.1.0 active scope as Binance-only and EMA-only.
  - Fixed dry-run-first / testnet-first gate and no-default-production-trading boundary.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No runtime implementation.
  - No production secret read, storage, print or repository commit.
  - No production endpoint connection.
  - No production broker connection.
  - No signed endpoint / account endpoint / listenKey call.
  - No real order submission / cancellation / replacement.
  - No non-Binance active venue.
  - No non-EMA active concrete strategy.
  - No RiskEngine / ExecutionEngine / OMS / kill switch bypass.
  - No next Project / Issue creation or release v0.1.0 post-stage promotion.
- Validation:
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 404 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - MTPRO L4 Live Production / Trading Commands v1 Project closure

- Project: `MTPRO L4 Live Production / Trading Commands v1`
- Queue:
  - GitHub fallback queue used because this L4 stage did not use Linear.
  - GH-452 through GH-472 are all closed and carry `done`.
  - PR #473 through PR #493 are all merged and carried required check `checks` SUCCESS.
  - Terminal issue PR #493 merge commit: `57dd86c9ef0b1d8bd87e3e0a0a1073596ba6bd6e`.
- Stage Code Audit:
  - Added `docs/audit/mtpro-l4-live-production-trading-commands-v1-stage-code-audit.md`.
  - Report covers command / credential / signed boundary、read-only account / private stream evidence、ExecutionClient / ExecutionEngine sandbox path、OMS lifecycle、RiskEngine pre-trade gate、kill switch、reconciliation、audit trail / incident replay、Dashboard / Live PRO Console split、guarded sandbox UI、sandbox validation matrix、production cutover future gate and no-default-production-trading policy.
- Root Docs Refresh:
  - Updated `GOAL.md`, `BLUEPRINT.md`, `docs/roadmap.md`, `docs/product/mtpro-live-readiness-roadmap-v1.md`, `docs/validation/latest-verification-summary.md`, `docs/automation/automation-readiness.md` and `checks/automation-readiness.sh`.
  - Project Closure Count moves to `33 / 33 (100%)`.
  - Final Product Goal Progress remains `9 / 9 (100%)`.
  - Engine Maturity Roadmap Progress remains `4 / 4 (100%)`.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No `.codex/*`, `.build/*` or `graphify-out/*` submitted.
  - No production cutover execution.
  - No real API key / secret read, storage, print or repository commit.
  - No production endpoint connection.
  - No signed endpoint call.
  - No broker gateway enablement.
  - No production OMS.
  - No real order submission / cancellation / replacement.
  - No Live PRO Console production command.
  - No order form or trading button.
  - No next Project / Issue creation or promotion.
- Validation:
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 386 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-07 - GH-472 L4 Stage Audit input closeout

- Issue: GH-472 `L4: 21/21 Close L4 Stage Audit input`
- Queue:
  - GitHub fallback queue used because this L4 stage is not using Linear.
  - WIP=1 preflight passed before implementation: #472 was OPEN with `mtpro / backlog / non-executable`; dependency #471 was CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #472 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/audit/inputs/mtpro-l4-live-production-trading-commands-v1-stage-audit-input.md`.
  - Summarized GH-452 through GH-471 issue / PR / merge evidence chain.
  - Backfilled `TVM-L4-STAGE-AUDIT-INPUT-CLOSEOUT`, validation plan, domain language, latest summary and automation readiness anchors.
  - Prepared Root Docs Delta input and no-next-project stop rule for the later closure flow.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No final production approval.
  - No root docs refresh in this issue.
  - No production cutover execution.
  - No production endpoint connection.
  - No real API key / secret read, storage, print or repository commit.
  - No signed endpoint call.
  - No broker gateway enablement.
  - No Dashboard command bypass.
  - No Live PRO Console production command.
  - No order form.
  - No trading button.
  - No next Project / Issue creation or promotion.
  - No real order submission / cancellation / replacement.
- Validation:
  - Focused XCTest: not applicable; docs-only Stage Audit input closeout.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 386 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-522 Release v0.1.0 ownership gap retirement

- Issue: GH-522 `Retire remaining Core / Adapters / Persistence / Runtime ownership gaps`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #522 was OPEN with `mtpro / backlog / non-executable`; dependency #521 was CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #522 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/contracts/release-v0.1.0-ownership-gap-retirement-contract.md`.
  - Backfilled `TVM-RELEASE-V010-OWNERSHIP-GAP-RETIREMENT`, validation plan, domain language, latest summary and automation readiness anchors.
  - Added `TargetGraphTests/testGH522ReleaseV010OwnershipGapsAreRetiredOrExplicitlyDeferred` to prove Package target source snapshot and deferred ownership register.
  - Classified `Adapters` as compatibility re-export only.
  - Deferred `Runtime -> DataEngine/Ingest`, `Runtime -> Database/ReplayProjection`, `Persistence -> Database/Projections` and `Core -> LiveTradingBoundary / LiveMonitoring*` to later scoped release issues.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No runtime implementation.
  - No production source move.
  - No SwiftPM dependency graph change.
  - No production secret read, print or storage.
  - No production endpoint connection.
  - No signed endpoint, account endpoint or listenKey connection.
  - No production trading.
  - No real order submission / cancellation / replacement.
  - No non-Binance venue.
  - No non-EMA active strategy.
- Validation:
  - `swift test --filter TargetGraphTests/testGH522ReleaseV010OwnershipGapsAreRetiredOrExplicitlyDeferred`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 405 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-523 Release v0.1.0 real target smoke coverage

- Issue: GH-523 `Add real target smoke tests for all release modules`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #523 was OPEN with `mtpro / backlog / non-executable`; dependency #522 was CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #523 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `TargetGraphTests/testGH523ReleaseV010TargetsExposeRealSmokeCoverage`.
  - Backfilled `GH-523-RELEASE-V010-REAL-TARGET-SMOKE-COVERAGE` in the release v0.1.0 contract.
  - Backfilled `TVM-RELEASE-V010-REAL-TARGET-SMOKE-COVERAGE`, validation plan, domain language, latest summary and automation readiness guard.
  - Covered `DomainModel`, `MessageBus`, `Database`, `DataClient`, `DataEngine`, `Cache`, `Trader`, `TraderStrategies`, `Portfolio`, `RiskEngine`, `ExecutionEngine`, `ExecutionClient` and `Dashboard` through real public API smoke usage.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No release runtime implementation.
  - No broker gateway, signed endpoint client, account endpoint client, listenKey lifecycle or private WebSocket runtime.
  - No production secret read, print or storage.
  - No production endpoint connection.
  - No production trading.
  - No real order submission / cancellation / replacement.
  - No non-Binance venue.
  - No non-EMA active strategy.
- Validation:
  - `swift test --filter TargetGraphTests/testGH523ReleaseV010TargetsExposeRealSmokeCoverage`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 406 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-524 Binance public market data runtime path

- Issue: GH-524 `Implement Binance public market data runtime path into DataEngine and Cache`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #524 was OPEN with `mtpro / backlog / non-executable`; dependency #523 was CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #524 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `Sources/DataEngine/BinancePublicMarketDataRuntimePath.swift`.
  - Added Cache batch projection helpers in `Sources/Cache/MarketData/MarketDataCache.swift`.
  - Added `TargetGraphTests/testGH524BinancePublicMarketDataRuntimePathProjectsIntoCacheReadModel`.
  - Updated `Package.swift` so `DataEngine` owns `BinancePublicMarketDataRuntimePath.swift` while `Core` / `Runtime` compatibility envelopes explicitly exclude it.
  - Backfilled `GH-524-BINANCE-PUBLIC-MARKET-DATA-RUNTIME-PATH`, `TVM-RELEASE-V010-BINANCE-PUBLIC-MARKET-DATA-PATH`, validation plan, domain language, latest summary and automation readiness guard.
  - Covered Binance public kline, recent trade, best bid / ask, depth snapshot and depth delta through mock transport, DataClient decoder, DataEngine neutral journal replay evidence and Cache read model projection.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No private account read.
  - No signed endpoint, account endpoint, listenKey or private WebSocket runtime.
  - No broker gateway, OMS or execution command.
  - No production secret read, print or storage.
  - No production endpoint connection.
  - No production trading.
  - No real order submission / cancellation / replacement.
  - No non-Binance venue.
  - No non-EMA active strategy.
- Validation:
  - `swift test --filter TargetGraphTests/testGH524BinancePublicMarketDataRuntimePathProjectsIntoCacheReadModel`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 407 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-525 Binance signed account read runtime

- Issue: GH-525 `Implement Binance signed account read runtime`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #525 was OPEN with `mtpro / backlog / non-executable`; dependency #524 was CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #525 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `Sources/DataClient/Binance/SignedAccount/BinanceSignedAccountReadRuntime.swift`.
  - Added `swift-crypto` / `Crypto` dependency to `DataClient` for HMAC-SHA256 request signature construction.
  - Added `TargetGraphTests/testGH525BinanceSignedAccountReadRuntimeMapsCanonicalSnapshotWithoutCommandSurface`.
  - Backfilled `GH-525-BINANCE-SIGNED-ACCOUNT-READ-RUNTIME`, `TVM-RELEASE-V010-BINANCE-SIGNED-ACCOUNT-READ`, validation plan, domain language, latest summary and automation readiness guard.
  - Covered Binance Spot testnet / local fixture-first signed `/api/v3/account` GET request, credential reference-only evidence, `X-MBX-APIKEY` header transport boundary, HMAC-SHA256 signature query item, production endpoint rejection and canonical account / balance snapshot mapping.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No production secret read, print or storage.
  - No production endpoint connection.
  - No listenKey lifecycle or private WebSocket runtime.
  - No broker gateway, OMS or execution command.
  - No raw signed payload exposure.
  - No production trading.
  - No real order submission / cancellation / replacement.
  - No non-Binance venue.
  - No non-EMA active strategy.
- Validation:
  - `swift test --filter TargetGraphTests/testGH525BinanceSignedAccountReadRuntimeMapsCanonicalSnapshotWithoutCommandSurface`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 408 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-526 Binance private stream account snapshot runtime

- Issue: GH-526 `Implement Binance private stream and account snapshot runtime`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #526 was OPEN with `mtpro / backlog / non-executable`; dependency #525 was CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #526 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `Sources/DataClient/Binance/PrivateStream/BinancePrivateStreamAccountSnapshotRuntime.swift`.
  - Added `TargetGraphTests/testGH526BinancePrivateStreamAccountSnapshotRuntimeMapsEventsWithoutCommandSurface`.
  - Backfilled `GH-526-BINANCE-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-RUNTIME`, `TVM-RELEASE-V010-BINANCE-PRIVATE-STREAM-ACCOUNT-SNAPSHOT`, validation plan, domain language, latest summary and automation readiness guard.
  - Covered Binance Spot testnet / local fixture-first listenKey lifecycle request, redacted listenKey reference, mock private stream frame ingest, `outboundAccountPosition` / `balanceUpdate` account / balance / position read-model mapping, stale / blocked / missing / disconnected freshness evidence and forbidden `executionReport` rejection.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No production secret read, print or storage.
  - No production endpoint or production stream connection.
  - No raw listenKey exposure.
  - No raw private payload or broker payload exposure.
  - No broker gateway, OMS or execution command.
  - No production trading.
  - No real order submission / cancellation / replacement.
  - No non-Binance venue.
  - No non-EMA active strategy.
- Validation:
  - `swift test --filter TargetGraphTests/testGH526BinancePrivateStreamAccountSnapshotRuntimeMapsEventsWithoutCommandSurface`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 409 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-527 Trader runtime lifecycle

- Issue: GH-527 `Implement Trader runtime lifecycle for Accounts, EMA and Coordination`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #527 was OPEN with `mtpro / backlog / non-executable`; dependencies #523 and #526 were CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #527 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `Sources/Trader/Runtime/TraderRuntimeLifecycle.swift`.
  - Added `TargetGraphTests/testGH527TraderRuntimeLifecycleManagesAccountsEMAAndCoordinationWithoutOrderSubmission`.
  - Backfilled `GH-527-TRADER-RUNTIME-LIFECYCLE`, `GH-527-TRADER-ACCOUNTS-EMA-COORDINATION-LIFECYCLE`, `GH-527-NO-DIRECT-ORDER-SUBMISSION`, `TVM-RELEASE-V010-TRADER-RUNTIME-LIFECYCLE`, validation plan, domain language, latest summary and automation readiness guard.
  - Covered Trader startup / shutdown event sequence, account context binding, EMA strategy instance registration, Coordination/RiskBinding handoff, RiskEngine handoff required evidence and no-command flags.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No production secret read, print or storage.
  - No production endpoint or production broker endpoint connection.
  - No direct ExecutionClient, broker gateway or OMS path.
  - No production trading.
  - No real order submission / cancellation / replacement.
  - No non-Binance venue.
  - No non-EMA active strategy.
- Validation:
  - `swift test --filter TargetGraphTests/testGH527TraderRuntimeLifecycleManagesAccountsEMAAndCoordinationWithoutOrderSubmission`: pass; 1 test / 0 failures.
  - `swift test --filter 'CoreTests/testMTP210TraderContainerCompletenessValidationLocksAccountsEMAAndRiskBindingOnly|TargetGraphTests/testGH527TraderRuntimeLifecycleManagesAccountsEMAAndCoordinationWithoutOrderSubmission'`: pass; 2 tests / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 410 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-528 EMA strategy proposal runtime

- Issue: GH-528 `Implement EMA strategy proposal runtime`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #528 was OPEN with `mtpro / backlog / non-executable`; dependency #527 was CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #528 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `Sources/Trader/Strategies/EMA/EMAProposalRuntime.swift`.
  - Added `TargetGraphTests/testGH528EMAProposalRuntimeGeneratesRiskConsumableProposalWithoutExecutionPath`.
  - Backfilled `GH-528-EMA-STRATEGY-PROPOSAL-RUNTIME`, `GH-528-EMA-SIGNAL-TO-PAPER-PROPOSAL`, `GH-528-RISKENGINE-CONSUMABLE-PROPOSAL`, `TVM-RELEASE-V010-EMA-PROPOSAL-RUNTIME`, validation plan, domain language, latest summary and automation readiness guard.
  - Covered live-read compatible market bars / EMA signal sample input, paper-only proposal generation, RiskEngine consumable risk query evidence, EMA-only / Binance-only identity and no-command flags.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No production secret read, print or storage.
  - No production endpoint or production broker endpoint connection.
  - No direct ExecutionClient, broker gateway or OMS path.
  - No production trading.
  - No real order submission / cancellation / replacement.
  - No non-Binance venue.
  - No non-EMA active strategy.
- Validation:
  - `swift test --filter TargetGraphTests/testGH528EMAProposalRuntimeGeneratesRiskConsumableProposalWithoutExecutionPath`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 411 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-529 RiskEngine pre-trade gate

- Issue: GH-529 `Implement RiskEngine live pre-trade gate`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #529 was OPEN with `mtpro / backlog / non-executable`; dependencies #527 and #528 were CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #529 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `Sources/RiskEngine/LiveGate/ReleaseV010RiskPreTradeGate.swift`.
  - Added `TargetGraphTests/testGH529RiskEnginePreTradeGateConsumesEMAProposalBeforeExecutionPath`.
  - Backfilled `GH-529-RISKENGINE-LIVE-PRETRADE-GATE`, `GH-529-EMA-PROPOSAL-RISK-DECISION`, `GH-529-NO-TRADE-GUARD`, `TVM-RELEASE-V010-RISKENGINE-PRETRADE-GATE`, validation plan, domain language, latest summary and automation readiness guard.
  - Covered #528 neutral `PaperActionProposal` / `RiskEvaluationQuery` input, approved / rejected / blocked decision evidence, quantity / notional / available balance rejection, no-trade guard blocked path and no-command flags.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No production secret read, print or storage.
  - No production endpoint or production broker endpoint connection.
  - No ExecutionClient, broker gateway or OMS call.
  - No production trading.
  - No real order submission / cancellation / replacement.
  - No non-Binance venue.
  - No non-EMA active strategy.
  - No Dashboard command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter TargetGraphTests/testGH529RiskEnginePreTradeGateConsumesEMAProposalBeforeExecutionPath`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 412 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-530 ExecutionEngine OMS lifecycle

- Issue: GH-530 `Implement ExecutionEngine order lifecycle and OMS state machine`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #530 was OPEN with `mtpro / backlog / non-executable`; dependency #529 was CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #530 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `Sources/ExecutionEngine/OMSFutureGate/ReleaseV010ExecutionOMSStateMachine.swift`.
  - Added `TargetGraphTests/testGH530ExecutionEngineOMSStateMachineRequiresRiskApprovedEvidence`.
  - Backfilled `GH-530-EXECUTIONENGINE-OMS-STATE-MACHINE`, `GH-530-RISK-APPROVED-ORDER-INTENT`, `GH-530-OMS-EVENT-LOG-AUDIT-EVIDENCE`, `GH-530-NO-PRODUCTION-OMS-RUNTIME`, `TVM-RELEASE-V010-EXECUTIONENGINE-OMS-LIFECYCLE`, validation plan, domain language, latest summary and automation readiness guard.
  - Covered #529 approved risk decision -> local order intent, `new` / `accepted` / `rejected` / `canceled` / `replaced` / `filled` state coverage, append-only OMS event log audit evidence and rejected / blocked risk decision -> rejected path.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No production secret read, print or storage.
  - No production endpoint or production broker endpoint connection.
  - No ExecutionClient or broker gateway call.
  - No production OMS runtime.
  - No production order store write.
  - No production trading.
  - No real order submission / cancellation / replacement.
  - No reconciliation runtime.
  - No non-Binance venue.
  - No non-EMA active strategy.
  - No Dashboard command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter TargetGraphTests/testGH530ExecutionEngineOMSStateMachineRequiresRiskApprovedEvidence`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 413 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-531 Binance ExecutionClient testnet submit / cancel / replace

- Issue: GH-531 `Implement Binance ExecutionClient testnet submit, cancel and replace`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #531 was OPEN with `mtpro / backlog / non-executable`; dependency #530 was CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #531 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `Sources/ExecutionClient/FutureGate/ReleaseV010BinanceExecutionClientTestnetCommands.swift`.
  - Added `TargetGraphTests/testGH531BinanceExecutionClientTestnetSubmitCancelReplaceRequiresCredentialGuardAndOMS`.
  - Backfilled `GH-531-BINANCE-TESTNET-SUBMIT-CANCEL-REPLACE`, `GH-531-BINANCE-TESTNET-REQUEST-MAPPING`, `GH-531-TESTNET-CREDENTIAL-GUARD`, `GH-531-BINANCE-TESTNET-CAPABILITY-MATRIX`, `GH-531-TESTNET-SUBMIT-CANCEL-REPLACE-EVIDENCE`, `GH-531-PRODUCTION-ENDPOINT-EXPLICIT-GATE`, `TVM-RELEASE-V010-BINANCE-EXECUTIONCLIENT-TESTNET-SCR`, validation plan, domain language, latest summary and automation readiness guard.
  - Covered Binance Spot testnet submit / cancel / replace request mapping, testnet credential reference guard, #530 OMS source identity, capability matrix, production endpoint explicit gate and deterministic acknowledgement evidence.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No production secret read, print or storage.
  - No production endpoint or production broker endpoint connection.
  - No production submit / cancel / replace.
  - No broker gateway.
  - No signature value, credential value or raw secret material exposure.
  - No execution report / broker fill parser.
  - No reconciliation runtime or Portfolio update path.
  - No production trading.
  - No non-Binance venue.
  - No non-EMA active strategy.
  - No Dashboard command surface, trading button, live command or order form.
- Validation:
  - `swift test --filter TargetGraphTests/testGH531BinanceExecutionClientTestnetSubmitCancelReplaceRequiresCredentialGuardAndOMS`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 414 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-532 Binance execution report / broker fill parser

- Issue: GH-532 `Implement execution report and broker fill parser`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #532 was OPEN with `mtpro / backlog / non-executable`; dependency #531 was CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #532 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `Sources/ExecutionClient/FutureGate/ReleaseV010BinanceExecutionReportBrokerFillParser.swift`.
  - Added `TargetGraphTests/testGH532BinanceExecutionReportParserMapsBrokerFillAndInvalidEvidence`.
  - Backfilled `GH-532-BINANCE-EXECUTION-REPORT-BROKER-FILL-PARSER`, `GH-532-EXECUTIONENGINE-EVENT-MODEL-HANDOFF`, `GH-532-BROKER-FILL-MAPPING`, `GH-532-PARTIAL-CANCEL-REJECT-EVIDENCE`, `GH-532-INVALID-REPORT-BLOCKED-EVIDENCE`, `GH-532-PRODUCTION-PARSER-DISABLED`, `TVM-RELEASE-V010-EXECUTION-REPORT-BROKER-FILL-PARSER`, validation plan, domain language, latest summary and automation readiness guard.
  - Covered #531 command evidence -> normalized ExecutionEngine event model handoff, full / partial broker fill mapping, cancel / reject evidence and abnormal report blocked / invalid evidence.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No production secret read, print or storage.
  - No production raw execution report accepted.
  - No production endpoint or production broker endpoint connection.
  - No production parser enabled by default.
  - No broker gateway.
  - No reconciliation runtime or Portfolio update path.
  - No Dashboard command surface, trading button, live command or order form.
  - No production trading.
  - No non-Binance venue.
  - No non-EMA active strategy.
- Validation:
  - `swift test --filter TargetGraphTests/testGH532BinanceExecutionReportParserMapsBrokerFillAndInvalidEvidence`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 415 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-533 Portfolio reconciliation update path

- Issue: GH-533 `Implement reconciliation and portfolio update path`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #533 was OPEN with `mtpro / backlog / non-executable`; dependencies #530 and #532 were CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #533 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `Sources/ExecutionEngine/OMSFutureGate/ReleaseV010PortfolioReconciliationUpdatePath.swift`.
  - Added `TargetGraphTests/testGH533PortfolioReconciliationUpdatesFromExecutionAndAccountEvidence`.
  - Backfilled `GH-533-EXECUTION-ACCOUNT-PORTFOLIO-RECONCILIATION`, `GH-533-ACCOUNT-POSITION-BALANCE-SNAPSHOT-EVIDENCE`, `GH-533-PORTFOLIO-UPDATE-PATH`, `GH-533-MISMATCH-STALE-BLOCKED-AUDIT-EVIDENCE`, `GH-533-PRODUCTION-TRADING-STAYS-DISABLED`, `TVM-RELEASE-V010-PORTFOLIO-RECONCILIATION-UPDATE-PATH`, validation plan, domain language, latest summary and automation readiness guard.
  - Covered #532 execution event + GH-526 account / balance / position read-model evidence -> Portfolio update projection, positions / net positions / margin / open value evidence and matched / mismatched / stale / blocked audit states.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No production secret read, print or storage.
  - No production account endpoint or production broker endpoint connection.
  - No raw private payload or listenKey value read.
  - No repair command.
  - No Dashboard command surface, trading button, live command or order form.
  - No production trading.
  - No non-Binance venue.
  - No non-EMA active strategy.
- Validation:
  - `swift test --filter TargetGraphTests/testGH533PortfolioReconciliationUpdatesFromExecutionAndAccountEvidence`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true` and `dashboardReadModelOnly=true`; 416 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-534 Dashboard live monitoring surfaces

- Issue: GH-534 `Add Dashboard live monitoring surfaces`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #534 was OPEN with `mtpro / backlog / non-executable`; dependencies #526, #528 and #533 were CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #534 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `Sources/Dashboard/Report/ReleaseV010LiveMonitoringSurface.swift`.
  - Added `AppTests/testGH534ReleaseV010DashboardLiveMonitoringSurfaceIsReadModelOnly`.
  - Backfilled `GH-534-DASHBOARD-LIVE-MONITORING-SURFACE`, `GH-534-CONNECTION-HEALTH-READ-MODEL`, `GH-534-ACCOUNT-PRIVATE-STREAM-STATUS`, `GH-534-TRADER-EMA-RISK-EXECUTION-PORTFOLIO-SUMMARY`, `GH-534-READ-MODEL-ONLY-NO-COMMAND-SURFACE`, `TVM-RELEASE-V010-DASHBOARD-LIVE-MONITORING-SURFACE`, validation plan, domain language, latest summary and automation readiness guard.
  - Covered Dashboard Report / shell access to #526 account/private stream, #528 EMA proposal, #529 RiskEngine gate, #530 ExecutionEngine / OMS, #532 execution report / broker fill and #533 Portfolio reconciliation evidence identity.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No Dashboard direct runtime object consumption.
  - No production secret read, print or storage.
  - No production endpoint or production broker endpoint connection.
  - No raw private payload, listenKey value or account endpoint response exposure.
  - No secret editor, command surface, trading button, live command or order form.
  - No production trading.
  - No non-Binance venue.
  - No non-EMA active strategy.
- Validation:
  - `swift test --filter AppTests/testGH534ReleaseV010DashboardLiveMonitoringSurfaceIsReadModelOnly`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true`, `dashboardReadModelOnly=true` and `releaseLiveMonitoringSurface=7`; 417 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-535 Dashboard controlled command surface with production disabled by default

- Issue: GH-535 `Add Dashboard controlled command surface with production disabled by default`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #535 was OPEN with `mtpro / backlog / non-executable`; dependency #534 was CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #535 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `Sources/Dashboard/Report/ReleaseV010ControlledCommandSurface.swift`.
  - Added `AppTests/testGH535ReleaseV010DashboardControlledCommandSurfaceDefaultsNoTrade`.
  - Backfilled `GH-535-DASHBOARD-CONTROLLED-COMMAND-SURFACE`, `GH-535-DEFAULT-NO-TRADE-COMMAND-ENTRY`, `GH-535-DRYRUN-TESTNET-GATE`, `GH-535-PRODUCTION-DISABLED-BY-DEFAULT`, `GH-535-NO-RISK-EXECUTION-KILLSWITCH-BYPASS`, `TVM-RELEASE-V010-DASHBOARD-CONTROLLED-COMMAND-SURFACE`, validation plan, domain language, latest summary and automation readiness guard.
  - Covered Dashboard Report / shell access to default no-trade command entry, dry-run/testnet gate labels and production disabled explanation.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No production secret read, print or storage.
  - No production endpoint or production broker endpoint connection.
  - No ExecutionClient call, broker connection, RiskEngine bypass, ExecutionEngine bypass, OMS bypass or kill switch bypass.
  - No real submit / cancel / replace.
  - No production trading.
  - No non-Binance venue.
  - No non-EMA active strategy.
- Validation:
  - `swift test --filter AppTests/testGH535ReleaseV010DashboardControlledCommandSurfaceDefaultsNoTrade`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true`, `dashboardReadModelOnly=true`, `releaseLiveMonitoringSurface=7` and `releaseCommandSurface=3`; 418 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-536 Kill switch / no-trade / rollback controls

- Issue: GH-536 `Add kill switch, no-trade and rollback controls`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #536 was OPEN with `mtpro / backlog / non-executable`; dependencies #530, #531 and #535 were CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #536 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `Sources/Dashboard/Report/ReleaseV010KillSwitchNoTradeRollbackSurface.swift`.
  - Added `AppTests/testGH536ReleaseV010KillSwitchBlocksSubmitCancelReplaceAndAuditsRollback`.
  - Backfilled `GH-536-KILL-SWITCH-NO-TRADE-ROLLBACK-CONTROLS`, `GH-536-GLOBAL-NO-TRADE-MODE`, `GH-536-SUBMIT-CANCEL-REPLACE-BLOCKED`, `GH-536-ROLLBACK-OPERATOR-EVIDENCE`, `GH-536-NO-PRODUCTION-DEFAULT`, `TVM-RELEASE-V010-KILL-SWITCH-NO-TRADE-ROLLBACK`, validation plan, domain language, latest summary and automation readiness guard.
  - Covered Dashboard Report / shell access to submit / cancel / replace blocked evidence, global no-trade state, kill switch active state, rollback plan evidence and operator evidence.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No production secret read, print or storage.
  - No production endpoint or production broker endpoint connection.
  - No ExecutionClient call, broker connection, RiskEngine bypass, ExecutionEngine bypass, OMS bypass or kill switch bypass.
  - No real submit / cancel / replace.
  - No automatic recovery, rollback command or broker emergency API.
  - No production trading.
  - No non-Binance venue.
  - No non-EMA active strategy.
- Validation:
  - `swift test --filter AppTests/testGH536ReleaseV010KillSwitchBlocksSubmitCancelReplaceAndAuditsRollback`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true`, `dashboardReadModelOnly=true`, `releaseLiveMonitoringSurface=7`, `releaseCommandSurface=3` and `releaseKillSwitch=3`; 419 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-537 Binance dry-run / testnet validation suite

- Issue: GH-537 `Add Binance dry-run and testnet validation suite`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #537 was OPEN with `mtpro / backlog / non-executable`; dependencies #531, #532, #533 and #536 were CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #537 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `Sources/ExecutionEngine/OMSFutureGate/ReleaseV010DryRunTestnetValidationSuite.swift`.
  - Added `TargetGraphTests/testGH537ReleaseDryRunTestnetValidationSuiteIsRepeatableAndProductionSafe`.
  - Added `checks/release-v0.1.0-dryrun-testnet.sh` and wired it into `checks/run.sh`.
  - Backfilled `GH-537-BINANCE-DRYRUN-TESTNET-VALIDATION-SUITE`, `GH-537-DRYRUN-END-TO-END`, `GH-537-TESTNET-SUBMIT-CANCEL-REPLACE`, `GH-537-EXECUTION-REPORT-FILL-RECONCILIATION-CHECKS`, `GH-537-NO-PRODUCTION-ORDER-ON-FAILURE`, `TVM-RELEASE-V010-BINANCE-DRYRUN-TESTNET-VALIDATION`, validation plan, domain language, latest summary and automation readiness guard.
  - Covered GH-531 Binance testnet submit / cancel / replace request + ack evidence, GH-532 execution report / broker fill parser evidence, GH-533 reconciliation / Portfolio update evidence and GH-536 kill switch / no-trade / rollback anchor in one deterministic release validation suite.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No production secret read, print or storage.
  - No production endpoint or production broker endpoint connection.
  - No real testnet network connection.
  - No broker connection, RiskEngine bypass, ExecutionEngine bypass, OMS bypass or kill switch bypass.
  - No real submit / cancel / replace.
  - No automatic recovery, rollback command or broker emergency API.
  - No production trading.
  - No non-Binance venue.
  - No non-EMA active strategy.
- Validation:
  - `bash checks/release-v0.1.0-dryrun-testnet.sh`: pass; 1 test / 0 failures; final output `MTPRO release v0.1.0 dry-run/testnet validation suite passed.`
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true`, `dashboardReadModelOnly=true`, `releaseLiveMonitoringSurface=7`, `releaseCommandSurface=3` and `releaseKillSwitch=3`; 420 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-538 No-default-production-trading automation guard

- Issue: GH-538 `Add no-default-production-trading automation guards`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #538 was OPEN with `mtpro / backlog / non-executable`; dependencies #536 and #537 were CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #538 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `checks/automation-readiness.d/release-v010-no-default-production-trading.sh`.
  - Wired #538 guard into `checks/automation-readiness.d/run-domain-guards.sh`, making it part of required `bash checks/automation-readiness.sh`.
  - Backfilled l4-boundary self-guard for the #538 script, runner, focused test, release contract, matrix, validation plan, domain context and automation readiness evidence chain.
  - Added `TargetGraphTests/testGH538NoDefaultProductionTradingGuardIsRequiredAutomationReadiness`.
  - Backfilled `GH-538-NO-DEFAULT-PRODUCTION-TRADING-AUTOMATION-GUARD`, `GH-538-FORBIDDEN-PRODUCTION-CONFIG-DEFAULTS`, `GH-538-SECRET-ENDPOINT-GUARD-EVIDENCE`, `GH-538-DRYRUN-TESTNET-KILLSWITCH-BYPASS-GUARD`, `TVM-RELEASE-V010-NO-DEFAULT-PRODUCTION-TRADING-GUARD`, release contract, trading matrix, validation plan, domain language, latest summary and automation readiness docs.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No production secret read, print or storage.
  - No production endpoint, production broker endpoint, account endpoint, listenKey or private WebSocket connection.
  - No real Binance testnet network connection.
  - No broker connection, RiskEngine bypass, ExecutionEngine bypass, OMS bypass, kill switch bypass or no-trade bypass.
  - No real submit / cancel / replace.
  - No production order on failure, sandbox-to-production command promotion, automatic recovery, rollback command or broker emergency API.
  - No production trading.
  - No non-Binance venue.
  - No non-EMA active strategy.
- Validation:
  - `bash checks/automation-readiness.d/release-v010-no-default-production-trading.sh`: pass; output `MTPRO release v0.1.0 no-default-production-trading guard passed.`
  - `swift test --filter TargetGraphTests/testGH538NoDefaultProductionTradingGuardIsRequiredAutomationReadiness`: pass; 1 test / 0 failures.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true`, `dashboardReadModelOnly=true`, `releaseLiveMonitoringSurface=7`, `releaseCommandSurface=3` and `releaseKillSwitch=3`; 421 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-539 Release docs and operator runbook

- Issue: GH-539 `Add release docs and operator runbook`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #539 was OPEN with `mtpro / backlog / non-executable`; dependency #538 was CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #539 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/release/mtpro-release-v0.1.0-binance-ema-operator-runbook.md`.
  - Backfilled `GH-539-RELEASE-DOCS-OPERATOR-RUNBOOK`, `GH-539-DRYRUN-TESTNET-ACCEPTANCE-PROCEDURE`, `GH-539-CREDENTIAL-HANDLING-INSTRUCTIONS`, `GH-539-PRODUCTION-DISABLED-BOUNDARY`, `GH-539-ROLLBACK-NO-TRADE-PROCEDURE`, `TVM-RELEASE-V010-OPERATOR-RUNBOOK`, release contract, trading matrix, validation plan, domain language, latest summary and automation readiness docs.
  - Covered dry-run / testnet acceptance sequence, credential handling instructions, production disabled by default boundary, rollback / no-trade procedure and operator checklist for Binance + EMA release v0.1.0.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No runtime, adapter, OMS, broker gateway, Dashboard command runtime or order form implementation.
  - No production secret read, print, storage or derivation.
  - No production endpoint, production broker endpoint, account endpoint, listenKey or private WebSocket connection.
  - No real Binance testnet network connection.
  - No broker connection, RiskEngine bypass, ExecutionEngine bypass, OMS bypass, kill switch bypass or no-trade bypass.
  - No real submit / cancel / replace.
  - No production order on failure, sandbox-to-production command promotion, automatic recovery, rollback command or broker emergency API.
  - No production trading.
  - No non-Binance venue.
  - No non-EMA active strategy.
- Validation:
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO release v0.1.0 no-default-production-trading guard passed.` and `MTPRO automation readiness checks passed.`
  - `bash checks/release-v0.1.0-dryrun-testnet.sh`: pass; 1 test / 0 failures; final output `MTPRO release v0.1.0 dry-run/testnet validation suite passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true`, `dashboardReadModelOnly=true`, `releaseLiveMonitoringSurface=7`, `releaseCommandSurface=3` and `releaseKillSwitch=3`; 421 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-540 Validation matrix and stage audit input closeout

- Issue: GH-540 `Close release v0.1.0 validation matrix and stage audit input`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #540 was OPEN with `mtpro / backlog / non-executable`; dependencies #538 and #539 were CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #540 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/audit/inputs/mtpro-release-v0.1.0-binance-ema-runtime-stage-audit-input.md`.
  - Backfilled `GH-540-STAGE-AUDIT-INPUT`, `GH-540-ISSUE-PR-EVIDENCE-CHAIN`, `GH-540-VALIDATION-MATRIX-CLOSEOUT`, `GH-540-FORBIDDEN-PRODUCTION-CAPABILITY-AUDIT`, `GH-540-NO-FINAL-STAGE-CODE-AUDIT`, `TVM-RELEASE-V010-STAGE-AUDIT-INPUT-CLOSEOUT`, release contract, trading matrix, validation plan, domain language, latest summary and automation readiness docs.
  - Recorded PR #542 through #560 as merged with required check `checks` SUCCESS for GH-521 through GH-539.
  - Prepared GH-541 final Stage Code Audit / Root Docs Refresh input without outputting final Stage Code Audit Report in GH-540.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No final Stage Code Audit Report and no Root Docs Refresh in GH-540.
  - No runtime, adapter, OMS, broker gateway, Dashboard command runtime or order form implementation.
  - No production secret read, print, storage or derivation.
  - No production endpoint, production broker endpoint, account endpoint, listenKey or private WebSocket connection.
  - No real Binance testnet network connection.
  - No broker connection, RiskEngine bypass, ExecutionEngine bypass, OMS bypass, kill switch bypass or no-trade bypass.
  - No real submit / cancel / replace.
  - No production order on failure, sandbox-to-production command promotion, automatic recovery, rollback command or broker emergency API.
  - No production trading.
  - No non-Binance venue.
  - No non-EMA active strategy.
- Validation:
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO release v0.1.0 no-default-production-trading guard passed.` and `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; Dashboard smoke includes `readModelOnly=true`, `dashboardReadModelOnly=true`, `releaseLiveMonitoringSurface=7`, `releaseCommandSurface=3` and `releaseKillSwitch=3`; 421 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-08 - GH-541 Final Stage Code Audit and Root Docs Refresh

- Issue: GH-541 `Final Stage Code Audit and Root Docs Refresh`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #541 was OPEN with `mtpro / backlog / non-executable`; dependency #540 was CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #541 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/audit/mtpro-release-v0.1.0-binance-ema-runtime-stage-code-audit.md`.
  - Refreshed `GOAL.md`, `BLUEPRINT.md`, `docs/roadmap.md`, `docs/validation/latest-verification-summary.md` and this `verification.md` with completed release facts.
  - Added `Release v0.1.0 final Stage Code Audit and Root Docs Refresh anchor` to `docs/automation/automation-readiness.md`.
  - Added mechanical checks for the final Stage Code Audit Report, root docs refresh and verification evidence to `checks/automation-readiness.d/l4-boundary.sh`.
  - Confirmed release maturity statement: `MTPRO Release v0.1.0 Binance + EMA runtime validation complete with production trading disabled by default`.
- Evidence:
  - GH-521 through GH-541 belong to GitHub milestone `MTPRO Release v0.1.0`.
  - GH-521 through GH-540 were CLOSED / done before this #541 PR.
  - PR #542 through PR #561 were MERGED before this #541 PR, with required check `checks` SUCCESS.
  - #541 closure PR must pass required check `checks`, then be squash merged, and #541 must be CLOSED / done before final release closure result.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No new runtime, adapter, OMS, broker gateway, Dashboard command runtime or order form implementation.
  - No production secret read, print, storage or derivation.
  - No production endpoint, production broker endpoint, account endpoint, listenKey or private WebSocket connection.
  - No real Binance testnet network connection.
  - No broker connection, RiskEngine bypass, ExecutionEngine bypass, OMS bypass, kill switch bypass or no-trade bypass.
  - No real submit / cancel / replace.
  - No production order on failure, sandbox-to-production command promotion, automatic recovery, rollback command or broker emergency API.
  - No production trading.
  - No non-Binance venue.
  - No non-EMA active strategy.
  - No next Project / Issue creation and no release v0.1.0 post-stage promotion.
- Validation:
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass; output `MTPRO release v0.1.0 no-default-production-trading guard passed.` and `MTPRO automation readiness checks passed.`
  - `bash checks/run.sh`: pass; local Swift toolchain accepted as Apple Swift 6.3; release dry-run / testnet validation suite passed; Dashboard smoke includes `readModelOnly=true`, `dashboardReadModelOnly=true`, `releaseLiveMonitoringSurface=7`, `releaseCommandSurface=3` and `releaseKillSwitch=3`; 421 XCTest / 0 failures; final output `MTPRO checks passed.`

## 2026-06-13 - GH-709 Release v0.4.0 Final Stage Code Audit and release docs refresh

- Issue: GH-709 `V040-16 Close v0.4.0 stage audit and release docs`
- Queue:
  - GitHub fallback queue used because this release stage does not use Linear.
  - WIP=1 preflight passed before implementation: #709 was OPEN with `mtpro / backlog / non-executable`; dependencies #694 through #708 were CLOSED with `done`; no other open issue carried `todo`, `in-progress` or `in-review`; no open PR was present.
  - #709 was promoted to `todo`, then to `in-progress` after removing `backlog / non-executable`.
- Scope:
  - Added `docs/audit/mtpro-release-v0.4.0-unified-runtime-rehearsal-pipeline-stage-code-audit.md`.
  - Added `docs/release/mtpro-release-v0.4.0-unified-runtime-rehearsal-pipeline-notes.md`.
  - Refreshed `README.md`, `GOAL.md`, `docs/roadmap.md`, `docs/validation/latest-verification-summary.md` and this `verification.md` with completed release facts.
  - Added `GH-709-RELEASE-V040-FINAL-STAGE-AUDIT-RELEASE-DOCS` and `TVM-RELEASE-V040-FINAL-STAGE-AUDIT-RELEASE-DOCS` to validation plan, trading matrix, automation readiness and readiness script.
  - Confirmed release maturity statement: `MTPRO Release v0.4.0 Unified Runtime Rehearsal Pipeline complete with production trading disabled by default`.
- Evidence:
  - GH-694 through GH-709 belong to GitHub milestone `MTPRO Release v0.4.0 Unified Runtime Rehearsal Pipeline`.
  - GH-694 through GH-708 were CLOSED / done before this #709 PR.
  - PR #710 through PR #724 were MERGED before this #709 PR, with required check `checks` SUCCESS.
  - #709 closure PR must pass required check `checks`, then be squash merged, and #709 must be CLOSED / done before final release closure result.
- Boundary:
  - No Linear use.
  - No Symphony / `symphony-issue`.
  - No Graphify / code-index / Figma.
  - No new runtime, adapter, OMS, broker gateway, Dashboard command runtime or order form implementation.
  - No production secret read, print, storage or derivation.
  - No production endpoint, production broker endpoint, account endpoint, listenKey or private WebSocket connection.
  - No real Binance testnet network connection.
  - No broker connection, RiskEngine bypass, ExecutionEngine bypass, OMS bypass, kill switch bypass or no-trade bypass.
  - No real submit / cancel / replace.
  - No production order on failure, sandbox-to-production command promotion, automatic recovery, rollback command or broker emergency API.
  - No production trading.
  - No non-Binance venue.
  - No non-Spot / non-USDSM active product.
  - No non-EMA / non-RSI active strategy.
  - No next Project / Issue creation and no release v0.4.0 post-stage promotion.
- Validation:
  - `swift test --filter TargetGraphTests/testGH709ReleaseV040StageAuditAndReleaseDocsCloseCompletedFactsOnly`: required focused closure guard.
  - `bash checks/verify-v0.4.0.sh`: required release validation suite.
  - `git diff --check`: required whitespace validation.
  - `bash checks/automation-readiness.sh`: required readiness validation.
  - `bash checks/run.sh`: required full local validation.

## 2026-06-18 - v0.9.0 Release Publication Fact Audit Fix

- Executor: Codex.
- Scope:
  - Audited the already-published stable GitHub Release `v0.9.0`.
  - Confirmed release URL: `https://github.com/atxinbao/MTPRO/releases/tag/v0.9.0`.
  - Confirmed tag peeled commit: `4296bf73673fe0fd8f09e34c40ef2a3a9ba7e55c`.
  - Updated root/release/validation docs so v0.9.0 is no longer described as publication-pending.
  - Added v0.9.0 publication-fact guards to `checks/verify-v0.9.0.sh` and `TargetGraphTests/testGH856ReleaseV090FinalAuditDocsRunbookCloseCompletedFactsOnly`.
- Boundary:
  - Did not move or rewrite the existing `v0.9.0` tag or GitHub Release.
  - Did not create a new Project or Issue.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
- Validation:
  - `bash checks/verify-v0.9.0.sh`: pass.
  - `swift test --filter TargetGraphTests/testGH856ReleaseV090FinalAuditDocsRunbookCloseCompletedFactsOnly`: pass.

## 2026-06-18 - v0.9.1 v0.9.0 Audit Hardening Patch

- Executor: Codex.
- Scope:
  - Fixed v0.9.0 audit findings without moving or rewriting the existing `v0.9.0` tag or GitHub Release.
  - Added Dashboard macOS v0.9 focused guard coverage before Dashboard build / smoke.
  - Updated `mtpro verify` wording to current `v0.9.0` release facts while retaining historical v0.8 / v0.7 evidence.
  - Bound monitor CLI actions to `ReleaseV090TestnetReadOnlyMonitorSessionStore` evidence instead of pure placeholder output.
  - Standardized current runtime mode wording to `testnet-read-only-monitor` while keeping `testnet-read-only-probe` as legacy.
  - Added v0.9.1 patch audit notes, release notes, aggregate verification script, and automation readiness anchors.
- Boundary:
  - Did not create a `v0.9.1` tag or GitHub Release.
  - Did not create a new Project or Issue.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
  - Did not add trading buttons, order forms, OMS production commands, or broker submission paths.
- Validation:
  - `bash checks/verify-v0.9.1-dashboard-macos-v090-guards.sh`: required Dashboard macOS v0.9 focused guard.
  - `bash checks/verify-v0.9.1-cli-verify-v090-wording.sh`: required CLI verify v0.9.0 wording guard.
  - `swift test --filter TargetGraphTests/testV091DashboardGuardAndCLIMonitorStoreBindingPatch`: required focused patch guard.
  - `bash checks/verify-v0.9.1.sh`: required aggregate v0.9.1 patch validation.
  - `git diff --check`: required whitespace validation.
  - `bash checks/automation-readiness.sh`: required readiness validation.
  - `bash checks/run.sh`: required full local validation.

## 2026-06-18 - v0.10.1 Production Readiness Audit Hardening Patch Closeout

- Executor: Codex.
- Scope:
  - Closed the #912 patch audit, release notes and aggregate verification contract for `v0.10.1`.
  - Added `docs/audit/mtpro-release-v0.10.1-production-readiness-audit-hardening-patch-stage-code-audit.md`.
  - Added `docs/release/mtpro-release-v0.10.1-production-readiness-audit-hardening-patch-notes.md`.
  - Added `checks/verify-v0.10.1.sh` and wired it into `checks/run.sh`.
  - Added the focused guard `TargetGraphTests/testGH912ReleaseV0101PatchAuditReleaseNotesCloseout`.
  - Carried #907 through #911 completion evidence and PR #926 through PR #930 checks / merge evidence into the v0.10.1 audit trail.
  - Recorded that v0.11.0 owns real readiness artifact runtime and integrity hardening.
- Boundary:
  - Did not create a `v0.10.1` tag or GitHub Release.
  - Did not create a new Project or Issue.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
  - Did not implement `ProductionReadinessArtifactStore`, readiness artifact write runtime, signed endpoint runtime, OMS runtime, broker adapter, trading button, order form, or live command path.
- Validation:
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass.
  - `bash checks/verify-v0.10.0.sh`: pass.
  - `bash checks/verify-v0.10.1.sh`: pass.
  - `bash checks/run.sh`: pass, 596 tests / 0 failures.

## 2026-06-18 - GH-913 v0.11.0 Production Readiness Evidence Runtime Contract

- Executor: Codex.
- Scope:
  - Defined `docs/contracts/release-v0.11.0-production-readiness-evidence-runtime-contract.md`.
  - Added `checks/verify-v0.11.0.sh` and wired it into `checks/run.sh`.
  - Added automation readiness, validation plan, trading validation matrix, latest summary and TargetGraph anchors for `GH-913-VERIFY-V0110-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT`.
  - Fixed V0110 queue order as `GH-913..GH-924`.
  - Defined local readiness artifact lifecycle, runtime states, manifest requirements, SHA256 checksum rules, allowed local readiness commands, Dashboard / CLI / policy / kill switch / approval workflow / shadow parity boundaries and forbidden production capability flags.
- Boundary:
  - Did not create a `v0.11.0` tag or GitHub Release.
  - Did not create a new Project or Issue.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
  - Did not implement artifact writing, `ProductionReadinessArtifactStore`, production OMS, trading button, order form or live command path.
- Validation:
  - `swift test --filter TargetGraphTests/testGH913ReleaseV0110ProductionReadinessEvidenceRuntimeContract`: pass.
  - `bash checks/verify-v0.11.0.sh`: pass.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass.
  - `bash checks/verify-v0.10.0.sh`: pass.
  - `bash checks/run.sh`: pass, 597 tests / 0 failures.

## 2026-06-18 - GH-914 v0.11.0 Production Readiness Artifact Store

- Executor: Codex.
- Scope:
  - Implemented `Sources/ExecutionClient/FutureGate/ReleaseV0110ProductionReadinessArtifactStore.swift`.
  - Added `ProductionReadinessArtifactStore`, `ProductionReadinessArtifactDescriptor`, `ProductionReadinessArtifactRecord`, `ProductionReadinessArtifactStoreSnapshot` and explicit `ProductionReadinessArtifactState` values: `missing`, `invalid`, `stale`, `valid`.
  - Bound the store to approved local file evidence roots with default `.local/mtpro/readiness/v0.11.0`.
  - Added safe relative path validation, local JSON / text read-write primitives and forbidden production capability rejection.
  - Added `GH-914-VERIFY-V0110-PRODUCTION-READINESS-ARTIFACT-STORE` anchors to the v0.11.0 contract, automation readiness, validation plan, trading validation matrix, latest summary, verifier and TargetGraph focused test.
- Boundary:
  - Did not create a `v0.11.0` tag or GitHub Release.
  - Did not create a new Project or Issue.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
  - Did not implement manifest schema, atomic manifest write order, canonical JSON SHA256, Dashboard real artifact binding, CLI runtime, approval transition or shadow parity runner.
  - Did not add production OMS, trading button, order form or live command path.
- Validation:
  - `swift test --filter TargetGraphTests/testGH914ProductionReadinessArtifactStoreUsesLocalExplicitStates`: pass.
  - `bash checks/verify-v0.11.0.sh`: pass.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass.
  - `bash checks/verify-v0.10.0.sh`: pass.
  - `bash checks/run.sh`: pass, 598 tests / 0 failures.

## 2026-06-18 - GH-915 v0.11.0 Readiness Manifest Atomic IO

- Executor: Codex.
- Scope:
  - Extended `Sources/ExecutionClient/FutureGate/ReleaseV0110ProductionReadinessArtifactStore.swift`.
  - Added `ProductionReadinessManifestEntry`, `ProductionReadinessManifest`, `ProductionReadinessManifestReadResult`, manifest read/write/validate methods and deterministic local checksum support.
  - Added atomic JSON manifest writing, policyVersion validation, manifest entry state validation and real artifact size/checksum/state revalidation.
  - Added `GH-915-VERIFY-V0110-READINESS-MANIFEST-ATOMIC-IO` anchors to the v0.11.0 contract, automation readiness, validation plan, trading validation matrix, latest summary, verifier and TargetGraph focused test.
- Boundary:
  - Did not create a `v0.11.0` tag or GitHub Release.
  - Did not create a new Project or Issue.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
  - Did not implement canonical JSON SHA256, Dashboard real artifact binding, CLI runtime, approval transition or shadow parity runner.
  - Did not add production OMS, trading button, order form or live command path.
- Validation:
  - `swift test --filter TargetGraphTests/testGH915ReadinessManifestSchemaAndAtomicIORequireRealArtifacts`: pass.
  - `bash checks/verify-v0.11.0.sh`: pass.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass.
  - `bash checks/verify-v0.10.0.sh`: pass.
  - `bash checks/run.sh`: pass, 599 tests / 0 failures.

## 2026-06-18 - GH-916 v0.11.0 Canonical JSON SHA256 Checksum

- Executor: Codex.
- Scope:
  - Updated `Sources/ExecutionClient/FutureGate/ReleaseV0110ProductionReadinessArtifactStore.swift`.
  - Added `ProductionReadinessCanonicalChecksumAnchors`, canonical JSON byte normalization, `sha256:<64 hex>` checksum generation and checksum format validation.
  - Replaced manifest entry checksum generation and validation with canonical JSON SHA256 and fail-closed invalid checksum / mismatch states.
  - Added `swift-crypto` to the `ExecutionClient` target for SHA256 hashing.
  - Added `GH-916-VERIFY-V0110-CANONICAL-JSON-SHA256-CHECKSUM` anchors to the v0.11.0 contract, automation readiness, validation plan, trading validation matrix, latest summary, verifier and TargetGraph focused test.
- Boundary:
  - Did not create a `v0.11.0` tag or GitHub Release.
  - Did not create a new Project or Issue.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
  - Did not implement readiness bundle validation, Dashboard real artifact binding, CLI runtime, approval transition or shadow parity runner.
  - Did not add production OMS, trading button, order form or live command path.
- Validation:
  - `swift test --filter TargetGraphTests/testGH916CanonicalJSONSHA256RejectsPlaceholderAndMismatchChecksums`: pass.
  - `swift test`: pass, 600 tests / 0 failures.
  - `bash checks/verify-v0.11.0.sh`: pass.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass.
  - `bash checks/verify-v0.10.0.sh`: pass.
  - `bash checks/run.sh`: pass, 600 tests / 0 failures.

## 2026-06-18 - GH-917 v0.11.0 Readiness Bundle Validation

- Executor: Codex.
- Scope:
  - Updated `Sources/ExecutionClient/FutureGate/ReleaseV0110ProductionReadinessArtifactStore.swift`.
  - Added `ProductionReadinessBundleValidationAnchors`, `ProductionReadinessBundleValidationState`, `ProductionReadinessBundleValidationResult`, explicit not-evaluated state and local `validateReadinessBundle(...)`.
  - Bundle validation now rechecks manifest schema, required artifact set, artifact existence, canonical JSON SHA256 checksum, size, timestamp and policyVersion.
  - Added `GH-917-VERIFY-V0110-READINESS-BUNDLE-VALIDATION` anchors to the v0.11.0 contract, automation readiness, validation plan, trading validation matrix, latest summary, verifier and TargetGraph focused test.
- Boundary:
  - Did not create a `v0.11.0` tag or GitHub Release.
  - Did not create a new Project or Issue.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
  - Did not implement Dashboard real artifact binding, CLI runtime, approval transition or shadow parity runner.
  - Did not add production OMS, trading button, order form or live command path.
- Validation:
  - `swift test --filter TargetGraphTests/testGH917ReadinessBundleValidationClassifiesRequiredArtifactsPolicyAndChecksum`: pass.
  - `bash checks/verify-v0.11.0.sh`: pass.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass.
  - `bash checks/verify-v0.10.0.sh`: pass.
  - `bash checks/run.sh`: pass, 601 tests / 0 failures.

## 2026-06-18 - GH-918 v0.11.0 Shadow Dry-run Parity Runner

- Executor: Codex.
- Scope:
  - Updated `Sources/ExecutionClient/FutureGate/ReleaseV0110ProductionReadinessArtifactStore.swift`.
  - Added `ProductionReadinessShadowDryRunParityRunnerAnchors`, local evidence input kinds, evidence summaries, `ProductionReadinessShadowDryRunParityArtifact`, run result bundling and `writeShadowDryRunParityArtifact(...)`.
  - The runner consumes local run evidence descriptors for `events.jsonl`, strategy intents, risk decisions, OMS dry-run events, portfolio projection and reconciliation timeline, then writes `shadow_dry_run_parity.json` through the artifact store, manifest and bundle validation pipeline.
  - Missing evidence now returns blocked state; marker/checksum/staleness/incomplete evidence returns invalid state; valid evidence records source checksums and keeps `derivedFromLocalRunEvidence=true` with `referenceOnlyStageConstantsUsed=false`.
  - Added `GH-918-VERIFY-V0110-SHADOW-DRY-RUN-PARITY-RUNNER` anchors to the v0.11.0 contract, automation readiness, validation plan, trading validation matrix, latest summary, verifier and TargetGraph focused test.
- Boundary:
  - Did not create a `v0.11.0` tag or GitHub Release.
  - Did not create a new Project or Issue.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
  - Did not implement Dashboard real artifact binding, CLI runtime, approval transition, production OMS, trading button, order form or live command path.
- Validation:
  - `swift test --filter TargetGraphTests/testGH918ShadowDryRunParityRunnerBuildsArtifactFromLocalRunEvidence`: pass.
  - `bash checks/verify-v0.11.0.sh`: pass.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass.
  - `bash checks/run.sh`: pass, 602 tests / 0 failures.

## 2026-06-18 - GH-919 v0.11.0 Dashboard Real Artifact State

- Executor: Codex.
- Scope:
  - Updated `Sources/Dashboard/Report/ReleaseV0100DashboardProductionReadinessCenter.swift`.
  - Added Dashboard-local artifact state inputs for readiness manifest and bundle validation JSON, covering `not-evaluated`, `valid`, `blocked`, `stale`, `missing`, `invalid` and `checksum-mismatch`.
  - Bound Production Readiness Center cards to local artifact evidence existence, checksum match state and bundle validation reason instead of static fixture-only evidence.
  - Kept the default Dashboard fixture at `local-artifact-state-not-evaluated` so missing local artifacts do not imply readiness.
  - Added `GH-919-VERIFY-V0110-DASHBOARD-REAL-ARTIFACT-STATE` anchors to the v0.11.0 contract, automation readiness, validation plan, trading validation matrix, latest summary, verifier, AppTests and TargetGraph focused test.
- Boundary:
  - Did not create a `v0.11.0` tag or GitHub Release.
  - Did not create a new Project or Issue.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
  - Did not implement CLI runtime, approval transition, production OMS, trading button, order form or live command path.
- Validation:
  - `swift test --filter AppTests/testGH919DashboardProductionReadinessCenterBindsRealLocalArtifactStatesReadOnly`: pass.
  - `swift test --filter TargetGraphTests/testGH919DashboardProductionReadinessCenterBindsRealArtifactStateAnchors`: pass.
  - `bash checks/verify-v0.11.0.sh`: pass.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass.
  - `bash checks/run.sh`: pass, 604 tests / 0 failures.

## 2026-06-18 - GH-920 v0.11.0 Readiness CLI Local Artifact Commands

- Executor: Codex.
- Scope:
  - Updated `Sources/MTPROCLI/main.swift`.
  - Added `mtpro readiness build`, `status`, `validate`, `export` and `approval-status` runtime commands backed by the local `ProductionReadinessArtifactStore`.
  - Added explicit local artifact states for build/status/validate/export output, including missing, invalid, stale, blocked and checksum mismatch handling.
  - Retired the v0.10.1 readiness placeholder help contract in favor of the v0.11.0 local artifact command contract.
  - Added a narrow `MTPROCLI -> ExecutionClient` dependency exception for the local readiness artifact store only; CLI remains outside broker, OMS, production endpoint and live command paths.
  - Added `GH-920-VERIFY-V0110-READINESS-CLI-LOCAL-ARTIFACTS` anchors to the v0.11.0 contract, automation readiness, validation plan, trading validation matrix, latest summary, verifier and TargetGraph focused test.
- Boundary:
  - Did not create a `v0.11.0` tag or GitHub Release.
  - Did not create a new Project or Issue.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
  - Did not implement approval transition, production OMS, trading button, order form or live command path.
  - `approval-status` reports approval evidence only; it does not convert approval evidence into trading permission.
- Validation:
  - `swift build --product mtpro`: pass.
  - `swift test --filter TargetGraphTests/testGH910ReadinessCLIHelpPlaceholderIsNonMutatingAndFailsClosed`: pass.
  - `swift test --filter TargetGraphTests/testGH920ReadinessCLIOperatesOnLocalArtifactsWithoutProductionCapabilities`: pass.
  - `bash checks/verify-v0.10.1-readiness-cli-help.sh`: pass.
  - `bash checks/verify-v0.11.0.sh`: pass.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass.
  - `bash checks/run.sh`: pass, 605 tests / 0 failures.

## 2026-06-19 - GH-921 v0.11.0 Fixed-point Capital / Exposure Policy

- Executor: Codex.
- Scope:
  - Updated `Sources/ExecutionClient/FutureGate/ReleaseV0100CapitalExposureLimitReadinessGate.swift`.
  - Added `ReleaseV0110FixedPointPolicyValue` and `ReleaseV0110FixedPointPolicyUnit` so capital, notional, exposure, daily loss and leverage policy values are typed fixed-point values with explicit `minorUnits`, `scale` and `unit`.
  - Replaced string-only readiness policy comparisons with unit-safe and scale-safe fixed-point comparisons for max capital, max notional, single-order notional, symbol exposure, product exposure, daily loss and leverage.
  - Bound the risk policy identity to explicit policy hash inputs derived from the typed fixed-point values, preventing stale string-only policy fixtures from passing readiness.
  - Added `GH-921-VERIFY-V0110-FIXED-POINT-CAPITAL-EXPOSURE-POLICY` anchors to the v0.11.0 contract, automation readiness, validation plan, trading validation matrix, latest summary, verifier and TargetGraph focused test.
- Boundary:
  - Did not create a `v0.11.0` tag or GitHub Release.
  - Did not create a new Project or Issue.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
  - Did not implement approval transition, production OMS, trading button, order form or live command path.
  - Policy evidence remains local readiness evidence only; it does not grant production trading permission.
- Validation:
  - `swift test --filter TargetGraphTests/testGH400TryBangPreconditionFailureAndFatalErrorStayInAllowedConstructs`: pass.
  - `swift test --filter TargetGraphTests/testGH883CapitalExposureLimitReadinessGateBindsRiskPolicyAndDisablesOrders`: pass.
  - `swift test --filter TargetGraphTests/testGH921CapitalExposureReadinessUsesFixedPointPolicyValuesAndSafeComparisons`: pass.
  - `bash checks/verify-v0.10.0.sh`: pass.
  - `bash checks/verify-v0.11.0.sh`: pass.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass.
  - `bash checks/run.sh`: pass, 606 tests / 0 failures.

## 2026-06-19 - GH-922 v0.11.0 Kill Switch / No-trade State Model

- Executor: Codex.
- Scope:
  - Updated `Sources/ExecutionClient/FutureGate/ReleaseV0100KillSwitchNoTradeReadinessGate.swift`.
  - Expanded kill switch / no-trade readiness state from active-only evidence to explicit `active`, `inactive`, `unknown`, `stale` and `unavailable` states.
  - Added freshness and review evidence states so `unknown`, `stale`, `unavailable`, non-fresh or non-reviewed evidence fails closed.
  - Added `ReleaseV0110KillSwitchNoTradeReadinessStateModel` and fixtures proving that only inactive + fresh + reviewed can enter approval-request eligibility.
  - Added `GH-922-VERIFY-V0110-KILL-SWITCH-NO-TRADE-STATE-MODEL` anchors to the v0.11.0 contract, automation readiness, validation plan, trading validation matrix, latest summary, verifier, artifact anchor store and TargetGraph focused test.
- Boundary:
  - Did not create a `v0.11.0` tag or GitHub Release.
  - Did not create a new Project or Issue.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
  - Did not implement approval transition, production OMS, trading button, order form or live command path.
  - Approval-request eligibility remains local readiness evidence only; it does not grant production trading permission.
- Validation:
  - `swift test --filter TargetGraphTests/testGH922KillSwitchNoTradeStateModelFailsClosedAndOnlyAllowsApprovalRequestEligibility`: pass.
  - `swift test --filter TargetGraphTests/testGH884KillSwitchNoTradeReadinessGateBlocksCutoverAndOrders`: pass.
  - `bash checks/verify-v0.11.0.sh`: pass.
  - `bash checks/verify-v0.10.0.sh`: pass.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass.
  - `bash checks/run.sh`: pass, 607 tests / 0 failures.

## 2026-06-19 - GH-923 v0.11.0 Auditable Approval Workflow Transitions

- Executor: Codex.
- Scope:
  - Added `Sources/ExecutionClient/FutureGate/ReleaseV0110AuditableApprovalWorkflow.swift`.
  - Added `ReleaseV0110AuditableApprovalWorkflowStateModel`, `ReleaseV0110ApprovalWorkflowState`, `ReleaseV0110ApprovalWorkflowTransition` and actor references for requested / reviewed / approved approval workflow evidence.
  - Defined the local-only approval transition graph: not requested -> requested -> reviewing -> approved / rejected, with explicit expired and revoked fail-closed exits.
  - Added quorum, expiry, revocation reason, transition contiguity, timestamp monotonicity and duplicate reviewer validation.
  - Added `approval_workflow_transitions.json` as a local readiness artifact written through `ProductionReadinessArtifactStore`.
  - Added `GH-923-VERIFY-V0110-AUDITABLE-APPROVAL-WORKFLOW-TRANSITIONS` anchors to the v0.11.0 contract, automation readiness, validation plan, trading validation matrix, latest summary, verifier and TargetGraph focused test.
- Boundary:
  - Did not create a `v0.11.0` tag or GitHub Release.
  - Did not create a new Project or Issue.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
  - Did not implement production OMS, trading button, order form or live command path.
  - Approval workflow evidence remains local readiness evidence only; approved evidence does not convert into trading permission.
- Validation:
  - `swift test --filter TargetGraphTests/testGH923AuditableApprovalWorkflowTransitionsFailClosedAndExportLocalEvidence`: pass.
  - `bash checks/verify-v0.11.0.sh`: pass.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass.
  - `bash checks/run.sh`: pass, 608 tests / 0 failures.

## 2026-06-19 - GH-924 v0.11.0 Final Audit / Release Docs Closeout

- Executor: Codex.
- Scope:
  - Added `docs/audit/mtpro-release-v0.11.0-production-readiness-evidence-runtime-integrity-hardening-stage-code-audit.md`.
  - Added `docs/release/mtpro-release-v0.11.0-production-readiness-evidence-runtime-integrity-hardening-notes.md`.
  - Updated root docs and compressed validation entries for `MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening`.
  - Added `GH-924-VERIFY-V0110-FINAL-AUDIT-RELEASE-DOCS` anchors to automation readiness, validation plan, trading validation matrix, latest summary, verifier and TargetGraph focused test.
  - Extended `checks/verify-v0.11.0.sh` to require #924 audit / release docs / root docs refresh evidence and run `testGH924ReleaseV0110FinalAuditReleaseDocsCloseout`.
- Boundary:
  - Did not create a `v0.11.0` tag or GitHub Release.
  - Did not create a new Project or Issue.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
  - Did not implement new runtime, production OMS, trading button, order form or live command path.
  - Approval workflow evidence remains local readiness evidence only; approved evidence does not convert into trading permission.
- Validation:
  - `swift test --filter TargetGraphTests/testGH924ReleaseV0110FinalAuditReleaseDocsCloseout`: pass.
  - `bash checks/verify-v0.11.0.sh`: pass.
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass.
  - `bash checks/verify-v0.10.0.sh`: pass; required because this PR refreshed root docs carrying v0.10.x historical guards.
  - `bash checks/run.sh`: pass, 609 tests / 0 failures.

## 2026-06-27 - Target Venue / Product Goal Revision

- Executor: Codex.
- Scope:
  - Updated `GOAL.md`, `BLUEPRINT.md`, `README.md`, `architecture.md`, `docs/roadmap.md`, and `docs/validation/latest-verification-summary.md`.
  - Reframed MTPRO as a local-first, macOS-native, evidence-first live-native trading system.
  - Clarified the long-term target venue / product matrix: Binance Spot, Binance USDⓈ-M Futures, OKX Spot, and OKX Swap.
  - Recorded Bybit Spot / Linear Perpetual as future candidates only, not part of the current active commitment.
  - Updated automation readiness wording guards so future root-doc edits must preserve the Binance / OKX target matrix.
- Boundary:
  - Did not change business code, `Package.swift`, SwiftPM targets, or `Sources`.
  - Did not add OKX, Binance futures, Bybit, or new venue runtime implementation.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
  - Production trading remains explicit-gate only and default-off.
- Validation:
  - `git diff --check`: pass.
  - `bash checks/automation-readiness.sh`: pass.
  - `bash checks/run.sh`: pass, 725 tests / 0 failures.

## 2026-06-29 - GH-1215 v0.19.0 Stage Audit / Release Docs Closeout

- Executor: Codex.
- Scope:
  - Added `docs/audit/mtpro-release-v0.19.0-venue-product-registry-runtime-adapter-foundation-stage-code-audit.md`.
  - Added `docs/release/mtpro-release-v0.19.0-venue-product-registry-runtime-adapter-foundation-notes.md`.
  - Added `GH-1215-VERIFY-V0190-STAGE-AUDIT-RELEASE-DOCS`, `TVM-RELEASE-V0190-STAGE-AUDIT-RELEASE-DOCS`, `V0190-010-STAGE-CODE-AUDIT`, `V0190-010-RELEASE-NOTES`, `V0190-010-VALIDATION-MATRIX`, `V0190-010-ROOT-DOCS-REFRESH`, `V0190-010-STALE-WORDING-GUARD`, `V0190-010-NO-PRODUCTION-CUTOVER` and `V0190-010-NO-TAG-OR-RELEASE-PUBLICATION` anchors to root docs, automation readiness, validation plan, trading validation matrix, latest summary, release publication policy, focused verifier and TargetGraph focused test.
  - Recorded #1206..#1215 construction closeout, PR #1222..#1230 merge/check evidence and v0.19.0 release docs handoff.
- Boundary:
  - Did not create a `v0.19.0` tag or GitHub Release.
  - Did not create a new Project or Issue.
  - Did not promote a next Todo.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
  - Did not implement new runtime, production OMS, trading button, order form or live command path.
- Validation:
  - `swift test --filter TargetGraphTests/testGH1215ReleaseV0190StageAuditReleaseDocsCloseout`: required focused test.
  - `bash checks/verify-v0.19.0-stage-audit-release-docs.sh`: required focused verifier.
  - `git diff --check`: required.
  - `bash checks/automation-readiness.sh`: required.
  - `bash checks/run.sh`: required.

## 2026-06-29 - GH-1233 v0.19.1 v0.19.0 Historical Closeout Wording Guard

- Executor: Codex.
- Scope:
  - Added `GH-1233-VERIFY-V0191-V0190-HISTORICAL-CLOSEOUT-WORDING`, `V0191-002-V0190-HISTORICAL-CLOSEOUT-WORDING-GUARD`, `TVM-RELEASE-V0191-V0190-HISTORICAL-CLOSEOUT-WORDING`, `V0191-002-CONSTRUCTION-CLOSEOUT-HISTORICAL`, `V0191-002-CURRENT-RELEASE-PUBLISHED` and `V0191-002-NO-PRODUCTION-CUTOVER`.
  - Reframed #1215 no-tag / no-release wording as historical construction closeout evidence in root docs, release notes, Stage Code Audit and release publication policy.
  - Preserved current v0.19.0 stable GitHub Release fact: `https://github.com/atxinbao/MTPRO/releases/tag/v0.19.0`, tag peeled commit `53e9b1e81db075ef464b74f8f35c66ebd61ea03c`, publication timestamp `2026-06-29T13:42:34Z`.
- Boundary:
  - Did not move `v0.19.0` tag.
  - Did not overwrite GitHub Release.
  - Did not create v0.19.1 tag / GitHub Release.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
- Validation:
  - `swift test --filter TargetGraphTests/testGH1233ReleaseV0191V0190HistoricalCloseoutWordingGuard`: required focused test.
  - `bash checks/verify-v0.19.1-v0190-historical-closeout-wording.sh`: required focused verifier.
  - `git diff --check`: required.
  - `bash checks/automation-readiness.sh`: required.
  - `bash checks/run.sh`: required.

## 2026-06-29 - GH-1234 v0.19.1 v0.19.0 Stale Wording Guard

- Executor: Codex.
- Scope:
  - Added `GH-1234-VERIFY-V0191-V0190-STALE-WORDING-GUARD`, `V0191-003-V0190-STALE-WORDING-GUARD`, `V0191-003-HISTORICAL-CONSTRUCTION-CLOSEOUT-ALLOWLIST`, `TVM-RELEASE-V0191-V0190-STALE-WORDING-GUARD`, `V0191-003-CURRENT-FACING-STALE-WORDING-REJECTION` and `V0191-003-NO-PRODUCTION-CUTOVER`.
  - Added `checks/verify-v0.19.1-v0190-stale-wording-guard.sh` to reject current-facing stale v0.19.0 publication wording while allowing historical construction closeout evidence only with current release facts.
  - Preserved current v0.19.0 stable GitHub Release fact: `https://github.com/atxinbao/MTPRO/releases/tag/v0.19.0`, tag peeled commit `53e9b1e81db075ef464b74f8f35c66ebd61ea03c`, publication timestamp `2026-06-29T13:42:34Z`.
- Boundary:
  - Did not move `v0.19.0` tag.
  - Did not overwrite GitHub Release.
  - Did not create v0.19.1 tag / GitHub Release.
  - Did not authorize production cutover.
  - Did not read production secrets, connect production endpoints or broker endpoints, or send orders.
- Validation:
  - `swift test --filter TargetGraphTests/testGH1234ReleaseV0191V0190StaleWordingGuardRejectsCurrentFacingDrift`: required focused test.
  - `bash checks/verify-v0.19.1-v0190-stale-wording-guard.sh`: required focused verifier.
  - `git diff --check`: required.
  - `bash checks/automation-readiness.sh`: required.
  - `bash checks/run.sh`: required.

## 2026-06-29 - Target Mainline v0.20-v0.25 Route Anchor

- Executor: Codex.
- Scope:
  - Fixed the current target mainline in `README.md`, `GOAL.md`, `BLUEPRINT.md`, `docs/roadmap.md`, `docs/validation/latest-verification-summary.md`, and `docs/automation/automation-readiness.md`.
  - Recorded the approved route: v0.19.1 release fact / stale wording patch -> v0.20.0 Binance Spot production-shadow / read-only live readiness -> v0.21.0 Binance Spot controlled production canary -> v0.22.0 Binance USDⓈ-M Futures read-only foundation -> v0.23.0 Binance USDⓈ-M Futures testnet execution closed loop -> v0.24.0 Spot + Futures unified OMS / Portfolio / Risk / Reconciliation -> v0.25.0 Binance dual-product production readiness / canary hardening.
  - Added `checks/automation-readiness.sh` guards so future root-doc edits must preserve the fixed v0.20-v0.25 route and Binance-first dual-product sequencing.
- Boundary:
  - Did not change business code, `Package.swift`, SwiftPM targets, or `Sources`.
  - Did not create OKX active source, Binance futures runtime, production endpoint connection, broker endpoint connection, or real order path.
  - Did not authorize production cutover.
  - v0.20.0 remains no-order read-only / production-shadow; v0.21.0 is the first Spot controlled canary gate; Futures starts at v0.22.0 read-only foundation.
- Validation:
  - `git diff --check`: required.
  - `bash checks/automation-readiness.sh`: required.
  - `bash checks/run.sh`: required.

## 2026-07-05 - MTPRO Release v0.22.0 Aggregate Validation Suite

- Executor: Codex.
- Scope:
  - Added `checks/verify-v0.22.0.sh`.
  - Added `GH-1319-VERIFY-V0220-AGGREGATE-VALIDATION`, `TVM-RELEASE-V0220-AGGREGATE-VALIDATION`, `V0220-011-AGGREGATE-VALIDATION-SUITE`, `V0220-011-LIVE-CANARY-TRANSPORT-CHAIN`, `V0220-011-FOCUSED-GUARDS-COVERED`, `V0220-011-RUN-AUTOMATION-WIRING`, `V0220-011-FAIL-CLOSED-NEGATIVE-CASES`, `V0220-011-NO-FUTURES-OKX`, `V0220-011-NO-PRODUCTION-CUTOVER` and `V0220-011-NO-TAG-OR-RELEASE-PUBLICATION`.
  - Wired `bash checks/verify-v0.22.0.sh` into `checks/run.sh`.
  - Required the aggregate suite from `checks/automation-readiness.sh`.
- Boundary:
  - Did not add Futures or OKX active runtime.
  - Did not add Dashboard trading controls.
  - Did not authorize production cutover.
  - Did not create a tag or GitHub Release.
- Validation:
  - `bash checks/verify-v0.22.0.sh`: required.
  - `swift test --filter TargetGraphTests/testGH1319ReleaseV0220AggregateValidationSuite`: required.
  - `git diff --check`: required.
  - `bash checks/automation-readiness.sh`: required.
  - `bash checks/verify-v0.21.0.sh`: required.
  - `bash checks/run.sh`: required.
## 2026-07-06 - MTPRO Release v0.22.0 Stage Audit / Release Docs Closeout

- Executor: Codex.
- Scope:
  - Added `docs/audit/mtpro-release-v0.22.0-binance-spot-live-canary-transport-completion-stage-code-audit.md`.
  - Added `docs/release/mtpro-release-v0.22.0-binance-spot-live-canary-transport-completion-notes.md`.
  - Added `checks/verify-v0.22.0-stage-audit-release-docs.sh`.
  - Added `GH-1320-VERIFY-V0220-STAGE-AUDIT-RELEASE-DOCS`, `TVM-RELEASE-V0220-STAGE-AUDIT-RELEASE-DOCS`, `V0220-012-STAGE-CODE-AUDIT`, `V0220-012-RELEASE-NOTES`, `V0220-012-VALIDATION-MATRIX`, `V0220-012-ROOT-DOCS-REFRESH`, `V0220-012-STALE-WORDING-GUARD`, `V0220-012-RELEASE-PUBLICATION-GATE-HANDOFF`, `V0220-012-NO-PRODUCTION-CUTOVER`, `V0220-012-NO-TAG-OR-RELEASE-PUBLICATION`, `V0220-012-NO-FUTURES-OKX` and `V0220-012-NO-DASHBOARD-TRADING-CONTROLS`.
  - Wired `bash checks/verify-v0.22.0-stage-audit-release-docs.sh` into `checks/run.sh`.
- Boundary:
  - Did not add Futures or OKX active runtime.
  - Did not add Dashboard trading controls.
  - Did not authorize production cutover.
  - Did not create a tag or GitHub Release.
- Validation:
  - `swift test --filter TargetGraphTests/testGH1320ReleaseV0220StageAuditReleaseDocsCloseout`: required.
  - `bash checks/verify-v0.22.0-stage-audit-release-docs.sh`: required.
  - `git diff --check`: required.
  - `bash checks/automation-readiness.sh`: required.
  - `bash checks/verify-v0.21.0.sh`: required.
  - `bash checks/verify-v0.22.0.sh`: required.
  - `bash checks/run.sh`: required.

## MTPRO Release v0.22.1 Publication Fact Sync Patch

- GH-1337-VERIFY-V0221-V0220-RELEASE-FACT-SYNC
- TVM-RELEASE-V0221-V0220-RELEASE-FACT-SYNC
- V0221-001-V0220-RELEASE-FACT-SYNC
- GH-1338-VERIFY-V0221-V0220-STALE-WORDING-GUARD
- V0221-002-V0220-STALE-WORDING-GUARD
- GH-1339-VERIFY-V0221-VERSION-ROADMAP-CORRECTION
- V0221-003-V0220-SPOT-LIVE-CANARY-TRANSPORT
- V0221-003-V0230-FUTURES-READONLY-NEXT
- GH-1340-VERIFY-V0221-PATCH-AUDIT-RELEASE-NOTES
- TVM-RELEASE-V0221-PATCH-AUDIT-RELEASE-NOTES
- V0221-004-PATCH-AUDIT
- V0221-004-RELEASE-NOTES
- V0221-004-NO-CAPABILITY-CHANGE
- V0221-004-NO-PRODUCTION-CUTOVER
- V0221-004-NO-TAG-OR-RELEASE-PUBLICATION
- v0.22.0 is Binance Spot live canary transport completion.
- Release URL: `https://github.com/atxinbao/MTPRO/releases/tag/v0.22.0`.
- Tag peeled commit: `1589492558fa55aad3424e5727415c2f8f453ed8`.
- Publication timestamp: `2026-07-06T11:16:35Z`.
- v0.23.0 is Binance USD-M Futures read-only foundation.
- production cutover not authorized.
- Verification: `bash checks/verify-v0.22.1.sh`.

## MTPRO Release v0.23.0 Binance USD-M Futures Read-only Foundation

- GH-1341-VERIFY-V0230-FUTURES-READONLY-CONTRACT
- TVM-RELEASE-V0230-FUTURES-READONLY-CONTRACT
- V0230-001-BINANCE-USDM-FUTURES-READONLY-FOUNDATION
- V0230-001-NO-FUTURES-ORDER-EXECUTION
- GH-1342-VERIFY-V0230-FUTURES-PROFILE-ENDPOINT-ALLOWLIST
- V0230-002-BINANCE-USDM-FUTURES-PROFILE
- V0230-002-READ-ONLY-ENDPOINT-ALLOWLIST
- GH-1343-VERIFY-V0230-FUTURES-CREDENTIAL-REFERENCE-GATE
- V0230-003-CREDENTIAL-REFERENCE-ONLY
- V0230-003-SIGNED-READONLY-APPROVAL-GATE
- GH-1344-VERIFY-V0230-FUTURES-ACCOUNT-SNAPSHOT-REDACTION
- V0230-004-REDACTED-ACCOUNT-SNAPSHOT
- GH-1345-VERIFY-V0230-FUTURES-POSITION-MARGIN-LEVERAGE-READONLY
- V0230-005-POSITION-MARGIN-LEVERAGE-OBSERVED-STATE
- GH-1346-VERIFY-V0230-FUTURES-FUNDING-MARK-LIQUIDATION-READONLY
- V0230-006-FUNDING-MARK-LIQUIDATION-OBSERVATION
- GH-1347-VERIFY-V0230-FUTURES-TRANSPORT-ARTIFACT-FAILURE-CLASSIFICATION
- V0230-007-READONLY-TRANSPORT-ARTIFACT
- V0230-007-FAIL-CLOSED-FAILURE-CLASSIFICATION
- GH-1348-VERIFY-V0230-FUTURES-READONLY-RECONCILIATION
- V0230-008-LOCAL-REGISTRY-RECONCILIATION
- V0230-008-NO-BROKER-RECONCILIATION-RUNTIME
- GH-1349-VERIFY-V0230-DASHBOARD-CLI-FUTURES-READONLY-SURFACE
- TVM-RELEASE-V0230-DASHBOARD-CLI-FUTURES-READONLY-SURFACE
- V0230-009-DASHBOARD-CLI-READONLY-FUTURES-READINESS
- V0230-009-NO-TRADING-COMMANDS
- V0230-009-NO-DASHBOARD-TRADING-CONTROLS
- GH-1350-VERIFY-V0230-AGGREGATE-VALIDATION
- TVM-RELEASE-V0230-AGGREGATE-VALIDATION
- V0230-010-AGGREGATE-VALIDATION-SUITE
- V0230-010-FUTURES-READONLY-FOUNDATION
- V0230-010-NO-FUTURES-ORDER-EXECUTION
- GH-1351-VERIFY-V0230-STAGE-AUDIT-RELEASE-DOCS
- V0230-011-STAGE-CODE-AUDIT
- V0230-011-NO-PRODUCTION-CUTOVER
- Binance USD-M Futures read-only foundation.
- futuresOrderExecutionEnabled=false.
- production cutover not authorized.
- Verification: `bash checks/verify-v0.23.0.sh`.

## Release v0.23.1 publication fact sync / read-only guard patch verification

- GH-1353-VERIFY-V0231-V0230-RELEASE-FACT-SYNC / TVM-RELEASE-V0231-V0230-RELEASE-FACT-SYNC / V0231-001-V0230-GITHUB-RELEASE-PUBLISHED / V0231-001-V0230-TAG-FIXED: v0.23.0 release facts are fixed to the published GitHub Release and immutable tag target.
- GH-1354-VERIFY-V0231-V0230-STALE-WORDING-GUARD / V0231-002-PUBLISHED-V0230-STALE-WORDING-GUARD: stale construction closeout wording is rejected.
- GH-1355-VERIFY-V0231-LATEST-VERIFICATION-MILESTONE-FACTS / V0231-003-V0221-V0230-MILESTONES-COMPLETE: v0.22.1 issues #1337-#1340 closed; v0.23.0 issues #1341-#1351 closed.
- GH-1356-VERIFY-V0231-FUTURES-READONLY-GUARD-HARDENING / V0231-004-NO-FUTURES-MUTATION / V0231-004-NO-LISTENKEY-PRIVATE-STREAM / V0231-004-NO-OKX-PRODUCTION-CUTOVER: no Futures mutation, listenKey, private stream, OKX, production cutover or live order capability.
- GH-1357-VERIFY-V0231-PATCH-AUDIT-RELEASE-NOTES / V0231-005-PATCH-AUDIT / V0231-005-V0240-BLOCKED-BY-V0231-COMPLETION / V0231-005-NO-CAPABILITY-CHANGE: v0.23.1 is docs / guard patch only, with no capability change.
- Verification: `bash checks/verify-v0.23.1.sh`.

## Release v0.24.0 Spot + Futures unified read-only foundation verification

- GH-1358-VERIFY-V0240-DUAL-PRODUCT-CONTRACT / TVM-RELEASE-V0240-DUAL-PRODUCT-CONTRACT / V0240-001-SPOT-FUTURES-DUAL-PRODUCT-UNIFICATION / V0240-001-BLOCKED-BY-V0231-COMPLETION.
- GH-1359-VERIFY-V0240-PRODUCT-AWARE-OMS-EVIDENCE / V0240-002-UNIFIED-OMS-EVENT-EVIDENCE / V0240-002-NO-FUTURES-ORDER-EXECUTION.
- GH-1360-VERIFY-V0240-UNIFIED-PORTFOLIO-PROJECTION / V0240-003-SPOT-CANARY-FUTURES-READONLY-PORTFOLIO / V0240-003-FUTURES-READONLY-NOT-TRADING-AUTHORIZATION.
- GH-1361-VERIFY-V0240-UNIFIED-RISK-READINESS / V0240-004-SPOT-FUTURES-RISK-READINESS / V0240-004-READINESS-NOT-PRODUCTION-RISK-APPROVAL.
- GH-1362-VERIFY-V0240-DUAL-PRODUCT-RECONCILIATION / V0240-005-SPOT-FUTURES-RECONCILIATION-FOUNDATION / V0240-005-NO-BROKER-RECONCILIATION-RUNTIME.
- GH-1363-VERIFY-V0240-DUAL-PRODUCT-FAILURE-MATRIX / V0240-006-DUAL-PRODUCT-FAILURE-CLASSIFICATION / V0240-006-FAIL-CLOSED-EVIDENCE.
- GH-1364-VERIFY-V0240-DASHBOARD-CLI-DUAL-PRODUCT-SURFACE / TVM-RELEASE-V0240-DASHBOARD-CLI-DUAL-PRODUCT-SURFACE / V0240-007-DASHBOARD-CLI-DUAL-PRODUCT-READONLY / V0240-007-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND.
- GH-1365-VERIFY-V0240-AGGREGATE-VALIDATION / TVM-RELEASE-V0240-AGGREGATE-VALIDATION / V0240-008-AGGREGATE-VALIDATION-SUITE / V0240-008-STAGE-AUDIT-RELEASE-DOCS / V0240-008-NO-PRODUCTION-CUTOVER.
- Verification: `bash checks/verify-v0.24.0.sh`.

## Release v0.24.1 publication fact sync / milestone semantics patch verification

- GH-1367-VERIFY-V0241-V0240-RELEASE-FACT-SYNC / TVM-RELEASE-V0241-V0240-RELEASE-FACT-SYNC / V0241-001-V0240-GITHUB-RELEASE-PUBLISHED / V0241-001-V0240-TAG-FIXED / V0241-001-V0240-PUBLISHED-AT-2026-07-06T19-43-49Z: v0.24.0 release facts are fixed to https://github.com/atxinbao/MTPRO/releases/tag/v0.24.0 / `995065ba4ae4f9c80009fc68891176e5c0a56270` / `2026-07-06T19:43:49Z`.
- GH-1368-VERIFY-V0241-MILESTONE-COMPLETION-FACTS / V0241-002-V0231-V0240-MILESTONES-CLOSED: v0.23.1 milestone #38 closed with 0 open / 5 closed issues; v0.24.0 milestone #39 closed with 0 open / 8 closed issues.
- GH-1369-VERIFY-V0241-V0240-STALE-WORDING-GUARD / V0241-003-PUBLISHED-V0240-STALE-WORDING-GUARD: published v0.24.0 current-facing stale wording is rejected.
- GH-1370-VERIFY-V0241-SPOT-CANARY-FUTURES-READONLY-SEMANTICS / V0241-004-SPOT-CANARY-EVIDENCE-NOT-FUTURES-EXECUTION / V0241-004-FUTURES-READONLY-EVIDENCE-NOT-TRADING-AUTHORIZATION: Spot canary evidence and Futures read-only evidence remain separate semantics.
- GH-1371-VERIFY-V0241-PATCH-AUDIT-RELEASE-NOTES / V0241-005-PATCH-AUDIT / V0241-005-V0250-BLOCKED-BY-V0241-COMPLETION / V0241-005-NO-CAPABILITY-CHANGE: v0.24.1 is docs / guard patch only, with no capability change.
- Verification: `bash checks/verify-v0.24.1.sh`.
## 2026-07-07 - MTPRO Release v0.25.0 Aggregate Validation / Release Closeout

- GH-1372-VERIFY-V0250-DUAL-PRODUCT-PRODUCTION-READINESS-CONTRACT
- GH-1373-VERIFY-V0250-PRODUCTION-ENVIRONMENT-ISOLATION-CREDENTIAL-POLICY
- GH-1374-VERIFY-V0250-SPOT-CANARY-OPERATOR-CONTROL-EVIDENCE
- GH-1375-VERIFY-V0250-FUTURES-READONLY-FRESHNESS-FAIL-CLOSED-EVIDENCE
- GH-1376-VERIFY-V0250-UNIFIED-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATE-EVIDENCE
- GH-1377-VERIFY-V0250-INCIDENT-ROLLBACK-NOTRADE-KILLSWITCH-READINESS-EVIDENCE
- GH-1378-VERIFY-V0250-DASHBOARD-CLI-OPERATOR-READINESS-SURFACE
- GH-1379-VERIFY-V0250-AGGREGATE-VALIDATION-RELEASE-CLOSEOUT
- TVM-RELEASE-V0250-AGGREGATE-VALIDATION
- V0250-008-AGGREGATE-VALIDATION-SUITE
- V0250-008-STAGE-AUDIT-RELEASE-DOCS
- V0250-008-ROOT-DOCS-REFRESH
- V0250-008-RELEASE-PUBLICATION-GATE-HANDOFF
- V0250-008-NO-PRODUCTION-CUTOVER
- V0250-008-NO-TAG-OR-RELEASE-PUBLICATION
- Added `checks/verify-v0.25.0.sh`, stage audit report, release notes, root docs refresh, validation matrix and automation readiness anchors.
- Validation commands: `swift test --filter TargetGraphTests/testGH1379ReleaseV0250AggregateValidationReleaseCloseout`, `bash checks/verify-v0.25.0.sh`, `git diff --check`, `bash checks/automation-readiness.sh`, `bash checks/run.sh`.
- Boundary: no production cutover, no Futures order execution, no OKX active runtime, no production secret read, no production endpoint / broker endpoint auto-connect, no trading button, no order form, no live command and no tag / GitHub Release publication in the construction PR.

## 2026-07-08 - MTPRO Release v0.25.1 Publication Fact Sync / Roadmap Correction Patch

- GH-1389-VERIFY-V0251-V0250-RELEASE-FACT-SYNC
- TVM-RELEASE-V0251-V0250-RELEASE-FACT-SYNC
- V0251-001-V0250-GITHUB-RELEASE-PUBLISHED
- V0251-001-V0250-TAG-FIXED
- V0251-001-V0250-PUBLISHED-AT-2026-07-07T14-47-50Z
- GH-1390-VERIFY-V0251-MILESTONE-COMPLETION-FACTS
- V0251-002-V0250-MILESTONE-CLOSED
- GH-1391-VERIFY-V0251-V022-V023-MAINLINE-WORDING
- V0251-003-V0220-SPOT-LIVE-CANARY-TRANSPORT
- V0251-003-V0230-FUTURES-READONLY-FOUNDATION
- GH-1392-VERIFY-V0251-V0250-STALE-WORDING-GUARD
- V0251-004-PUBLISHED-V0250-STALE-WORDING-GUARD
- GH-1393-VERIFY-V0251-PATCH-AUDIT-RELEASE-NOTES
- V0251-005-PATCH-AUDIT
- V0251-005-V0260-BLOCKED-BY-V0251-COMPLETION
- V0251-005-NO-CAPABILITY-CHANGE
- v0.25.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.25.0`.
- v0.25.0 tag fixed at `1dad68196b28eca7285a5c8efb3d15ce74c`.
- v0.25.0 published at `2026-07-07T14:47:50Z`.
- v0.25.0 milestone #41 closed.
- v0.22.0 is Binance Spot live canary transport completion.
- v0.23.0 is Binance USD-M Futures read-only foundation.
- v0.25.1 is no-capability-change patch; v0.26.0 remains blocked by v0.25.1 completion.
- production cutover not authorized.

## 2026-07-08 - MTPRO Release v0.26.0 Futures Testnet Controlled Execution Foundation

- GH-1394-VERIFY-V0260-FUTURES-TESTNET-CONTROLLED-EXECUTION-CONTRACT
- TVM-RELEASE-V0260-FUTURES-TESTNET-CONTROLLED-EXECUTION
- V0260-001-FUTURES-TESTNET-CONTROLLED-EXECUTION
- V0260-001-NO-PRODUCTION-CUTOVER
- GH-1395-VERIFY-V0260-FUTURES-TESTNET-ENVIRONMENT-CREDENTIAL-GATE
- V0260-002-FUTURES-TESTNET-ENVIRONMENT-GATE
- V0260-002-CREDENTIAL-REFERENCE-ONLY
- GH-1396-VERIFY-V0260-FUTURES-TESTNET-ORDER-INTENT-VALIDATION
- V0260-003-NO-PRODUCTION-CUTOVER
- V0260-003-ORDER-INTENT-VALIDATED
- GH-1397-VERIFY-V0260-FUTURES-TESTNET-SUBMIT-EVIDENCE
- V0260-004-MANUAL-APPROVAL-HARD-CAPS
- V0260-004-IDEMPOTENCY-REDACTION
- GH-1398-VERIFY-V0260-FUTURES-TESTNET-CANCEL-STATUS-ROLLBACK
- V0260-005-CANCEL-STATUS-ROLLBACK
- V0260-005-FAIL-CLOSED-STATUS-AMBIGUITY
- GH-1399-VERIFY-V0260-FUTURES-TESTNET-OMS-RECONCILIATION
- V0260-006-OMS-EVENT-LOG-RECONCILIATION
- V0260-006-APPEND-ONLY-EVIDENCE
- GH-1400-VERIFY-V0260-FUTURES-TESTNET-RISK-NOTIONAL-LEVERAGE-GUARDS
- V0260-007-RISK-NOTIONAL-LEVERAGE-MODE-GUARD
- V0260-007-REDUCE-ONLY-HARD-CAP
- GH-1401-VERIFY-V0260-DASHBOARD-CLI-FUTURES-TESTNET-STATUS-SURFACE
- TVM-RELEASE-V0260-DASHBOARD-CLI-FUTURES-TESTNET-STATUS-SURFACE
- V0260-008-DASHBOARD-CLI-READONLY-FUTURES-TESTNET-STATUS
- V0260-008-NO-DASHBOARD-TRADING-CONTROLS
- GH-1402-VERIFY-V0260-AGGREGATE-VALIDATION
- TVM-RELEASE-V0260-AGGREGATE-VALIDATION
- V0260-009-AGGREGATE-VALIDATION-SUITE
- GH-1403-VERIFY-V0260-STAGE-AUDIT-RELEASE-DOCS
- V0260-010-STAGE-CODE-AUDIT
- V0260-010-NO-PRODUCTION-CUTOVER
- V0260-010-NO-TAG-OR-RELEASE-PUBLICATION
- Added `checks/verify-v0.26.0.sh`, the Futures testnet controlled execution evidence contract, Dashboard / CLI read-only surface, stage audit, release notes and validation anchors.
- Binance USD-M Futures testnet controlled execution foundation.
- `productionFuturesOrderExecutionEnabled=false`.
- production cutover not authorized.
- Validation commands: `swift test --filter TargetGraphTests/testGH1394To1403ReleaseV0260FuturesTestnetControlledExecutionFoundation`, `bash checks/verify-v0.26.0.sh`, `git diff --check`, `bash checks/automation-readiness.sh`, `bash checks/run.sh`.

## Release v0.26.1 Publication Fact Sync / Milestone Closure Patch Verification

- GH-1406-VERIFY-V0261-V0260-RELEASE-FACT-SYNC
- TVM-RELEASE-V0261-V0260-RELEASE-FACT-SYNC
- V0261-001-V0260-GITHUB-RELEASE-PUBLISHED
- V0261-001-V0260-TAG-FIXED
- V0261-001-V0260-PUBLISHED-AT-2026-07-08T13-00-01Z
- GH-1407-VERIFY-V0261-V0260-MILESTONE-COMPLETION
- V0261-002-V0260-MILESTONE-CLOSED
- V0261-002-V0260-ISSUES-1394-1403-DONE
- GH-1408-VERIFY-V0261-V0260-STALE-WORDING-GUARD
- V0261-003-PUBLISHED-V0260-STALE-WORDING-GUARD
- GH-1409-VERIFY-V0261-V0260-BASELINE-WORDING
- V0261-004-V0260-CURRENT-PUBLISHED-BASELINE
- V0261-004-FUTURES-TESTNET-CONTROLLED-EXECUTION-FOUNDATION
- GH-1410-VERIFY-V0261-PATCH-AUDIT-RELEASE-NOTES
- V0261-005-PATCH-AUDIT
- V0261-005-V0270-BLOCKED-BY-V0261-COMPLETION
- V0261-005-NO-CAPABILITY-CHANGE

v0.26.1 records the published v0.26.0 GitHub Release at https://github.com/atxinbao/MTPRO/releases/tag/v0.26.0, tag target `e3b65f2337c5275eaa7ce5c5f224b69475a7c9bb`, publication timestamp `2026-07-08T13:00:01Z`, and current maturity `Binance USD-M Futures testnet controlled execution foundation`. v0.26.0 milestone #43 is closed with 0 open / 10 closed issues; #1394 through #1403 are closed / done. production cutover not authorized. v0.27.0 remains blocked until v0.26.1 completion.

Validation commands: `swift test --filter TargetGraphTests/testGH1406To1410ReleaseV0261PublicationFactSyncMilestoneClosurePatch`, `bash checks/verify-v0.26.1.sh`, `git diff --check`, `bash checks/automation-readiness.sh`, `bash checks/run.sh`.
