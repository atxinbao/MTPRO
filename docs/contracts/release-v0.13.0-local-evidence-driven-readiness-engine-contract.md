# Release v0.13.0 Local Evidence-driven Readiness Engine Contract

更新日期：2026-06-20  
执行者：Codex

`GH-994-VERIFY-V0130-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT`

`TVM-RELEASE-V0130-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT`

`V0130-001-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT`

`V0130-001-REAL-LOCAL-EVIDENCE-INTAKE-REQUIRED`

`V0130-001-ARTIFACT-POLICY-MANIFEST-BUNDLE-REGISTRY-DIFF-CHAIN`

`V0130-001-LIFECYCLE-ORDER-FAIL-CLOSED`

`V0130-001-NO-SYNTHETIC-READINESS-DATA`

`V0130-001-NO-PRODUCTION-CUTOVER`

`GH-995-VERIFY-V0130-LOCAL-EVIDENCE-INTAKE-MODEL`

`TVM-RELEASE-V0130-LOCAL-EVIDENCE-INTAKE-MODEL`

`V0130-002-LOCAL-EVIDENCE-ROOT-LAYOUT`

`V0130-002-RUN-LOGS-EVENT-STREAM-ARTIFACTS-REGISTRY-PRIOR-ASSESSMENTS`

`V0130-002-SCHEMA-VALIDATION-DIAGNOSTICS`

`V0130-002-MISSING-MALFORMED-FAILS-CLOSED`

`V0130-002-NO-PRODUCTION-ENDPOINT-SECRET-ORDER`

`V0130-002-READ-ONLY-INTAKE`

`GH-996-VERIFY-V0130-SYNTHETIC-PROVENANCE-REJECTION`

`TVM-RELEASE-V0130-SYNTHETIC-PROVENANCE-REJECTION`

`V0130-003-INTAKE-DERIVED-MANIFEST-PROVENANCE`

`V0130-003-SOURCECOMMIT-SOURCERUN-ARTIFACT-METADATA`

`V0130-003-SYNTHETIC-PROVENANCE-FAILS-CLOSED`

`V0130-003-FIXTURE-ONLY-ISOLATION`

`V0130-003-NO-PRODUCTION-CUTOVER`

`GH-997-VERIFY-V0130-BUILD-PIPELINE`

`TVM-RELEASE-V0130-BUILD-PIPELINE`

`V0130-004-SCHEMA-CHECKSUM-POLICY-REGISTRY-FLOW`

`V0130-004-MANIFEST-BUNDLE-REGISTRY-WRITE`

`V0130-004-PROVENANCE-VALIDATION-REPORT`

`V0130-004-BUILD-FAILS-CLOSED`

`V0130-004-NO-PRODUCTION-CUTOVER`

`GH-998-VERIFY-V0130-EVIDENCE-CHAIN-VALIDATE`

`TVM-RELEASE-V0130-EVIDENCE-CHAIN-VALIDATE`

`V0130-005-REGISTRY-MANIFEST-BUNDLE-CONSISTENCY`

`V0130-005-ARTIFACT-POLICY-CHECKSUM-PROVENANCE`

`V0130-005-EXPORT-COMPARISON-IDENTITY`

`V0130-005-MISSING-STALE-TAMPERED-FAILS-CLOSED`

`V0130-005-NO-PRODUCTION-CUTOVER`

`GH-999-VERIFY-V0130-REDACTED-AUDIT-EXPORT-PACKAGE`

`TVM-RELEASE-V0130-REDACTED-AUDIT-EXPORT-PACKAGE`

`V0130-006-REDACTED-AUDIT-EXPORT-PACKAGE`

`V0130-006-COMPLETE-AUDIT-PACKAGE`

`V0130-006-EXPORT-CHECKSUMS-MATCH-SOURCE`

`V0130-006-MISSING-EVIDENCE-FAILS-CLOSED`

`V0130-006-NO-SECRET-PRODUCTION-CUTOVER`

`GH-1000-VERIFY-V0130-EVIDENCE-LEVEL-DIFF`

`TVM-RELEASE-V0130-EVIDENCE-LEVEL-DIFF`

`V0130-007-EVIDENCE-LEVEL-DIFF-COMPARE`

`V0130-007-SOURCE-POLICY-RISK-CHECKSUM-PROVENANCE-COMPLETENESS`

`V0130-007-BROKEN-EVIDENCE-LINK-BLOCKER`

`V0130-007-COMPARISON-EXPORT-VALIDATION`

