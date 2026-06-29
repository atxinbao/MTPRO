# Release Publication Policy

日期：2026-06-16

执行者：Codex

本文档服务 GitHub fallback issue `GH-808 V080-002 Align v0.7.0/v0.8.0 release publication docs and policy`。

后续维护记录：

- `GH-879 V0100-002 Align v0.9.1 / v0.10.0 release publication docs and version policy`
- `v0.11.0 Release Publication Gate fact sync`
- `GH-953 V0120-002 Align v0.11.x release publication and patch facts`
- `v0.12.0 Release Publication Gate fact sync`
- `GH-993 V0121-006 Close v0.12.1 patch audit and release notes`
- `GH-1064 V141-006 Correct v0.14 wording and close hardening patch audit`
- `GH-1094 V151-001 Sync v0.15.0 release facts in root docs`
- `GH-1095 V151-002 Clarify injected transport versus built-in network runner wording`
- `GH-1100 V151-007 Harden v0.15 execution artifact decoding and close patch validation`
- `GH-1105 V160-005 Add signed order status query`
- `GH-1106 V160-006 Add local execution artifact store`
- `GH-1107 V160-007 Add OMS observed status reconciliation`
- `GH-1108 V160-008 Add Dashboard artifact-backed execution view`
- `GH-1109 V160-009 Add failure recovery workflow`
- `GH-1112 V160-012 Close v0.16.0 audit / runbook / release docs`
- `GH-1133 V161-001 Sync v0.16.0 publication facts into v0.16.1 patch docs`
- `GH-1134 V161-002 Validate manual evidence bundle content in GitHub workflow`
- `GH-1135 V161-003 Centralize v0.16 artifact redaction policy`
- `GH-1136 V161-004 Add redaction regression coverage for Binance headers, signed query and production hosts`
- `GH-1148 V170-010 Close v0.17.0 stage audit and release docs`
- `GH-1200 V181-001 Sync v0.18.0 publication facts`
- `GH-1233 V191-002 Rewrite v0.19.0 construction closeout wording as historical context`
- `GH-1234 V191-003 Harden v0.19.0 stale wording guard`

## GH-808-RELEASE-PUBLICATION-POLICY

`GH-808-RELEASE-PUBLICATION-POLICY`

MTPRO release line 必须区分两类 gate：

- construction closeout gate：收口 issue queue、Stage Code Audit、root docs / release docs / runbook、validation command 和 no-default-production-trading evidence。
- public release publication gate：在 construction closeout 完成后，单独确认 tag、GitHub Release、release notes、target commit、source checksum expectation 和 publication boundary。

construction closeout 不等于 public release publication。public release publication 也不等于 production cutover。

## V080-002-V070-ACTUAL-GITHUB-RELEASE

`V080-002-V070-ACTUAL-GITHUB-RELEASE`

v0.7.0 当前存在 stable GitHub Release：

- release tag：`v0.7.0`
- release title：`MTPRO v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity`
- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.7.0`
- release type：stable release；非 draft；非 prerelease
- tag peeled commit：`79bd7309b5d644599b6879e615489562455cd3fe`
- publication timestamp：`2026-06-15T13:36:43Z`

v0.7.0 的 Stage Code Audit、release notes 和 root docs refresh 是 construction closeout evidence；后续 GitHub Release publication 是独立发布动作。文档不得再把 v0.7.0 描述成没有 GitHub Release。

## GH-835-V081-V080-ACTUAL-GITHUB-RELEASE

`GH-835-V081-V080-ACTUAL-GITHUB-RELEASE`

v0.8.0 当前存在 stable GitHub Release：

- release tag：`v0.8.0`
- release title：`MTPRO v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring`
- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.8.0`
- release type：stable release；非 draft；非 prerelease
- tag peeled commit：`d83b3b564096a5427db15a437921fc797b22564d`
- publication timestamp：`2026-06-16T11:56:09Z`

v0.8.0 的 Stage Code Audit、release notes 和 root docs refresh 是 construction closeout evidence；后续 GitHub Release publication 已通过独立 stable GitHub Release gate 完成。文档不得再把 v0.8.0 描述成 publication pending，也不得把 GitHub Release publication 当作 production cutover authorization。

## V090-ACTUAL-GITHUB-RELEASE

`V090-ACTUAL-GITHUB-RELEASE`

v0.9.0 当前存在 stable GitHub Release：

- release tag：`v0.9.0`
- release title：`MTPRO v0.9.0 Testnet No-order Observability`
- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.9.0`
- release type：stable release；非 draft；非 prerelease
- tag peeled commit：`4296bf73673fe0fd8f09e34c40ef2a3a9ba7e55c`
- publication timestamp：`2026-06-17T17:09:19Z`

v0.9.0 的 Stage Code Audit、release notes、operator runbook 和 root docs refresh 是 construction closeout evidence；后续 GitHub Release publication 已通过独立 stable GitHub Release gate 完成。文档不得再把 v0.9.0 描述成 publication pending，也不得把 GitHub Release publication 当作 production cutover authorization。

## GH-879-V0100-V091-ACTUAL-GITHUB-RELEASE

`GH-879-V0100-V091-ACTUAL-GITHUB-RELEASE`

`GH-879-VERIFY-V0100-V091-PUBLICATION-POLICY`

`V0100-002-V091-PUBLICATION-FACT`

`TVM-RELEASE-V0100-V091-PUBLICATION-POLICY`

v0.9.1 当前存在 stable GitHub Release：

- release tag：`v0.9.1`
- release title：`MTPRO v0.9.1 Audit Hardening Patch`
- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.9.1`
- release type：stable release；非 draft；非 prerelease
- tag peeled commit：`d041f0dd304075562a85e494695697290972288f`
- publication timestamp：`2026-06-17T19:45:42Z`

v0.9.1 的 Stage Code Audit 和 release notes 是 audit hardening patch closeout evidence；后续 GitHub Release publication 已通过独立 stable GitHub Release gate 完成。文档不得再把 v0.9.1 描述成 tagless patch、没有 tag 或没有 GitHub Release，也不得把 GitHub Release publication 当作 production cutover authorization。

## V0100-002-V0100-RELEASE-POLICY-ANCHOR

`V0100-002-V0100-RELEASE-POLICY-ANCHOR`

v0.10.0 使用 `MTPRO Release v0.10.0 Production Cutover Readiness Gate` 作为 release construction queue。该 queue 只能评估 production cutover readiness，不授权 production cutover。

v0.10.0 release fact flow 在 v0.10.1 patch 中固定为四段 gate：

1. construction closeout gate（也称 construction / readiness closeout gate）：收口 GitHub fallback queue `GH-878..GH-891`、Stage Code Audit、release docs、runbook、validation command 和 no-default-production-trading evidence。
2. release publication gate：只有在 construction closeout 完成后，才能通过显式发布指令创建或核对 tag / GitHub Release。
3. release fact sync gate：publication 完成后同步 root docs、release docs、validation summary、automation readiness 和 audit / runbook 里的已发生事实。
4. stale wording guard gate：通过 `GH-907-VERIFY-V0101-RELEASE-FACT-STALE-WORDING-GUARD` / `V0101-002-RELEASE-FACT-SYNC-GUARD` / `V0101-002-FOUR-GATE-RELEASE-FLOW` / `TVM-RELEASE-V0101-RELEASE-FACT-SYNC-GUARD` 阻止 v0.10.0 文档保留过期 publication wording。

Production cutover remains a separate non-release gate；production cutover gate 保持独立，不能由 construction closeout、release publication、release fact sync 或 stale wording guard 自动触发。

v0.10.0 当前存在 stable GitHub Release：

- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.10.0`
- tag target commit：`7b0e1f8bb6a671cd3b96f7e7b020b803f8cea4b4`
- release title：`MTPRO v0.10.0 Production Cutover Readiness Gate`
- publication timestamp：`2026-06-18T05:19:46Z`
- release type：stable；非 draft；非 prerelease

v0.10.0 的 construction / readiness closeout 已通过 `GH-878..GH-891` 完成，public GitHub Release publication 已通过独立 gate 完成。文档不得再保留与当前 publication fact 冲突的旧 wording；也不得把 GitHub Release publication 当作 production cutover authorization。

v0.10.0 readiness evidence 允许记录 approval workflow、manual confirmation checklist、operator runbook、Dashboard readiness center 和 audit bundle；这些 evidence 仍不授权 production trading，不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order。

## V0110-ACTUAL-GITHUB-RELEASE

`V0110-ACTUAL-GITHUB-RELEASE`

`GH-945-VERIFY-V0111-RELEASE-FACT-STALE-WORDING-GUARD`

`V0111-001-RELEASE-FACT-SYNC-GUARD`

`V0111-001-FOUR-GATE-RELEASE-FLOW`

`TVM-RELEASE-V0111-RELEASE-FACT-SYNC-GUARD`

v0.11.0 使用 `MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening` 作为 release construction queue。#924 construction closeout 本身只收口 Stage Code Audit、release notes、root docs refresh、aggregate verifier guard 和 focused closeout test；它不创建 tag，也不发布 GitHub Release。

v0.11.0 当前存在 public GitHub Release：

- release tag：`v0.11.0`
- release title：`MTPRO v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening`
- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.11.0`
- release type：stable release；非 draft；非 prerelease
- tag peeled commit：`13f592d0710de91351286e5c5490bfacb63c19b0`
- publication timestamp：`2026-06-19T01:20:58Z`

v0.11.0 的 construction closeout、Release Publication Gate、release fact sync / stale wording guard 和 production cutover 仍是独立 gate。已发布事实不授权 production trading，不读取 production secret，不连接 production endpoint / broker endpoint，不发送真实订单，不创建下一 Project / Issue，也不推进 v0.12.0。

GH-945 / v0.11.1 stale wording guard 固定该 release fact：所有未限定为 #924 历史 closeout 的 v0.11.0 文档不得继续描述为 publication pending、tag pending、release not created、没有 GitHub Release、未创建 release 或待发布。

## V0120-ACTUAL-GITHUB-RELEASE

`V0120-ACTUAL-GITHUB-RELEASE`

`GH-988-VERIFY-V0121-RELEASE-FACT-STALE-WORDING-GUARD`

`V0121-001-RELEASE-FACT-SYNC-GUARD`

`V0121-001-FOUR-GATE-RELEASE-FLOW`

`TVM-RELEASE-V0121-RELEASE-FACT-SYNC-GUARD`

v0.12.0 使用 `MTPRO Release v0.12.0 Readiness Assessment Sessions` 作为 release construction queue。#965 construction closeout 本身只收口 Stage Code Audit、release notes、operator runbook、root docs refresh、aggregate verifier guard 和 focused closeout test；它不授权 production cutover。

v0.12.0 当前存在 public GitHub Release：

