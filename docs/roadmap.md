# docs/roadmap.md

本文档是 Construction Plan / 施工路线。它是 `BLUEPRINT.md` 的二级权重承接文档，根据蓝图和工程模块定义施工顺序、进度和下一阶段 handoff。

ROADMAP 只定义阶段地图，不授权执行。正式执行必须来自 Human 指定的唯一 live queue source；`MTPRO Release v0.12.0 Readiness Assessment Sessions` 使用 GitHub fallback issue queue，不使用 Linear。

完整产品终局和 Future Construction Zones / 未来建设区见 `BLUEPRINT.md`；工程模块细节见 `architecture.md`。

## Target Goal Revision / 目标口径修正

截至 2026-06-27，MTPRO 长期目标从“Binance-first 专业交易工作台”修正为“Binance + OKX 的实盘原生交易系统”：

```text
Venue
  Binance
    Spot
    USDⓈ-M Futures
  OKX
    Spot
    Swap
```

当前实现和当前 release queue 仍不得被误读为完整目标已实现。Binance Spot 是当前最成熟 testnet / operator beta path；Binance USDⓈ-M Futures、OKX Spot、OKX Swap 是后续目标能力，需要独立 venue / product-aware planning、GitHub issues、PR evidence、validation gates 和 Human approval。Bybit Spot / Linear Perpetual 只作为 future candidate，当前不进入 active roadmap commitment。

路线优先级固定为 Binance-first dual-product path：

| Version | 路线定位 | 不允许越界 |
| --- | --- | --- |
| v0.19.1 | v0.19.0 release fact / stale wording patch | patch-only，不新增交易能力 |
| v0.20.0 | Binance Spot production-shadow / read-only live readiness | 不提交订单，不开启 Spot canary |
| v0.21.0 | Binance Spot controlled production canary | 仅 Human-approved 小额度 Spot canary，不混入 Futures / OKX |
| v0.22.0 | Binance USDⓈ-M Futures read-only foundation | 只读 account / position / margin / leverage / funding，不执行 Futures order |
| v0.23.0 | Binance USDⓈ-M Futures testnet execution closed loop | Futures testnet only，不进入 production futures |
| v0.24.0 | Spot + Futures 统一 OMS / Portfolio / Risk / Reconciliation | 统一双产品底层，不允许两套割裂 OMS / Portfolio / Risk / Reconciliation |
| v0.25.0 | Binance dual-product production readiness / canary hardening | readiness / canary hardening only，production cutover 仍需单独 Human gate |

执行顺序必须保持：先完成 v0.19.1；v0.20.0 只做 Binance Spot read-only / production-shadow；v0.21.0 才允许 Spot 小额 canary；Futures 从 v0.22.0 read-only foundation 开始，v0.23.0 才进入 testnet execution；v0.24.0 再统一 Spot + Futures 的 OMS / Portfolio / Risk / Reconciliation；v0.25.0 才做 Binance dual-product production readiness / canary hardening。OKX Spot / Swap 延后到 Binance dual-product path 收敛之后。

v0.20.0 首个合同 anchor：`GH-1239-VERIFY-V0200-PRODUCTION-SHADOW-READINESS-CONTRACT`、`TVM-RELEASE-V0200-PRODUCTION-SHADOW-READINESS-CONTRACT`、`V0200-001-V0191-PREFLIGHT-GATE`、`V0200-001-BINANCE-SPOT-PRODUCTION-SHADOW`、`V0200-001-READ-ONLY-LIVE-READINESS`、`V0200-001-NO-ORDER-SUBMIT-CANCEL-REPLACE`、`V0200-001-SPOT-CANARY-DEFERRED-TO-V0210`、`V0200-001-QUEUE-ORDER`、`V0200-001-NO-PRODUCTION-CUTOVER`。

v0.20.0 environment profile anchor：`GH-1240-VERIFY-V0200-PRODUCTION-SHADOW-ENVIRONMENT-PROFILE`、`TVM-RELEASE-V0200-PRODUCTION-SHADOW-ENVIRONMENT-PROFILE`、`V0200-002-BINANCE-SPOT-PRODUCTION-SHADOW-PROFILE`、`V0200-002-CREDENTIAL-REFERENCE-NO-SECRET-VALUE`、`V0200-002-ENDPOINT-INTENT-NO-CONNECTION`、`V0200-002-OPERATOR-READINESS-STATE`、`V0200-002-READ-ONLY-FAIL-CLOSED`、`V0200-002-FUTURES-OKX-OUT-OF-SCOPE`、`V0200-002-NO-PRODUCTION-CUTOVER`。

该目标修正只更新路线方向，不授权 production trading、不读取 production secret、不连接 production endpoint / broker endpoint、不创建 OKX active source 或 order path。

## Roadmap Responsibility / 路线职责

`docs/roadmap.md` 只回答四个问题：

1. 已完成哪些建设阶段。
2. 当前目标切片完成到哪里。
3. 下一轮 planning 应该从哪些未完成切片里选择。
4. Project closure 后如何反写进度和 handoff。

它不定义最终产品终局，不定义工程模块细节，不授权执行。

## Roadmap Inputs / 路线输入

路线更新必须按以下输入顺序读取：

```text
GOAL.md
-> BLUEPRINT.md
-> architecture.md
-> docs/audit/<project-stage-code-audit>.md
-> docs/validation/latest-verification-summary.md
-> approved live queue source state
```

输入解释：

- `GOAL.md` 提供目标切片和硬边界。
- `BLUEPRINT.md` 提供完整产品终局、Current / Future 分界和 Live gates。
- `architecture.md` 提供工程模块地图和模块依赖方向。
- `docs/audit/` 提供已完成 Project 的事实证据。
- `docs/validation/latest-verification-summary.md` 提供最近验证和当前边界。
- approved live queue source 只用于确认 Project / issue 当前状态，不写死到本文档中；`MTPRO Release v0.9.0 Testnet No-order Observability` 的 live queue source 是 GitHub fallback issue queue。

## Completed Project Map / 已完成阶段地图

| 阶段族群 | 状态 | 压缩结果 |
| --- | --- | --- |
| Foundation / Paper / Workbench | Completed | 引导、Research / Backtest / Report、Paper Session / Execution / Control Shell、Market Replay Operations 已完成；完整证据见 `docs/audit/`。 |
| Live boundary / read-model-only | Completed | Live foundation、monitoring、execution control、risk gate、audit / incident / stop、L3.0-L3.4 read-model-only readiness 已完成；不授权真实 Live runtime、signed endpoint、broker、OMS 或 trading command。 |
| Engine / target graph / ownership | Completed | Event-driven paper runtime、Data Catalog、Simulated Exchange、module boundary、source migration、Trader-owned Strategies、Trader Accounts / Coordination、Persistence validation、SwiftPM target graph、TargetGraph retirement、Core envelope retirement 已完成；保留 final residual hardening PR #448 与 production executable `try!` = 0 evidence。 |
| L4 / production cutover readiness | Completed | `MTPRO L4 Live Production / Trading Commands v1` 与 `MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1` 已完成；PR #473 至 #493 evidence、PR #511 至 #519 evidence 已落在 stage audit / latest summary；不授权真实 broker / real order / production trading。 |
| Releases | Completed | v0.1.0 Binance + EMA、v0.2.0 Binance Spot + USDⓈ-M Perpetual + EMA/RSI、v0.3.0 rehearsal evidence、v0.4.0 unified runtime rehearsal、v0.5.0 guarded testnet runtime foundation、v0.6.0 local operational runtime + testnet read-only probe hardening、v0.7.0 operator runtime session + real testnet read-only connectivity、v0.8.0 persistent operator runtime + testnet read-only monitoring、v0.9.0 testnet no-order observability、v0.10.0 production cutover readiness gate、v0.11.0 production readiness evidence runtime + integrity hardening、v0.12.0 readiness assessment sessions、v0.12.1 readiness assessment provenance hardening patch、v0.13.0 local evidence-driven readiness engine、v0.14.1 local execution evidence hardening patch、v0.15.0 Real Binance Testnet Execution MVP stable GitHub Release、v0.19.0 Venue/Product Registry + Runtime Adapter Foundation stable GitHub Release 均 completed；production trading 默认保持关闭，production cutover 未授权。 |

Completed Project 的完整证据见 `docs/audit/`。当前 Project、active issue、Todo / In Progress / In Review 状态必须从 Human 指定的 live queue source 和 Parent Codex queue preview 实时读取，不写死在仓库文档中。

Roadmap 里的 `production trading 默认保持关闭`、`production cutover 未授权` 和各 release 的 `not authorized` 都是当前阶段的 gate 状态，不是永久禁止实盘。MTPRO 的目标仍包含受控 Live trading；路线必须先完成本地 evidence-driven readiness、venue / product-aware testnet closed loop、production read-only / signed endpoint、shadow live、controlled canary 等阶段，再由 Human approval 明确授权。

Machine guard anchors:

- MTPRO Release v0.2.0 | Completed
- Project Closure Count: 45 / 45 (100%)
- Latest Completed Project：`MTPRO Release v0.15.0 Real Binance Testnet Execution MVP`
- Latest Completed Patch：`MTPRO Release v0.14.1 Local Execution Evidence Hardening Patch`
- Current maturity statement：`MTPRO Release v0.19.0 Venue/Product Registry + Runtime Adapter Foundation complete and published as stable GitHub Release with production trading disabled by default and production cutover not authorized`
- PR #473 至 #493 evidence
- PR #511 至 #519 evidence
- final residual hardening PR #448
- production executable `try!` = 0
- 不授权真实 broker
- TargetGraph Anchor Retirement / Real Module Source Root Migration before L4

