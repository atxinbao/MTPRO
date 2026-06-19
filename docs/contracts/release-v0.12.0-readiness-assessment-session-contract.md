# Release v0.12.0 Readiness Assessment Session No-authorization Contract

更新日期：2026-06-19  
执行者：Codex

`GH-952-VERIFY-V0120-READINESS-ASSESSMENT-SESSION-CONTRACT`

`TVM-RELEASE-V0120-READINESS-ASSESSMENT-SESSION-CONTRACT`

`V0120-001-READINESS-ASSESSMENT-SESSION-CONTRACT`

## Contract Scope

`v0.12.0` 定义 readiness assessment session / 就绪度评估会话。该会话只允许整理、校验、比较和展示本地 readiness evidence，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 testnet 或 production order。

本 contract 是 `MTPRO Release v0.12.0 readiness assessment sessions` queue 的第一个 gate。它继承 `v0.11.0` readiness evidence runtime 和 `v0.11.1` readiness runtime guard patch 的完成事实，但不移动、重写、覆盖或重新发布任何既有 tag / GitHub Release。

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