- release tag：`v0.12.0`
- release title：`MTPRO v0.12.0 Readiness Assessment Sessions`
- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.12.0`
- release type：stable release；非 draft；非 prerelease
- tag peeled commit：`25e31afd351db9a372db62222226b0a3db26c93a`
- publication timestamp：`2026-06-20T01:11:22Z`

v0.12.0 的 construction closeout、Release Publication Gate、release fact sync / stale wording guard 和 production cutover 仍是独立 gate。已发布事实不授权 production trading，不读取 production secret，不连接 production endpoint / broker endpoint，不发送真实订单，不创建下一 Project / Issue，也不推进 v0.13.0。

GH-988 / v0.12.1 stale wording guard 固定该 release fact：所有未限定为 #965 历史 closeout 的 v0.12.0 文档不得继续描述为 publication pending、tag pending、release not created、no public tag、no GitHub Release、未创建 release 或待发布。

## V0151-001-V0150-RELEASE-FACT-SYNC-GUARD

`GH-1094-VERIFY-V0151-V0150-RELEASE-FACT-SYNC`

`V0151-001-V0150-RELEASE-FACT-SYNC-GUARD`

`TVM-RELEASE-V0151-V0150-RELEASE-FACT-SYNC`

v0.15.0 Real Binance Testnet Execution MVP 已在 #1076 construction closeout 后通过独立 Release Publication Gate 发布 stable GitHub Release。

- GitHub Release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.15.0`
- tag peeled commit：`1590b6c40e6ca7887cff0ca59b2f74e4fe7e3ece`
- publication timestamp：`2026-06-23T01:26:30Z`

#1076 是 construction closeout / release CI / manual testnet workflow / audit evidence gate，不是 release publication gate；但 release publication 已在后续独立 gate 中完成。所有未限定为 #1076 historical closeout 的 v0.15.0 文档不得继续描述为 publication pending、tag pending、release not created、没有 GitHub Release、未创建 release 或待发布。

v0.15.0 release publication、v0.15.1 release fact sync / stale wording guard、后续 hardening patch 和 production cutover 仍是独立 gate。已发布事实不授权 production trading，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 production order，不创建下一 Project / Issue，也不推进 v0.15.1 后续 issue。

## V0151-002-INJECTED-TRANSPORT-WORDING

`GH-1095-VERIFY-V0151-INJECTED-TRANSPORT-WORDING`

`V0151-002-INJECTED-TRANSPORT-NOT-BUILTIN-RUNNER`

`V0151-002-MOCK-MANUAL-PROOF-SPLIT`

`V0151-002-FUTURE-URLSESSION-RUNNER-DEFERRED`

`TVM-RELEASE-V0151-INJECTED-TRANSPORT-WORDING`

v0.15.0 release publication 固定的是 signed execution runtime contracts 和 redacted evidence identity，不把仓库升级为 out-of-the-box built-in URLSession runner。所有 root / release / runbook / validation wording 必须区分：

- injected Spot Testnet transport protocol evidence；
- deterministic mock proof；
- operator manual proof；
- 后续 #1096 concrete URLSession transport runner。

`mtpro` CLI operator flow 不得被描述为 default real-network execution runner。任何 concrete URLSession runner、real network runner wiring 或 production broker connector 都必须由后续 issue 单独实现、验证和收口。该 wording guard 不移动 v0.15.0 tag，不覆盖 release，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。

## V0151-003-URLSESSION-SPOT-TESTNET-TRANSPORT

`GH-1096-VERIFY-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT`

`TVM-RELEASE-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT`

`V0151-003-URLSESSION-SPOT-TESTNET-ALLOWLIST`

`V0151-003-SUBMIT-CANCEL-URLSESSION-TRANSPORT`

`V0151-003-REDACTED-RESPONSE-DIGEST`

`V0151-003-NO-SECRET-PERSISTENCE`

`V0151-003-PRODUCTION-ENDPOINT-REJECTED`

`V0151-003-NO-PRODUCTION-CUTOVER`

#1096 是 v0.15.1 对 #1095 wording split 的 concrete hardening slice：它允许仓库内存在一个 bounded URLSession-backed Binance Spot Testnet transport，但只允许 `https://testnet.binance.vision/api/v3/order` 的 submit / cancel request。

## V0151-004-CLI-TESTNET-EXECUTION-RUNTIME

`GH-1097-VERIFY-V0151-CLI-TESTNET-EXECUTION-RUNTIME`

`TVM-RELEASE-V0151-CLI-TESTNET-EXECUTION-RUNTIME`

`V0151-004-CLI-GUARDED-RUNTIME-INVOKED`

`V0151-004-TESTNET-ONLY-CREDENTIAL-PROVIDER`

`V0151-004-SUBMIT-CANCEL-CANCEL-REPLACE-RUNTIME`

`V0151-004-EXPLICIT-OPERATOR-CONFIRMATION`

`V0151-004-REDACTED-OUTPUT`

`V0151-004-MISSING-CREDENTIAL-FAIL-CLOSED`

`V0151-004-RUN-ID-ARTIFACT-CHECKSUM`

`V0151-004-NO-PRODUCTION-CUTOVER`

#1097 是 v0.15.1 对 #1096 concrete transport 的 CLI wiring hardening slice：它允许 `mtpro testnet-execution` 在 `testnet-env` credential provider、显式 operator confirmation 和 redacted output 下调用 v0.15 guarded submit / cancel / cancel-replace runtime。缺少 testnet credential 或 confirmation 必须 fail-closed。该 policy 不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。

## V0151-005-RUNTIME-INTERNAL-GATES

`GH-1098-VERIFY-V0151-RUNTIME-INTERNAL-GATES`

`TVM-RELEASE-V0151-RUNTIME-INTERNAL-GATES`

`V0151-005-RISKENGINE-GATE-IN-RUNTIME`

`V0151-005-KILL-SWITCH-GATE-IN-RUNTIME`

`V0151-005-NO-TRADE-GATE-IN-RUNTIME`

`V0151-005-OPERATOR-CONFIRMATION-IN-RUNTIME`

`V0151-005-TRANSPORT-NOT-INVOKED-WHEN-BLOCKED`

`V0151-005-NO-PRODUCTION-CUTOVER`

#1098 是 v0.15.1 对 #1097 CLI runtime 的 internal gate hardening slice：它要求 submit / cancel / cancel-replace runtime 在触达 Binance Spot Testnet transport 前重新检查 RiskEngine allow、kill switch inactive、no-trade inactive 和 operator confirmation。Rejected risk、active kill switch、active no-trade 或 missing confirmation 必须 fail-closed，且 transport invocation 不发生。该 policy 不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。

## V0151-006-CLIENT-ORDER-IDENTITY-CHAIN

`GH-1099-VERIFY-V0151-CLIENT-ORDER-IDENTITY-CHAIN`

`TVM-RELEASE-V0151-CLIENT-ORDER-IDENTITY-CHAIN`

`V0151-006-DETERMINISTIC-NEW-CLIENT-ORDER-ID`

`V0151-006-REDACTED-CLIENT-ORDER-REFERENCE`

`V0151-006-SUBMIT-TO-CANCEL-IDENTITY-HANDOFF`

`V0151-006-RAW-UNTRACKED-ORDER-ID-REJECTED`

`V0151-006-NO-PRODUCTION-CUTOVER`

## V0151-007-CODABLE-DECODE-CLOSEOUT

`GH-1100-VERIFY-V0151-CODABLE-DECODE-CLOSEOUT`

`TVM-RELEASE-V0151-CODABLE-DECODE-CLOSEOUT`

`V0151-007-CODABLE-DECODE-VALIDATION`

`V0151-007-CORRUPTED-JSON-FAILS-CLOSED`

`V0151-007-CHECKSUM-MISMATCH-FAILS-CLOSED`

`V0151-007-PRODUCTION-HOST-MUTATION-REJECTED`

`V0151-007-NO-PRODUCTION-CUTOVER`

v0.15.1 是 v0.15.0 后的 real testnet execution hardening patch closeout。#1100 只增强 submit / cancel / cancel-replace evidence、network event log、OMS snapshot 和 reconciliation report 的 Codable decode-time validation，并同步 Stage Code Audit / release notes / validation matrix。

本 `v0.15.1` closeout 不创建 `v0.15.1` tag，不创建 `v0.15.1` GitHub Release，不移动既有 `v0.15.0` release identity，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。若后续需要 public `v0.15.1` release，必须走独立 Release Publication Gate。

## V0160-001-OPERATOR-BETA-CONTRACT

`GH-1101-VERIFY-V0160-OPERATOR-BETA-CONTRACT`

`TVM-RELEASE-V0160-OPERATOR-BETA-CONTRACT`

`V0160-001-V0151-PREFLIGHT-GATE`

`V0160-001-BINANCE-SPOT-TESTNET-ONLY`

`V0160-001-OPERATOR-CONFIRMATION-REQUIRED`

`V0160-001-REDACTED-EVIDENCE-REQUIRED`

`V0160-001-QUEUE-ORDER`

`V0160-001-NO-PRODUCTION-CUTOVER`

#1101 是 v0.16.0 Binance Spot Testnet Operator Execution Beta 的 contract / preflight slice。它只定义 #1100 依赖、#1102..#1112 queue order、Binance Spot Testnet-only scope、显式 operator confirmation、redacted evidence 和 production 禁区。

本 `v0.16.0` contract slice 不创建 tag，不创建 GitHub Release，不读取 credential value，不连接 testnet endpoint，不提交 testnet order，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。后续 issue 只有在各自 GitHub issue scope 明确授权时，才能逐步实现 bounded Spot Testnet operator runtime。

## V0160-002-OPERATOR-RUN-MODEL

`GH-1102-VERIFY-V0160-OPERATOR-RUN-MODEL`

`TVM-RELEASE-V0160-OPERATOR-RUN-MODEL`

`V0160-002-RUN-ID-LIFECYCLE`

`V0160-002-ACTION-SEQUENCE`

`V0160-002-ARTIFACT-LINKAGE`

`V0160-002-INVALID-TRANSITION-FAILS-CLOSED`

`V0160-002-REDACTED-METADATA`

`V0160-002-NO-NETWORK-BY-THIS-ISSUE`

`V0160-002-NO-PRODUCTION-CUTOVER`

#1102 是 v0.16.0 Binance Spot Testnet Operator Execution Beta 的 operator run model slice。它只定义 durable run id lifecycle、action sequence、artifact linkage、redacted metadata 和 invalid transition fail-closed guard。

本 `v0.16.0` run model slice 不创建 tag，不创建 GitHub Release，不读取 credential value，不连接 testnet endpoint，不提交 testnet order，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。submit / cancel / status / reconciliation runtime 只有在后续 GitHub issue scope 明确授权时才能实现。

## V0160-003-STABLE-CLI-SUBMIT

`GH-1103-VERIFY-V0160-CLI-SUBMIT-FLOW`

`TVM-RELEASE-V0160-CLI-SUBMIT-FLOW`

`V0160-003-STABLE-CLI-SUBMIT`

`V0160-003-V0151-RUNTIME-DELEGATION`