## Current Release Construction Scope / 当前 release 建设口径

`GH-1215-VERIFY-V0190-STAGE-AUDIT-RELEASE-DOCS`

`TVM-RELEASE-V0190-STAGE-AUDIT-RELEASE-DOCS`

`V0190-010-STAGE-CODE-AUDIT`

`V0190-010-RELEASE-NOTES`

`V0190-010-VALIDATION-MATRIX`

`V0190-010-ROOT-DOCS-REFRESH`

`V0190-010-STALE-WORDING-GUARD`

`V0190-010-NO-PRODUCTION-CUTOVER`

`V0190-010-NO-TAG-OR-RELEASE-PUBLICATION`

Historical completed GitHub fallback queue is `MTPRO Release v0.19.0 Venue/Product Registry + Runtime Adapter Foundation`, issue range `GH-1206..GH-1215`. GH-1215 closes the v0.19.0 stage audit / release docs, validation matrix, root docs refresh and stale wording guard. The closeout records completed construction facts only: at construction closeout time it does not create `v0.19.0` tag, does not create GitHub Release, does not create the next Project / Issue, does not promote a next Todo, and does not authorize production cutover. That no-tag / no-release statement is historical closeout evidence, not current v0.19.0 release state. production cutover not authorized.

GH-1232 uses `GH-1232-VERIFY-V0191-V0190-RELEASE-FACT-SYNC`, `V0191-001-V0190-RELEASE-FACT-SYNC-GUARD`, `TVM-RELEASE-V0191-V0190-RELEASE-FACT-SYNC`, `V0191-001-V0190-TAG-FIXED`, `V0191-001-PATCH-QUEUE-NOT-PUBLICATION` and `V0191-001-NO-PRODUCTION-CUTOVER` to sync the later v0.19.0 stable GitHub Release fact into the v0.19.1 patch guard and root docs. The v0.19.0 Release URL is `https://github.com/atxinbao/MTPRO/releases/tag/v0.19.0`, the tag peeled commit is `53e9b1e81db075ef464b74f8f35c66ebd61ea03c`, and the publication timestamp is `2026-06-29T13:42:34Z`. v0.19.1 是 v0.19.0 后的 release fact / stale wording patch queue；GH-1232 不移动 `v0.19.0` tag，不覆盖 GitHub Release，不创建 v0.19.1 tag / GitHub Release，不授权 production cutover；production cutover not authorized.

GH-1233 uses `GH-1233-VERIFY-V0191-V0190-HISTORICAL-CLOSEOUT-WORDING`, `V0191-002-V0190-HISTORICAL-CLOSEOUT-WORDING-GUARD`, `TVM-RELEASE-V0191-V0190-HISTORICAL-CLOSEOUT-WORDING`, `V0191-002-CONSTRUCTION-CLOSEOUT-HISTORICAL`, `V0191-002-CURRENT-RELEASE-PUBLISHED` and `V0191-002-NO-PRODUCTION-CUTOVER` to rewrite v0.19.0 construction closeout wording as historical context. #1215 no-tag / no-release wording remains valid only when scoped to historical construction closeout evidence; current-facing docs must also carry the v0.19.0 stable GitHub Release URL, tag peeled commit and publication timestamp. GH-1233 does not move `v0.19.0` tag, does not overwrite GitHub Release, does not create v0.19.1 tag / GitHub Release, and does not authorize production cutover.
GH-1234 uses `GH-1234-VERIFY-V0191-V0190-STALE-WORDING-GUARD`, `V0191-003-V0190-STALE-WORDING-GUARD`, `V0191-003-HISTORICAL-CONSTRUCTION-CLOSEOUT-ALLOWLIST`, `TVM-RELEASE-V0191-V0190-STALE-WORDING-GUARD`, `V0191-003-CURRENT-FACING-STALE-WORDING-REJECTION` and `V0191-003-NO-PRODUCTION-CUTOVER` to reject current-facing stale v0.19.0 publication wording. Historical construction closeout evidence remains allowed only when paired with `https://github.com/atxinbao/MTPRO/releases/tag/v0.19.0`, `53e9b1e81db075ef464b74f8f35c66ebd61ea03c` and `2026-06-29T13:42:34Z`. GH-1234 does not move `v0.19.0` tag, does not overwrite GitHub Release, does not create v0.19.1 tag / GitHub Release, and production cutover not authorized.

GH-1200 uses `GH-1200-VERIFY-V0181-V0180-RELEASE-FACT-SYNC`, `V0181-001-V0180-RELEASE-FACT-SYNC-GUARD`, `TVM-RELEASE-V0181-V0180-RELEASE-FACT-SYNC`, `V0181-001-V0180-TAG-FIXED`, `V0181-001-PATCH-QUEUE-NOT-PUBLICATION`, `V0181-001-V0180-STALE-WORDING-GUARD` and `V0181-001-NO-PRODUCTION-CUTOVER` to sync the later v0.18.0 stable GitHub Release fact into the v0.18.1 patch guard and root docs. The v0.18.0 Release URL is `https://github.com/atxinbao/MTPRO/releases/tag/v0.18.0`, the tag peeled commit is `cd284a5817694ffc7c98cd6ccc6b51769fdf6ac9`, and the publication timestamp is `2026-06-28T04:55:36Z`. v0.18.1 是 v0.18.0 后的 Venue/Product Lifecycle Recovery CLI + Release Fact Patch queue；GH-1200 不移动 `v0.18.0` tag，不覆盖 GitHub Release，不创建 v0.18.1 tag / GitHub Release，不授权 production cutover；production cutover not authorized.

Historical v0.18.0 closeout anchor retained：`GH-1185-VERIFY-V0180-STAGE-AUDIT-RELEASE-DOCS`、`TVM-RELEASE-V0180-STAGE-AUDIT-RELEASE-DOCS`、`V0180-010-STAGE-CODE-AUDIT`、`V0180-010-RELEASE-NOTES`、`V0180-010-VALIDATION-MATRIX`、`V0180-010-ROOT-DOCS-REFRESH`、`V0180-010-STALE-WORDING-GUARD`、`V0180-010-NO-PRODUCTION-CUTOVER` 和 `V0180-010-NO-TAG-OR-RELEASE-PUBLICATION`。该 historical anchor 只保留 #1185 construction closeout evidence；当前 construction closeout 已推进到 v0.19.0 GH-1215，production cutover not authorized。

`GH-1139-VERIFY-V0170-OPERATOR-BETA-RUNTIME-HARDENING-CONTRACT`

`TVM-RELEASE-V0170-OPERATOR-BETA-RUNTIME-HARDENING-CONTRACT`

`V0170-001-V0161-PREFLIGHT-GATE`

`V0170-001-ARTIFACT-STATUS-RUNTIME-HARDENING-SCOPE`

`V0170-001-BINANCE-SPOT-TESTNET-ONLY`

`V0170-001-REDACTED-ARTIFACT-EVIDENCE-REQUIRED`

`V0170-001-QUEUE-ORDER`

`V0170-001-NO-PRODUCTION-CUTOVER`

Completed GitHub fallback queue is `MTPRO Release v0.17.0 Operator Beta Artifact + Status Runtime Hardening`, issue range `GH-1139..GH-1148`. GH-1139 is the contract / preflight issue only: it defines v0.16.1 closeout dependency, WIP=1 queue order, Binance Spot Testnet operator beta artifact / status runtime hardening scope, redacted artifact evidence and no-production-cutover guard. It does not read credential values, connect testnet or production endpoints, submit testnet or production orders, publish a tag / GitHub Release, or authorize production cutover.

`GH-1140-VERIFY-V0170-ARTIFACT-BUNDLE-REPLAY-VALIDATOR`

`TVM-RELEASE-V0170-ARTIFACT-BUNDLE-REPLAY-VALIDATOR`

`V0170-002-REAL-ARTIFACT-BUNDLE-INGEST`

`V0170-002-SCHEMA-CHECKSUM-REPLAY-VALIDATION`

`V0170-002-ACTION-SEQUENCE-VALIDATION`

`V0170-002-RECONCILIATION-ARTIFACT-REQUIRED`

`V0170-002-DETERMINISTIC-PASS-FAIL-RESULT`

`V0170-002-NO-PRODUCTION-CUTOVER`

GH-1140 adds the local artifact bundle ingest / replay validator for v0.17.0. It validates redacted operator beta bundles from disk with schema / checksum / action sequence / reconciliation checks and deterministic pass/fail output. It does not read credential values, connect endpoints, send orders, publish a tag / GitHub Release, or authorize production cutover.

`GH-1141-VERIFY-V0170-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL`
`TVM-RELEASE-V0170-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL`
`V0170-003-BOUNDED-STATUS-QUERY-RETRY`
`V0170-003-PER-ATTEMPT-TIMEOUT`
`V0170-003-CLASSIFIED-FAILURE-EVIDENCE`
`V0170-003-RETRY-LIMIT-FAIL-CLOSED`
`V0170-003-REDACTED-FAILURE-EVIDENCE`
`V0170-003-NO-PRODUCTION-CUTOVER`

GH-1141 adds bounded retry, per-attempt timeout and classified redacted failure evidence around the Binance Spot Testnet signed status query path. It does not read credential values, connect production endpoint / broker endpoint, send orders, publish a tag / GitHub Release, or authorize production cutover.

