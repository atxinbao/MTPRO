# Release v0.12.0 Readiness Assessment Session No-authorization Contract

更新日期：2026-06-19  
执行者：Codex

`GH-952-VERIFY-V0120-READINESS-ASSESSMENT-SESSION-CONTRACT`

`TVM-RELEASE-V0120-READINESS-ASSESSMENT-SESSION-CONTRACT`

`V0120-001-READINESS-ASSESSMENT-SESSION-CONTRACT`

`GH-953-VERIFY-V0120-V011X-RELEASE-PATCH-FACTS`

`TVM-RELEASE-V0120-V011X-RELEASE-PATCH-FACTS`

`V0120-002-V0110-PUBLICATION-FACT`

`V0120-002-V0111-PATCH-FACT`

`V0120-002-CONSTRUCTION-PUBLICATION-CUTOVER-SEPARATION`

`V0120-002-NO-PRODUCTION-CUTOVER`

`GH-954-VERIFY-V0120-READINESS-ASSESSMENT-REGISTRY-STORE`

`TVM-RELEASE-V0120-READINESS-ASSESSMENT-REGISTRY-STORE`

`V0120-003-READINESS-ASSESSMENT-REGISTRY-STORE`

`V0120-003-REGISTRY-JSON-PATH`

`V0120-003-ASSESSMENT-DIRECTORY-PATH`

`V0120-003-CREATE-LIST-INSPECT-ARCHIVE-RECOVER`

`V0120-003-COMPARE-READY-METADATA`

`V0120-003-NO-PRODUCTION-CUTOVER`

`GH-955-VERIFY-V0120-ASSESSMENT-TRANSACTION-LOCK`

`TVM-RELEASE-V0120-ASSESSMENT-TRANSACTION-LOCK`

`V0120-004-ASSESSMENT-TRANSACTION-LOCK`

`V0120-004-TRANSACTION-ID-GENERATION-ID`

`V0120-004-STAGING-DIRECTORY-COMMIT-MARKER`

`V0120-004-COMPARE-AND-SWAP-MANIFEST`

`V0120-004-CRASH-RECOVERY-SEMANTICS`

`V0120-004-NO-PRODUCTION-CUTOVER`

`GH-956-VERIFY-V0120-READINESS-MANIFEST-V2`

`TVM-RELEASE-V0120-READINESS-MANIFEST-V2`

`V0120-005-READINESS-MANIFEST-V2`

`V0120-005-ASSESSMENT-GENERATION-PROVENANCE`

`V0120-005-SOURCE-RUN-COMMIT-PROVENANCE`

`V0120-005-CANONICAL-ARTIFACT-METADATA`

`V0120-005-PRODUCER-VERSION-SCHEMA`

`V0120-005-NO-PRODUCTION-CUTOVER`

`GH-957-VERIFY-V0120-ARTIFACT-CONTENT-POLICY-REDACTION`

`TVM-RELEASE-V0120-ARTIFACT-CONTENT-POLICY-REDACTION`

`V0120-006-ARTIFACT-CONTENT-POLICY`

`V0120-006-JSON-SCHEMA-ALLOWLIST`

`V0120-006-FORBIDDEN-FIELD-REJECTION`

`V0120-006-RAW-SECRET-LISTENKEY-REJECTION`

`V0120-006-ORDER-ENDPOINT-PAYLOAD-REJECTION`

`V0120-006-CONTENT-VALIDATION-CHECKSUM`

`V0120-006-NO-PRODUCTION-CUTOVER`

## Contract Scope

`v0.12.0` 定义 readiness assessment session / 就绪度评估会话。该会话只允许整理、校验、比较和展示本地 readiness evidence，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 testnet 或 production order。

本 contract 是 `MTPRO Release v0.12.0 readiness assessment sessions` queue 的第一个 gate。它继承 `v0.11.0` readiness evidence runtime 和 `v0.11.1` readiness runtime guard patch 的完成事实，但不移动、重写、覆盖或重新发布任何既有 tag / GitHub Release。

