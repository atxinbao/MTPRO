# Release v0.11.0 Production Readiness Evidence Runtime Contract

日期：2026-06-18

执行者：Codex

本文档服务 GitHub fallback issue `GH-913 V0110-001 Define production readiness evidence runtime contract`。

本文档只定义 `MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening` 的本地 readiness evidence runtime 合同。它把 v0.10.0 reference readiness evidence 模型推进为本地证据 artifact lifecycle、manifest、checksum、validation 和 operator approval evidence 边界，但不授权 production cutover，不读取 production secret value，不连接 production endpoint 或 broker endpoint，不提交、取消或替换 testnet / production order，不启用 production OMS、trading button、order form 或 live command。

## V0110-002-PRODUCTION-READINESS-ARTIFACT-STORE

`V0110-002-PRODUCTION-READINESS-ARTIFACT-STORE`

`GH-914-VERIFY-V0110-PRODUCTION-READINESS-ARTIFACT-STORE`

`TVM-RELEASE-V0110-PRODUCTION-READINESS-ARTIFACT-STORE`

GH-914 在 GH-913 合同之后增加 `ProductionReadinessArtifactStore`。Store 的授权范围固定为本地文件系统 evidence root：

- `V0110-002-LOCAL-EVIDENCE-ROOT`
- `V0110-002-ARTIFACT-STATES`
- `V0110-002-READ-WRITE-PRIMITIVES`
- `V0110-002-NO-PRODUCTION-SECRET-ENDPOINT-ORDER`

Artifact store 必须满足：

- approved local evidence root 只能是 file URL，本地默认 root 为 `.local/mtpro/readiness/v0.11.0`；
- artifact descriptor 只能使用 safe relative path，拒绝绝对路径、`..`、空路径和 `~` 逃逸；
- artifact state 必须显式表达 `missing`、`invalid`、`stale`、`valid`，不能硬编码 `evidenceExists=true`；
- write primitive 只能写本地 JSON / text evidence，必须拒绝空 payload、invalid JSON 和 forbidden production true flag；
- read primitive 只能读取 `valid` 本地 artifact；
- snapshot 必须统计 missing / invalid / stale / valid 数量；
- store record 必须固定 `productionTradingEnabledByDefault=false`、`productionSecretRead=false`、`productionEndpointConnected=false`、`brokerEndpointConnected=false`、`productionOrderSubmitted=false`、`testnetOrderSubmissionAllowed=false` 和 `productionCutoverAuthorized=false`。

GH-914 不实现 readiness manifest schema、atomic manifest write order、canonical JSON SHA256、Dashboard real artifact binding、CLI build / status / validate / export / approval-status runtime、approval transition 或 shadow parity runner；这些能力必须留给后续 GH-915 至 GH-924。

## V0110-003-READINESS-MANIFEST-SCHEMA

`V0110-003-READINESS-MANIFEST-SCHEMA`

`GH-915-VERIFY-V0110-READINESS-MANIFEST-ATOMIC-IO`

`TVM-RELEASE-V0110-READINESS-MANIFEST-ATOMIC-IO`

GH-915 在 GH-914 的 local artifact store 之上增加 readiness manifest schema 和 atomic JSON artifact IO。当前授权范围固定为本地 readiness evidence integrity hardening：

- `V0110-003-ATOMIC-JSON-ARTIFACT-IO`
- `V0110-003-MANIFEST-POLICY-VERSION`
- `V0110-003-MANIFEST-ENTRY-STATE-VALIDATION`
- `V0110-003-EVIDENCE-EXISTS-IS-NOT-SUFFICIENT`

Manifest entry 必须包含 artifact path、artifact type、size、checksum、createdAt、policy version 和 validation state。`evidenceExists` 只能作为审计字段，不能单独证明 artifact valid；manifest 读取时必须重新 inspect/read 本地 artifact，并拒绝 malformed、missing、stale、policy-mismatched、size-mismatched 或 checksum-mismatched entry。