`V0130-007-NO-PRODUCTION-CUTOVER`

`GH-1001-VERIFY-V0130-TRANSACTION-RECOVERY-SNAPSHOT`

`TVM-RELEASE-V0130-TRANSACTION-RECOVERY-SNAPSHOT`

`V0130-008-TRANSACTION-RECOVERY-SNAPSHOT`

`V0130-008-STAGING-STATE-INTENDED-COMPLETED-WRITES`

`V0130-008-CLEANUP-AUDIT-TRACE`

`V0130-008-PARTIAL-WRITES-FAIL-CLOSED`

`V0130-008-NO-PRODUCTION-CUTOVER`

## Contract Scope

`v0.13.0` 定义 local evidence-driven readiness engine / 本地证据驱动就绪引擎。它承接 v0.12.0 readiness assessment sessions 和 v0.12.1 provenance hardening patch 的已完成事实，把 readiness assessment 从“可生成本地 assessment evidence”推进为“只能从真实本地 evidence root intake、校验、打包、登记、比较和导出”的 engine contract。

本 contract 起始于 `MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine` queue 的第一个 gate。#994 只定义输入、输出、证据根、schema contract、生命周期顺序和 fail-closed behavior；后续 issue 按 WIP=1 逐项完成。当前执行事实：#994、#995、#996、#997、#998、#999 和 #1000 已完成；#1001 在 fresh WIP=1 preflight 后作为唯一 active transaction recovery forensic snapshot gate 执行；#1002..#1005 继续 blocked，直到 #1001 PR merged、required checks success、issue closed / done、本地 `main == origin/main` 且 worktree clean。

## Inputs

v0.13.0 readiness engine 的输入必须全部来自显式 local evidence root。允许的输入类型固定为：

| 输入 | 说明 | 必须拒绝 |
| --- | --- | --- |
| run logs | local run journal / operation journal / CLI run output | production endpoint response、raw secret、listenKey、broker payload |
| event stream | append-only local event log / replay event set | broker execution report、production account stream、private WebSocket raw frame |
| artifacts | redacted JSON evidence、bundle、manifest、policy、checksum metadata | order payload、account endpoint payload、signed request payload |
| registry | local readiness registry and assessment metadata | remote registry、production approval service、broker state |
| prior assessments | 本地 baseline / follow-up assessment snapshot | synthetic assessmentID-only evidence、fabricated sourceRunID |

Local evidence root 必须由后续 #995 明确指定和验证；#994 不创建默认路径、不读取真实文件、不写 assessment output。任何缺失、不可读、schema mismatch、checksum mismatch、sourceRunID mismatch、policy violation 或 lifecycle order violation 都必须 fail closed。

## #995 Local Evidence Intake Model

#995 在 #994 contract gate 完成后，只实现 real local evidence intake model / 真实本地证据 intake model。它固定显式 local evidence root 的目录 layout，并以只读方式发现和校验 run logs / event stream / artifacts / registry / prior assessments 五类 evidence。

Canonical layout：

| Category | Required path | Schema |
| --- | --- | --- |
| run logs | `run-logs/run-journal.jsonl` | JSONL，必须包含 `sourceRunID`、`sourceCommit`、`eventType`、`createdAt` |
| event stream | `event-stream/events.jsonl` | JSONL，必须包含 `eventID`、`sourceRunID`、`eventType`、`occurredAt` |
| artifacts | `artifacts/artifact-index.json` | JSON object，必须包含 `sourceRunID`、`sourceCommit`、`artifacts` |
| registry | `registry/registry.json` | JSON object，必须包含 `registryVersion`、`assessments` |
| prior assessments | `prior-assessments/assessments-index.json` | JSON object，必须包含 `assessmentIDs`、`sourceRunIDs` |

CLI surface 固定为 `readiness intake <evidenceRoot>`。该命令只能输出 read-only local intake diagnostics，包括 `intakeValid`、`failClosed`、missing evidence diagnostic、malformed JSON / JSONL diagnostic 和 forbidden production marker diagnostic。它不写 registry、不生成 bundle、不执行 diff，不创建 assessment output，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 submit / cancel / replace。

#995 必须对 missing local evidence root、缺失 required directory、缺失 required file、malformed JSON / JSONL、schema field 缺失、production endpoint marker、secret / listenKey marker、signed endpoint payload、account endpoint payload 和 order endpoint payload fail closed。失败输出必须是 actionable local diagnostic evidence，不能补造 sourceRunID、sourceCommit、artifact metadata、registry entry、bundle 或 diff。