`V0160-003-EXPLICIT-OPERATOR-CONFIRMATION`

`V0160-003-TESTNET-CREDENTIAL-PROFILE`

`V0160-003-REDACTED-OUTPUT-ARTIFACT-CHECKSUM`

`V0160-003-MISSING-GATE-CREDENTIAL-CONFIRMATION-FAILS-CLOSED`

`V0160-003-NO-PRODUCTION-CUTOVER`

#1103 是 v0.16.0 Binance Spot Testnet Operator Execution Beta 的 stable CLI submit flow slice。它只授权 `spot-testnet-submit` submit-only operator command，委托 v0.15.1 guarded runtime，要求 explicit v0.16 operator confirmation、testnet-env credential profile、redacted artifact path 和 checksum。

本 `v0.16.0` CLI submit slice 不创建 tag，不创建 GitHub Release，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。cancel / status / reconciliation / Dashboard review / recovery 只有在后续 GitHub issue scope 明确授权时才能实现。

## V0160-004-STABLE-CLI-CANCEL

`GH-1104-VERIFY-V0160-CLI-CANCEL-FLOW`

`TVM-RELEASE-V0160-CLI-CANCEL-FLOW`

`V0160-004-STABLE-CLI-CANCEL`

`V0160-004-SUBMIT-ARTIFACT-IDENTITY`

`V0160-004-V0151-RUNTIME-DELEGATION`

`V0160-004-EXPLICIT-OPERATOR-CONFIRMATION`

`V0160-004-TESTNET-CREDENTIAL-PROFILE`

`V0160-004-REDACTED-ORDER-REFERENCE`

`V0160-004-APPEND-ONLY-EVENT-EVIDENCE`

`V0160-004-MISSING-PRIOR-ARTIFACT-FAILS-CLOSED`

`V0160-004-NO-PRODUCTION-CUTOVER`

#1104 是 v0.16.0 Binance Spot Testnet Operator Execution Beta 的 stable CLI cancel flow slice。它只授权 `spot-testnet-cancel` cancel-only operator command，消费 source submit evidence JSON 和 network event log JSON，委托 v0.15.1 guarded runtime，要求 explicit v0.16 operator confirmation、testnet-env credential profile、redacted order reference、append-only event evidence、redacted artifact path 和 checksum。

本 `v0.16.0` CLI cancel slice 不创建 tag，不创建 GitHub Release，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。status / reconciliation / Dashboard review / recovery 只有在后续 GitHub issue scope 明确授权时才能实现。

## V0160-005-SIGNED-GET-ORDER-STATUS

`GH-1105-VERIFY-V0160-SIGNED-ORDER-STATUS-QUERY`

`TVM-RELEASE-V0160-SIGNED-ORDER-STATUS-QUERY`

`V0160-005-SIGNED-GET-ORDER-STATUS`

`V0160-005-TESTNET-ENDPOINT-ALLOWLIST`

`V0160-005-REDACTED-REQUEST-RESPONSE-EVIDENCE`

`V0160-005-NO-RAW-SECRET-PERSISTENCE`

`V0160-005-PRODUCTION-HOST-REJECTED`

`V0160-005-NO-PRODUCTION-CUTOVER`

#1105 是 v0.16.0 Binance Spot Testnet Operator Execution Beta 的 signed order status query slice。它只授权 `spot-testnet-status-query` status-only operator command，消费 source submit evidence JSON 和 network event log JSON，从 submit evidence 派生短生命周期 order identity，并构造 allowlisted signed GET `/api/v3/order` status query。

本 `v0.16.0` order status query slice 不创建 tag，不创建 GitHub Release，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。reconciliation / Dashboard review / recovery 只有在后续 GitHub issue scope 明确授权时才能实现。

## V0160-006-APPEND-ONLY-ARTIFACT-PERSISTENCE

`GH-1106-VERIFY-V0160-LOCAL-EXECUTION-ARTIFACT-STORE`

`TVM-RELEASE-V0160-LOCAL-EXECUTION-ARTIFACT-STORE`

`V0160-006-APPEND-ONLY-ARTIFACT-PERSISTENCE`

`V0160-006-CHECKSUM-MANIFEST`

`V0160-006-CHECKSUM-MISMATCH-REJECTED`

`V0160-006-REPLAY-VALIDATION`

`V0160-006-REDACTED-EXPORT-BUNDLE`

`V0160-006-NO-PRODUCTION-CUTOVER`

#1106 是 v0.16.0 Binance Spot Testnet Operator Execution Beta 的 local execution artifact store slice。它只授权本地 append-only JSONL artifact persistence、checksum manifest、checksum mismatch rejection、replay validation 和 redacted export bundle，用于承接 submit、cancel、status 和后续 reconciliation evidence。

本 `v0.16.0` local execution artifact store slice 不创建 tag，不创建 GitHub Release，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。Dashboard review / recovery / reconciliation 只有在后续 GitHub issue scope 明确授权时才能实现。

## V0160-007-SUBMIT-OBSERVED-RECONCILIATION

`GH-1107-VERIFY-V0160-OMS-OBSERVED-STATUS-RECONCILIATION`

`TVM-RELEASE-V0160-OMS-OBSERVED-STATUS-RECONCILIATION`

`V0160-007-SUBMIT-OBSERVED-RECONCILIATION`

`V0160-007-CANCEL-OBSERVED-RECONCILIATION`

`V0160-007-UNKNOWN-STATUS-FAILS-CLOSED`

`V0160-007-MISMATCH-FAILS-CLOSED`

`V0160-007-LOCAL-ARTIFACTS-ONLY`

`V0160-007-NO-PRODUCTION-CUTOVER`

#1107 是 v0.16.0 Binance Spot Testnet Operator Execution Beta 的 OMS observed-status reconciliation slice。它只授权消费 #1106 本地 replay surface 中的 submit、cancel 和 status artifacts，生成 deterministic reconciliation report，并覆盖 submit observed、cancel observed、unknown status、expected-state mismatch、missing cancel artifact 和非 status evidence 的 pass / fail-closed 证据。

本 `v0.16.0` OMS observed-status reconciliation slice 不创建 tag，不创建 GitHub Release，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。Dashboard review / recovery 只有在后续 GitHub issue scope 明确授权时才能实现。

## V0160-008-LOCAL-ARTIFACT-BACKED-ROWS

`GH-1108-VERIFY-V0160-DASHBOARD-ARTIFACT-BACKED-EXECUTION-VIEW`

`TVM-RELEASE-V0160-DASHBOARD-ARTIFACT-BACKED-EXECUTION-VIEW`

`V0160-008-LOCAL-ARTIFACT-BACKED-ROWS`

`V0160-008-ACTION-SEQUENCE-VISIBLE`

`V0160-008-CHECKSUMS-VISIBLE`

`V0160-008-OMS-RECONCILIATION-RESULT-VISIBLE`

`V0160-008-DASHBOARD-READ-ONLY-NO-COMMANDS`

`V0160-008-NO-PRODUCTION-CUTOVER`

#1108 是 v0.16.0 Binance Spot Testnet Operator Execution Beta 的 Dashboard artifact-backed execution view slice。它只授权 Dashboard 消费本地 read-model artifacts，并以只读方式展示 artifact-backed rows、action sequence、artifact checksums、artifact paths 和 OMS reconciliation result。

本 `v0.16.0` Dashboard artifact-backed execution view slice 不创建 tag，不创建 GitHub Release，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order，不提供 Dashboard command surface、trading button、order form 或 live command。

## V0160-009-SUBMIT-SUCCEEDED-ARTIFACT-WRITE-FAILED

`GH-1109-VERIFY-V0160-FAILURE-RECOVERY-WORKFLOW`

`TVM-RELEASE-V0160-FAILURE-RECOVERY-WORKFLOW`

`V0160-009-SUBMIT-SUCCEEDED-ARTIFACT-WRITE-FAILED`

`V0160-009-NETWORK-TIMEOUT-POSSIBLE-EXCHANGE-RECEIPT`

`V0160-009-CANCEL-UNKNOWN-STATE`

`V0160-009-STATUS-QUERY-COMPENSATION-WORKFLOW`

`V0160-009-NO-AUTOMATIC-PRODUCTION-RETRY`

`V0160-009-NO-PRODUCTION-CUTOVER`

#1109 是 v0.16.0 Binance Spot Testnet Operator Execution Beta 的 failure recovery workflow slice。它只授权本地 recovery runbook evidence，覆盖 submit 可能成功但 artifact 写入失败、network timeout 但 exchange receipt 未知、cancel unknown state，以及 manual status query compensation workflow。

本 `v0.16.0` failure recovery slice 不创建 tag，不创建 GitHub Release，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order，不自动 retry 到 production。后续 review / audit / closeout 只有在后续 GitHub issue scope 明确授权时才能实现。

#1099 是 v0.15.1 对 #1098 internal gate 后的 submit-to-cancel identity hardening slice：它要求 submit evidence 生成 deterministic redacted `newClientOrderId` reference，cancel 只能从 submit evidence 派生短生命周期 identity material，raw / untracked order id 必须 fail-closed。该 policy 不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。

该 transport policy 的固定事实：

- scheme 必须为 `https`；
- host 必须为 `testnet.binance.vision`；
- path 必须为 `/api/v3/order`；
- `api.binance.com`、`fapi.binance.com` 和 `dapi.binance.com` 必须 fail-closed；
- response body 只允许降维为 `response-sha256` redacted digest；
- API key、signing secret 和 raw order identity 不得进入持久 evidence；
- production cutover、production secret read、production endpoint / broker endpoint connection 和 production order 仍未授权。

该 guard 不移动 v0.15.0 tag，不覆盖 release，不创建下一 Project / Issue，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。

## V0141-006-PATCH-AUDIT-RELEASE-NOTES

`GH-1064-VERIFY-V0141-PATCH-AUDIT-RELEASE-NOTES`

`TVM-RELEASE-V0141-PATCH-AUDIT-RELEASE-NOTES`

`V0141-006-PATCH-AUDIT`

`V0141-006-RELEASE-NOTES`

`V0141-006-VALIDATION-SUMMARY`

`V0141-006-LOCAL-EVIDENCE-WORDING`

`V0141-006-NO-PRODUCTION-CUTOVER`

`V0141-006-NO-TAG-OR-RELEASE-PUBLICATION`

v0.14.1 Local Execution Evidence Hardening Patch 是 v0.14.0 public Release 后的 local execution evidence hardening closeout。它只收口 #1059..#1064 的 release CI / Dashboard evidence、Codable decode validation、submit evidence network guard、golden JSON contract validation、Dashboard local artifact loading、Stage Code Audit、release notes 和 root-doc wording。

#1064 is not a release publication gate:

- 不创建 `v0.14.1` tag。
- 不创建 `v0.14.1` GitHub Release。
- 不移动、不覆盖、不重写 `v0.14.0` tag 或 GitHub Release。
- 不推进 v0.15.0。
- 不授权 production cutover。