Atomic JSON IO 固定为本地 file artifact write，不连接 endpoint，不读取 secret，不产生 broker session，不提交 testnet 或 production order。GH-915 建立 manifest 与真实 artifact payload 的重新验证路径；GH-916 接管最终 checksum policy，把 manifest entry checksum 固定为 canonical JSON SHA256。

GH-915 不实现 Dashboard real artifact binding、CLI build / status / validate / export / approval-status runtime、approval transition、shadow parity runner、production cutover、production OMS、trading button、order form 或 live command path。

## V0110-004-CANONICAL-JSON-SHA256

`V0110-004-CANONICAL-JSON-SHA256`

`GH-916-VERIFY-V0110-CANONICAL-JSON-SHA256-CHECKSUM`

`TVM-RELEASE-V0110-CANONICAL-JSON-SHA256-CHECKSUM`

GH-916 在 GH-915 manifest schema 之上替换 readiness checksum policy。授权范围只覆盖本地 canonical JSON bytes 和 `sha256:<64 hex>` checksum：

- `V0110-004-CHECKSUM-FORMAT-VALIDATION`
- `V0110-004-CHECKSUM-MISMATCH-FAILS-CLOSED`
- `V0110-004-NO-PLACEHOLDER-CHECKSUMS`

Canonical JSON 固定为 sorted key、无 pretty whitespace、不转义 slash 的本地 JSON bytes。Manifest entry checksum 必须使用真实 canonical JSON SHA256，格式必须是 `sha256:` 加 64 位小写十六进制 digest。`sha256:gh890-secret-readiness`、`fnv1a64-*` 或其他占位 / 非 SHA256 checksum 必须 fail closed。

Manifest read 必须重新读取真实 artifact，重新计算 canonical JSON SHA256，并在 checksum mismatch 时拒绝该 readiness evidence。该校验不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover。

GH-916 不实现 readiness bundle validation、Dashboard real artifact binding、CLI build / status / validate / export / approval-status runtime、approval transition、shadow parity runner、production OMS、trading button、order form 或 live command path。

## V0110-005-READINESS-BUNDLE-VALIDATION

`V0110-005-READINESS-BUNDLE-VALIDATION`

`GH-917-VERIFY-V0110-READINESS-BUNDLE-VALIDATION`

`TVM-RELEASE-V0110-READINESS-BUNDLE-VALIDATION`

GH-917 在 GH-916 canonical JSON SHA256 之上增加本地 readiness bundle validation。授权范围只覆盖本地 manifest 与 manifest entries 指向的本地 artifact：

- `V0110-005-REQUIRED-ARTIFACT-SET`
- `V0110-005-BUNDLE-VALIDATION-STATES`
- `V0110-005-POLICY-VERSION-BLOCKED`
- `V0110-005-CHECKSUM-MISMATCH-STATE`
- `V0110-005-NO-PRODUCTION-CUTOVER`

Bundle validation 必须重新校验 manifest schema、artifact existence、canonical JSON SHA256 checksum、size、timestamp、policy version 和 required artifact set。Validation state 固定为 `not-evaluated`、`valid`、`blocked`、`stale`、`missing`、`invalid` 和 `checksum-mismatch`。`valid` 只表示本地 readiness bundle integrity pass，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order。

GH-917 不实现 Dashboard real artifact binding、CLI build / status / validate / export / approval-status runtime、approval transition、shadow parity runner、production OMS、trading button、order form 或 live command path。

## V0110-001-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT

`V0110-001-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT`

GH-913 是 V0110 queue `GH-913..GH-924` 的第一个 gate。当前权威 source anchor：