## V0120-002-V011X-RELEASE-PATCH-FACT-BASELINE

`V0120-002-V0110-PUBLICATION-FACT`

`V0120-002-V0111-PATCH-FACT`

`V0120-002-CONSTRUCTION-PUBLICATION-CUTOVER-SEPARATION`

v0.12.0 readiness assessment session 必须把 v0.11.x 已发生事实作为 baseline evidence，而不是重新解释、重新发布或扩大授权：

- v0.11.0 public GitHub Release 已通过独立 Release Publication Gate 完成：`https://github.com/atxinbao/MTPRO/releases/tag/v0.11.0`。
- v0.11.0 tag peeled commit 固定为 `13f592d0710de91351286e5c5490bfacb63c19b0`。
- v0.11.0 publication timestamp 固定为 `2026-06-19T01:20:58Z`。
- #924 是 v0.11.0 construction closeout，负责 Stage Code Audit、release notes、root docs refresh、aggregate verifier guard 和 focused closeout test；#924 本身不创建 tag / GitHub Release。
- v0.11.1 Readiness Runtime Guard Patch 是 v0.11.0 public GitHub Release 之后的 guard hardening closeout，覆盖 #945..#951。
- v0.11.1 patch closeout 不创建 `v0.11.1` tag，不创建 `v0.11.1` GitHub Release，不移动、不覆盖、不重写 `v0.11.0` tag 或 GitHub Release。
- v0.11.1 patch closeout 不推进 v0.12.0；只有 Parent Codex queue preflight 在 #951 / #952 merged、checks success、closed done、main fast-forward 后才能推进本 queue。
- construction closeout、public release publication、release fact sync / stale wording guard、v0.11.1 patch closeout 和 production cutover 必须继续保持独立 gate。

`V0120-002-NO-PRODUCTION-CUTOVER`

以上 baseline facts 只提供 assessment provenance。它们不授权 production cutover，不打开 production trading，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 testnet 或 production order，也不创建下一 Project / Issue。

## V0120-003-READINESS-ASSESSMENT-REGISTRY-STORE

`V0120-003-REGISTRY-JSON-PATH`

`V0120-003-ASSESSMENT-DIRECTORY-PATH`

`V0120-003-CREATE-LIST-INSPECT-ARCHIVE-RECOVER`

`V0120-003-COMPARE-READY-METADATA`

v0.12.0 readiness assessment registry store 固定为本地 metadata history store。它只允许写入 `.local/mtpro/readiness/registry.json`，并为每个 assessment 建立 `.local/mtpro/readiness/assessments/<assessmentID>/` 本地 evidence 目录。

Registry store 允许的操作固定为 create / list / inspect / archive / recover，以及读取 compare-ready metadata state。`compare-ready` 只表示该 assessment metadata 可以进入后续本地 diff / compare，不表示 production ready、operator approval、broker connection 或 order authority。

每个 registry entry 必须保存 assessmentID、source release / patch、artifact path、lifecycle state、comparison base、checksum 和 fail-closed metadata。assessmentID 必须是安全的本地路径组件；缺失、损坏或 checksum mismatch 的 registry 必须 fail closed。

Registry store 可以持有以下本地 metadata state：

- `baseline`
- `follow-up`
- `ready`
- `compare-ready`
- `blocked`
- `incomplete`
- `invalid`
- `stale`
- `superseded`
- `archived`
- `recovered`

`V0120-003-NO-PRODUCTION-CUTOVER`

Registry store 不授权 production cutover，不打开 production trading，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 testnet 或 production order，不创建下一 Project / Issue，不移动 tag / Release。

## V0120-004-ASSESSMENT-TRANSACTION-LOCK

`V0120-004-TRANSACTION-ID-GENERATION-ID`

`V0120-004-STAGING-DIRECTORY-COMMIT-MARKER`

`V0120-004-COMPARE-AND-SWAP-MANIFEST`

