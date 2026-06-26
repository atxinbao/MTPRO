# MTPRO Release v0.16.1 Operator Beta Evidence Hardening Patch Notes

日期：2026-06-26

执行者：Codex

## Summary

`MTPRO Release v0.16.1 Operator Beta Evidence Hardening Patch` 是 `v0.16.0` 后的 evidence hardening patch queue。v0.16.1 是后续 evidence hardening patch queue。GH-1133 只同步 `v0.16.0` stable GitHub Release 已发布事实，并把后续 v0.16.1 patch 语义固定为文档和验证 guard；它不移动 `v0.16.0` tag，不覆盖 GitHub Release，不创建 `v0.16.1` public release，不授权 production cutover。

`v0.16.0` stable GitHub Release 已由独立 Release Publication Gate 发布：

- Release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.16.0`
- tag peeled commit：`28779236262bd7ffaf71e286b27b95854c5cd3e1`
- publication timestamp：`2026-06-26T01:29:21Z`
- release type：stable；非 draft；非 prerelease

GH-1134 增加 manual evidence bundle content guard：workflow 必须读取 redacted bundle JSON 内容，并校验 schema、action sequence、checksum references、reconciliation 和 no-secret / no-production markers。GH-1135 将 v0.16 operator beta artifact redaction policy 收敛为 `ReleaseV0161OperatorBetaArtifactRedactionPolicy`，artifact store、manual workflow validator、Dashboard read model 和 tests 共同复用同一 forbidden marker / validation anchor source。GH-1136 增加 redaction regression coverage：Binance sensitive header、signed query marker、listenKey / secret variants、production Binance hosts、raw broker / order payload variants 都必须由同一共享 policy fail closed。GH-1137 澄清 status query evidence wording：`networkStatusQueryPerformed=false` 只属于 request evidence flag，表示 request construction evidence 不直接声明 transport side effect；guarded Testnet status transport result evidence 仍由 `ReleaseV0160BinanceSpotTestnetOrderStatusTransportResult` 单独记录。该分层不是 fabricated / mocked status wording，也不扩大为 production readiness。后续 #1138 仍必须按 GitHub fallback queue、WIP=1、dependency order 和 issue scope 单独执行。

## Validation Anchors

- `GH-1133-VERIFY-V0161-V0160-RELEASE-FACT-SYNC`
- `V0161-001-V0160-RELEASE-FACT-SYNC-GUARD`
- `TVM-RELEASE-V0161-V0160-RELEASE-FACT-SYNC`
- `V0161-001-V0160-TAG-FIXED`
- `V0161-001-PATCH-QUEUE-NOT-PUBLICATION`
- `V0161-001-NO-PRODUCTION-CUTOVER`
- `GH-1134-VERIFY-V0161-MANUAL-EVIDENCE-BUNDLE-CONTENT`
- `TVM-RELEASE-V0161-MANUAL-EVIDENCE-BUNDLE-CONTENT`
- `V0161-002-BUNDLE-SCHEMA-PARSED`
- `V0161-002-ACTION-SEQUENCE-CHECKED`
- `V0161-002-CHECKSUM-REFERENCES-CHECKED`
- `V0161-002-NO-SECRET-NO-PRODUCTION-MARKERS`
- `V0161-002-NO-PRODUCTION-CUTOVER`
- `GH-1135-VERIFY-V0161-CENTRAL-ARTIFACT-REDACTION-POLICY`
- `TVM-RELEASE-V0161-CENTRAL-ARTIFACT-REDACTION-POLICY`
- `V0161-003-SHARED-REDACTION-POLICY-SOURCE`
- `V0161-003-ARTIFACT-STORE-POLICY-USES-SHARED-SOURCE`
- `V0161-003-WORKFLOW-BUNDLE-POLICY-USES-SHARED-SOURCE`
- `V0161-003-DASHBOARD-READ-MODEL-POLICY-USES-SHARED-SOURCE`
- `V0161-003-NO-SECRET-NO-PRODUCTION-MARKERS`
- `V0161-003-NO-PRODUCTION-CUTOVER`
- `GH-1136-VERIFY-V0161-REDACTION-REGRESSION-COVERAGE`
- `TVM-RELEASE-V0161-REDACTION-REGRESSION-COVERAGE`
- `V0161-004-BINANCE-SENSITIVE-HEADER-MARKERS`
- `V0161-004-SIGNED-QUERY-MARKERS`
- `V0161-004-PRODUCTION-HOST-MARKERS`
- `V0161-004-RAW-BROKER-ORDER-PAYLOAD-MARKERS`
- `V0161-004-WORKFLOW-BUNDLE-REGRESSION-COVERAGE`
- `GH-1137-VERIFY-V0161-STATUS-QUERY-TRANSPORT-WORDING`
- `TVM-RELEASE-V0161-STATUS-QUERY-TRANSPORT-WORDING`
- `V0161-005-REQUEST-EVIDENCE-FLAG-CLARIFIED`
- `V0161-005-TRANSPORT-RESULT-EVIDENCE-CLARIFIED`
- `V0161-005-NO-FAKE-STATUS-QUERY-WORDING`
- `V0161-005-NO-PRODUCTION-READINESS-OVERSTATEMENT`

Focused verifier:

```bash
bash checks/verify-v0.16.1-release-fact-sync.sh
bash checks/verify-v0.16.1-manual-evidence-bundle-content.sh
bash checks/verify-v0.16.1-central-artifact-redaction-policy.sh
bash checks/verify-v0.16.1-redaction-regression-coverage.sh
bash checks/verify-v0.16.1-status-query-transport-wording.sh
```

Focused test:

```bash
swift test --filter TargetGraphTests/testGH1133ReleaseV0161V0160ReleaseFactSyncGuard
swift test --filter TargetGraphTests/testGH1134ReleaseV0161ManualEvidenceBundleContentValidationReadsBundle
swift test --filter TargetGraphTests/testGH1135ReleaseV0161CentralArtifactRedactionPolicyIsSharedAcrossSurfaces
swift test --filter TargetGraphTests/testGH1136ReleaseV0161RedactionRegressionCoverageRejectsSensitiveMarkers
swift test --filter TargetGraphTests/testGH1137ReleaseV0161StatusQueryTransportEvidenceWording
```

Full validation remains:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Patch Boundary

- `v0.16.1` 是 v0.16.0 后的 patch queue，不是新的 production cutover gate。
- `v0.16.0` tag remains fixed at `28779236262bd7ffaf71e286b27b95854c5cd3e1`。
- GH-1133 不创建、不移动、不重写任何 tag 或 GitHub Release。
- GH-1133 不推进 #1134..#1138；GH-1134 只处理 manual evidence bundle content validation；GH-1135 只处理 central artifact redaction policy，不推进 #1136..#1138；GH-1136 只处理 redaction regression coverage，不推进 #1137..#1138；GH-1137 只澄清 status query request-evidence flag 与 guarded Testnet transport-result evidence 的措辞，不推进 #1138；后续 issue 必须等待当前 issue 完整 Done 后再由 queue preflight 推进。
- production trading 仍默认关闭。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不发送 production submit / cancel / replace。
- 不授权 production cutover。
- production cutover not authorized。