v0.14.1 的 engineering semantic 是 `local execution evidence chain / testnet evidence only`。它不是真实 signed Binance testnet execution release，不代表真实 Binance testnet order execution，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 testnet 或 production order。若 Human 后续要求发布 `v0.14.1`，必须在 #1064 PR merge、required checks SUCCESS、issue closed / done、main == origin/main 和 worktree clean 后，执行独立 Release Publication Gate。

## V0121-006-PATCH-AUDIT-RELEASE-NOTES

`GH-993-VERIFY-V0121-PATCH-AUDIT-RELEASE-NOTES`

`TVM-RELEASE-V0121-PATCH-AUDIT-RELEASE-NOTES`

`V0121-006-PATCH-AUDIT`

`V0121-006-RELEASE-NOTES`

`V0121-006-VALIDATION-SUMMARY`

`V0121-006-NO-PRODUCTION-CUTOVER`

`V0121-006-NO-TAG-OR-RELEASE-MOVE`

v0.12.1 Readiness Assessment Provenance Hardening Patch 是 v0.12.0 public Release 后的 provenance hardening closeout。它只收口 #988..#993 的 release fact sync、source commit provenance、local evidence metadata、compare fail-closed behavior、generated JSON inspection、Stage Code Audit、release notes 和 root-doc patch facts。

GH-993 is not a release publication gate:

- 不创建 `v0.12.1` tag。
- 不创建 `v0.12.1` GitHub Release。
- 不移动、不覆盖、不重写 `v0.12.0` tag 或 GitHub Release。
- 不推进 v0.13.0。
- 不授权 production cutover。

v0.12.0 public GitHub Release 仍保持为 `https://github.com/atxinbao/MTPRO/releases/tag/v0.12.0`，tag peeled commit `25e31afd351db9a372db62222226b0a3db26c93a`，publication timestamp `2026-06-20T01:11:22Z`。v0.12.1 patch closeout 不改变该 release identity。

## V0111-007-PATCH-AUDIT-RELEASE-NOTES

`GH-951-VERIFY-V0111-PATCH-AUDIT-RELEASE-NOTES`

`TVM-RELEASE-V0111-PATCH-AUDIT-RELEASE-NOTES`

`V0111-007-PATCH-AUDIT`

`V0111-007-RELEASE-NOTES`

`V0111-007-VALIDATION-SUMMARY`

`V0111-007-AGGREGATE-VERIFY`

`V0111-007-NO-PRODUCTION-CUTOVER`

`V0111-007-NO-TAG-OR-RELEASE-MOVE`

v0.11.1 Readiness Runtime Guard Patch 是 v0.11.0 public Release 后的 guard hardening closeout。它只收口 #945..#951 的 release fact sync、Dashboard macOS focused guard、Dashboard SHA-256 / readiness state invariants、readiness artifact symlink root confinement、readiness artifact owner-only permissions、aggregate verifier、Stage Code Audit 和 release notes。

GH-951 不是 release publication gate：

- 不创建 `v0.11.1` tag。
- 不创建 `v0.11.1` GitHub Release。
- 不移动、不覆盖、不重写 `v0.11.0` tag 或 GitHub Release。
- 不推进 v0.12.0。
- 不授权 production cutover。

v0.11.0 public GitHub Release 仍保持为 `https://github.com/atxinbao/MTPRO/releases/tag/v0.11.0`，tag peeled commit `13f592d0710de91351286e5c5490bfacb63c19b0`，publication timestamp `2026-06-19T01:20:58Z`。v0.11.1 patch closeout 不改变该 release identity。

## V0120-002-V011X-RELEASE-PATCH-FACT-BASELINE

`GH-953-VERIFY-V0120-V011X-RELEASE-PATCH-FACTS`

`TVM-RELEASE-V0120-V011X-RELEASE-PATCH-FACTS`

`V0120-002-V0110-PUBLICATION-FACT`

`V0120-002-V0111-PATCH-FACT`

`V0120-002-CONSTRUCTION-PUBLICATION-CUTOVER-SEPARATION`

`V0120-002-NO-PRODUCTION-CUTOVER`

v0.12.0 readiness assessment sessions must inherit these v0.11.x publication / patch facts as baseline evidence:

- v0.11.0 public GitHub Release exists at `https://github.com/atxinbao/MTPRO/releases/tag/v0.11.0`.
- v0.11.0 tag peeled commit remains `13f592d0710de91351286e5c5490bfacb63c19b0`.
- v0.11.0 publication timestamp remains `2026-06-19T01:20:58Z`.
- #924 remains the v0.11.0 construction closeout, not the publication gate.
- v0.11.1 Readiness Runtime Guard Patch 是 v0.11.0 public Release 后的 guard hardening closeout，覆盖 #945..#951。
- v0.11.1 patch closeout does not create a `v0.11.1` tag or GitHub Release, and it does not move, rewrite or replace the `v0.11.0` tag / GitHub Release.

This baseline only supports local readiness assessment provenance. It does not authorize production cutover, production trading, production secret reads, production endpoint / broker endpoint connections, testnet orders or production orders.

## V080-002-V080-CONSTRUCTION-VS-PUBLICATION

`V080-002-V080-CONSTRUCTION-VS-PUBLICATION`

v0.8.0 GitHub fallback queue construction phase 已完成。`GH-807..GH-820` 已收口 persistent local operator runtime、testnet read-only monitoring、manual proof summary、Dashboard read-only monitor、safe local controls、validation split 和 final audit / docs / runbook。

v0.8.0 的 construction closeout 必须先满足：

- `GH-807..GH-820` 全部 closed / done。
- open PR = 0。
- open `todo` / `in-progress` / `in-review` issue = 0。
- `main == origin/main`。
- worktree clean。
- `git diff --check` 通过。
- `bash checks/automation-readiness.sh` 通过。
- `bash checks/run.sh` 通过。

v0.8.0 public release publication 已在 construction closeout 之后通过独立 release publication task 明确授权并完成。`GH-808` 本身不创建 tag，不创建 GitHub Release，不移动任何已有 tag，不推进 v0.8.0 之后的阶段；后续 `GH-835` 只把已发生的 v0.8.0 stable GitHub Release 事实同步回文档和验证 guard。

## V080-002-TAG-NAMING-RULES

`V080-002-TAG-NAMING-RULES`

Release tag 命名规则：

- 正式 release 使用 `vMAJOR.MINOR.PATCH`，例如 `v0.7.0`、`v0.8.0`。
- patch hardening release 使用递增 patch 号，例如 `v0.7.1`。
- tag 必须指向已验证、已同步的 `main` commit。
- tag 必须在 release publication gate 中创建；construction closeout issue 不创建 tag。
- 已存在 tag 不得移动、覆盖或重写；若 tag / release 已存在，只能只读核对并报告。

## V080-002-GITHUB-RELEASE-CHECKLIST

`V080-002-GITHUB-RELEASE-CHECKLIST`

GitHub Release publication checklist：

1. 确认 release target commit 等于 `main` 和 `origin/main`。
2. 确认 worktree clean。
3. 确认 open PR = 0。
4. 确认 open issue = 0，或确认 release task 明确允许的非阻塞 issue。
5. 确认没有 `todo` / `in-progress` / `in-review` label 的 active queue item。
6. 确认 required validation 已通过：`git diff --check`、`bash checks/automation-readiness.sh`、`bash checks/run.sh`。
7. 确认 tag / GitHub Release 尚不存在；若已存在，不移动、不覆盖、不重写。
8. 创建 annotated git tag。
9. push tag。
10. 创建 stable GitHub Release，非 draft，非 prerelease。
11. 发布后复核 release URL、tag target、open PR、open issue 和 clean worktree。

## V080-002-SOURCE-CHECKSUM-EXPECTATIONS

`V080-002-SOURCE-CHECKSUM-EXPECTATIONS`

Source checksum expectation 必须绑定 exact tag，不绑定 mutable branch：

```bash
git fetch --tags origin
git rev-parse v0.8.0^{}
git archive --format=tar --prefix=MTPRO-v0.8.0/ v0.8.0 | shasum -a 256
```

若 release notes 记录 source checksum，必须同时记录 tag、peeled commit、checksum algorithm、checksum command 和执行日期。checksum 只证明 source archive identity，不授权 production trading、production secret read、production endpoint / broker connection 或 real order。

## V080-002-RELEASE-NOTES-PUBLISHING-GATE

`V080-002-RELEASE-NOTES-PUBLISHING-GATE`

Release notes publishing gate 必须覆盖：

- release scope。
- completed issue / PR / checks evidence summary。
- validation summary。
- source checksum expectation 或 actual checksum。
- known residual risk。
- no-default-production-trading boundary。
- production cutover remains separately gated。
- no production secret auto-read。
- no production endpoint / broker auto-connect。
- no testnet or production submit / cancel / replace unless a later issue explicitly authorizes it.
- no next Project / Issue auto-promotion。

## TVM-RELEASE-V080-RELEASE-PUBLICATION-POLICY

`TVM-RELEASE-V080-RELEASE-PUBLICATION-POLICY`

Required validation：

- `bash checks/verify-v0.8.0-release-publication-policy.sh`
- `bash checks/verify-v0.10.0-release-policy.sh`
- `swift test --filter TargetGraphTests/testGH808ReleasePublicationPolicySeparatesConstructionCloseoutFromGitHubRelease`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

- productionTradingEnabledByDefault=false
- productionSecretRead=false
- productionEndpointConnected=false
- productionBrokerConnected=false
- productionOrderSubmitted=false
- productionCutoverAuthorized=false
- testnetOrderSubmissionAllowed=false
- testnetOrderRoutingAllowed=false

GH-808 不发布 v0.8.0，不创建下一 Project / Issue，不推进下一 Todo，不启动 Linear / Symphony / Graphify / code-index / Figma，不修改 production capability，不读取 secret，不连接 endpoint，不提交订单。

## GH-1110 Release v0.16.0 Beta Safety Guard Policy

`GH-1110-VERIFY-V0160-BETA-SAFETY-GUARDS`

`TVM-RELEASE-V0160-BETA-SAFETY-GUARDS`

Release v0.16.0 Binance Spot Testnet Operator Execution Beta 在任何 submit / cancel / status-query transport call 之前必须执行本地 beta safety guard：

- `V0160-010-MAX-QUANTITY-GUARD`
- `V0160-010-MAX-ORDERS-PER-RUN-GUARD`
- `V0160-010-COOLDOWN-GUARD`
- `V0160-010-SYMBOL-ALLOWLIST-GUARD`
- `V0160-010-TESTNET-ONLY-CREDENTIAL-PROFILE`
- `V0160-010-TRANSPORT-PRECHECK-FAILS-CLOSED`
- `V0160-010-REDACTED-SAFETY-EVIDENCE`
- `V0160-010-NO-PRODUCTION-CUTOVER`

Required validation：

