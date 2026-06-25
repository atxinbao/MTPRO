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