## #996 Synthetic Provenance Rejection

#996 在 #995 intake gate 完成后，把 v0.13 normal manifest provenance 绑定到显式 local evidence root。#996 的 provenance layer 必须先读取 local evidence root，再调用 #995 intake model，最后只把 intake-derived sourceCommit、sourceRunIDs、artifact bytes 和 artifact checksums 交给 Manifest V2。

`readiness build-v013 <assessmentID> <evidenceRoot>` 不得从 assessmentID、generationID、固定字符串或 artifact checksum fallback 伪造 sourceRunID。它必须拒绝 placeholder sourceCommit、zero / demo commit、`gh-963-source-run`、`source-run-*` synthetic sourceRunID、缺失 artifact file、artifact byte / checksum mismatch，以及显式 `fixtureOnly=true` 或 `evidenceClassification=fixture` 的 fixture-only evidence。

Normal manifest provenance 只能在 `normalManifestEligible=true`、`syntheticProvenanceRejected=true`、`fixtureOnly=false`、`localEvidenceTraceable=true` 时进入后续 build。#996 本身不执行 diff、不读取 production secret、不连接 production endpoint / broker endpoint、不发送 submit / cancel / replace，也不授权 production cutover。

## #997 Build Pipeline

#997 在 #996 provenance gate 完成后，升级 `readiness build-v013 <assessmentID> <evidenceRoot>` 为 deterministic verify-and-build pipeline。该命令必须读取真实 local evidence root，执行 #995 schema validation，复用 #996 sourceCommit / sourceRunID / artifact provenance，重新计算 raw artifact checksum，并对每个 local artifact 执行 content policy validation。#997 固定为 schema / checksum / policy / manifest / bundle / registry flow。

## #998 Evidence-chain Validate

#998 在 #997 build pipeline gate 完成后，升级 `readiness validate <assessmentID>` 为完整 evidence-chain consistency check。该命令必须读取 local registry store，逐项校验 registry / manifest / bundle / artifact / policy / checksum / provenance 是否一致，并在存在 export / comparison artifact 时确认它们绑定同一个 assessment identity。export / comparison identity 必须与 registry entry 的 assessmentID 保持一致。只有完整 evidence chain coherent 时，validate 才能返回 valid。

Validate 通过条件必须同时满足：

- registry document 和 registry entry 均 held。
- Manifest V2 存在且 held。
- Bundle V2 存在且 held。
- bundle manifest 存在且 held。
- bundle JSON bytes 与 bundle manifest 的 checksum / byte count 一致。
- registry entry、Manifest V2、Bundle V2 和 bundle manifest 的 assessmentID / generationID / bundleChecksum 一致。
- Manifest V2 与 Bundle V2 的 sourceCommit / sourceRunIDs 一致。
- artifact snapshots 存在，且每个 snapshot 的 manifestChecksum、artifactSHA256、contentValidationChecksum 与 Manifest V2 / policy 链路一致。
- provenance summary、comparison metadata 和 redacted export directory 如果存在，必须包含同一个 assessmentID。

`readiness validate <assessmentID>` 必须对 missing、stale、tampered、inconsistent evidence fail closed，并输出明确 failure reasons。它不能只检查文件存在或 anchor 存在，也不能把 incoherent evidence 降级为 warning。

#998 不执行 diff、不生成 redacted audit export package、不创建 CLI lifecycle ordering、不发布 tag / GitHub Release、不授权 production cutover、不读取 production secret、不连接 production endpoint / broker endpoint、不发送 submit / cancel / replace。

## #999 Redacted Audit Export Package

Anchors:

- `GH-999-VERIFY-V0130-REDACTED-AUDIT-EXPORT-PACKAGE`
- `TVM-RELEASE-V0130-REDACTED-AUDIT-EXPORT-PACKAGE`
- `V0130-006-REDACTED-AUDIT-EXPORT-PACKAGE`
- `V0130-006-COMPLETE-AUDIT-PACKAGE`
- `V0130-006-EXPORT-CHECKSUMS-MATCH-SOURCE`
- `V0130-006-MISSING-EVIDENCE-FAILS-CLOSED`
- `V0130-006-NO-SECRET-PRODUCTION-CUTOVER`