- `bash checks/verify-v0.16.0-beta-safety-guards.sh`
- `swift test --filter TargetGraphTests/testGH1110ReleaseV0160BetaSafetyGuardsFailClosedBeforeTransport`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-1110 不发布 tag / GitHub Release，不创建下一 Project / Issue，不推进下一 Todo，不启动 Linear / Symphony / Graphify / code-index / Figma，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。

## GH-1111 Release v0.16.0 Manual Testnet Validation Workflow Policy

`GH-1111-VERIFY-V0160-MANUAL-TESTNET-VALIDATION-WORKFLOW`

`TVM-RELEASE-V0160-MANUAL-TESTNET-VALIDATION-WORKFLOW`

Release v0.16.0 Binance Spot Testnet Operator Execution Beta 的手动 testnet validation workflow 只能验证 operator 已生成的 redacted evidence bundle：

- `V0160-011-MANUAL-WORKFLOW-ONLY`
- `V0160-011-SUBMIT-STATUS-CANCEL-STATUS-SEQUENCE`
- `V0160-011-RECONCILIATION-PASSED`
- `V0160-011-REDACTED-EVIDENCE-BUNDLE`
- `V0160-011-CHECKSUM-REFERENCES`
- `V0160-011-NO-PRODUCTION-CREDENTIALS`
- `V0160-011-NO-PRODUCTION-ENDPOINT`
- `V0160-011-NO-PRODUCTION-CUTOVER`

Required validation：

- `bash checks/verify-v0.16.0-manual-testnet-validation-workflow.sh`
- `swift test --filter TargetGraphTests/testGH1111ReleaseV0160ManualTestnetValidationWorkflowRequiresRedactedBundle`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-1111 不发布 tag / GitHub Release，不创建下一 Project / Issue，不推进下一 Todo，不启动 Linear / Symphony / Graphify / code-index / Figma，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。

## GH-1112 Release v0.16.0 Stage Audit / Release Docs Policy

`GH-1112-VERIFY-V0160-STAGE-AUDIT-RELEASE-DOCS`

`TVM-RELEASE-V0160-STAGE-AUDIT-RELEASE-DOCS`

`V0160-012-STAGE-CODE-AUDIT`

`V0160-012-RELEASE-NOTES`

`V0160-012-OPERATOR-RUNBOOK`

`V0160-012-VALIDATION-MATRIX`

`V0160-012-STALE-WORDING-GUARD`

`V0160-012-NO-PRODUCTION-CUTOVER`

`V0160-012-NO-TAG-OR-RELEASE-PUBLICATION`

#1112 是 v0.16.0 Binance Spot Testnet Operator Execution Beta 的 construction closeout slice。它只同步已发生事实：#1101..#1112 closed / done、Stage Code Audit、release notes、operator runbook、validation matrix、automation readiness 和 stale wording guard。

GH-1112 construction closeout 本身不创建 tag / GitHub Release，不创建下一 Project / Issue，不推进下一 Todo，不启动 Linear / Symphony / Graphify / code-index / Figma，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。

`v0.16.0` public GitHub Release 已在本 construction closeout 完成后由独立 Release Publication Gate 显式触发并完成：`https://github.com/atxinbao/MTPRO/releases/tag/v0.16.0`，tag peeled commit `28779236262bd7ffaf71e286b27b95854c5cd3e1`，publication timestamp `2026-06-26T01:29:21Z`。Release publication 仍不等于 production cutover authorization。

## GH-1133 Release v0.16.1 v0.16.0 Release Fact Sync Policy

`GH-1133-VERIFY-V0161-V0160-RELEASE-FACT-SYNC`

`V0161-001-V0160-RELEASE-FACT-SYNC-GUARD`

`TVM-RELEASE-V0161-V0160-RELEASE-FACT-SYNC`

`V0161-001-V0160-TAG-FIXED`

`V0161-001-PATCH-QUEUE-NOT-PUBLICATION`

`V0161-001-NO-PRODUCTION-CUTOVER`

v0.16.1 是 v0.16.0 后的 evidence hardening patch queue。GH-1133 只同步 v0.16.0 publication facts 到 patch docs、validation matrix、automation readiness 和 stale wording guard。

v0.16.0 stable GitHub Release facts:

- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.16.0`
- tag peeled commit：`28779236262bd7ffaf71e286b27b95854c5cd3e1`
- publication timestamp：`2026-06-26T01:29:21Z`

GH-1133 不移动 `v0.16.0` tag，不覆盖 GitHub Release，不创建 `v0.16.1` public release，不推进 #1134..#1138，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。production cutover not authorized。

## GH-1134 Release v0.16.1 Manual Evidence Bundle Content Policy

`GH-1134-VERIFY-V0161-MANUAL-EVIDENCE-BUNDLE-CONTENT`

`TVM-RELEASE-V0161-MANUAL-EVIDENCE-BUNDLE-CONTENT`

`V0161-002-BUNDLE-SCHEMA-PARSED`

`V0161-002-ACTION-SEQUENCE-CHECKED`

`V0161-002-CHECKSUM-REFERENCES-CHECKED`

`V0161-002-NO-SECRET-NO-PRODUCTION-MARKERS`

`V0161-002-NO-PRODUCTION-CUTOVER`

GH-1134 只强化 v0.16.0 manual testnet validation workflow 的 redacted evidence bundle 内容校验。`.github/workflows/release-v0.16.0-manual-testnet-validation.yml` 必须调用 `swift run mtpro validate-manual-evidence-bundle "${{ inputs.evidence_bundle_path }}"`，并由 `ReleaseV0161ManualTestnetValidationEvidenceBundle` 解析 schema、action sequence、checksum references、reconciliation 和 no-secret / no-production markers。

GH-1134 不创建 tag，不创建 GitHub Release，不移动 `v0.16.0` tag，不覆盖 release，不推进 #1135..#1138，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 testnet 或 production order。production cutover not authorized。

`GH-1135-VERIFY-V0161-CENTRAL-ARTIFACT-REDACTION-POLICY`

`TVM-RELEASE-V0161-CENTRAL-ARTIFACT-REDACTION-POLICY`

`V0161-003-SHARED-REDACTION-POLICY-SOURCE`

`V0161-003-ARTIFACT-STORE-POLICY-USES-SHARED-SOURCE`

`V0161-003-WORKFLOW-BUNDLE-POLICY-USES-SHARED-SOURCE`

`V0161-003-DASHBOARD-READ-MODEL-POLICY-USES-SHARED-SOURCE`

`V0161-003-NO-SECRET-NO-PRODUCTION-MARKERS`

`V0161-003-NO-PRODUCTION-CUTOVER`

GH-1135 将 v0.16 operator beta artifact redaction policy 收敛为 `ReleaseV0161OperatorBetaArtifactRedactionPolicy`，并要求 `ReleaseV0160LocalExecutionArtifactPayload`、`ReleaseV0161ManualTestnetValidationEvidenceBundle`、`ReleaseV0160DashboardArtifactBackedExecutionViewModel` 和 focused tests 共同引用同一 forbidden marker / validation anchor source。

GH-1135 不创建 tag，不创建 GitHub Release，不移动 `v0.16.0` tag，不覆盖 release，不推进 #1136..#1138，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 testnet 或 production order。production cutover not authorized。

## GH-1136 Release v0.16.1 Redaction Regression Coverage Policy

`GH-1136-VERIFY-V0161-REDACTION-REGRESSION-COVERAGE`

`TVM-RELEASE-V0161-REDACTION-REGRESSION-COVERAGE`

`V0161-004-BINANCE-SENSITIVE-HEADER-MARKERS`

`V0161-004-SIGNED-QUERY-MARKERS`

`V0161-004-PRODUCTION-HOST-MARKERS`

`V0161-004-RAW-BROKER-ORDER-PAYLOAD-MARKERS`

`V0161-004-WORKFLOW-BUNDLE-REGRESSION-COVERAGE`

GH-1136 adds regression coverage for Binance sensitive headers, signed query markers, listenKey / secret variants, production Binance hosts, raw broker payload variants and raw order payload variants. 这些 markers 必须由 `ReleaseV0161OperatorBetaArtifactRedactionPolicy` 统一维护，并被 local execution artifact store、manual evidence bundle validator、Dashboard read model 和 focused tests 共同消费。

GH-1136 不创建 tag，不创建 GitHub Release，不移动 `v0.16.0` tag，不覆盖 release，不推进 #1137..#1138，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 testnet 或 production order。production cutover not authorized。

## GH-1137 Release v0.16.1 Status Query Transport Evidence Wording Policy

`GH-1137-VERIFY-V0161-STATUS-QUERY-TRANSPORT-WORDING`

`TVM-RELEASE-V0161-STATUS-QUERY-TRANSPORT-WORDING`

`V0161-005-REQUEST-EVIDENCE-FLAG-CLARIFIED`

`V0161-005-TRANSPORT-RESULT-EVIDENCE-CLARIFIED`

`V0161-005-NO-FAKE-STATUS-QUERY-WORDING`

`V0161-005-NO-PRODUCTION-READINESS-OVERSTATEMENT`

GH-1137 fixes release wording around the #1105 status query evidence layers. `networkStatusQueryPerformed=false` belongs to the signed request evidence and means the request-construction evidence does not itself assert a network side effect. Guarded Testnet status transport result evidence remains represented by `ReleaseV0160BinanceSpotTestnetOrderStatusTransportResult`, its redacted request / response evidence, artifact path and checksum. This distinction must not be described as fabricated or mocked status wording, and it must not be overstated as production readiness.

GH-1137 不创建 tag，不创建 GitHub Release，不移动 `v0.16.0` tag，不覆盖 release，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 testnet 或 production order。production cutover not authorized。

## GH-1138 Release v0.16.1 Patch Audit / Release Notes Closeout Policy

`GH-1138-VERIFY-V0161-PATCH-AUDIT-RELEASE-NOTES`

`TVM-RELEASE-V0161-PATCH-AUDIT-RELEASE-NOTES`

`V0161-006-PATCH-AUDIT`

`V0161-006-RELEASE-NOTES`

`V0161-006-VALIDATION-MATRIX`

`V0161-006-PUBLICATION-GUIDANCE`

`V0161-006-NO-PRODUCTION-CUTOVER`

`V0161-006-NO-TAG-OR-RELEASE-PUBLICATION`

GH-1138 closes the v0.16.1 patch audit, release notes, validation matrix and publication guidance. It records GH-1133..GH-1137 evidence, adds `docs/audit/mtpro-release-v0.16.1-operator-beta-evidence-hardening-patch-stage-code-audit.md`, refreshes the v0.16.1 patch notes, and registers `checks/verify-v0.16.1-patch-audit-release-notes.sh` in automation readiness.

GH-1138 does not create a `v0.16.1` tag, does not create a GitHub Release, does not move the `v0.16.0` tag, does not overwrite the `v0.16.0` release, does not create the next Project / Issue, and does not authorize production cutover.

If Human later requests `v0.16.1` publication, it must be handled by a separate explicit Release Publication Gate after clean `main`, open PR = 0, open active issue = 0, and validation evidence are re-confirmed. production cutover not authorized；production trading remains disabled by default；production secret read, production endpoint / broker endpoint connection and production submit / cancel / replace remain unauthorized.

## GH-1148 Release v0.17.0 Stage Audit / Release Docs Closeout Policy

`GH-1148-VERIFY-V0170-STAGE-AUDIT-RELEASE-DOCS`

`TVM-RELEASE-V0170-STAGE-AUDIT-RELEASE-DOCS`

`V0170-010-STAGE-CODE-AUDIT`

`V0170-010-RELEASE-NOTES`

`V0170-010-VALIDATION-MATRIX`

`V0170-010-ROOT-DOCS-REFRESH`

`V0170-010-STALE-WORDING-GUARD`

`V0170-010-NO-PRODUCTION-CUTOVER`

`V0170-010-NO-TAG-OR-RELEASE-PUBLICATION`

GH-1148 closes the v0.17.0 stage audit, release notes, validation matrix, root docs refresh and stale wording guard. It records GH-1139..GH-1147 evidence, adds `docs/audit/mtpro-release-v0.17.0-operator-beta-artifact-status-runtime-hardening-stage-code-audit.md`, adds `docs/release/mtpro-release-v0.17.0-operator-beta-artifact-status-runtime-hardening-notes.md`, and registers `checks/verify-v0.17.0-stage-audit-release-docs.sh` in automation readiness.

GH-1148 does not create a `v0.17.0` tag, does not create a GitHub Release, does not move any existing tag, does not create the next Project / Issue, does not submit testnet or production orders, and does not authorize production cutover. production cutover not authorized.

## GH-1169 Release v0.17.1 v0.17.0 Release Fact Sync Policy

`GH-1169-VERIFY-V0171-V0170-RELEASE-FACT-SYNC`

`V0171-004-V0170-RELEASE-FACT-SYNC-GUARD`

`TVM-RELEASE-V0171-V0170-RELEASE-FACT-SYNC`

`V0171-004-V0170-TAG-FIXED`

`V0171-004-PATCH-QUEUE-NOT-PUBLICATION`

`V0171-004-NO-PRODUCTION-CUTOVER`

v0.17.1 是 v0.17.0 后的 artifact validation fail-closed patch queue。GH-1169 只同步 v0.17.0 publication facts 到 patch docs、validation matrix、automation readiness、Stage Audit、release notes 和 stale wording guard。

v0.17.0 stable GitHub Release facts:

- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.17.0`
- tag peeled commit：`c83879f80a525665c3484878d7071b1f5214da20`
- publication timestamp：`2026-06-27T06:37:33Z`