`GH-1142-VERIFY-V0170-OPERATOR-RUN-RESUME-FROM-ARTIFACT-STORE`
`TVM-RELEASE-V0170-OPERATOR-RUN-RESUME-FROM-ARTIFACT-STORE`
`V0170-004-LOCAL-ARTIFACT-STORE-RESUME`
`V0170-004-REPLAY-VALIDATION-REQUIRED`
`V0170-004-AUDIT-CONTINUITY-PRESERVED`
`V0170-004-NO-RESUBMIT-ON-RESUME`
`V0170-004-REDACTED-RESUME-EVIDENCE`
`V0170-004-NO-PRODUCTION-CUTOVER`

GH-1142 adds operator run resume from the local redacted artifact store for v0.17.0. It reuses GH-1140 replay validation and v0.16.0 append-only manifest / record checksums to produce a resume cursor with audit continuity. It does not read credential values, connect endpoints, resubmit orders, publish a tag / GitHub Release, or authorize production cutover.

`GH-1143-VERIFY-V0170-CANCEL-STATUS-RECONCILIATION-RECOVERY-PATH`
`TVM-RELEASE-V0170-CANCEL-STATUS-RECONCILIATION-RECOVERY-PATH`
`V0170-005-CANCEL-STATUS-MISMATCH-CLASSIFICATION`
`V0170-005-INTERRUPTED-STATUS-EVIDENCE-RECOVERY`
`V0170-005-RESUME-CURSOR-CONTINUITY-REQUIRED`
`V0170-005-STATUS-COMPENSATION-REQUIRED`
`V0170-005-NO-AUTOMATIC-ORDER-RETRY`
`V0170-005-REDACTED-RECOVERY-EVIDENCE`
`V0170-005-NO-PRODUCTION-CUTOVER`

GH-1143 adds the cancel/status reconciliation recovery path for v0.17.0. It classifies cancel/status mismatch and interrupted status evidence from GH-1142 resume cursor, GH-1107 reconciliation report and GH-1141 status query failure evidence into a local fail-closed recovery report. It does not read credential values, connect endpoints, resubmit orders, publish a tag / GitHub Release, or authorize production cutover.

`GH-1144-VERIFY-V0170-DASHBOARD-ARTIFACT-VALIDATION-ERROR-SURFACE`
`TVM-RELEASE-V0170-DASHBOARD-ARTIFACT-VALIDATION-ERROR-SURFACE`
`V0170-006-ARTIFACT-VALIDATION-STATUS-VISIBLE`
`V0170-006-FAILURE-REASONS-VISIBLE`
`V0170-006-RECOVERY-CASE-SUMMARY-VISIBLE`
`V0170-006-DASHBOARD-READ-ONLY-NO-COMMANDS`
`V0170-006-NO-PRODUCTION-CUTOVER`

GH-1144 adds the Dashboard artifact validation error surface for v0.17.0. It exposes GH-1140 artifact validation result and GH-1143 recovery report as read-only Dashboard status, failure reasons and recovery summary. It does not add command handlers, trading buttons, order forms, live commands, endpoint connections, order submission, tag / GitHub Release publication, or production cutover authorization.

`GH-1145-VERIFY-V0170-CLI-ARTIFACT-VERIFY-COMMAND`
`TVM-RELEASE-V0170-CLI-ARTIFACT-VERIFY-COMMAND`
`V0170-007-LOCAL-ARTIFACT-BUNDLE-VERIFY`
`V0170-007-LOCAL-ONLY-NO-NETWORK`
`V0170-007-DETERMINISTIC-VALIDATION-REPLAY-OUTPUT`
`V0170-007-REDACTED-OUTPUT`
`V0170-007-NO-PRODUCTION-CUTOVER`

GH-1145 adds the CLI artifact verify command for v0.17.0. It exposes GH-1140 artifact bundle replay validation as local `mtpro verify-operator-beta-artifact-bundle <storageRoot> <runID>` output with deterministic validation / replay evidence. It only reads the local redacted artifact store and does not read credential values, connect endpoints, submit orders, publish a tag / GitHub Release, or authorize production cutover.

`GH-1146-VERIFY-V0170-MANUAL-WORKFLOW-ARTIFACT-VALIDATION`
`TVM-RELEASE-V0170-MANUAL-WORKFLOW-ARTIFACT-VALIDATION`
`V0170-008-MANUAL-WORKFLOW-UPLOAD-DOWNLOAD-VALIDATION`
`V0170-008-SHARED-RUNTIME-VALIDATOR-PATH`
`V0170-008-UPLOADED-BUNDLE-VALIDATED`
`V0170-008-DOWNLOADED-BUNDLE-VALIDATED`
`V0170-008-LOCAL-ONLY-NO-NETWORK`
`V0170-008-REDACTED-EVIDENCE-RECORDED`
`V0170-008-NO-PRODUCTION-CUTOVER`

GH-1146 adds manual workflow artifact upload/download validation for v0.17.0. It validates uploaded and downloaded local artifact store roots through the same `mtpro verify-operator-beta-artifact-bundle` CLI / GH-1140 shared validator path, records deterministic local evidence, and does not read credential values, connect endpoints, submit orders, publish a tag / GitHub Release, or authorize production cutover.

`GH-1147-VERIFY-V0170-BETA-SAFETY-POLICY-PROFILE-EVIDENCE`
`TVM-RELEASE-V0170-BETA-SAFETY-POLICY-PROFILE-EVIDENCE`
`V0170-009-ACTIVE-SAFETY-POLICY-PROFILE`
`V0170-009-VENUE-PRODUCT-SYMBOL-LIMITS`
`V0170-009-NOTIONAL-LIMIT-EVIDENCE`
`V0170-009-ORDER-COUNT-LIMIT-EVIDENCE`
`V0170-009-PRODUCTION-GUARD-STATE`
`V0170-009-REDACTED-POLICY-EVIDENCE`
`V0170-009-NO-PRODUCTION-CUTOVER`

GH-1147 adds beta safety policy profile evidence for v0.17.0. It records active safety policy profile, venue / product / symbol / notional / order-count limits and production-disabled guard state as local redacted evidence inherited from GH-1110 beta safety guard evidence. It does not read credential values, connect endpoints, submit orders, publish a tag / GitHub Release, or authorize production cutover.

`GH-1148-VERIFY-V0170-STAGE-AUDIT-RELEASE-DOCS`
`TVM-RELEASE-V0170-STAGE-AUDIT-RELEASE-DOCS`
`V0170-010-STAGE-CODE-AUDIT`
`V0170-010-RELEASE-NOTES`
`V0170-010-VALIDATION-MATRIX`
`V0170-010-ROOT-DOCS-REFRESH`
`V0170-010-STALE-WORDING-GUARD`
`V0170-010-NO-PRODUCTION-CUTOVER`
`V0170-010-NO-TAG-OR-RELEASE-PUBLICATION`

GH-1148 closes v0.17.0 Stage Code Audit, release notes, validation matrix, root docs refresh and stale wording guard. The v0.17.0 construction queue `GH-1139..GH-1148` is closed / done. GH-1148 does not publish a tag / GitHub Release, does not create the next Project / Issue, and does not authorize production cutover. production cutover not authorized.

`GH-1169-VERIFY-V0171-V0170-RELEASE-FACT-SYNC`
`V0171-004-V0170-RELEASE-FACT-SYNC-GUARD`
`TVM-RELEASE-V0171-V0170-RELEASE-FACT-SYNC`
`V0171-004-V0170-TAG-FIXED`
`V0171-004-PATCH-QUEUE-NOT-PUBLICATION`
`V0171-004-NO-PRODUCTION-CUTOVER`

GH-1169 syncs the later v0.17.0 stable GitHub Release fact into the v0.17.1 patch guard and root docs. The v0.17.0 Release URL is `https://github.com/atxinbao/MTPRO/releases/tag/v0.17.0`, the tag peeled commit is `c83879f80a525665c3484878d7071b1f5214da20`, and the publication timestamp is `2026-06-27T06:37:33Z`. v0.17.1 是 v0.17.0 后的 artifact validation fail-closed patch queue；GH-1169 不移动 `v0.17.0` tag，不覆盖 GitHub Release，不授权 production cutover；production cutover not authorized.

`GH-1005-VERIFY-V0130-STAGE-AUDIT-RELEASE-DOCS`

`GH-1064-VERIFY-V0141-PATCH-AUDIT-RELEASE-NOTES`

`GH-1066-VERIFY-V0150-CONTRACT-PREFLIGHT`

`GH-1067-VERIFY-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST`

`GH-1068-VERIFY-V0150-REAL-SPOT-TESTNET-SUBMIT-RUNTIME`

`GH-1071-VERIFY-V0150-NETWORK-EXECUTION-EVENT-LOG`

`GH-1069-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-RUNTIME`

`GH-1070-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-REPLACE-RUNTIME`