#999 在 #998 evidence-chain validate gate 完成后，升级 `readiness export <assessmentID>` 为本地 redacted audit export package writer。该命令必须先执行完整 evidence-chain consistency check；只有 registry document、registry entry、Manifest V2、Bundle V2、bundle manifest、bundle bytes、artifact snapshots、content validation checksum、source provenance 和 optional export / comparison identity 全部 coherent 时，才允许写出 redacted export directory。

导出包固定包含以下本地 JSON 文件：

- `assessment-summary.json`
- `manifest-v2.json`
- `bundle-v2.json`
- `validation-report.json`
- `provenance.json`
- `comparison.json`

`manifest-v2.json` 和 `bundle-v2.json` 必须 byte-for-byte 匹配 local registry store 的源 Manifest V2 / Bundle V2；导出 report 必须输出 `packageComplete=true`、`exportedChecksumsMatchSource=true`、`missingEvidenceFailsClosed=true`、`redactedEvidenceOnly=true`、`noSecretValue=true`、`noEndpointPayload=true` 和 `noOrderPayload=true`。导出目录、`provenance-summary.json` 和 `comparison-metadata.json` 中的所有 JSON 必须绑定同一个 `assessmentID`，确保后续 `readiness validate <assessmentID>` 继续返回 `exportComparisonIdentityConsistent=true`。

`readiness export <assessmentID>` 必须对 missing、stale、tampered、inconsistent evidence fail closed；不能在 validate blocked 时写出 partial package，不能把缺失 evidence 降级为 warning，不能补造 comparison evidence 或 source artifact checksum。

#999 不执行 diff / compare、不创建 CLI lifecycle ordering、不发布 tag / GitHub Release、不授权 production cutover、不读取 production secret、不连接 production endpoint / broker endpoint、不发送 submit / cancel / replace。

## #1000 Evidence-level Diff / Compare

Anchors:

- `GH-1000-VERIFY-V0130-EVIDENCE-LEVEL-DIFF`
- `TVM-RELEASE-V0130-EVIDENCE-LEVEL-DIFF`
- `V0130-007-EVIDENCE-LEVEL-DIFF-COMPARE`
- `V0130-007-SOURCE-POLICY-RISK-CHECKSUM-PROVENANCE-COMPLETENESS`
- `V0130-007-BROKEN-EVIDENCE-LINK-BLOCKER`
- `V0130-007-COMPARISON-EXPORT-VALIDATION`
- `V0130-007-NO-PRODUCTION-CUTOVER`

#1000 在 #999 redacted audit export package gate 完成后，升级 `readiness compare <baselineAssessmentID> <followUpAssessmentID>` 为 evidence-level readiness diff。该 compare 必须先对 baseline 和 follow-up assessment 执行 #998 evidence-chain validate；只有 registry、Manifest V2、Bundle V2、bundle manifest、bundle bytes、artifact snapshots、content validation checksum、source provenance、redacted export 和 optional comparison identity 均 coherent 时，才允许输出正常 diff。

Evidence-level diff 固定比较六段：

- source data。
- policy。
- risk posture。
- checksum chain。
- provenance。
- evidence completeness。

Canonical section phrase：source data、policy、risk posture、checksum chain、provenance、evidence completeness。

每段 diff 必须输出 `unchanged`、`changed` 或 `blocker`。sourceCommit / sourceRunIDs、content validation checksum、registry lifecycle / production-disabled flags、bundle / manifest / artifact checksum、producer version / generation / artifact path 和 validation completeness 都必须进入 deterministic fingerprint。broken evidence links、missing、tampered、stale 或 inconsistent evidence link 不能被降级为普通 changed；必须进入 `blockedSections` 和 `blockers`，并让 `comparisonState=blocked`。

`readiness compare <baselineAssessmentID> <followUpAssessmentID>` 必须保持 non-mutating：baseline 和 follow-up registry entry 除 comparison metadata sidecar 外不得被改写；compare 完成后必须再次运行 validate，保持 `exportComparisonIdentityConsistent=true`。比较输出必须可写入本地 `comparison-metadata.json`，如果 follow-up 已有 redacted export directory，也必须写出可验证的 export `comparison.json`。

CLI 输出必须包含 `comparisonFormat=evidence-level-readiness-diff`、`comparisonState`、`comparedSections`、`changedSections`、`unchangedSections`、`blockedSections`、`blockers`、`hasDifferences`、`reportChecksum`、`comparisonMetadataJSONPath`、`compareDoesNotMutateAssessments=true` 和 `operatorReviewOnly=true`。该输出只供 operator review，不授权 production cutover、不读取 production secret、不连接 production endpoint / broker endpoint、不发送 submit / cancel / replace。