`V0120-004-CRASH-RECOVERY-SEMANTICS`

v0.12.0 readiness assessment registry write 必须使用本地 transaction control，防止同一个 assessment 被多个 writer 混写。每次写入必须携带 `transactionID`、`generationID` 和可选 `expectedPreviousGenerationID`。`generationID` 必须单调推进；当当前 compare-and-swap manifest 中的 generation 与 `expectedPreviousGenerationID` 不一致时，写入必须 fail closed 为 concurrent modification。

每个 assessment 的本地 lock 固定为 `.local/mtpro/readiness/assessments/<assessmentID>/assessment.lock`。每个 transaction 的 staging directory 固定为 `.local/mtpro/readiness/staging/<assessmentID>/<transactionID>/`，其中保存 `transaction-manifest.json` 和 staging `commit-marker.json`。成功提交后，store 必须写入 `.local/mtpro/readiness/assessments/<assessmentID>/compare-and-swap-manifest.json` 和 `.local/mtpro/readiness/assessments/<assessmentID>/commit-marker.json`，并移除 staging directory。

Transaction abort 必须释放 assessment lock、移除 staging directory，并输出本地 `abort-marker-<transactionID>.json`。Crash recovery 只允许清理残留 staging directory 和残留 assessment lock，并输出本地 recovery report；不得补写、推断或伪造 production approval、broker state、order state 或 endpoint state。

`V0120-004-NO-PRODUCTION-CUTOVER`

Assessment transaction lock / generation control 只强化本地 readiness metadata write consistency。它不授权 production cutover，不打开 production trading，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 testnet 或 production order，不创建下一 Project / Issue，不移动 tag / Release。

## V0120-005-READINESS-MANIFEST-V2

`V0120-005-ASSESSMENT-GENERATION-PROVENANCE`

`V0120-005-SOURCE-RUN-COMMIT-PROVENANCE`

`V0120-005-CANONICAL-ARTIFACT-METADATA`

`V0120-005-PRODUCER-VERSION-SCHEMA`

Readiness Manifest V2 固定为 assessment-scoped 本地 provenance schema。每个 manifest 必须包含 `assessmentID`、`generationID`、`sourceRunIDs`、`sourceCommit`、`schemaVersion`、`canonicalizationAlgorithm`、`artifactContentType`、`artifactSHA256`、`artifactBytes`、`createdAt` 和 `producerVersion`。字段组必须能证明当前 assessment generation 来自哪些本地 run evidence、哪个 source commit，以及被记录 artifact 的 canonical content metadata。

Manifest V2 的本地路径固定为 `.local/mtpro/readiness/assessments/<assessmentID>/manifest-v2.json`。`schemaVersion` 固定为 `v0.12.0.readiness-assessment-manifest.v2`，`canonicalizationAlgorithm` 固定为 `canonical-json-sha256`，`artifactSHA256` 必须是 `sha256:<64 lowercase hex>`，`sourceCommit` 必须是 40 位 lowercase hex commit。`sourceRunIDs / sourceCommit / artifactSHA256 / artifactBytes / producerVersion` 是 provenance 必填字段。

`V0120-005-NO-PRODUCTION-CUTOVER`

Manifest V2 只强化本地 readiness assessment provenance。它不授权 production cutover，不打开 production trading，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 testnet 或 production order，不创建下一 Project / Issue，不移动 tag / Release。

## V0120-006-ARTIFACT-CONTENT-POLICY

`V0120-006-JSON-SCHEMA-ALLOWLIST`

`V0120-006-FORBIDDEN-FIELD-REJECTION`

`V0120-006-RAW-SECRET-LISTENKEY-REJECTION`

`V0120-006-ORDER-ENDPOINT-PAYLOAD-REJECTION`

`V0120-006-CONTENT-VALIDATION-CHECKSUM`