Historical boundary anchor：`GH-924-VERIFY-V0110-FINAL-AUDIT-RELEASE-DOCS` 仍作为 release v0.11.0 final audit / release docs evidence 保留；`GH-891-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK` 仍作为 release v0.10.0 final audit / docs / runbook evidence 保留；`GH-856-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK` 仍作为 release v0.9.0 final audit / docs / runbook evidence 保留；`GH-820-RELEASE-V080-FINAL-AUDIT-DOCS-RUNBOOK` 仍作为 release v0.8.0 final audit / docs / runbook evidence 保留；`GH-792-RELEASE-V070-FINAL-AUDIT-DOCS-RUNBOOK` 仍作为 release v0.7.0 final audit / docs / runbook evidence 保留；`GH-766-RELEASE-V060-FINAL-AUDIT-ROOT-DOCS` 仍作为 release v0.6.0 final audit / root docs evidence 保留；`GH-739-RELEASE-V050-FINAL-AUDIT-RELEASE-DOCS` 仍作为 release v0.5.0 release docs refresh evidence 保留；`GH-709-RELEASE-V040-FINAL-STAGE-AUDIT-RELEASE-DOCS` 仍作为 release v0.4.0 release docs refresh evidence 保留；`GH-670-RELEASE-V030-FINAL-STAGE-AUDIT-RELEASE-DOCS` 仍作为 release v0.3.0 root docs boundary refresh evidence 保留；`GH-564-RELEASE-V020-ROOT-DOCS-BOUNDARY-REFRESH` 仍作为 release v0.2.0 root docs boundary refresh evidence 保留；当前 release construction scope 已由 GH-1005 更新为 v0.13.0 local evidence-driven readiness engine closure。

Historical completed release construction scope 是 `MTPRO Release v0.12.0 Readiness Assessment Sessions`。它使用 GitHub fallback issue queue GH-952 至 GH-965 作为唯一队列来源；Linear 不参与本阶段执行。该 closure 已新增 Stage Code Audit Report `docs/audit/mtpro-release-v0.12.0-readiness-assessment-sessions-stage-code-audit.md`、release notes `docs/release/mtpro-release-v0.12.0-readiness-assessment-sessions-notes.md`、operator runbook `docs/operators/release-v0.12.0-readiness-assessment-sessions-runbook.md` 和 aggregate verifier `checks/verify-v0.12.0.sh`。#965 construction closeout 只收口 evidence / docs / runbook；后续独立 Release Publication Gate 已发布 v0.12.0 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.12.0`，tag peeled commit：`25e31afd351db9a372db62222226b0a3db26c93a`，publication timestamp：`2026-06-20T01:11:22Z`。该 publication 不授权 production cutover；已完成事实不授权创建下一 Project / Issue，不推进 release v0.12.0 之后的阶段。

最新完成的 patch scope 是 `MTPRO Release v0.12.1 Readiness Assessment Provenance Hardening Patch`。它使用 GitHub fallback issue queue GH-988 至 GH-993 作为唯一队列来源；Linear 不参与本 patch 执行。该 closeout 新增 Stage Code Audit Report `docs/audit/mtpro-release-v0.12.1-readiness-assessment-provenance-hardening-patch-stage-code-audit.md`、release notes `docs/release/mtpro-release-v0.12.1-readiness-assessment-provenance-hardening-patch-notes.md` 和 closeout verifier `checks/verify-v0.12.1-patch-audit-release-notes.sh`。GH-993 patch closeout 不创建 v0.12.1 tag，不创建 v0.12.1 GitHub Release，不移动 v0.12.0 release identity，不授权 production cutover，不推进 v0.13.0。

最新完成的 release construction scope 是 `MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine`。它使用 GitHub fallback issue queue GH-994 至 GH-1005 作为唯一队列来源；Linear 不参与本阶段执行。#994 已定义 inputs、outputs、evidence roots、schema contracts、lifecycle order、fail-closed behavior 和 artifact -> policy -> manifest -> bundle -> registry -> diff chain；#995 已实现显式 local evidence root 的只读 intake model、目录 layout、schema validation、missing / malformed diagnostics 和 `mtpro readiness intake <evidenceRoot>` 发现/校验输出；#996 已把 v0.13 normal manifest provenance 绑定到 #995 intake-derived sourceCommit、sourceRunIDs、artifact bytes 和 checksums，并拒绝 synthetic sourceRunID、placeholder sourceCommit 和 fixture-only evidence；#997 已通过 `mtpro readiness build-v013 <assessmentID> <evidenceRoot>` 串联 schema validation、artifact checksum、content policy、Manifest V2、Bundle V2、local registry entry 和 validation report checksum；#998 已通过 `mtpro readiness validate <assessmentID>` 检查 registry、Manifest V2、Bundle V2、bundle manifest、bundle bytes、artifact snapshot、content validation checksum、provenance 和可选 export / comparison identity；#999 已通过 `mtpro readiness export <assessmentID>` 写出本地 redacted audit export package，包含 `assessment-summary.json`、`manifest-v2.json`、`bundle-v2.json`、`validation-report.json`、`provenance.json` 和 `comparison.json` 的 checksum evidence；#1000 已通过 `mtpro readiness compare <baselineAssessmentID> <followUpAssessmentID>` 比较 source data、policy、risk posture、checksum chain、provenance 和 evidence completeness，并把 missing / tampered / stale evidence links 报告为 blocker；#1001 已写出本地 `transaction-recovery-snapshot.json` forensic sidecar，记录 interrupted / stale staging 的 intended writes、completed writes、missing writes、cleanup audit trace 和 failure reason；#1002 已把 readiness generation ID 从秒级碰撞风险改为带 collision-resistant deterministic suffix 的本地 safe path component，并保留 assessmentID / scope / epoch 前缀以便审计；#1003 已把 readiness CLI 固定为 create -> build -> validate -> export -> compare/archive 顺序，并用本地 `validation-state.json` 与 `export-state.json` marker 拒绝 export-before-validate、compare-before-follow-up-validate、archive-before-export 和手工放文件绕过；#1004 通过 `Tests/Fixtures/ReleaseV0130LocalEvidence/valid` 和 focused regression suite 覆盖 minimal valid local evidence、invalid / tampered / missing fixture cases、build / validate / export / compare / recovery regression 以及 fixture/runtime path separation；#1005 新增 Stage Code Audit Report `docs/audit/mtpro-release-v0.13.0-local-evidence-driven-readiness-engine-stage-code-audit.md`、release notes `docs/release/mtpro-release-v0.13.0-local-evidence-driven-readiness-engine-notes.md` 和 closeout validation anchors。GH-1005 construction closeout 不创建 v0.13.0 tag，不创建 GitHub Release，不授权 production cutover，不推进下一 Project / Issue。

Historical completed patch scope 是 `MTPRO Release v0.14.1 Local Execution Evidence Hardening Patch`。它使用 GitHub fallback issue queue GH-1059 至 GH-1064 作为唯一队列来源；Linear 不参与本 patch 执行。#1059 固定 v0.14.0 public release / CI / Dashboard evidence；#1060 固定 v0.14.x Codable decode fail-closed validation；#1061 固定 local adapter submit evidence 与 network submit / cancel / replace attempts 为 false；#1062 固定 golden JSON contract / corrupted payload fail-closed tests；#1063 固定 Dashboard 从本地 read-model artifact JSON 加载 read-only surface 前必须通过 boundary validation；#1064 新增 Stage Code Audit Report `docs/audit/mtpro-release-v0.14.1-local-execution-evidence-hardening-patch-stage-code-audit.md`、release notes `docs/release/mtpro-release-v0.14.1-local-execution-evidence-hardening-patch-notes.md` 和 closeout validation anchors。v0.14.1 是 local execution evidence chain / testnet evidence only，不是真实 signed Binance testnet execution release，不代表真实 Binance testnet order execution。GH-1064 patch closeout 不创建 v0.14.1 tag，不创建 GitHub Release，不授权 production cutover，不推进下一 Project / Issue。

已完成 GitHub fallback queue `MTPRO Release v0.15.0 Real Binance Testnet Execution MVP`，issue range 为 GH-1065 至 GH-1076。#1066 已通过 `docs/contracts/release-v0.15.0-real-binance-spot-testnet-execution-mvp-contract.md` 和 `checks/verify-v0.15.0-contract-preflight.sh` 固定 Binance Spot Testnet only、signed testnet boundary、production fail-closed、children backlog / non-executable 和 no Dashboard command surface。#1067 至 #1076 已完成 credential / signed request、guarded submit / cancel / cancel-replace runtime evidence、append-only network event log、OMS reconciliation、CLI operator flow、Dashboard read-only status、failure simulation 和 release CI / manual workflow / audit closeout。后续独立 Release Publication Gate 已发布 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.15.0`，tag peeled commit：`1590b6c40e6ca7887cff0ca59b2f74e4fe7e3ece`，publication timestamp：`2026-06-23T01:26:30Z`。v0.15.0 publication 不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。