GH-1169 不移动 `v0.17.0` tag，不覆盖 GitHub Release，不创建 `v0.17.1` public release，不推进 #1170..#1171，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。production cutover not authorized。

## GH-1170 Release v0.17.1 v0.17.0 Stale Wording Guard Policy

`GH-1170-VERIFY-V0171-V0170-STALE-WORDING-GUARD`

`V0171-005-V0170-STALE-WORDING-GUARD`

`V0171-005-HISTORICAL-CONSTRUCTION-CLOSEOUT-ALLOWLIST`

`TVM-RELEASE-V0171-V0170-STALE-WORDING-GUARD`

GH-1170 rejects unqualified stale v0.17.0 publication wording after GH-1169 synced the v0.17.0 stable GitHub Release facts. It scans root docs, release notes, Stage Audit and release policy for v0.17.0 pending release / pending tag / release not created / construction-only current-fact wording.

Historical #1148 / GH-1148 construction closeout wording is allowed only when it is clearly scoped as historical closeout evidence and the same file also carries the current v0.17.0 release URL, tag peeled commit and publication timestamp:

- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.17.0`
- tag peeled commit：`c83879f80a525665c3484878d7071b1f5214da20`
- publication timestamp：`2026-06-27T06:37:33Z`

GH-1170 不移动 `v0.17.0` tag，不覆盖 GitHub Release，不创建 `v0.17.1` public release，不推进下一 Project / Issue，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。production cutover not authorized。

## GH-1171 Release v0.17.1 Aggregate Patch Audit / Release Notes Closeout Policy

`GH-1171-VERIFY-V0171-AGGREGATE-PATCH-AUDIT-RELEASE-NOTES`

`TVM-RELEASE-V0171-AGGREGATE-PATCH-AUDIT-RELEASE-NOTES`

`V0171-006-AGGREGATE-GUARD`

`V0171-006-PATCH-AUDIT`

`V0171-006-RELEASE-NOTES`

`V0171-006-VALIDATION-MATRIX`

`V0171-006-V0180-HANDOFF`

`V0171-006-NO-PRODUCTION-CUTOVER`

`V0171-006-NO-TAG-OR-RELEASE-PUBLICATION`

GH-1171 closes the v0.17.1 patch audit by adding `checks/verify-v0.17.1.sh`, v0.17.1 Stage Code Audit, v0.17.1 release notes, validation matrix anchors and publication guidance. The aggregate guard must cover #1166, #1167, #1168, #1169 and #1170 before #1171 can close.

GH-1171 may record Venue/Product-aware lifecycle recovery as the next planning context only. It does not implement v0.18.0, does not create or publish a tag / GitHub Release, does not move `v0.17.0`, does not overwrite GitHub Release facts, does not promote any v0.18.0 Todo, does not authorize production cutover, does not read production secret, does not connect production endpoint / broker endpoint, and does not submit production order. production cutover not authorized。

## GH-1176 Release v0.18.0 Venue/Product-aware Operator Lifecycle Recovery Contract Policy

`GH-1176-VERIFY-V0180-VENUE-PRODUCT-LIFECYCLE-RECOVERY-CONTRACT`

`TVM-RELEASE-V0180-VENUE-PRODUCT-LIFECYCLE-RECOVERY-CONTRACT`

`V0180-001-DEPENDENCIES-CLOSED-DONE`

`V0180-001-NAMESPACE-CONTRACT`

`V0180-001-BINANCE-OKX-TARGET-ARCHITECTURE`

`V0180-001-ARTIFACT-LIFECYCLE-SCOPE`

`V0180-001-STATUS-RESUME-RECONCILIATION`

`V0180-001-CLI-NEXT-ACTION-DASHBOARD-DRILLDOWN`

`V0180-001-NO-PRODUCTION-CUTOVER`

GH-1176 defines the v0.18.0 venue/product-aware operator lifecycle recovery contract. The contract requires `{venue, product, environment, accountProfile, runID}` on artifact lifecycle, status query persistence, resume, reconciliation replay, CLI next-action and Dashboard drilldown evidence.

GH-1176 also fixes the v0.18.0 preflight boundary: #1168, #1169, #1170 and #1171 must be closed / done before v0.18.0 can start. Binance / OKX target architecture is documented as recovery taxonomy only. GH-1176 does not implement OKX runtime, does not activate a new venue/product, does not create or publish a tag / GitHub Release, does not authorize production cutover, does not read production secret, does not connect production endpoint / broker endpoint, and does not submit production order. production cutover not authorized。

## GH-1177 Release v0.18.0 Run Artifact Lifecycle Manifest Namespace Policy

`GH-1177-VERIFY-V0180-RUN-ARTIFACT-LIFECYCLE-MANIFEST-NAMESPACE`

`TVM-RELEASE-V0180-RUN-ARTIFACT-LIFECYCLE-MANIFEST-NAMESPACE`

`V0180-002-DEPENDENCY-GH1176-DONE`

`V0180-002-LIFECYCLE-MANIFEST-SCHEMA`

`V0180-002-VENUE-PRODUCT-ENVIRONMENT-NAMESPACE`

`V0180-002-ACCOUNT-RUNID-BINDING`

`V0180-002-BOUNDARY-REUSE-REJECTION`

`V0180-002-LOCAL-EVIDENCE-ONLY`

`V0180-002-NO-PRODUCTION-CUTOVER`

GH-1177 adds the v0.18.0 run artifact lifecycle manifest namespace guard. `lifecycle-manifest-v0.18.0.json` is a local companion manifest for `.local/mtpro/runs/<runID>/manifest.json`; it records `venue`, `product`, `environment`, `accountProfile` and `runID`, and rejects product / environment namespace reuse.

GH-1177 is local evidence only. It does not implement OKX runtime, does not activate a new venue/product runtime, does not create or publish a tag / GitHub Release, does not authorize production cutover, does not read production secret, does not connect production endpoint / broker endpoint, and does not submit production order. production cutover not authorized。

## GH-1178 Release v0.18.0 Status Query Retry Artifact Persistence Policy

`GH-1178-VERIFY-V0180-STATUS-QUERY-RETRY-ARTIFACT-PERSISTENCE`

`TVM-RELEASE-V0180-STATUS-QUERY-RETRY-ARTIFACT-PERSISTENCE`

`V0180-003-DEPENDENCY-GH1177-DONE`

`V0180-003-STATUS-QUERY-RETRY-RESULT-PERSISTED`

`V0180-003-VENUE-PRODUCT-ENVIRONMENT-NAMESPACE`

`V0180-003-RETRY-TIMEOUT-FAILURE-CLASSIFICATION`

`V0180-003-REDACTION-STATUS-PERSISTED`

`V0180-003-OPERATOR-VISIBLE-FAIL-CLOSED-EVIDENCE`

`V0180-003-LOCAL-ARTIFACT-STORE-REPLAY`

`V0180-003-NO-PRODUCTION-CUTOVER`

GH-1178 persists signed status-query retry / timeout / failure classification results into the local append-only artifact store. The persisted `statusQueryRetrySnapshot` records retry attempts, timeout result, classified failures, redaction status, operator next-action and `{venue, product, environment, accountProfile, runID}` namespace.

GH-1178 is local evidence only. It does not re-run status query, does not implement OKX runtime, does not activate a new venue/product runtime, does not create or publish a tag / GitHub Release, does not authorize production cutover, does not read production secret, does not connect production endpoint / broker endpoint, and does not submit production order. production cutover not authorized。

## GH-1179 Release v0.18.0 Resume After Interruption Command Policy

`GH-1179-VERIFY-V0180-RESUME-AFTER-INTERRUPTION-COMMAND`

`TVM-RELEASE-V0180-RESUME-AFTER-INTERRUPTION-COMMAND`

`V0180-004-DEPENDENCIES-GH1177-GH1178-DONE`

`V0180-004-LOCAL-ARTIFACT-BACKED-RESUME`

`V0180-004-LIFECYCLE-MANIFEST-REQUIRED`

`V0180-004-STATUS-QUERY-EVIDENCE-REQUIRED`

`V0180-004-RECONCILIATION-EVIDENCE-REQUIRED`

`V0180-004-CROSS-VENUE-PRODUCT-REUSE-REJECTED`

`V0180-004-NO-AUTOMATIC-NETWORK-RETRY`

`V0180-004-NO-PRODUCTION-CUTOVER`

GH-1179 adds the resume-after-interruption command on top of local artifact evidence. The command must consume validated lifecycle manifest namespace, persisted status-query retry evidence and reconciliation resume cursor before producing `mtpro operator-run resume`.

GH-1179 is local evidence only. It does not automatically retry network calls, does not mutate broker state, does not implement OKX runtime, does not activate a new venue/product runtime, does not create or publish a tag / GitHub Release, does not authorize production cutover, does not read production secret, does not connect production endpoint / broker endpoint, and does not submit production order. production cutover not authorized。

## GH-1180 Release v0.18.0 Cancel / Status Reconciliation Replay Command Policy

`GH-1180-VERIFY-V0180-CANCEL-STATUS-RECONCILIATION-REPLAY-COMMAND`

`TVM-RELEASE-V0180-CANCEL-STATUS-RECONCILIATION-REPLAY-COMMAND`

`V0180-005-DEPENDENCIES-GH1178-GH1179-DONE`

`V0180-005-LOCAL-ARTIFACT-REPLAY`

`V0180-005-CANCEL-STATUS-OBSERVED-EXPECTED-EXPLAINED`

`V0180-005-MISSING-RECONCILIATION-FAILS-CLOSED`

`V0180-005-MISMATCH-RECONCILIATION-FAILS-CLOSED`

`V0180-005-READ-ONLY-OPERATOR-ACTION`

`V0180-005-CROSS-VENUE-PRODUCT-REUSE-REJECTED`

`V0180-005-NO-PRODUCTION-CUTOVER`

GH-1180 adds the cancel/status reconciliation replay command on top of local artifact evidence. The command must consume GH-1178 status-query retry persistence, GH-1179 resume result, GH-1107 observed-status reconciliation report and GH-1143 recovery report before producing `mtpro operator-run replay-cancel-status-reconciliation`.

GH-1180 is local evidence only. It does not automatically retry network calls, does not mutate broker state, does not implement OKX runtime, does not activate a new venue/product runtime, does not create or publish a tag / GitHub Release, does not authorize production cutover, does not read production secret, does not connect production endpoint / broker endpoint, and does not submit production order. production cutover not authorized。

## GH-1181 Release v0.18.0 Operator Failure Classification Next Action CLI Policy

`GH-1181-VERIFY-V0180-OPERATOR-FAILURE-CLASSIFICATION-NEXT-ACTION-CLI`

`TVM-RELEASE-V0180-OPERATOR-FAILURE-CLASSIFICATION-NEXT-ACTION-CLI`

`V0180-006-DEPENDENCIES-GH1179-GH1180-DONE`

`V0180-006-ARTIFACT-MANIFEST-FAILURE-CLASSIFIED`

`V0180-006-STATUS-QUERY-FAILURE-CLASSIFIED`

`V0180-006-RESUME-FAILURE-CLASSIFIED`

`V0180-006-RECONCILIATION-REPLAY-FAILURE-CLASSIFIED`

`V0180-006-NEXT-ACTION-CLI`

`V0180-006-VENUE-PRODUCT-ENVIRONMENT-EXPLANATION`

`V0180-006-READ-ONLY-OPERATOR-ACTION`

`V0180-006-NO-PRODUCTION-CUTOVER`

GH-1181 adds operator-visible failure classification and next-action CLI on top of local artifact evidence. The command must classify artifact manifest, status-query, resume and reconciliation replay failure surfaces before producing `mtpro operator-run explain-failure`.

GH-1181 is local evidence only. It does not automatically remediate failures, does not mutate broker state, does not implement OKX runtime, does not activate a new venue/product runtime, does not create or publish a tag / GitHub Release, does not authorize production cutover, does not read production secret, does not connect production endpoint / broker endpoint, and does not submit production order. production cutover not authorized。

## GH-1182 Release v0.18.0 Dashboard Artifact Recovery Drilldown Policy

`GH-1182-VERIFY-V0180-DASHBOARD-ARTIFACT-RECOVERY-DRILLDOWN`

`TVM-RELEASE-V0180-DASHBOARD-ARTIFACT-RECOVERY-DRILLDOWN`

`V0180-007-DEPENDENCIES-GH1179-GH1180-GH1181-DONE`

`V0180-007-REAL-LOCAL-BUNDLE-EVIDENCE`

`V0180-007-LIFECYCLE-STATUS-RESUME-RECONCILIATION-DRILLDOWN`

`V0180-007-VENUE-PRODUCT-ENVIRONMENT-DRILLDOWN`

`V0180-007-FAILURE-CLASS-NEXT-ACTION-GUIDANCE`

`V0180-007-DASHBOARD-READ-ONLY-NO-COMMANDS`

`V0180-007-NO-PRODUCTION-CUTOVER`

GH-1182 adds Dashboard artifact / recovery drilldown on top of real local bundle evidence. The Dashboard surface must display lifecycle manifest, status query, resume, reconciliation replay and failure classification next-action state for the same venue/product/environment/accountProfile/runID namespace.

GH-1182 is read-only Dashboard evidence only. It does not depend on ExecutionClient target, does not expose command surface, trading button, order form, live command or submit / cancel / replace, does not implement OKX runtime, does not activate a new venue/product runtime, does not create or publish a tag / GitHub Release, does not authorize production cutover, does not read production secret, does not connect production endpoint / broker endpoint, and does not submit production order. production cutover not authorized。

## GH-1183 Release v0.18.0 Manual Workflow Fixture Negative Cases Policy

`GH-1183-VERIFY-V0180-MANUAL-WORKFLOW-FIXTURE-NEGATIVE-CASES`

`TVM-RELEASE-V0180-MANUAL-WORKFLOW-FIXTURE-NEGATIVE-CASES`

`V0180-008-DEPENDENCIES-GH1177-GH1178-DONE`

`V0180-008-CORRUPT-BUNDLE-FAILS-CLOSED`

`V0180-008-MISSING-FIELDS-FAIL-CLOSED`

`V0180-008-WRONG-VENUE-PRODUCT-ENVIRONMENT-FAILS-CLOSED`

`V0180-008-FAILED-VALIDATION-STATE-REJECTS-WORKFLOW`

`V0180-008-FAILED-CHECKS-CANNOT-PASS-WITH-FAILED-STATUS-STRING`

`V0180-008-NO-PRODUCTION-CUTOVER`

GH-1183 adds manual workflow fixture upload / download negative cases on top of v0.18.0 local artifact evidence. The fixture suite must cover corrupt bundle, missing required field, wrong venue, wrong product, wrong environment and failed validation state.

GH-1183 is local evidence only. It does not upload secret material, does not generate an order artifact from workflow alone, does not implement OKX runtime, does not activate a new venue/product runtime, does not create or publish a tag / GitHub Release, does not authorize production cutover, does not read production secret, does not connect production endpoint / broker endpoint, and does not submit production order. production cutover not authorized。

## GH-1184 Release v0.18.0 Beta Safety Profile Drift Detector Policy

`GH-1184-VERIFY-V0180-BETA-SAFETY-PROFILE-DRIFT-DETECTOR`

`TVM-RELEASE-V0180-BETA-SAFETY-PROFILE-DRIFT-DETECTOR`

`V0180-009-DEPENDENCIES-GH1177-GH1181-GH1183-DONE`

`V0180-009-VENUE-PRODUCT-ENVIRONMENT-SCOPE`

`V0180-009-BINANCE-SPOT-TO-OKX-SWAP-REUSE-REJECTED`

`V0180-009-BINANCE-SPOT-TO-USDM-FUTURES-REUSE-REJECTED`

`V0180-009-WRONG-ENVIRONMENT-REUSE-REJECTED`

`V0180-009-CROSS-PRODUCT-EVIDENCE-REUSE-FAILS-CLOSED`

`V0180-009-NO-PRODUCTION-CUTOVER`

GH-1184 adds beta safety profile drift detection on top of v0.17.0 beta safety policy evidence and v0.18.0 venue/product-aware local artifact evidence. The detector must bind expected and observed venue / product / environment / accountProfile / runID scope before evidence can be accepted.

Binance Spot evidence must not be reused as OKX Swap, Binance USDⓈ-M Futures, unsupported product or wrong environment evidence. Cross-product evidence reuse must produce `validationStatus=failed` and fail closed through `validateNoDrift`.

GH-1184 is local evidence only. It does not implement OKX runtime, does not activate a new venue/product runtime, does not create or publish a tag / GitHub Release, does not authorize production cutover, does not read production secret, does not connect production endpoint / broker endpoint, and does not submit production order. production cutover not authorized。

## GH-1185 Release v0.18.0 Stage Audit / Release Docs Closeout Policy

`GH-1185-VERIFY-V0180-STAGE-AUDIT-RELEASE-DOCS`

`TVM-RELEASE-V0180-STAGE-AUDIT-RELEASE-DOCS`

`V0180-010-STAGE-CODE-AUDIT`

`V0180-010-RELEASE-NOTES`

`V0180-010-VALIDATION-MATRIX`

`V0180-010-ROOT-DOCS-REFRESH`

`V0180-010-STALE-WORDING-GUARD`

`V0180-010-NO-PRODUCTION-CUTOVER`

`V0180-010-NO-TAG-OR-RELEASE-PUBLICATION`

GH-1185 closes the v0.18.0 stage audit by adding the Stage Code Audit, release notes, validation matrix anchors, root docs refresh and stale wording guard. It records `#1176..#1185` issue completion, PR #1190..#1198 merge evidence, required `checks` success and local validation commands as completed facts only.

