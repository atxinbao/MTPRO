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

## V0120-007-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT

`GH-958-VERIFY-V0120-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT`

`TVM-RELEASE-V0120-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT`

`V0120-007-READINESS-BUNDLE-V2-JSON`

`V0120-007-READINESS-BUNDLE-V2-MANIFEST-JSON`

`V0120-007-REVIEW-SNAPSHOT-IMMUTABLE`

`V0120-007-NEW-GENERATION-ON-CHANGE`

`V0120-007-BUNDLE-MANIFEST-CHECKSUM`

v0.12.0 readiness bundle snapshot 固定为 assessment generation scoped 本地 review evidence。每个进入 review 的 generation 必须输出 `readiness-bundle-v2.json` 和 `readiness-bundle-v2.manifest.json`，路径固定为 `.local/mtpro/readiness/assessments/<assessmentID>/generations/<generationID>/readiness-bundle-v2.json` 和 `.local/mtpro/readiness/assessments/<assessmentID>/generations/<generationID>/readiness-bundle-v2.manifest.json`。

`readiness-bundle-v2.json` 必须记录 `assessmentID`、`generationID`、`reviewState=in-review`、`sourceRunIDs`、`sourceCommit`、`artifactSnapshots`、`bundleChecksum`、`immutableAfterReview=true` 和 `changeRequiresNewGeneration=true`。Artifact snapshot 只允许引用 Manifest V2 / content-policy validation checksum、redacted local artifact path 和 no-secret / no-order proof；不得保存 raw secret、raw listenKey、endpoint response、broker payload 或 order payload。

`readiness-bundle-v2.manifest.json` 必须记录 bundle JSON 的 `bundleChecksum`、实际 `bundleJSONSHA256`、`bundleBytes`、`schemaVersion=v0.12.0.readiness-bundle-manifest.v2`、`canonicalizationAlgorithm=canonical-json-sha256` 和 `manifestChecksum`。`bundleChecksum` 与 `manifestChecksum` 必须稳定可复算。

一旦同一 generation 的 bundle 进入 `in-review`，store 必须 fail closed 拒绝同 generation 原地修改。任何 artifact snapshot、source run、source commit、producer version 或 generated content 变化都必须创建新的 `generationID`，并写入新的 generation directory。该规则只保证 review snapshot immutability，不等于 approval、production cutover 或 trading permission。

`V0120-007-NO-PRODUCTION-CUTOVER`

Immutable readiness bundle snapshot 只强化本地 review evidence 的 generation immutability。它不授权 production cutover，不打开 production trading，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 testnet 或 production order，不创建下一 Project / Issue，不移动 tag / Release。

## V0120-008-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS

`GH-959-VERIFY-V0120-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS`

`TVM-RELEASE-V0120-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS`

`V0120-008-OBSERVED-EXPIRES-REVIEWED-SOURCE-EVIDENCE`

`V0120-008-DERIVED-FRESHNESS-AND-REVIEW-STATE`

`V0120-008-STALE-UNREVIEWED-MISMATCH-FAIL-CLOSED`

`V0120-008-APPROVAL-REQUEST-ONLY-NO-CUTOVER`

v0.12.0 kill switch / no-trade trustworthy observations 固定为对 GH-922 state model 的证据派生收紧。每个 observation snapshot 必须记录 `observedAt`、`expiresAt`、`reviewedAt`、`reviewedBy`、`sourceArtifact`、`sourceChecksum` 和 `sourceRunID`。`sourceArtifact` 必须是安全相对路径，`sourceChecksum` 必须是 `sha256:<64 lowercase hex>`，`sourceRunID` 必须非空。

freshness state 必须由 `observedAt`、`expiresAt`、当前 `evaluatedAt` 和 expected source evidence 匹配结果推导：未来观测时间为 `unknown`，过期或 invalid observation window 为 `stale`，source artifact / checksum / runID mismatch 为 `unavailable`，只有未过期且 source evidence 匹配时才是 `fresh`。

review state 必须由 `reviewedAt`、`reviewedBy`、observation window 和 expected source evidence 匹配结果推导：缺少复核时间或复核人时为 `pending`，复核时间早于 observation、晚于 evaluatedAt 或超出 expiresAt 时为 `unknown`，source artifact / checksum / runID mismatch 为 `unavailable`，只有 source evidence 匹配且复核时间落在有效窗口内时才是 `reviewed`。

stale / expired / unreviewed / mismatched source evidence 必须 fail closed。`inactive + fresh + reviewed` 只允许进入 approval-request eligibility；该 eligibility 不等于 production cutover approval，也不授权 order submit / cancel / replace。