最新完成的 GitHub fallback queue 是 `MTPRO Release v0.15.1 Real Testnet Execution Hardening Patch`，issue range 为 GH-1094 至 GH-1100。#1094 使用 `GH-1094-VERIFY-V0151-V0150-RELEASE-FACT-SYNC` 同步 v0.15.0 publication facts 并已 closed / done；#1095 使用 `GH-1095-VERIFY-V0151-INJECTED-TRANSPORT-WORDING` 固定 injected Spot Testnet transport / manual proof / future URLSession runner split 并已 closed / done；#1096 已 closed / done，使用 `GH-1096-VERIFY-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT` 增加 concrete URLSession transport guard，只允许 Binance Spot Testnet `testnet.binance.vision` `/api/v3/order` submit / cancel request、production host fail-closed、response-sha256 脱敏和 no secret persistence；#1097 已 closed / done，使用 `GH-1097-VERIFY-V0151-CLI-TESTNET-EXECUTION-RUNTIME` 增加 CLI guarded runtime：`mtpro testnet-execution` submit / cancel / cancel-replace 均调用 v0.15 guarded runtime，credential provider 固定 `testnet-env`，缺失 testnet credential 或 operator confirmation 时 fail-closed，输出 redacted run id、artifact path 和 checksum；#1098 已 closed / done，使用 `GH-1098-VERIFY-V0151-RUNTIME-INTERNAL-GATES` 增加 runtime internal gate：RiskEngine / kill switch / no-trade / operator confirmation 在 submit / cancel / cancel-replace runtime 内部重新检查，blocked gate 必须在 transport invocation 前 fail-closed；#1099 已 closed / done，使用 `GH-1099-VERIFY-V0151-CLIENT-ORDER-IDENTITY-CHAIN` 增加 deterministic client order identity chain：submit evidence 生成 deterministic redacted `newClientOrderId` reference，cancel identity 从 submit evidence 派生短生命周期 material，raw / untracked order id fail-closed；#1100 codable decode closeout closed / done，使用 `GH-1100-VERIFY-V0151-CODABLE-DECODE-CLOSEOUT` 给 submit / cancel / cancel-replace evidence、network event log、OMS snapshot 和 reconciliation report 增加 decode-time validation，损坏 JSON、checksum mismatch、production host mutation 和 production boundary mutation 必须 fail-closed。release/v0.15.1 queue closed。

#1098 retained validation anchors：`GH-1098-VERIFY-V0151-RUNTIME-INTERNAL-GATES`、`TVM-RELEASE-V0151-RUNTIME-INTERNAL-GATES`、`V0151-005-RISKENGINE-GATE-IN-RUNTIME`、`V0151-005-KILL-SWITCH-GATE-IN-RUNTIME`、`V0151-005-NO-TRADE-GATE-IN-RUNTIME`、`V0151-005-OPERATOR-CONFIRMATION-IN-RUNTIME`、`V0151-005-TRANSPORT-NOT-INVOKED-WHEN-BLOCKED`、`V0151-005-NO-PRODUCTION-CUTOVER`。

#1099 validation anchors：`GH-1099-VERIFY-V0151-CLIENT-ORDER-IDENTITY-CHAIN`、`TVM-RELEASE-V0151-CLIENT-ORDER-IDENTITY-CHAIN`、`V0151-006-DETERMINISTIC-NEW-CLIENT-ORDER-ID`、`V0151-006-REDACTED-CLIENT-ORDER-REFERENCE`、`V0151-006-SUBMIT-TO-CANCEL-IDENTITY-HANDOFF`、`V0151-006-RAW-UNTRACKED-ORDER-ID-REJECTED`、`V0151-006-NO-PRODUCTION-CUTOVER`。

#1100 validation anchors：`GH-1100-VERIFY-V0151-CODABLE-DECODE-CLOSEOUT`、`TVM-RELEASE-V0151-CODABLE-DECODE-CLOSEOUT`、`V0151-007-CODABLE-DECODE-VALIDATION`、`V0151-007-CORRUPTED-JSON-FAILS-CLOSED`、`V0151-007-CHECKSUM-MISMATCH-FAILS-CLOSED`、`V0151-007-PRODUCTION-HOST-MUTATION-REJECTED`、`V0151-007-NO-PRODUCTION-CUTOVER`。

最新完成 GitHub fallback queue 是 `MTPRO Release v0.16.0 Binance Spot Testnet Operator Execution Beta`，issue range 为 GH-1101 至 GH-1112，全部 closed / done。#1101..#1111 完成 operator beta contract、run model、CLI submit、CLI cancel、signed status query、local artifact store、OMS observed-status reconciliation、Dashboard read-only artifact view、failure recovery、beta safety guards 和 manual testnet validation workflow。#1112 使用 `GH-1112-VERIFY-V0160-STAGE-AUDIT-RELEASE-DOCS`、`TVM-RELEASE-V0160-STAGE-AUDIT-RELEASE-DOCS`、`V0160-012-STAGE-CODE-AUDIT`、`V0160-012-RELEASE-NOTES`、`V0160-012-OPERATOR-RUNBOOK`、`V0160-012-VALIDATION-MATRIX`、`V0160-012-STALE-WORDING-GUARD`、`V0160-012-NO-PRODUCTION-CUTOVER` 和 `V0160-012-NO-TAG-OR-RELEASE-PUBLICATION` 收口 audit / release docs / runbook / matrix。v0.16.0 construction closeout 本身不创建 tag / GitHub Release；随后独立 Release Publication Gate 已发布 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.16.0`，tag peeled commit：`28779236262bd7ffaf71e286b27b95854c5cd3e1`，publication timestamp：`2026-06-26T01:29:21Z`；production cutover not authorized。

最新完成 patch queue 是 `MTPRO Release v0.16.1 Operator Beta Evidence Hardening Patch`。GH-1133 使用 `GH-1133-VERIFY-V0161-V0160-RELEASE-FACT-SYNC`、`V0161-001-V0160-RELEASE-FACT-SYNC-GUARD`、`TVM-RELEASE-V0161-V0160-RELEASE-FACT-SYNC`、`V0161-001-V0160-TAG-FIXED`、`V0161-001-PATCH-QUEUE-NOT-PUBLICATION` 和 `V0161-001-NO-PRODUCTION-CUTOVER` 将 v0.16.0 已发布事实同步为 patch guard：Release URL `https://github.com/atxinbao/MTPRO/releases/tag/v0.16.0`，tag peeled commit `28779236262bd7ffaf71e286b27b95854c5cd3e1`，publication timestamp `2026-06-26T01:29:21Z`。#1134..#1137 完成 manual evidence bundle content guard、central artifact redaction policy、redaction regression coverage 和 status query transport wording guard。#1138 使用 `GH-1138-VERIFY-V0161-PATCH-AUDIT-RELEASE-NOTES`、`TVM-RELEASE-V0161-PATCH-AUDIT-RELEASE-NOTES`、`V0161-006-PATCH-AUDIT`、`V0161-006-RELEASE-NOTES`、`V0161-006-VALIDATION-MATRIX`、`V0161-006-PUBLICATION-GUIDANCE`、`V0161-006-NO-PRODUCTION-CUTOVER` 和 `V0161-006-NO-TAG-OR-RELEASE-PUBLICATION` 收口 patch audit、release notes、validation matrix 和 publication guidance。v0.16.1 不移动 v0.16.0 tag、不覆盖 release、不创建 v0.16.1 tag / GitHub Release、不授权 production cutover；production cutover not authorized。

#1101 validation anchors：`GH-1101-VERIFY-V0160-OPERATOR-BETA-CONTRACT`、`TVM-RELEASE-V0160-OPERATOR-BETA-CONTRACT`、`V0160-001-V0151-PREFLIGHT-GATE`、`V0160-001-BINANCE-SPOT-TESTNET-ONLY`、`V0160-001-OPERATOR-CONFIRMATION-REQUIRED`、`V0160-001-REDACTED-EVIDENCE-REQUIRED`、`V0160-001-QUEUE-ORDER`、`V0160-001-NO-PRODUCTION-CUTOVER`。

#1102 validation anchors：`GH-1102-VERIFY-V0160-OPERATOR-RUN-MODEL`、`TVM-RELEASE-V0160-OPERATOR-RUN-MODEL`、`V0160-002-RUN-ID-LIFECYCLE`、`V0160-002-ACTION-SEQUENCE`、`V0160-002-ARTIFACT-LINKAGE`、`V0160-002-INVALID-TRANSITION-FAILS-CLOSED`、`V0160-002-REDACTED-METADATA`、`V0160-002-NO-NETWORK-BY-THIS-ISSUE`、`V0160-002-NO-PRODUCTION-CUTOVER`。

#1103 validation anchors：`GH-1103-VERIFY-V0160-CLI-SUBMIT-FLOW`、`TVM-RELEASE-V0160-CLI-SUBMIT-FLOW`、`V0160-003-STABLE-CLI-SUBMIT`、`V0160-003-V0151-RUNTIME-DELEGATION`、`V0160-003-EXPLICIT-OPERATOR-CONFIRMATION`、`V0160-003-TESTNET-CREDENTIAL-PROFILE`、`V0160-003-REDACTED-OUTPUT-ARTIFACT-CHECKSUM`、`V0160-003-MISSING-GATE-CREDENTIAL-CONFIRMATION-FAILS-CLOSED`、`V0160-003-NO-PRODUCTION-CUTOVER`。

#1104 validation anchors：`GH-1104-VERIFY-V0160-CLI-CANCEL-FLOW`、`TVM-RELEASE-V0160-CLI-CANCEL-FLOW`、`V0160-004-STABLE-CLI-CANCEL`、`V0160-004-SUBMIT-ARTIFACT-IDENTITY`、`V0160-004-V0151-RUNTIME-DELEGATION`、`V0160-004-EXPLICIT-OPERATOR-CONFIRMATION`、`V0160-004-TESTNET-CREDENTIAL-PROFILE`、`V0160-004-REDACTED-ORDER-REFERENCE`、`V0160-004-APPEND-ONLY-EVENT-EVIDENCE`、`V0160-004-MISSING-PRIOR-ARTIFACT-FAILS-CLOSED`、`V0160-004-NO-PRODUCTION-CUTOVER`。

<!-- Historical guard：最新完成的 release construction scope 是 `MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening`。 -->