GH-1185 does not create or publish a `v0.18.0` tag / GitHub Release, does not create the next Project / Issue, does not promote a next Todo, does not authorize production cutover, does not read production secret, does not connect production endpoint / broker endpoint, and does not submit production order. production cutover not authorized。

## GH-1200 Release v0.18.1 v0.18.0 Release Fact Sync Policy

`GH-1200-VERIFY-V0181-V0180-RELEASE-FACT-SYNC`

`V0181-001-V0180-RELEASE-FACT-SYNC-GUARD`

`TVM-RELEASE-V0181-V0180-RELEASE-FACT-SYNC`

`V0181-001-V0180-TAG-FIXED`

`V0181-001-PATCH-QUEUE-NOT-PUBLICATION`

`V0181-001-V0180-STALE-WORDING-GUARD`

`V0181-001-NO-PRODUCTION-CUTOVER`

v0.18.1 是 v0.18.0 后的 Venue/Product Lifecycle Recovery CLI + Release Fact Patch queue。GH-1200 只同步 v0.18.0 publication facts 到 patch docs、validation matrix、automation readiness、Stage Audit、release notes 和 stale wording guard。

v0.18.0 当前存在 stable GitHub Release：

- release tag：`v0.18.0`
- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.18.0`
- release type：stable release；非 draft；非 prerelease
- tag peeled commit：`cd284a5817694ffc7c98cd6ccc6b51769fdf6ac9`
- publication timestamp：`2026-06-28T04:55:36Z`

GH-1200 不移动 `v0.18.0` tag，不覆盖 GitHub Release，不创建 `v0.18.1` tag，不创建 `v0.18.1` GitHub Release，不授权 production cutover。

GH-1200 rejects unqualified stale v0.18.0 publication wording after the independent Release Publication Gate published the v0.18.0 stable GitHub Release facts. It scans root docs, release notes, Stage Audit and release publication policy for v0.18.0 pending release / pending tag / release not created / construction-only current-fact wording.

Historical #1185 / GH-1185 construction closeout wording is allowed only when it is clearly scoped as historical closeout evidence and the same file also carries the current v0.18.0 release URL, tag peeled commit and publication timestamp:

- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.18.0`
- tag peeled commit：`cd284a5817694ffc7c98cd6ccc6b51769fdf6ac9`
- publication timestamp：`2026-06-28T04:55:36Z`