- `docs/contracts/release-v0.11.0-production-readiness-evidence-runtime-contract.md`
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RELEASE-V0110-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT`
- `checks/verify-v0.11.0.sh`

合同固定：

- release version 固定为 `v0.11.0`
- project name 固定为 `MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening`
- queue range 固定为 `GH-913..GH-924`
- v0.10.0 readiness reference model 只能作为输入语义，不能自动转换为 production trading permission
- v0.11.0 只允许本地 readiness evidence runtime 和 integrity hardening
- 后续 issue 执行前必须通过 GitHub fallback queue preflight
- 所有 v0.11.0 evidence 只能证明本地 readiness artifact integrity，不得转换为 production cutover authorization。

## V0110-001-LOCAL-READINESS-ARTIFACT-RUNTIME

`V0110-001-LOCAL-READINESS-ARTIFACT-RUNTIME`

v0.11.0 允许建设本地 evidence runtime。Allowed local runtime scope 固定为：

- `readinessArtifactRuntimeAllowed=true`
- `productionReadinessArtifactStoreAllowed=true`
- `localArtifactStoreAllowed=true`
- `manifestValidationAllowed=true`
- `canonicalJSONSHA256Allowed=true`
- `dashboardReadModelBindingAllowed=true`
- `readinessCLIAllowed=true`
- `approvalWorkflowEvidenceAllowed=true`
- `shadowDryRunParityEvidenceAllowed=true`

以上 allowed scope 只授权本地 artifact、manifest、checksum、Dashboard read-model、CLI evidence command 和 approval evidence 的离线验证。它不授权 endpoint connection、secret resolution、broker session、OMS production lifecycle 或订单路径。

## V0110-001-READINESS-ARTIFACT-LIFECYCLE

`V0110-001-READINESS-ARTIFACT-LIFECYCLE`

readiness artifact lifecycle 固定为：

1. `collect-reference-evidence`：收集 v0.10.0 readiness reference evidence、v0.10.1 audit hardening evidence 和本地 run evidence 引用。
2. `build-local-bundle`：在本地 artifact store 中生成 readiness bundle 草案。
3. `validate-integrity`：校验 manifest、checksum、schema version、redaction proof、secret absence、order payload absence 和 forbidden capability flags。
4. `export-readonly-evidence`：导出只读 evidence bundle 供审计或 Dashboard / CLI 读取。
5. `approval-review-evidence`：记录 manual approval workflow 的 evidence 状态，但不把 approval evidence 转换为 cutover authorization。
6. `closeout-audit`：输出 Stage Audit input、validation summary 和 release notes evidence。

生命周期中没有 `production-cutover`、`broker-connect`、`order-submit`、`order-cancel`、`order-replace` 或 `production-oms-start` 状态。

## V0110-001-RUNTIME-STATES

`V0110-001-RUNTIME-STATES`

runtime state 固定为：

- `draft`
- `building`
- `built`
- `validated`
- `exported`
- `approval-review`
- `blocked`
- `invalid`

状态语义固定：

- `validated` 只表示本地 bundle integrity pass。
- `exported` 只表示 evidence 已以只读形式导出。
- `approval-review` 只表示 manual review evidence 已进入审查态。
- `blocked` 和 `invalid` 必须 fail closed，不能触发 fallback endpoint、secret read、broker connection 或 order command。
- 任一状态都不能代表 production cutover authorization。

## V0110-001-MANIFEST-CHECKSUM-RULES

`V0110-001-MANIFEST-CHECKSUM-RULES`

readiness manifest 必须至少包含：

- `schemaVersion`
- `releaseVersion=v0.11.0`
- `artifactID`
- `createdAt`
- `sourceEvidence`
- `entries`
- `path`
- `artifactType`
- `byteCount`
- `sha256`
- `redactionProof=true`
- `noSecretValue=true`
- `noOrderPayload=true`
- `productionCutoverAuthorized=false`

checksum 规则固定为：

- JSON evidence 使用 canonical JSON UTF-8 表达。
- canonical JSON key order 必须稳定。
- artifact checksum 使用 SHA256。
- manifest 必须在所有 artifact 写入和 checksum 计算后最后写入。
- manifest 缺失、checksum mismatch、schemaVersion 不匹配、未知 artifact type、secret value 泄漏、order payload 泄漏或 forbidden capability true flag 必须 fail closed。

## V0110-001-ALLOWED-LOCAL-COMMANDS

`V0110-001-ALLOWED-LOCAL-COMMANDS`

v0.11.0 允许的本地 CLI command surface 固定为：

- `mtpro readiness build`
- `mtpro readiness status`
- `mtpro readiness validate`
- `mtpro readiness export`
- `mtpro readiness approval-status`

这些 command 只能操作本地 readiness evidence runtime 和本地 artifact store。它们不得读取 production secret，不得连接 endpoint 或 broker，不得发送 testnet / production order，不得启动 production OMS，不得提供 submit / cancel / replace alias。

## V0110-001-FORBIDDEN-PRODUCTION-CAPABILITIES

`V0110-001-FORBIDDEN-PRODUCTION-CAPABILITIES`

v0.11.0 contract 固定 forbidden capability flags：

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

任何 verifier、Dashboard、CLI、artifact manifest 或 Stage Audit 文档出现对应 `true` 值都必须视为 release boundary violation。

## V0110-001-DASHBOARD-CLI-POLICY-KILL-SWITCH-APPROVAL-SHADOW-PARITY-BOUNDARIES

`V0110-001-DASHBOARD-CLI-POLICY-KILL-SWITCH-APPROVAL-SHADOW-PARITY-BOUNDARIES`

下游 V0110 issue 必须保持以下边界：

- artifact store：只保存本地 readiness artifact、manifest 和 checksum evidence。
- manifest：只表达本地 evidence inventory、checksum、redaction 和 forbidden capability state。
- Dashboard：只能读取 artifact read-model，不显示 trading button、order form、live command、submit / cancel / replace command。
- CLI：只能执行 allowed local readiness commands，不暴露 broker command。
- policy：capital / exposure policy 只作为 readiness evidence 和 validation input，不触发 RiskEngine production order permission。
- kill switch / no-trade：状态必须参与 readiness validation，并且 fail closed。
- approval workflow：manual approval evidence 只能记录审查状态，不等于 production cutover authorization。
- shadow parity：只验证 local dry-run / shadow evidence parity，不创建 broker command 或 order payload。

## V0110-001-DOWNSTREAM-QUEUE-ORDER

`V0110-001-DOWNSTREAM-QUEUE-ORDER`

V0110 canonical queue 固定为：

1. `GH-913 V0110-001 Define production readiness evidence runtime contract`
2. `GH-914 V0110-002 Add ProductionReadinessArtifactStore`
3. `GH-915 V0110-003 Add readiness manifest schema and atomic artifact IO`
4. `GH-916 V0110-004 Replace hardcoded checksums with canonical JSON SHA256`
5. `GH-917 V0110-005 Add readiness bundle validation`
6. `GH-918 V0110-006 Add real shadow dry-run parity runner from local run evidence`
7. `GH-919 V0110-007 Wire Dashboard Production Readiness Center to real artifact state`
8. `GH-920 V0110-008 Implement readonly mtpro readiness build/status/validate/export/approval status`
9. `GH-921 V0110-009 Convert capital / exposure limits to fixed-point policy types`
10. `GH-922 V0110-010 Expand kill switch / no-trade state model`
11. `GH-923 V0110-011 Add auditable approval workflow transitions`
12. `GH-924 V0110-012 Close v0.11.0 validation suite / stage audit / release docs`

WIP=1 仍是强制规则。只有当前 issue PR merged、required `checks` SUCCESS、issue closed/done、本地 `main == origin/main` 且 worktree clean 后，才能 preflight 下一个 issue。

## V0110-001-RELEASE-VALIDATION-MATRIX

`V0110-001-RELEASE-VALIDATION-MATRIX`

本 issue 的最小验证链为：

- `GH-913-VERIFY-V0110-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT`
- `TVM-RELEASE-V0110-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT`
- `checks/verify-v0.11.0.sh`
- `testGH913ReleaseV0110ProductionReadinessEvidenceRuntimeContract`

Validation 必须证明：

- v0.11.0 只定义本地 readiness evidence runtime contract；
- artifact lifecycle、runtime states、manifest、checksum、Dashboard、CLI、policy、kill switch、approval workflow 和 shadow parity boundaries 都已写入合同；
- production cutover 仍未授权；
- production trading、secret read、endpoint / broker connection、testnet / production order path、production OMS、trading button、order form 和 live command 全部保持 disabled / false。