- activeVenue == Binance
- activeProductTypes == [spot, usdsPerpetual]
- activeStrategies == [ema, rsi]
- productionTradingEnabledByDefault == false
- runtimeModes == [local-dry-run, testnet-read-only-monitor, recovery-observe, production-blocked]
- legacyRuntimeModes == [testnet-read-only-probe]
- historicalV040RehearsalModes == [dry-run, shadow, testnet-guarded, production-blocked]
- productionCapabilityGatedNotMissing == true
- oldPublicReadOnlyPaperOnlyEMAOnlyIsHistorical == true

`GH-687-RELEASE-V031-REHEARSAL-EVIDENCE-DOCS-HANDOFF`

Release v0.12.0、v0.11.0、v0.10.0、v0.9.0、v0.8.0、v0.7.0、v0.6.0、v0.5.0、v0.4.0 和 v0.3.x 的版本语义固定如下：

- v0.12.0 是 readiness assessment sessions closure：它证明本地 readiness assessment contract、registry store、transaction lock、Manifest V2 / provenance schema、artifact content-policy、immutable bundle snapshot、kill switch / no-trade trustworthy observations、approval role / quorum separation、shadow parity source snapshot、diff / compare、assessment-scoped CLI、Dashboard history / adversarial CI、final audit / release notes / operator runbook 和 `checks/verify-v0.12.0.sh` validation command 已闭环。
- v0.12.0 #965 construction closeout 本身不是 public GitHub Release publication；后续独立 Release Publication Gate 已完成 public GitHub Release publication：`https://github.com/atxinbao/MTPRO/releases/tag/v0.12.0`，tag peeled commit：`25e31afd351db9a372db62222226b0a3db26c93a`，publication timestamp：`2026-06-20T01:11:22Z`，且仍不授权 production cutover。
- v0.11.0 是 production readiness evidence runtime + integrity hardening closure：它证明 local readiness artifact store、manifest atomic IO、canonical JSON SHA256、bundle validation、shadow dry-run parity、Dashboard real artifact state、readiness CLI local artifacts、fixed-point capital / exposure policy、kill switch / no-trade state model、auditable approval workflow transitions 和 `checks/verify-v0.11.0.sh` validation command 已闭环。
- v0.11.0 #924 construction closeout 不是 public GitHub Release publication：它不创建 tag，不发布 GitHub Release，不授权 production cutover；后续独立 Release Publication Gate 已完成 public GitHub Release publication：`https://github.com/atxinbao/MTPRO/releases/tag/v0.11.0`，tag peeled commit：`13f592d0710de91351286e5c5490bfacb63c19b0`，publication timestamp：`2026-06-19T01:20:58Z`，且仍不授权 production cutover。
- v0.10.0 是 production cutover readiness gate closure：它证明 production readiness no-authorization contract、v0.9.1 publication policy carry-forward、production environment profile、secret provider readiness、endpoint policy readiness、capital / exposure limits、kill switch / no-trade、production command surface disabled proof、shadow dry-run parity、production readiness audit bundle、cutover approval workflow、incident / rollback runbook、Dashboard Production Readiness Center、operator runbook 和 `checks/verify-v0.10.0.sh` validation command 已闭环。
- v0.10.0 stable GitHub Release 已通过独立 publication gate 发布：`https://github.com/atxinbao/MTPRO/releases/tag/v0.10.0`；tag target commit 为 `7b0e1f8bb6a671cd3b96f7e7b020b803f8cea4b4`。
- v0.10.0 不是 production cutover：它不授权 production secret、production endpoint、production broker、testnet 或 production submit / cancel / replace、production OMS、Live PRO Console production command、trading button、order form 或 live command。
- v0.9.0 是 testnet no-order observability closure：它证明 v0.9.0 no-order observability contract、v0.8.0 publication alignment carry-forward、persistent TestnetReadOnlyMonitorSession、signed account snapshot freshness monitor、private stream heartbeat / staleness monitor、monitor recovery observe、Dashboard observability timeline、alert read-model、Portfolio reconciliation timeline、Risk policy application audit、run monitor export bundle、validation lanes split、Dashboard / CLI operator UX、operator runbook 和 `checks/verify-v0.9.0.sh` validation command 已闭环。
- v0.9.0 stable GitHub Release 已通过独立 publication gate 发布：`https://github.com/atxinbao/MTPRO/releases/tag/v0.9.0`；tag target commit 为 `4296bf73673fe0fd8f09e34c40ef2a3a9ba7e55c`。
- v0.9.0 不是 production cutover：它不授权 production secret、production endpoint、production broker、testnet 或 production submit / cancel / replace、production OMS、Live PRO Console production command、trading button、order form 或 live command。
- v0.8.0 是 persistent operator runtime + testnet read-only monitoring closure：它证明 persistent no-order operator runtime contract、v0.8 construction / public release publication separation、persistent RunRegistryStore、CLI local session actions、OperationalRunSessionStore、EventLogWriter crash recovery、manual Binance testnet signed account proof、manual private stream monitoring proof、Dashboard testnet read-only monitor、local Risk policy profile management、Portfolio reconciliation review workflow、Dashboard safe local controls、validation lanes split、operator runbook 和 `checks/verify-v0.8.0.sh` validation command 已闭环。
- v0.8.0 不是 production cutover：它不授权 production secret、production endpoint、production broker、testnet 或 production submit / cancel / replace、production OMS、Live PRO Console production command 或 trading button。
- v0.7.0 是 operator runtime session + real testnet read-only connectivity closure：它证明 no-order runtime session contract、canonical testnet endpoint policy、top-level CLI runtime session surface、Dashboard macOS focused guards、OperationalRunSession lifecycle、EventLogWriter recovery、RunRegistry / RunSupervisor、real Binance testnet signed account read-only probe、testnet private stream read-only probe、Dashboard read-only run operations、local Risk policy config、Portfolio read-only reconciliation projection、operator runbook 和 `checks/verify-v0.7.0.sh` validation command 已闭环。
- v0.7.0 不是 production cutover：它不授权 production secret、production endpoint、production broker、real submit / cancel / replace、production OMS、Live PRO Console production command 或 trading button。
- v0.6.0 是 local operational runtime + testnet read-only probe hardening closure：它证明 local run journal writer、run manifest / artifact checksum validator、sha256 runtime checksum chain、DataEngine local dry-run runner、EMA / RSI strategy runtime runner、RiskEngine runtime runner、ExecutionEngine / OMS dry-run runner、Portfolio journal projection、Dashboard / CLI run detail observer、operator-confirmed testnet read-only probe、operator runbook 和 `checks/verify-v0.6.0.sh` validation command 已闭环。
- v0.6.0 不是 production cutover：它不授权 production secret、production endpoint、production broker、real submit / cancel / replace、production OMS、Live PRO Console production command 或 trading button。

- v0.5.0 是 guarded testnet runtime foundation / deterministic-to-operational bridge closure：它证明 strict CLI、fail-closed environment / endpoint / secret policy、typed RuntimeMessageBus、durable local run journal、DataEngine operational dry-run path、testnet read-only no-submit gate、RiskEngine runner、ExecutionEngine / OMS dry-run lifecycle、Portfolio projection、Dashboard / CLI run observer、CI hardening、operator runbook 和 `checks/verify-v0.5.0.sh` validation command 已闭环。
- v0.5.0 不是 production cutover：它不授权 production secret、production endpoint、production broker、real submit / cancel / replace、production OMS、Live PRO Console production command 或 trading button。
- v0.4.0 是 unified runtime rehearsal pipeline closure：它证明 single runID evidence envelope、local dry-run RuntimeKernel、DataEngine -> MessageBus -> Trader / Strategy -> RiskEngine -> ExecutionEngine / OMS -> ExecutionClient dry-run / testnet-gated boundary -> Event Store -> Portfolio -> Dashboard / CLI 证据链、shadow replay、operator runbook 和 `checks/verify-v0.4.0.sh` validation suite 已闭环。
- v0.4.0 不是 production cutover：它不授权 production secret、production endpoint、production broker、real submit / cancel / replace、production OMS、Live PRO Console production command 或 trading button。

- v0.3.0 是 deterministic rehearsal evidence release：它证明本地 deterministic evidence chain、dry-run / testnet / shadow / production-blocked mode taxonomy、Dashboard / CLI rehearsal surface、kill switch / no-trade / rollback drill 和 `checks/verify-v0.3.0.sh` validation suite 已闭环。
- v0.3.1 是 rehearsal evidence hardening patch：它只补强 v0.3.0 evidence 边界、URL policy、文档语义和 patch release closeout，不新增 runtime pipeline、network connector、product type、strategy 或 production cutover。
- v0.3.x 不是 real testnet / shadow runtime runner：文档中出现的 `testnet` / `shadow` 表示 rehearsal evidence mode 和 deterministic mapping proof，不表示已启动真实 Binance testnet network loop、shadow production feed、broker connection、secret read、live private stream、real submit / cancel / replace 或 production endpoint。
- release v0.5.0 之后的下一阶段仍必须等待 Human + `@001 / PLN` 重新规划并写入新的 live queue source；本文档不创建下一 Project / Issue，不推进 Todo，不授权 execution。

`GH-564-PRODUCTION-CAPABILITY-GATED-NOT-MISSING`

Release v0.11.0 的 production readiness evidence runtime 是 gated evidence capability，不是 production trading capability，也不是默认开启能力。任何 production secret、production endpoint、broker connection、submit / cancel / replace、OMS、Event Store 或 Dashboard command surface 都必须在 CommandGateway、RiskEngine、ExecutionEngine、OMS、Event Store、kill switch / no-trade 和 validation gates 之后才可由后续 issue 明确授权。

`GH-564-NO-OLD-BOUNDARY-AS-CURRENT`