## v0.18.1 Release Full Matrix Publication Evidence Gate

`GH-1201-VERIFY-V0181-RELEASE-FULL-MATRIX-PUBLICATION-GATE`、`TVM-RELEASE-V0181-RELEASE-FULL-MATRIX-PUBLICATION-GATE`、`V0181-002-RELEASE-FULL-MATRIX-REQUIRED`、`V0181-002-LINUX-CHECKS-JOB-EVIDENCE`、`V0181-002-DASHBOARD-MACOS-JOB-EVIDENCE`、`V0181-002-PR-FAST-NOT-PUBLICATION-EVIDENCE` 和 `V0181-002-NO-PRODUCTION-CUTOVER` 固定后续 v0.18.1 publication evidence 的 CI gate。

release publication evidence must include GitHub Actions workflow run id, run attempt, workflow job ids: pr_fast_checks, linux_checks, dashboard_macos, release_publication_checks, and evidence artifacts from GitHub Actions run log, job summary, Linux `checks/run.sh` output, and Dashboard macOS build / smoke output.

release publication cannot be represented as complete by pr-fast-checks or checks aggregate alone. linux-checks and dashboard-macos must both be SUCCESS for tag publication evidence. Ordinary PR required `checks` remains fast-lane-only so review PRs do not wait on release full matrix. production cutover not authorized.

If Human later requests `v0.18.1` publication, it must be handled by a separate explicit Release Publication Gate after clean `main`, open PR = 0, open active issue = 0, validation evidence are re-confirmed, and the release full matrix evidence above is present. production cutover not authorized；production trading remains disabled by default；production secret read, production endpoint / broker endpoint connection and production submit / cancel / replace remain unauthorized.

## v0.18.1 Operator-run CLI Commands

`GH-1202-VERIFY-V0181-OPERATOR-RUN-CLI-COMMANDS`、`TVM-RELEASE-V0181-OPERATOR-RUN-CLI-COMMANDS`、`V0181-003-OPERATOR-RUN-HELP-VISIBLE`、`V0181-003-RESUME-CLI-ROUTE`、`V0181-003-REPLAY-CLI-ROUTE`、`V0181-003-EXPLAIN-FAILURE-CLI-ROUTE`、`V0181-003-FAILED-EVIDENCE-READ-ONLY-REPORT-PATH`、`V0181-003-LOCAL-ONLY-REDACTED-OUTPUT` 和 `V0181-003-NO-PRODUCTION-CUTOVER` 固定 v0.18.1 operator-run CLI publication-adjacent safety boundary.

GH-1202 wires operator-run CLI commands into the public MTPRO CLI surface for local read-only artifact model output: `operator-run help`, `operator-run resume`, `operator-run replay`, `operator-run replay-cancel-status-reconciliation` and `operator-run explain-failure`.

Failed evidence must be represented by an explicitly classified read-only report path or a recommended nonzero exit code. GH-1202 does not create a tag, does not create a GitHub Release, does not authorize production cutover, does not read production secret, does not connect production endpoint / broker endpoint and does not submit / cancel / replace any production order.

## v0.18.1 Artifact Namespace Paths

`GH-1203-VERIFY-V0181-ARTIFACT-NAMESPACE-PATHS`、`TVM-RELEASE-V0181-ARTIFACT-NAMESPACE-PATHS`、`V0181-004-RUNS-NAMESPACE-PATH`、`V0181-004-V0180-ACTIVE-PATHS-MIGRATED`、`V0181-004-CROSS-VENUE-PRODUCT-REUSE-FAILS-CLOSED`、`V0181-004-OLD-VERSION-FIXTURES-PRESERVED` 和 `V0181-004-NO-PRODUCTION-CUTOVER` 固定 v0.18.1 artifact namespace path guard.

GH-1203 fixes active v0.18 artifact namespace paths so status retry persistence, Dashboard drilldown and operator-run report references use `.local/mtpro/runs/<venue>/<product>/<environment>/<accountProfile>/<runID>/`. Historical v0.16 fixtures stay scoped to old release tests. Cross venue/product namespace reuse must fail closed before replay or Dashboard display.

GH-1203 does not create a tag, does not create a GitHub Release, does not authorize production cutover, does not read production secret, does not connect production endpoint / broker endpoint and does not submit / cancel / replace any production order.

## v0.18.1 Typed Namespace Model

`GH-1204-VERIFY-V0181-TYPED-NAMESPACE-MODEL`、`TVM-RELEASE-V0181-TYPED-NAMESPACE-MODEL`、`V0181-005-TYPED-VENUE-PRODUCT-ENVIRONMENT`、`V0181-005-ACCOUNT-PROFILE-ID`、`V0181-005-ALLOWED-PAIRS-FAIL-CLOSED`、`V0181-005-PRODUCTION-LIVE-FORBIDDEN-BY-DEFAULT`、`V0181-005-JSON-CODEC-MIGRATION` 和 `V0181-005-NO-PRODUCTION-CUTOVER` 固定 v0.18.1 typed namespace model guard。

GH-1204 replaces critical v0.18 namespace raw string switches with typed VenueID / ProductKind / TradingEnvironment / AccountProfileID where practical. Allowed pairs remain binance/spot, binance/usdmFutures, okx/spot and okx/swap. productionLive remains forbidden by default, account profile ids reject credential-like markers, and JSON encode/decode keeps the existing raw key migration evidence.

GH-1204 does not create a tag, does not create a GitHub Release, does not authorize production cutover, does not read production secret, does not connect production endpoint / broker endpoint and does not submit / cancel / replace any production order.

## v0.18.1 Aggregate Audit / Release Notes / Publication Guidance

`GH-1205-VERIFY-V0181-AGGREGATE-AUDIT-RELEASE-NOTES`、`TVM-RELEASE-V0181-AGGREGATE-AUDIT-RELEASE-NOTES`、`V0181-006-AGGREGATE-GUARD`、`V0181-006-PATCH-AUDIT`、`V0181-006-RELEASE-NOTES`、`V0181-006-VALIDATION-MATRIX`、`V0181-006-PUBLICATION-GUIDANCE`、`V0181-006-RELEASE-PUBLICATION-GATE-HANDOFF`、`V0181-006-NO-PRODUCTION-CUTOVER` 和 `V0181-006-NO-TAG-OR-RELEASE-PUBLICATION` 固定 v0.18.1 aggregate closeout boundary。

GH-1205 closes v0.18.1 aggregate audit / release notes / publication guidance for #1200..#1205 and PR #1216..#1220. It keeps `checks/verify-v0.18.1.sh` as the aggregate verifier and records that v0.19.0 is not started.

Explicit human publication instruction has been received for v0.18.1. Publication still occurs only after #1205 merge via independent Release Publication Gate: clean `main`, open PR = 0, open active issue = 0, worktree clean, validation evidence and GH-1201 full matrix publication evidence must be reconfirmed before creating or reporting any v0.18.1 tag / GitHub Release.

GH-1205 does not create a tag, does not create a GitHub Release, does not authorize production cutover, does not read production secret, does not connect production endpoint / broker endpoint and does not submit / cancel / replace any production order. production cutover not authorized.

## v0.19.0 Historical Stage Audit / Release Docs Closeout

`GH-1215-VERIFY-V0190-STAGE-AUDIT-RELEASE-DOCS`、`TVM-RELEASE-V0190-STAGE-AUDIT-RELEASE-DOCS`、`V0190-010-STAGE-CODE-AUDIT`、`V0190-010-RELEASE-NOTES`、`V0190-010-VALIDATION-MATRIX`、`V0190-010-ROOT-DOCS-REFRESH`、`V0190-010-STALE-WORDING-GUARD`、`V0190-010-NO-PRODUCTION-CUTOVER` 和 `V0190-010-NO-TAG-OR-RELEASE-PUBLICATION` 固定 v0.19.0 construction closeout boundary。

GH-1215 closes the v0.19.0 stage audit / release docs / validation matrix / root docs refresh / stale wording guard for #1206..#1215 and PR #1222..#1230. It records that the venue/product registry + runtime adapter foundation is complete as construction closeout.

`GH-1233-VERIFY-V0191-V0190-HISTORICAL-CLOSEOUT-WORDING`、`V0191-002-V0190-HISTORICAL-CLOSEOUT-WORDING-GUARD`、`TVM-RELEASE-V0191-V0190-HISTORICAL-CLOSEOUT-WORDING`、`V0191-002-CONSTRUCTION-CLOSEOUT-HISTORICAL`、`V0191-002-CURRENT-RELEASE-PUBLISHED` 和 `V0191-002-NO-PRODUCTION-CUTOVER` 固定后续 wording rule：GH-1215 no-tag / no-release 只允许作为 historical construction closeout evidence；当前-facing docs 必须同时保留 v0.19.0 stable GitHub Release 已发布事实。

`GH-1234-VERIFY-V0191-V0190-STALE-WORDING-GUARD`、`V0191-003-V0190-STALE-WORDING-GUARD`、`V0191-003-HISTORICAL-CONSTRUCTION-CLOSEOUT-ALLOWLIST`、`TVM-RELEASE-V0191-V0190-STALE-WORDING-GUARD`、`V0191-003-CURRENT-FACING-STALE-WORDING-REJECTION` 和 `V0191-003-NO-PRODUCTION-CUTOVER` 固定后续 guard rule：GH-1234 rejects current-facing stale v0.19.0 publication wording；historical construction closeout evidence 只有在同一 artifact 保留 release URL、tag peeled commit 和 publication timestamp 时允许。

v0.19.0 已在 GH-1215 之后通过独立 Release Publication Gate 发布 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.19.0`，tag peeled commit `53e9b1e81db075ef464b74f8f35c66ebd61ea03c`，publication timestamp `2026-06-29T13:42:34Z`。GH-1215 在 construction closeout 当时不创建 tag / GitHub Release、不授权 production cutover、不读取 production secret、不连接 production endpoint / broker endpoint、不提交 / cancel / replace production order；该 historical boundary 不覆盖当前 publication fact。production cutover not authorized.