`V0120-008-NO-PRODUCTION-CUTOVER`

Kill switch / no-trade trustworthy observations 只强化 readiness evidence 的可信派生。它不授权 production cutover，不打开 production trading，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 testnet 或 production order，不创建下一 Project / Issue，不移动 tag / Release。

## V0120-009-APPROVAL-ROLE-QUORUM-SEPARATION

`GH-960-VERIFY-V0120-APPROVAL-ROLE-QUORUM-SEPARATION`

`TVM-RELEASE-V0120-APPROVAL-ROLE-QUORUM-SEPARATION`

`V0120-009-REQUESTER-REVIEWER-APPROVER-ROLE-POLICY`

`V0120-009-QUORUM-SEPARATION-OF-DUTIES`

`V0120-009-APPROVAL-EXPIRY-REVOCATION-FAIL-CLOSED`

`V0120-009-BUNDLE-CHECKSUM-BINDING`

`V0120-009-TRANSITION-CHECKSUM-CHAIN`

v0.12.0 approval workflow hardening 固定为本地 readiness approval evidence 的角色和 quorum 收紧。Approval evidence 必须显式记录 requester、reviewer、approver 和 revoker role policy，并保持 separation of duties：requester 不得同时作为 reviewer 或 approver，reviewer 与 approver 不得互相代替。

Reviewer quorum 与 approver quorum 必须独立计算。Approver 不能自动计入 reviewer quorum，reviewer 也不能自动计入 approver quorum。Reviewer quorum 不足、approver quorum 不足、approvedBy 不在 approver role policy 内、requester 被当作 approver 或 role policy mismatch 都必须 fail closed。

Approval evidence 必须绑定 immutable readiness bundle checksum：`boundBundleChecksum` 必须等于 `expectedBundleChecksum`，且两者都必须是 `sha256:<64 lowercase hex>`。Bundle checksum mismatch 必须 fail closed，不得被解释为 partial approval。

Approval transition history 必须记录 `transitionChecksumChain`，并由每条 transition 的 from / to state、actor、timestamp 和 reason 稳定派生。Transition checksum chain mismatch 必须 fail closed。Expiry 与 revocation 继续保持 fail closed：过期 approval evidence、revoked approval evidence 或缺少 revocation reason 的 revoked state 都不能完成 approval evidence。

`V0120-009-NO-PRODUCTION-CUTOVER`

Approval roles / quorum hardening 只提高本地 approval evidence 的可信度。即使 `approvalEvidenceComplete=true`，它仍不授权 production cutover，不打开 production trading，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 testnet 或 production order，不创建下一 Project / Issue，不移动 tag / Release。

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

## V0120-010-SHADOW-PARITY-SOURCE-SNAPSHOT

`GH-961-VERIFY-V0120-SHADOW-PARITY-SOURCE-SNAPSHOT`

`TVM-RELEASE-V0120-SHADOW-PARITY-SOURCE-SNAPSHOT`

`V0120-010-SHADOW-PARITY-SOURCE-SNAPSHOT`

`V0120-010-SOURCE-RUN-MANIFEST-CHECKSUM`

`V0120-010-EVENT-ID-SET-BINDING`

`V0120-010-RISK-DECISION-ID-BINDING`

`V0120-010-OMS-DRY-RUN-LIFECYCLE-ID-BINDING`

`V0120-010-PORTFOLIO-PROJECTION-CHECKSUM-BINDING`

`V0120-010-RECONCILIATION-CHECKSUM-BINDING`

`V0120-010-NO-PRODUCTION-CUTOVER`

GH-961 将 v0.11.0 `shadow_dry_run_parity.json` 的本地 parity assessment 绑定到不可变 source run snapshot。snapshot 字段固定为 `sourceRunManifestChecksum`、`eventIDs`、`riskDecisionIDs`、`omsDryRunLifecycleIDs`、`portfolioProjectionChecksum`、`reconciliationChecksum` 和派生 `snapshotChecksum`。

`sourceSnapshotBindingHeld=true` 是 shadow parity 进入 `valid` 的必要条件；如果 source run manifest checksum、event ID set、risk decision ID set、OMS dry-run lifecycle ID set、portfolio projection checksum 或 reconciliation checksum 任一变化，artifact 必须输出 `sourceSnapshotMismatch=true`，assessment state 必须变为 `invalid`。

该绑定只校验本地 dry-run / shadow evidence 是否来自同一个不可变 source run snapshot，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 testnet 或 production order，不启用 production OMS、trading button、order form 或 live command。