public-read-only、paper-only、ExecutionClient future-gate、EMA-only、v0.3.x deterministic-only wording、v0.4.0 shadow/unified runtime wording、v0.5.0 guarded testnet wording、v0.6.0 local operational wording、v0.7.0 runtime-session wording、v0.8.0 persistent monitoring wording、v0.9.0 no-order observability wording 和 v0.10.0 readiness assessment wording 可以继续作为历史阶段、审计证据和 compatibility evidence 出现，但不得写成 release v0.11.0 当前边界。当前口径必须保持 Binance-only、Spot + USDⓈ-M Perpetual-only、EMA + RSI-only、local-dry-run / testnet-read-only-monitor / recovery-observe / production-blocked、production readiness evidence runtime、production disabled by default、production cutover not authorized 和 production capability gated-not-missing。

Core Envelope Retirement / Real Module Ownership Completion 的 post-audit hardening 已在 PR #448 后完成最终 closure audit：production executable `try!` = 0，`@unchecked Sendable` = 0，open GitHub issue / PR = 0，`main == origin/main == 2b78f27a8e2b04ba348d2fc90259c96b9a088aff`，完整本地验证通过。该事实只同步已发生 hardening closure，不新增 Project Closure Count，不授权 L4 execution。

## Progress Model / 进度模型

MTPRO 采用两层进度口径：

1. Current Foundation Progress：当前已批准 paper-only foundation 的完成度。
2. Final Product Goal Progress：最终专业交易工作台产品目标的完成度。

Project Closure Count 只说明当前已批准、已执行、已 closure 的建设阶段 Project 数量，不代表完整产品蓝图或 Future Construction Zones / 未来建设区已经完成。

```text
Phase: MTPRO professional trading workstation
Project Closure Count: 45 / 45 (100%)
Current Foundation Progress: 4 / 4 (100%)
Final Product Goal Progress: 9 / 9 (100%)
Engine Maturity Roadmap Progress: 4 / 4 (100%)
Foundation Progress: [##########] 100%
Final Product Progress: [##########] 100%
Engine Maturity Progress: [##########] 100%
```

Historical Project Closure Count: 44 / 44 (100%) recorded the `MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening` closure baseline before GH-965 advanced the current completed Project count to 45 / 45.
Historical Project Closure Count: 43 / 43 (100%) recorded the `MTPRO Release v0.9.0 Testnet No-order Observability` closure baseline before GH-891 advanced the current completed Project count to 44 / 44.
Historical Project Closure Count: 42 / 42 (100%) recorded the `MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring` closure baseline before GH-856 advanced the current completed Project count to 43 / 43.
Historical Project Closure Count: 41 / 41 (100%) recorded the `MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity` closure baseline before GH-820 advanced the completed Project count to 42 / 42.
Historical guard retains previous Latest completed release construction scope: `MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring`
Historical guard retains previous Latest completed release construction scope: `MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity`
Historical Project Closure Count: 40 / 40 (100%) recorded the `MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening` closure baseline before GH-792 advanced the completed Project count to 41 / 41.
Historical Project Closure Count: 39 / 39 (100%) recorded the `MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge` closure baseline before GH-766 advanced the completed Project count to 40 / 40.
Historical Project Closure Count: 38 / 38 (100%) recorded the `MTPRO Release v0.4.0 Unified Runtime Rehearsal Pipeline` closure baseline before GH-739 advanced the completed Project count to 39 / 39.
Historical Project Closure Count: 37 / 37 (100%) recorded the `MTPRO Release v0.3.0 Testnet / Shadow Production Rehearsal` closure baseline before GH-709 advanced the completed Project count to 38 / 38.
Historical Project Closure Count: 36 / 36 recorded the `MTPRO Release v0.2.0` closure baseline before GH-670 advanced the completed Project count to 37 / 37.
Historical Project Closure Count: 36 / 36 (100%)

Current Foundation Progress 基于 `GOAL.md` 的当前 foundation 目标切片计算：

| Foundation 目标切片 | 状态 | 证据 |
| --- | --- | --- |
| Research / Backtest / Report / Paper readiness | Complete | Runtime Research Workbench、Trading Validation、Paper Session Runtime 已完成 |
| Paper-only execution evidence | Complete | Paper Execution Workflow v1 已完成 |
| Paper workflow 可观察性和本地控制壳 | Complete | Paper Workflow Control Shell v1 已完成 |
| 更长周期 market data replay / operations | Complete | Market Data Replay Operations v1 已完成 |

Final Product Goal Progress 基于 `GOAL.md` 的完整产品目标切片计算：

| # | 最终产品目标切片 | 状态 | 证据 / 下一步 |
| --- | --- | --- | --- |
| 1 | 研究 / 回测 / 报告基础能力（Research / Backtest / Report foundation） | Complete | Runtime Research Workbench、Trading Validation 和 Report evidence 已完成 |
| 2 | Paper 模拟执行基础能力（Paper execution foundation） | Complete | Paper Session Runtime 和 Paper Execution Workflow 已完成 |
| 3 | 工作台证据导航与本地控制壳（Workbench evidence navigation and local control shell） | Complete | Paper Workflow Control Shell v1 已完成 |
| 4 | 行情数据回放运营能力（Market data replay operations） | Complete | Market Data Replay Operations v1 已完成 |
| 5 | 实盘交易基础边界（Live trading foundation） | Complete | Live Trading Boundary Definition v1 已完成 boundary taxonomy、credential endpoint boundary、adapter isolation、real order lifecycle terminology、blocked evidence 和只读展示面；真实 Live trading、signed endpoint、broker adapter 和 real order lifecycle 仍未实现 |
| 6 | 实盘监控台（Live monitoring console） | Complete / read-model-only evidence surface | Live Monitoring Console v1 已完成 information architecture、runtime health / connection read model、market / order stream blocked evidence、latency / error / degraded evidence、Dashboard / Report / Event Timeline evidence surface；真实 live runtime、signed/account stream、broker stream 和交易控制仍未实现 |
| 7 | 实盘执行控制（Live execution control） | Complete / contract + blocked evidence | Live Execution Control Contract v1 已完成 terminology、submit / cancel / replace future gates、execution report / broker fill / reconciliation future gates、paper / real command isolation、read-model-only blocked evidence、Dashboard / Report / Event Timeline evidence surface；真实 execution runtime、真实 submit / cancel / replace、broker fill、execution report 和 reconciliation 仍未实现 |
| 8 | 实盘风险控制（Live risk control） | Complete / contract + blocked evidence | Live Risk Gate Contract v1 已完成 risk terminology、exposure / notional / frequency / loss / drawdown / circuit breaker / no-trade future gates、paper / live risk isolation、read-model-only blocked evidence 和 Dashboard / Report / Event Timeline evidence surface；真实 live risk engine、真实账户风控、real pre-trade allow / reject runtime、risk command、stop command 和 emergency stop 仍未实现 |
| 9 | 实盘审计 / 事故回放 / 停机控制（Live audit / incident replay / stop controls） | Complete / contract + blocked evidence | Live Audit Incident Stop Boundary v1 已完成 audit / incident / stop terminology、audit trail / incident replay / stop controls future gates、blocked evidence isolation、read-model-only evidence surface 和 forbidden capability tests；真实 audit trail runtime、incident replay runtime、emergency stop、shutdown、restore、production operations、Live PRO Console、live command 和 trading button 仍未实现 |

Latest Completed Project：`MTPRO Release v0.12.0 Readiness Assessment Sessions`

Historical Latest Completed Project：`MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening`
Historical Latest Completed Project：`MTPRO Release v0.9.0 Testnet No-order Observability`
Historical Latest Completed Project：`MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring`
Historical Latest Completed Project：`MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity`
Historical Latest Completed Project：`MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening`
Historical Latest Completed Project：`MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge`
Historical Latest Completed Project：`MTPRO Release v0.4.0 Unified Runtime Rehearsal Pipeline`
Historical Latest Completed Project：`MTPRO Release v0.3.0 Testnet / Shadow Production Rehearsal`
Historical Latest Completed Project：`MTPRO Release v0.2.0`
Historical guard retains previous Latest Completed Project：`MTPRO Release v0.2.0`

Current maturity statement：`MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine complete with production trading disabled by default and production cutover not authorized`
Historical guard retains previous Current maturity statement：`MTPRO Release v0.12.0 Readiness Assessment Sessions complete with production trading disabled by default and production cutover not authorized`
Historical maturity statement：`MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening complete with production trading disabled by default and production cutover not authorized`
Historical maturity statement：`MTPRO Release v0.9.0 Testnet No-order Observability complete with production trading disabled by default`
Historical maturity statement：`MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring complete with production trading disabled by default`
Historical maturity statement：`MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity complete with production trading disabled by default`
Historical guard retains previous Current maturity statement：`MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity complete with production trading disabled by default`
Historical guard retains previous Current maturity statement：`MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening complete with production trading disabled by default`
Historical maturity statement：`MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening complete with production trading disabled by default`
Historical maturity statement：`MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge complete with production trading disabled by default`
Historical maturity statement：`MTPRO Release v0.4.0 Unified Runtime Rehearsal Pipeline complete with production trading disabled by default`
Historical maturity statement：`MTPRO Release v0.3.0 Testnet / Shadow Production Rehearsal complete with production trading disabled by default`
Historical guard retains previous Current maturity statement：`MTPRO Release v0.2.0 Binance Spot + USDⓈ-M Perpetual + EMA/RSI validation complete with production trading disabled by default`