v0.12.0 artifact content-policy 固定为 assessment artifact 的本地 JSON evidence redaction validator。每个 policy 必须记录 `policyVersion`、`artifactID`、`artifactContentType`、`allowedJSONFields`、`requiredJSONFields`、`forbiddenJSONFields`、`forbiddenRawMarkers` 和 `policyChecksum`。`schemaVersion` 固定为 `v0.12.0.artifact-content-policy.v1`，`checksumAlgorithm` 固定为 `canonical-json-sha256`。

Artifact content validation 只接受 Manifest V2 声明的 `jsonEvidence` artifact。validator 必须重新 canonicalize artifact JSON、重新计算 `artifactSHA256`，并确认 artifact top-level JSON fields 只出现在 `allowedJSONFields` 内，所有 `requiredJSONFields` 都存在，递归 JSON field name 没有命中 `forbiddenJSONFields`，raw payload 没有命中 `forbiddenRawMarkers`。验证成功时必须输出 `contentValidationChecksum`，并把 validation state 固定为 `valid`。

Artifact content-policy 必须 fail closed 拒绝 raw secret、raw listenKey、private payload、order payload、production endpoint response、unexpected top-level field、missing required field 和 artifact SHA256 mismatch。禁止字段和 marker 至少覆盖 `secret`、`signature`、`listenKey`、`privatePayload`、`orderId`、`clientOrderId`、`quantity`、`price`、`side`、`type`、`serverTime`、`balances`、`/api/v3/account`、`/api/v3/order`、`/api/v3/userDataStream`、`X-MBX-APIKEY`、`api.binance.com`、`listenKey=`、`raw-secret` 和 `raw-listen-key`。

`V0120-006-NO-PRODUCTION-CUTOVER`

Artifact content-policy / redaction validator 只验证本地 readiness artifact 内容是否符合 allowlist 和 redaction policy。它不授权 production cutover，不打开 production trading，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 testnet 或 production order，不创建下一 Project / Issue，不移动 tag / Release。

## V0120-001-READINESS-ASSESSMENT-SESSION-CONTRACT

允许的 assessment session 固定为本地、显式、可审计的 no-authorization session：

- `assessmentSessionAllowed=true`
- `assessmentSessionLocalOnly=true`
- `assessmentSessionRequiresExplicitInput=true`
- `assessmentSessionMayReadLocalReadinessArtifacts=true`
- `assessmentSessionMayBuildDerivedReadModels=true`
- `assessmentSessionMayRecordHistory=true`
- `assessmentSessionMayComparePreviousAssessments=true`
- `assessmentSessionMayExportRedactedEvidence=true`

禁止将 assessment session 解释为 approval、cutover、runtime launch、broker connection 或 order authority。任何 assessment result 只能表达 `ready` / `blocked` / `incomplete` / `invalid` / `stale` 等证据状态，不能表达交易许可。

## V0120-001-EVIDENCE-PROVENANCE-MODEL

`V0120-001-EVIDENCE-PROVENANCE-MODEL`

每个 assessment session 必须保留 evidence provenance / 证据来源：

- source release / patch，例如 `v0.11.0`、`v0.11.1`
- source issue / PR / check evidence reference
- source artifact path 或 redacted external reference
- canonical checksum / content hash reference
- validation command reference
- assessment generatedAt / assessedBy / reason
- fail-closed classification when provenance is missing, stale, unreadable or checksum-mismatched

Assessment session 不得接受 raw secret value、listenKey value、production endpoint token、broker payload 或 order payload 作为 provenance。

## V0120-001-MULTI-ASSESSMENT-HISTORY

`V0120-001-MULTI-ASSESSMENT-HISTORY`

v0.12.0 允许同一 release readiness scope 存在多次 assessment history。历史记录必须是 append-only evidence lineage，并至少区分：

- baseline assessment
- follow-up assessment
- superseded assessment
- blocked assessment
- invalid assessment