#1000 不创建 CLI lifecycle ordering、不创建 transaction recovery snapshot、不发布 tag / GitHub Release、不授权 production cutover、不读取 production secret、不连接 production endpoint / broker endpoint、不发送 submit / cancel / replace。

## #1001 Transaction Recovery Forensic Snapshot

Anchors:

- `GH-1001-VERIFY-V0130-TRANSACTION-RECOVERY-SNAPSHOT`
- `TVM-RELEASE-V0130-TRANSACTION-RECOVERY-SNAPSHOT`
- `V0130-008-TRANSACTION-RECOVERY-SNAPSHOT`
- `V0130-008-STAGING-STATE-INTENDED-COMPLETED-WRITES`
- `V0130-008-CLEANUP-AUDIT-TRACE`
- `V0130-008-PARTIAL-WRITES-FAIL-CLOSED`
- `V0130-008-NO-PRODUCTION-CUTOVER`

#1001 在 #1000 evidence-level diff / compare gate 完成后，新增 transaction recovery forensic snapshot。该 snapshot 只用于解释 interrupted / stale local readiness staging，不补写 Manifest V2、Bundle V2、registry entry、redacted export 或 comparison metadata。

Snapshot 必须记录：

- `operation`：被中断的本地 readiness 操作，如 build pipeline、redacted export 或 evidence-level compare。
- `stagingState`：interrupted / stale / cleaned 等本地 staging 状态。
- intended writes / completed writes / missing writes：让 operator 能区分计划写入、已经写入和缺失写入。
- cleanup result 和 cleanup audit trace：staging cleanup 必须留下本地可审计路径，而不是只删除现场。
- failure reason：必须解释中断原因或 stale 判断来源。
- production-disabled flags：production trading、production secret read、production endpoint / broker endpoint connection、testnet / production order submission 和 production cutover authorization 必须保持 false。

partial writes 不能被当作有效 assessment output。只要 intended writes 和 completed writes 不一致，snapshot 必须保留 missing writes，并把该状态视为 forensic / fail-closed evidence，而不是 normal build / export / compare 成功。Stale staging 也必须显式标记，不能被解释成可继续复用的 source evidence。

#1001 不新增 CLI lifecycle ordering、不创建 generation collision-proofing、不创建 fixture suite、不发布 tag / GitHub Release、不授权 production cutover、不读取 production secret、不连接 production endpoint / broker endpoint、不发送 submit / cancel / replace。

Build pipeline 的固定顺序为：

1. `schemaValidated=true`：run logs / event stream / artifacts / registry / prior assessments 必须通过 #995 schema gate。
2. `checksumValidated=true`：artifact index 的 path、byte count 和 checksum 必须与本地文件一致。
3. `contentPolicyValidated=true`：artifact JSON 必须通过 allowlist / denylist / raw marker policy；raw secret、listenKey、production endpoint、account endpoint、order endpoint 和 broker payload marker 必须 fail closed。
4. `manifestWritten=true`：写入 Manifest V2，并保留 #996 intake-derived provenance。
5. `readinessBundleWritten=true`：写入 immutable readiness Bundle V2 review snapshot。
6. `registryEntryConfirmed=true`：确认或创建 local readiness registry entry。
7. 输出 `validationReportChecksum`，把 provenance、policy、manifest、bundle 和 registry checksum 串成 validation report。

#997 必须对 schema、checksum、policy、manifest、bundle 或 registry consistency 任一失败 fail closed。#997 不执行 diff / compare，不创建 tag / GitHub Release，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 submit / cancel / replace，不授权 production cutover。

## Outputs

v0.13.0 readiness engine 的输出必须仍是本地、redacted、readiness-only evidence：

- validated local evidence intake report。
- artifact content-policy validation report。
- Manifest V2 / future Manifest V3-compatible provenance report。
- immutable readiness bundle snapshot。
- local registry lifecycle entry。
- non-mutating readiness diff / compare report。
- redacted audit export package。
- transaction recovery forensic snapshot。

这些输出只能说明 local readiness evidence chain 是否一致、完整、可追溯；不能被解释为 production readiness approval、production cutover authorization、broker connection authorization、testnet order permission 或 production order permission。

## Artifact -> Policy -> Manifest -> Bundle -> Registry -> Diff Chain

v0.13.0 readiness engine 必须按 `artifact -> policy -> manifest -> bundle -> registry -> diff` 链路组织 evidence，不允许跳步：