Next recommended maturity slice：none active after `release/v0.13.0` construction closeout。

Next maturity planning candidate：real broker / production trading / next Project 仍必须经 Human + `@001 / PLN` 重新规划。

Next Handoff：Human + `@001 / PLN`

本进度条不统计未授权 future capability，不授权下一阶段执行。下一阶段方向、目标、架构路线和优先级仍交给 Human + `@001 / PLN`。

## Product Route / 产品路线

1. 研究 / 回测 / 报告基础能力：Completed。
2. Paper 模拟执行基础能力：Completed。
3. 工作台证据导航与本地控制壳：Completed。
4. 行情数据回放运营能力：Completed。
5. 实盘交易基础边界：Completed；仅完成基础边界、阻断证据和只读展示面，不实现真实 Live trading。
6. 实盘监控台：Completed；仅完成 read-model-only monitoring evidence surface，不实现真实 live runtime、signed/account stream、broker stream 或交易控制。
7. 实盘执行控制：Completed / contract + blocked evidence；不实现真实 execution runtime、真实订单命令、broker fill、execution report 或 reconciliation。
8. 实盘风险控制：Completed / contract + blocked evidence；不实现真实 live risk engine、真实账户风控、real pre-trade allow / reject runtime、risk command、stop command 或 emergency stop。
9. 实盘审计 / 事故回放 / 停机控制：Completed / contract + blocked evidence；不实现真实 audit trail runtime、incident replay runtime、emergency stop、shutdown、restore、production operations、Live PRO Console、live command 或 trading button。

## Module Maturity Development Plan / 模块成熟度开发计划

Final Product Goal Progress `9 / 9 (100%)` 表示原定 contract / evidence / Workbench / Live boundary 切片已完成，不表示 MTPRO 已达到 `atxinbao/nautilus_trader` 级别的 production trading engine 成熟度。9 / 9 后的新开发路线以“引擎成熟度”推进：先完成 MTPRO 自身 paper-only event-driven runtime，再完成 local-first Data Catalog / Scenario Replay 数据地基，之后才进入 Simulated Exchange / Backtest Parity、Workbench Beta Readiness 和 Future Gated live readiness。

该计划是开发路线地图，不授权执行，不创建 Linear Project / Issue，不推进 `Todo`。每个阶段都必须先由 Human 确认，再由 `@001 / PLN` 输出 Project Planning Record，经 Linear 写入和 Parent Codex queue preflight 后，才能让唯一 eligible issue 进入 `Todo`。

Engine 级分层和成熟度门槛由 `docs/product/mtpro-core-engine-architecture-module-maturity-map-v1.md` 维护。后续任何 Project Planning Record 必须说明目标 Engine / Layer、目标 maturity level、当前 evidence、允许施工范围和 forbidden capabilities，避免把单个页面、证据面或零散模块误当成完整 trading engine maturity。

| Maturity family | 状态 | 边界 |
| --- | --- | --- |
| L1-L2+ paper / data / parity / Workbench | Done | Engine Maturity Roadmap Progress `4 / 4 (100%)`；证据见对应 `docs/audit/mtpro-*-stage-code-audit.md`。 |
| L3 read-model-only readiness | Done / not counted in old denominator | Live read-only、APB、private stream simulation、Live Monitoring v2、Strategy / Trader Instance readiness 都只是 read-model-only / simulation / forbidden capability evidence。 |
| Module / target graph / Core envelope | Done / not counted in old denominator | Module boundary、physical layout、Trader strategy/account/coordination、Persistence validation、SwiftPM target graph、TargetGraph retirement、real target ownership 和 Core envelope retirement 已闭环；保留 final residual hardening PR #448 与 production executable `try!` = 0。 |
| L4 / production readiness | Done / no-default-production-trading | Historical L4 maturity statement：`L4 Live Production / Trading Commands v1 complete with no-default-production-trading policy`；PR #473 至 #493 evidence 与 PR #511 至 #519 evidence 只证明 future-gated / readiness-only gates，不授权真实 broker、production endpoint、signed endpoint、account endpoint / listenKey、production OMS、real submit / cancel / replace、trading button、live command、order form 或 production trading。 |
| Release v0.1.0 baseline | Done / Binance + EMA runtime validation / production disabled by default | `MTPRO Release v0.1.0` 只证明 Binance + EMA dry-run / testnet validation、operator runbook 和 no-default-production-trading guard；production trading 默认关闭，不读取 production secret，不连接 production endpoint 或 production broker endpoint。 |

## Construction Slice Selection / 施工切片选择

下一阶段 planning 只能从 `BLUEPRINT.md` 的 Future Construction Zones / 未来建设区中选择一个清晰切片，并把它收敛为 Project Planning Record。选择切片时必须满足：

- 能对应 `GOAL.md` 的某个 Final Product Goal Slice。
- 能落到 `architecture.md` 中可解释的工程模块或模块边界。
- 能被拆成 WIP=1 的 Linear issue queue。
- 能用 deterministic validation、PR evidence、Stage Code Audit 和 Root Docs Refresh 收口。
- 不把多个 future capability 一次性打包成模糊大 Project。

当前已完成的 live-route 候选顺序：

```text
实盘监控台
-> 实盘执行控制
-> 实盘风险控制
-> 实盘审计 / 事故回放 / 停机控制
```

上述四个 live-route 目标切片均已完成各自的 read-model-only / contract + blocked evidence 切片。该顺序不是执行授权。Human + `@001 / PLN` 可以基于最新 Stage Audit、风险和产品优先级重新定义下一轮 planning；`docs/roadmap.md` 不自动决定下一阶段方向。

## Live Route Gates / 实盘路线门槛

实盘相关目标切片必须按门槛推进，不能从 paper-only foundation 直接跳到真实订单：

| 目标切片 | 进入前置 | 当前状态 |
| --- | --- | --- |
| 实盘交易基础边界 | Human 独立决策、独立 Project Definition、secret / signed endpoint / account endpoint / broker adapter / real order lifecycle gates | Complete：已定义 foundation taxonomy、credential endpoint boundary、adapter isolation、real order lifecycle terminology、blocked evidence 和只读 evidence surface；未实现真实 Live trading |
| 实盘监控台 | 已定义 live runtime health、connection、market stream、order stream、error、latency 和 operations evidence | Complete / read-model-only evidence surface：已完成 health、connection、stream、latency、error evidence 展示面；真实 live runtime、signed/account stream、broker stream 和交易控制仍未实现 |
| 实盘执行控制 | 已定义 real order submit / cancel / replace、execution report、reconciliation 和 incident fallback | Complete / contract + blocked evidence；真实 execution runtime、真实订单命令、broker fill、execution report 和 reconciliation 仍 gated |
| 实盘风险控制 | 已定义 live pre-trade risk、exposure / order notional / frequency / loss / drawdown / circuit breaker / no-trade gates 和 read-model-only blocked evidence | Complete / contract + blocked evidence；真实 live risk engine、真实账户风控、real pre-trade allow / reject runtime、risk command、stop command 和 emergency stop 仍 gated |
| 实盘审计 / 事故回放 / 停机控制 | 已定义 live event chain、audit trail、incident replay、shutdown / restore policy | Complete / contract + blocked evidence；真实 audit trail runtime、incident replay runtime、emergency stop、shutdown、restore、production operations、Live PRO Console、live command 和 trading button 仍 gated |

任何缺少对应 gate 的变更只能停留在蓝图或 planning 草案中，不能进入 Linear execution。

## Project Closure Rule / Project 收口规则

当前 Project 全部有效 issues `Done` 后，必须按顺序关闭：

```text
Linear Project status Completed
-> Stage Code Audit Report
-> Root Docs Refresh Gate
-> Current Phase Progress Bar
-> Next Human Project Planning
```

`@002 / PAR` 只同步已发生事实；下一阶段方向、目标、架构路线和优先级必须由 Human + `@001 / PLN` 决定。

Project closure 后，`docs/roadmap.md` 只更新这些事实：

- Project 是否 Completed。
- Stage Code Audit Report 路径。
- Root Docs Refresh Gate 是否 closure。
- Project Closure Count。
- Current Foundation Progress。
- Final Product Goal Progress。
- Next Handoff。

不把 child issue 细节、PR 流水账或临时 CI 失败详情写入本文档；这些进入 `docs/audit/`、`docs/validation/` 或 `verification.md`。

## Next Handoff Contract / 下一轮交接合同

下一轮交给 Human + `@001 / PLN` 时，必须带上：

- 当前 Final Product Goal Progress。
- 当前 pending / gated 目标切片。
- 最近 Stage Code Audit Report。
- Root Docs Refresh Gate closure 结果。
- 不能触碰的禁止能力。
- 候选 Project 方向，但不创建 Linear Project / Issue。

`@001 / PLN` 输出 Project / Issue draft 后，也仍然不授权执行。只有 Human review / merge、Linear 写入、`@002 / PAR` startup gate 和 queue preflight 全部完成后，唯一 eligible issue 才能进入 `Todo`。

## 非授权边界

- `docs/roadmap.md` 不创建 Linear Project / Issue。
- `docs/roadmap.md` 不修改 Linear status。
- `docs/roadmap.md` 不启动额外调度服务。
- `docs/roadmap.md` 不运行图谱更新服务。
- `docs/roadmap.md` 不解锁下一个 issue。
- `docs/roadmap.md` 不授权任何 Agent 直接把 issue 改为 `Todo`。