后续 issue 可在本 contract 内实现 registry、transaction lock、manifest v2、content-policy、snapshot、kill switch observation、approval quorum、shadow parity source snapshot、diff / compare、CLI lifecycle、Dashboard history 和 final audit closeout。所有后续能力都只能消费或生成本地 readiness assessment evidence，不授权 production cutover。

## V0120-001-FORBIDDEN-PRODUCTION-CAPABILITIES

`V0120-001-FORBIDDEN-PRODUCTION-CAPABILITIES`

v0.12.0 assessment session 必须固定以下 forbidden capability flags：

- `productionTradingEnabledByDefault=false`
- `productionCutoverAuthorized=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `brokerEndpointConnected=false`
- `productionBrokerConnected=false`
- `productionOrderSubmitted=false`
- `realOrderSubmissionEnabled=false`
- `testnetOrderSubmissionAllowed=false`
- `testnetOrderRoutingAllowed=false`
- `productionOMSImplemented=false`
- `tradingButtonEnabled=false`
- `orderFormEnabled=false`
- `liveCommandEnabled=false`

任何后续实现如果需要真实 secret、production endpoint、broker connection、submit / cancel / replace、production OMS 或 production cutover authorization，必须停止并重新规划；本 v0.12.0 contract 不授权这些能力。

## V0120-001-NO-PRODUCTION-CUTOVER

`V0120-001-NO-PRODUCTION-CUTOVER`

Assessment session 的最高权限是形成本地 readiness evidence。即使所有 evidence 均为 `ready`，结果仍不能自动打开 production trading，也不能自动发起 broker connection 或 production endpoint connection。

Production cutover 仍是独立 human-approved gate。v0.12.0 只加强 readiness assessment 可信度，不改变 no-default-production-trading policy。

## V0120-001-DOWNSTREAM-QUEUE-ORDER

`V0120-001-DOWNSTREAM-QUEUE-ORDER`

v0.12.0 canonical queue 固定为：

1. `GH-952 V0120-001 Define v0.12.0 readiness assessment session no-authorization contract`
2. `GH-953 V0120-002 Align v0.11.x release publication and patch facts`
3. `GH-954 V0120-003 Add ReadinessAssessmentRegistryStore`
4. `GH-955 V0120-004 Add assessment transaction lock and generation control`
5. `GH-956 V0120-005 Add Readiness Manifest V2 and provenance schema`
6. `GH-957 V0120-006 Add artifact content-policy and redaction validator`
7. `GH-958 V0120-007 Add immutable readiness bundle snapshot`
8. `GH-959 V0120-008 Add trustworthy kill switch and no-trade observations`
9. `GH-960 V0120-009 Harden approval roles quorum and separation of duties`
10. `GH-961 V0120-010 Bind shadow parity to immutable source run snapshot`
11. `GH-962 V0120-011 Add readiness assessment diff and compare`
12. `GH-963 V0120-012 Add assessment-scoped CLI lifecycle`
13. `GH-964 V0120-013 Add Dashboard assessment history and adversarial CI`
14. `GH-965 V0120-014 Close v0.12.0 final audit docs and runbook`

每个 downstream issue 必须等待前序 issue merged / checks success / closed done / main fast-forward 后，才能由 Parent Codex queue preflight 推进。

## V0120-001-RELEASE-VALIDATION-MATRIX

`V0120-001-RELEASE-VALIDATION-MATRIX`

本 contract 的验证入口固定为：

- `checks/verify-v0.12.0.sh`
- `checks/automation-readiness.sh`
- `checks/run.sh`
- `Tests/TargetGraphTests/TargetGraphTests.swift::testGH952ReleaseV0120ReadinessAssessmentSessionNoAuthorizationContract`
- `docs/validation/validation-plan.md` 的 `GH-952 Release v0.12.0 Readiness Assessment Session No-authorization Contract Validation`
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RELEASE-V0120-READINESS-ASSESSMENT-SESSION-CONTRACT`

这些验证只证明 no-authorization readiness assessment contract 存在且被 automation guard 覆盖，不证明 production cutover readiness，也不授权任何真实交易动作。