## V0120-011-READINESS-ASSESSMENT-DIFF-COMPARE

`GH-962-VERIFY-V0120-READINESS-ASSESSMENT-DIFF-COMPARE`

`TVM-RELEASE-V0120-READINESS-ASSESSMENT-DIFF-COMPARE`

`V0120-011-READINESS-ASSESSMENT-DIFF-COMPARE`

`V0120-011-POLICY-ARTIFACT-RISK-KILL-APPROVAL-SECTIONS`

`V0120-011-SOURCE-RUN-EVIDENCE-COMPARISON`

`V0120-011-NON-MUTATING-COMPARE`

`V0120-011-NO-PRODUCTION-CUTOVER`

GH-962 允许为 operator review 比较两个本地 readiness assessment snapshot。比较 section 固定为 `policy`、`artifacts`、`risk-limits`、`kill-switch-state`、`approval-state` 和 `source-run-evidence`。

每个 snapshot 只允许携带 `policyChecksum`、`artifactBundleChecksum`、`riskLimitChecksum`、`killSwitchStateChecksum`、`approvalStateChecksum` 和 `sourceRunSnapshot`。`source-run-evidence` section 必须比较 GH-961 `ReleaseV0120ShadowParitySourceRunSnapshot.snapshotChecksum`，而不是重新读取 endpoint、secret、broker payload 或 order payload。

Compare 输出只能是 local operator review report，包含 matched / changed section、baseline / follow-up assessment ID、generation ID、`compareDoesNotMutateAssessments=true` 和稳定 `reportChecksum`。Compare 不得写回 registry，不得修改 assessment metadata，不得创建 approval，不得移动 tag / release，也不得授权 production cutover、production secret read、production endpoint / broker connection、testnet order 或 production order。

## V0120-012-ASSESSMENT-SCOPED-CLI-LIFECYCLE

`GH-963-VERIFY-V0120-ASSESSMENT-CLI-LIFECYCLE`

`TVM-RELEASE-V0120-ASSESSMENT-CLI-LIFECYCLE`

`V0120-012-ASSESSMENT-SCOPED-CLI-LIFECYCLE`

`V0120-012-CREATE-BUILD-STATUS-VALIDATE-EXPORT-ARCHIVE`

`V0120-012-COMPARE-LOCAL-ASSESSMENTS`

`V0120-012-INVALID-ASSESSMENT-ID-FAIL-CLOSED`

`V0120-012-LOCAL-REGISTRY-STORE-ONLY`

`V0120-012-NO-PRODUCTION-CUTOVER`

GH-963 只把 v0.12.0 readiness assessment lifecycle 暴露为本地 CLI：

- `mtpro readiness create [assessmentID]`
- `mtpro readiness build <assessmentID>`
- `mtpro readiness status <assessmentID>`
- `mtpro readiness validate <assessmentID>`
- `mtpro readiness export <assessmentID>`
- `mtpro readiness archive <assessmentID>`
- `mtpro readiness compare <baselineAssessmentID> <followUpAssessmentID>`

CLI implementation 固定在 `Sources/MTPROCLI/main.swift` 的 `ReleaseV0120ReadinessAssessmentCLI`。它只使用 `MTPRO_READINESS_ROOT` 或默认 `.local/mtpro/readiness` 作为本地 storage root，并通过 `ReadinessAssessmentRegistryStore` 读写 registry entry、manifest v2、readiness bundle v2 review snapshot 和 compare report。

`invalidAssessmentIDsFailClosed=true`：assessmentID 必须是 safe path component。空字符串、以 `-` 开头、`.`、`..`、`~`、包含 `/` 或 `\` 的值都必须在 CLI parser 层 fail closed，并输出 `mtpro.readiness.arguments`。

`localRegistryStoreOnly=true`：所有命令只产生或读取本地 redacted evidence。`compare` 只返回 operator-review-only report，不修改 assessment registry，不创建 approval，不移动 tag，不创建 GitHub Release。

Boundary flags 必须继续固定为：

- `productionTradingEnabledByDefault=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `brokerEndpointConnected=false`
- `productionOrderSubmitted=false`
- `testnetOrderSubmissionAllowed=false`
- `testnetOrderRoutingAllowed=false`
- `productionCutoverAuthorized=false`

GH-963 不读取 production secret，不连接 production endpoint / broker endpoint，不发送 testnet 或 production order，不实现 production OMS，不暴露 trading button / order form / live command，不授权 production cutover。

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
