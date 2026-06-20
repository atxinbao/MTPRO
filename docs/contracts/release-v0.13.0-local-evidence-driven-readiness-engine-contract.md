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

## Contract Scope

`v0.13.0` 定义 local evidence-driven readiness engine / 本地证据驱动就绪引擎。它承接 v0.12.0 readiness assessment sessions 和 v0.12.1 provenance hardening patch 的已完成事实，把 readiness assessment 从“可生成本地 assessment evidence”推进为“只能从真实本地 evidence root intake、校验、打包、登记、比较和导出”的 engine contract。

本 contract 是 `MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine` queue 的第一个 gate。它只定义输入、输出、证据根、schema contract、生命周期顺序和 fail-closed behavior；不实现 #995 之后的 evidence intake、build pipeline、validate、diff、CLI lifecycle 或 fixtures。#995 至 #1005 必须继续被 #994 阻塞，直到本 contract PR merged、required checks success、#994 closed / done、本地 `main == origin/main` 且 worktree clean。

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

#996 在 #995 intake gate 完成后，把 v0.13 normal manifest provenance 绑定到显式 local evidence root。CLI surface 固定为 `readiness build-v013 <assessmentID> <evidenceRoot>`；该命令必须先读取既有 local assessment entry，再调用 #995 intake model，最后只把 intake-derived sourceCommit、sourceRunIDs、artifact bytes 和 artifact checksums 写入 Manifest V2。

`readiness build-v013 <assessmentID> <evidenceRoot>` 不得从 assessmentID、generationID、固定字符串或 artifact checksum fallback 伪造 sourceRunID。它必须拒绝 placeholder sourceCommit、zero / demo commit、`gh-963-source-run`、`source-run-*` synthetic sourceRunID、缺失 artifact file、artifact byte / checksum mismatch，以及显式 `fixtureOnly=true` 或 `evidenceClassification=fixture` 的 fixture-only evidence。

Normal manifest 只能在 `normalManifestEligible=true`、`syntheticProvenanceRejected=true`、`fixtureOnly=false`、`localEvidenceTraceable=true` 时生成。#996 仍不写 readiness bundle、不推进 registry lifecycle、不执行 diff、不读取 production secret、不连接 production endpoint / broker endpoint、不发送 submit / cancel / replace，也不授权 production cutover。

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
| #1000 | evidence-level diff / compare | blocked by #998 |
| #1001 | transaction recovery forensic snapshot | blocked by #997 |
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

- 不实现 #997 之后的 build pipeline、bundle、registry lifecycle、diff、fixture suite 或 stage audit。
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