```text
local evidence root
-> artifact intake
-> artifact content policy validation
-> manifest provenance binding
-> immutable readiness bundle
-> local registry lifecycle entry
-> evidence-level diff / compare
-> redacted audit export
```

每一步必须绑定上一阶段的 checksum、sourceRunID、sourceCommit、generationID 和 policy result。任一步缺失或 mismatch 时，后续步骤不得继续生成“成功”状态，只能输出 blocked / invalid / incomplete / stale / mismatch / recovery-required 之类 fail-closed state。

## Lifecycle Order

v0.13.0 readiness engine 的 canonical lifecycle order 固定为：

1. discover evidence root。
2. inspect allowed local evidence files。
3. validate evidence schema and redaction policy。
4. build artifact metadata and checksums。
5. bind manifest provenance。
6. build immutable readiness bundle。
7. write registry lifecycle entry。
8. validate full evidence chain consistency。
9. compare baseline / follow-up assessments without mutation。
10. export redacted audit package。

CLI 或 automation 不得允许 compare-before-build、export-before-validate、registry-write-before-policy-validation、bundle-before-manifest 或 diff-without-source-evidence。后续 #1003 必须把该顺序落实到 CLI guard；#994 只定义该顺序。

## v0.13.0 Queue Dependency Contract

| Issue | Contract role | Dependency |
| --- | --- | --- |
| #994 | 定义 local evidence-driven readiness engine contract | blocked by #993 |
| #995 | real local evidence intake model | blocked by #994 |
| #996 | replace synthetic source commit / source run / artifact metadata | blocked by #995 |
| #997 | build pipeline schema + checksum + policy + registry flow | blocked by #996 |
| #998 | full evidence-chain consistency validate | blocked by #997 |
| #999 | redacted audit export package | blocked by #998 |
| #1000 | evidence-level diff / compare | blocked by #999 |
| #1001 | transaction recovery forensic snapshot | blocked by #1000 |
| #1002 | generation ID collision-proofing | blocked by #997 |
| #1003 | ordered CLI execution lifecycle | blocked by #998, #999, #1000, #1001, #1002 |
| #1004 | local evidence fixtures and regression suite | blocked by #1003 |
| #1005 | v0.13.0 stage audit and release docs | blocked by #1004 |

Parent Codex queue supervision must keep WIP=1. Only the unique eligible issue may move from backlog / non-executable to todo; all later issues remain blocked until their dependency issue is closed / done and merge evidence is complete.

## Fail-closed Behavior

v0.13.0 readiness engine must fail closed for:

- missing local evidence root。
- malformed JSON。
- checksum mismatch。
- sourceRunID missing or fabricated。
- sourceCommit placeholder or zero value。
- synthetic readiness data。
- synthetic sourceRunID。
- fixture-only evidence。
- stale registry generation。
- transaction collision。
- compare-before-build。
- export-before-validate。
- raw secret、raw listenKey、signed endpoint payload、account endpoint payload、order endpoint payload。
- production endpoint / broker endpoint marker。
- production trading enabled flag。

Fail-closed output must be actionable local diagnostic evidence. It must not silently continue, infer missing evidence, fabricate replacement evidence, or downgrade the failure to a warning.

## Non-goals

- 不实现 #1001 之后的 CLI lifecycle、generation collision-proofing、fixture suite 或 stage audit。
- 不新增 runtime pipeline。
- 不发布 v0.13.0 tag 或 GitHub Release。
- 不移动、不覆盖、不重写 v0.12.0 tag / GitHub Release。
- 不创建下一 Project / Issue。
- 不授权 production cutover。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不发送 testnet 或 production submit / cancel / replace。
- 不新增非 Binance venue。
- 不新增非 EMA / RSI active strategy。

## Boundary

`productionTradingEnabledByDefault=false`

`productionCutoverAuthorized=false`

`productionSecretRead=false`

`productionEndpointConnected=false`

`brokerEndpointConnected=false`

`productionOrderSubmitted=false`

`testnetOrderSubmissionAllowed=false`

`testnetOrderRoutingAllowed=false`

`productionOMSImplemented=false`

`tradingButtonEnabled=false`

`orderFormEnabled=false`

`liveCommandEnabled=false`

`V0130-001-NO-PRODUCTION-CUTOVER`

v0.13.0 contract gate 只定义 local evidence-driven readiness engine 的建设合同。它不打开 production trading，不读取 production secret，不连接 production endpoint / broker endpoint，不发送真实订单，不授权 production cutover。
