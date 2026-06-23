# MTPRO

MTPRO 是 SwiftPM-first、local-first 的 macOS 原生专业交易工作台。它以 Research -> Backtest -> Report -> Paper -> guarded runtime evidence 的可追溯链路为基础，最终目标是专业版交易工作台：Live trading、实盘监控、实盘执行控制、实盘风险控制、实盘审计、事故回放和停机控制。

Latest completed release construction scope: `MTPRO Release v0.15.0 Real Binance Testnet Execution MVP`。

Latest completed patch scope: `MTPRO Release v0.14.1 Local Execution Evidence Hardening Patch`。

Current GitHub fallback queue: `MTPRO Release v0.15.1 Real Testnet Execution Hardening Patch`。

Historical guard retains previous Latest completed release construction scope: `MTPRO Release v0.12.0 Readiness Assessment Sessions`。
Historical guard retains previous Latest completed release construction scope: `MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening`。
Historical guard retains previous Latest completed release construction scope: `MTPRO Release v0.10.0 Production Cutover Readiness Gate`。
Historical guard retains previous Latest completed release construction scope: `MTPRO Release v0.9.0 Testnet No-order Observability`。
Historical guard retains previous Latest completed release construction scope: `MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring`。

当前最新完成范围：`MTPRO Release v0.15.0 Real Binance Testnet Execution MVP`。它收口 GitHub fallback queue `#1065..#1076`：v0.15.0 release contract、v0.14.1 preflight、Binance Spot Testnet credential reference、HMAC-SHA256 signed request construction、guarded submit / cancel / cancel-replace runtime evidence、append-only network event log、OMS state sync / reconciliation、CLI operator flow、Dashboard read-only execution status、failure simulation，以及 #1076 release CI / manual Spot Testnet workflow / Stage Code Audit / release notes closeout。后续独立 Release Publication Gate 已发布 `v0.15.0` stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.15.0`，tag peeled commit：`1590b6c40e6ca7887cff0ca59b2f74e4fe7e3ece`，publication timestamp：`2026-06-23T01:26:30Z`。该 publication 不授权 production cutover；production trading 仍默认关闭，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。

最新完成 patch scope：`MTPRO Release v0.14.1 Local Execution Evidence Hardening Patch`。它收口 GitHub fallback queue `#1059..#1064`：release CI / Dashboard evidence、Codable decode validation、submit evidence network guards、golden JSON contract tests、Dashboard local artifact loading，以及 #1064 Stage Code Audit / release notes closeout。v0.14.1 的工程语义是 local execution evidence chain / testnet evidence only，不是真实 signed Binance testnet execution release，不代表真实 Binance testnet order execution；#1064 本身不创建 `v0.14.1` tag，不创建 GitHub Release，不授权 production cutover。

当前 GitHub fallback queue 为 `release/v0.15.1` issues `#1094..#1100`。#1094 已通过 `GH-1094-VERIFY-V0151-V0150-RELEASE-FACT-SYNC` 同步 v0.15.0 已发布事实；#1095 closed / done，并通过 `GH-1095-VERIFY-V0151-INJECTED-TRANSPORT-WORDING` 明确 v0.15.0 提供 signed execution runtime contracts 和 injected Spot Testnet transport protocol evidence，不等于仓库内置 URLSession network runner，也不等于 CLI 默认真实联网执行器。#1096 已通过 `GH-1096-VERIFY-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT` 增加 concrete URLSession Spot Testnet transport guard：只允许 `https://testnet.binance.vision/api/v3/order` submit / cancel request，fail-closed 拒绝 production host，并只落 redacted response digest。current issue `#1097` 是 `GH-1097-VERIFY-V0151-CLI-TESTNET-EXECUTION-RUNTIME`，用于把 `mtpro testnet-execution` 的 submit / cancel / cancel-replace operator flow 接到 v0.15 guarded runtime，并要求 `testnet-env` credential provider、显式 operator confirmation、redacted output、run id、artifact path 和 checksum。#1098..#1100 remain backlog / non-executable until dependencies are done。v0.15.1 是 v0.15.0 后的 hardening patch queue，不创建下一 Project / Issue，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。

Historical completed release construction scope：`MTPRO Release v0.12.0 Readiness Assessment Sessions`。它收口本地 readiness assessment session contract、v0.11.x publication / patch fact baseline、assessment registry store、transaction lock / generation control、Manifest V2 / provenance schema、artifact content-policy / redaction validator、immutable readiness bundle snapshot、kill switch / no-trade trustworthy observations、approval role / quorum separation、shadow parity source snapshot binding、readiness assessment diff / compare、assessment-scoped CLI lifecycle、Dashboard assessment history / adversarial CI，以及 final audit / release docs / operator runbook closure。#965 construction closeout 只收口 evidence / docs / runbook；后续独立 Release Publication Gate 已发布 v0.12.0 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.12.0`，tag peeled commit：`25e31afd351db9a372db62222226b0a3db26c93a`，publication timestamp：`2026-06-20T01:11:22Z`。该 publication 不授权 production cutover；production trading 仍默认关闭。

Historical completed release construction scope：`MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening`。它收口本地 readiness artifact store、manifest atomic IO、canonical JSON SHA256、bundle validation、shadow dry-run parity、Dashboard real artifact state、readiness CLI local artifact commands、fixed-point capital / exposure policy、kill switch / no-trade state model、auditable approval workflow transitions 和 final audit / release docs closure。#924 construction closeout 本身不创建 public tag / GitHub Release；后续独立 Release Publication Gate 已发布 v0.11.0 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.11.0`，tag peeled commit：`13f592d0710de91351286e5c5490bfacb63c19b0`，publication timestamp：`2026-06-19T01:20:58Z`。该 publication 不授权 production cutover；production cutover 仍未授权。v0.10.0 已通过独立 public release publication gate 发布 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.10.0`，tag target commit：`7b0e1f8bb6a671cd3b96f7e7b020b803f8cea4b4`。该 publication 不授权 production cutover。

Historical completed release construction scope：`MTPRO Release v0.9.0 Testnet No-order Observability`。它是 testnet read-only no-order observability、persistent monitor session、signed account snapshot freshness、private stream heartbeat / staleness、monitor recovery observe、Dashboard observability timeline、alert read-model、Portfolio reconciliation timeline、Risk policy application audit、run monitor export bundle、validation lanes split、Dashboard / CLI operator UX 和 final audit / docs / runbook closure。v0.7.0 和 v0.8.0 均已通过各自独立 release publication gate 发布 stable GitHub Release；v0.8.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.8.0`。v0.9.0 也已通过独立 release publication gate 发布 stable GitHub Release；v0.9.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.9.0`，target commit：`4296bf73673fe0fd8f09e34c40ef2a3a9ba7e55c`。v0.9.1 patch evidence 收口 v0.9.0 audit hardening：Dashboard macOS v0.9 focused guard、`mtpro verify v0.9.0` wording、monitor store binding 和 probe / monitor naming；v0.9.1 已通过独立 release publication gate 发布 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.9.1`，tag peeled commit：`d041f0dd304075562a85e494695697290972288f`。v0.8.1 patch evidence 只收口 release publication docs alignment、Dashboard macOS guard、CLI wording、local session wording、status artifact role、private stream redaction 和 patch docs；v0.9.0 construction closeout、v0.9.0 / v0.9.1 public GitHub Release publication 和 production cutover 仍是独立 gate；已发布事实、patch evidence、v0.9.0 construction evidence 和 v0.10.0 readiness evidence 均不授权 production cutover。

Historical completed release construction scope：`MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring`。

Historical completed release construction scope：`MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity`。

MTPRO 借鉴 `nautilus_trader` 的 Kernel / MessageBus / Cache / Engine / Adapter 分层思想，也参考 `macos-trader` 的产品语义；不引入 NautilusTrader 作为运行依赖，不复制 `macos-trader` 整仓代码。

## 当前边界

| 项 | 当前事实 |
| --- | --- |
| Current maturity statement | `MTPRO Release v0.15.0 Real Binance Testnet Execution MVP complete and published as stable GitHub Release with production trading disabled by default and production cutover not authorized` |
| Latest patch statement | `MTPRO Release v0.14.1 Local Execution Evidence Hardening Patch complete as local execution evidence hardening patch without tag publication and without production cutover authorization` |
| Current v0.15.1 queue | `MTPRO Release v0.15.1 Real Testnet Execution Hardening Patch`；#1094 closed / done；#1095 closed / done；#1096 closed / done；current issue `#1097`；`GH-1097-VERIFY-V0151-CLI-TESTNET-EXECUTION-RUNTIME`；`#1098..#1100` remain backlog / non-executable until dependencies are done |
| Active venue / products / strategies | `activeVenue == Binance`；`activeProductTypes == [spot, usdsPerpetual]`；`activeStrategies == [ema, rsi]` |
| Runtime modes | `runtimeModes == [local-dry-run, testnet-read-only-monitor, recovery-observe, production-blocked]` |
| Production default | `productionTradingEnabledByDefault == false`；这是当前 release line 的默认关闭策略，不是永久禁止实盘。 |
| Production capability | `productionCapabilityGatedNotMissing == true` |
| Historical boundary | `oldPublicReadOnlyPaperOnlyEMAOnlyIsHistorical == true` |

Production trading、production secret、production endpoint、production broker connection、testnet / production submit / cancel / replace、production OMS 和 production cutover 都没有默认启用，也没有被 v0.13.0 授权。这里的“不授权 / 默认关闭”是当前阶段的 readiness gate，不是 MTPRO 的永久产品限制。MTPRO 的长期目标仍包含受控 Live trading；后续只能在 evidence-driven readiness、signed endpoint / credential、OMS、pre-trade / post-trade risk、kill switch、reconciliation、audit trail、operator runbook 和 Human approval 全部满足后，按唯一 live queue source 逐层启用。

最新完成的 GitHub fallback queue 为 `release/v0.15.0` issues `#1065..#1076`。`#1066` 至 `#1076` 已完成 release contract、credential / signed request、guarded Spot Testnet submit / cancel / cancel-replace runtime evidence、network event log、OMS state sync / reconciliation、CLI operator flow、Dashboard read-only status、failure simulation 和 release CI / manual workflow / audit closeout。`v0.15.0` 已通过独立 Release Publication Gate 发布 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.15.0`，tag peeled commit：`1590b6c40e6ca7887cff0ca59b2f74e4fe7e3ece`，publication timestamp：`2026-06-23T01:26:30Z`。v0.15.0 publication 不授权 production cutover。

最新完成的 patch queue 为 `release/v0.14.1` issues `#1059..#1064`。`#1059` 至 `#1063` 已完成 v0.14.1 release CI / Dashboard evidence、Codable decode validation、submit evidence network guards、golden JSON contracts 和 Dashboard local artifact loading；`#1064` 收口 Stage Code Audit、release notes、latest verification、automation readiness、release publication policy 和 root docs wording。v0.14.1 patch closeout 不创建下一 Project / Issue，不授权 production cutover。

当前 GitHub fallback queue 为 `release/v0.15.1` issues `#1094..#1100`。#1094 release fact sync guard 已 closed / done；#1095 injected transport wording guard 已 closed / done；#1096 concrete URLSession Spot Testnet transport 已 closed / done；当前 WIP=1 是 #1097 CLI guarded runtime wiring。#1098..#1100 在 #1097 PR merge、required checks SUCCESS、issue closed / done、main fast-forward 和 worktree clean 前保持 backlog / non-executable。

## 必读入口

1. `README.md`
2. `AGENTS.md`
3. `GOAL.md`
4. `BLUEPRINT.md`
5. `environment.md`
6. `architecture.md`
7. `docs/roadmap.md`
8. `docs/domain/context.md`
9. `docs/validation/latest-verification-summary.md`

完整 `verification.md` 只在审计、追溯或 debug 时读取。

## 文档地图

| 文件 / 目录 | 作用 |
| --- | --- |
| `GOAL.md` | Project Charter：目标、受众、当前阶段硬边界、永久边界和成功标准 |
| `BLUEPRINT.md` | Canonical Blueprint：Root Blueprint + Complete Blueprint |
| `environment.md` | 本地环境、验证入口、外部系统能力和禁区 |
| `architecture.md` | Engineering Module Map / 工程模块地图：模块边界、依赖方向、数据流和不变量 |
| `docs/roadmap.md` | Construction Plan：根据蓝图和工程模块定义施工顺序、完成进度和下一阶段 handoff |
| `docs/domain/context.md` | Shared Language：领域术语、禁止混用词和 production-disabled-by-default 语义 |
| `docs/automation/` | Parent Codex、Execution Agent、PR automation、Post-Issue Ledger、readiness guards、AEP 方法论和从 `mattpocock/skills` 吸收的方法 |
| `docs/validation/` | 最近验证摘要、长期验证计划、trading validation matrix |
| `docs/audit/` | Project / release 级 Stage Code Audit 和 audit inputs |
| `docs/operators/`、`docs/release/` | release / operation runbook 和 release notes |

根文档层级：`GOAL.md` 定义目标和硬边界；`BLUEPRINT.md` 定义完整蓝图；`environment.md`、`architecture.md`、`docs/roadmap.md` 只能承接和细化蓝图，不能推翻它。

## 当前证据入口

| 类别 | 锚点 / 文件 |
| --- | --- |
| v0.15.0 OMS state sync reconciliation | `GH-1072-VERIFY-V0150-OMS-STATE-SYNC-RECONCILIATION`；`TVM-RELEASE-V0150-OMS-STATE-SYNC-RECONCILIATION`；`V0150-007-CONSUMES-NETWORK-EVENT-LOG`；`V0150-007-OMS-STATE-SYNC-FROM-APPEND-ONLY-EVIDENCE`；`V0150-007-EXPECTED-OBSERVED-RECONCILIATION`；`V0150-007-MISMATCH-FAIL-CLOSED`；`V0150-007-SUBMIT-CANCEL-CANCEL-REPLACE-COVERAGE`；`V0150-007-NO-PRODUCTION-CUTOVER`；`docs/contracts/release-v0.15.0-oms-state-sync-reconciliation-contract.md`；`checks/verify-v0.15.0-oms-state-sync-reconciliation.sh`；`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetOMSStateReconciliation.swift`；`testGH1072ReleaseV0150OMSStateReconciliationConsumesNetworkEventLog`；derivedFromNetworkEventLogOnly=true；appendOnlyNetworkExecutionEventLog=true；expectedObservedReconciliation=true；mismatchesFailClosed=true；submitCancelCancelReplaceCoverage=true；raw broker payload and broker fill remain false；production endpoint blocked；production order remains false |
| v0.15.0 real Spot Testnet cancel-replace runtime | `GH-1070-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-REPLACE-RUNTIME`；`TVM-RELEASE-V0150-REAL-SPOT-TESTNET-CANCEL-REPLACE`；`V0150-005-CANCEL-REPLACE-EMULATION`；`V0150-005-CANCEL-THEN-NEW-SUBMIT`；`V0150-005-OMS-REPLACE-STATE-TRANSITION`；`V0150-005-APPEND-ONLY-CANCEL-REPLACE-EVENT`；`V0150-005-UNSUPPORTED-NATIVE-REPLACE-FAIL-CLOSED`；`V0150-005-PRODUCTION-ENDPOINT-BLOCKED`；`V0150-005-NO-PRODUCTION-CUTOVER`；`docs/contracts/release-v0.15.0-real-spot-testnet-cancel-replace-runtime-contract.md`；`checks/verify-v0.15.0-real-spot-testnet-cancel-replace-runtime.sh`；`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetCancelReplaceRuntime.swift`；`testGH1070ReleaseV0150SpotTestnetCancelReplaceRuntimeEmulatesCancelThenSubmit`；nativeCancelReplaceSupported=false；nativeReplaceRejectedFailClosed=true；cancelThenNewSubmitEmulationUsed=true；appendOnlyCancelReplaceEvidenceCreated=true；omsStateTransitionIntegrated=true；production endpoint blocked；production order remains false |
| v0.15.0 real Spot Testnet cancel runtime | `GH-1069-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-RUNTIME`；`TVM-RELEASE-V0150-REAL-SPOT-TESTNET-CANCEL`；`V0150-004-CANCEL-REQUEST-CONSTRUCTION`；`V0150-004-SIGNED-TESTNET-TRANSPORT`；`V0150-004-REDACTED-CANCEL-RESPONSE-EVIDENCE`；`V0150-004-OMS-CANCEL-STATE-TRANSITION`；`V0150-004-APPEND-ONLY-CANCEL-EVENT`；`V0150-004-PRODUCTION-ENDPOINT-BLOCKED`；`V0150-004-NO-PRODUCTION-CUTOVER`；`docs/contracts/release-v0.15.0-real-spot-testnet-cancel-runtime-contract.md`；`checks/verify-v0.15.0-real-spot-testnet-cancel-runtime.sh`；`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetCancelRuntime.swift`；`testGH1069ReleaseV0150SpotTestnetCancelRuntimeAppendsRedactedCancelEvidence`；httpMethod=DELETE；testnetNetworkCancelPerformed=true；appendOnlyCancelEvidenceCreated=true；omsStateTransitionIntegrated=true；production endpoint blocked；production order remains false |
| v0.15.0 network execution event log | `GH-1071-VERIFY-V0150-NETWORK-EXECUTION-EVENT-LOG`；`TVM-RELEASE-V0150-NETWORK-EXECUTION-EVENT-LOG`；`V0150-006-APPEND-ONLY-NETWORK-EVENT-LOG`；`V0150-006-REQUEST-RESPONSE-IDENTITY`；`V0150-006-CHECKSUM-CHAIN`；`V0150-006-RAW-SECRET-NOT-PERSISTED`；`V0150-006-NO-PRODUCTION-CUTOVER`；`docs/contracts/release-v0.15.0-network-execution-event-log-contract.md`；`checks/verify-v0.15.0-network-execution-event-log.sh`；`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog.swift`；`testGH1071ReleaseV0150NetworkExecutionEventLogChainsRedactedArtifacts`；appendOnlyNetworkExecutionEventLog=true；redactedRequestIdentity=true；redactedResponseIdentity=true；checksumChainVerified=true；rawSecretPersisted=false；production endpoint blocked；production order remains false |
| v0.15.0 real Spot Testnet submit runtime | `GH-1068-VERIFY-V0150-REAL-SPOT-TESTNET-SUBMIT-RUNTIME`；`TVM-RELEASE-V0150-REAL-SPOT-TESTNET-SUBMIT`；`V0150-003-ORDERINTENT-TO-SIGNED-SUBMIT`；`V0150-003-REDACTED-RESPONSE-EVIDENCE`；`V0150-003-TESTNET-NETWORK-SUBMIT-PERFORMED`；`V0150-003-PRODUCTION-ENDPOINT-BLOCKED`；`V0150-003-NO-PRODUCTION-CUTOVER`；`docs/contracts/release-v0.15.0-real-spot-testnet-submit-runtime-contract.md`；`checks/verify-v0.15.0-real-spot-testnet-submit-runtime.sh`；`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetSubmitRuntime.swift`；`testGH1068ReleaseV0150SpotTestnetSubmitRuntimeProducesRedactedNetworkEvidence`；testnetNetworkSubmitPerformed=true；append-only redacted response evidence；production endpoint blocked；production order remains false |
| v0.15.0 signed request builder | `GH-1067-VERIFY-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST`；`TVM-RELEASE-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST`；`V0150-002-CREDENTIAL-REFERENCE`；`V0150-002-HMAC-SHA256-SIGNED-REQUEST`；`V0150-002-BINANCE-SPOT-TESTNET-ONLY`；`docs/contracts/release-v0.15.0-testnet-credential-provider-signed-request-builder-contract.md`；`checks/verify-v0.15.0-testnet-credential-signed-request.sh`；HMAC signed request construction evidence only；production secret auto-read blocked；production endpoint blocked；no network action |
| v0.15.0 contract / preflight | `GH-1066-VERIFY-V0150-CONTRACT-PREFLIGHT`；`TVM-RELEASE-V0150-CONTRACT-PREFLIGHT`；`V0150-001-RELEASE-CONTRACT`；`V0150-001-V0141-PREFLIGHT-GATE`；`V0150-001-BINANCE-SPOT-TESTNET-ONLY`；`docs/contracts/release-v0.15.0-real-binance-spot-testnet-execution-mvp-contract.md`；`checks/verify-v0.15.0-contract-preflight.sh`；v0.15.0 is Binance Spot Testnet only；production trading disabled by default；#1066 closed / done before #1067 |
| v0.15.1 injected transport wording | `GH-1095-VERIFY-V0151-INJECTED-TRANSPORT-WORDING`；`TVM-RELEASE-V0151-INJECTED-TRANSPORT-WORDING`；`V0151-002-INJECTED-TRANSPORT-NOT-BUILTIN-RUNNER`；`V0151-002-MOCK-MANUAL-PROOF-SPLIT`；`V0151-002-FUTURE-URLSESSION-RUNNER-DEFERRED`；v0.15.0 runtime evidence 需要 injected Spot Testnet transport protocol 或手工 operator proof，不表示仓库已内置 URLSession runner、CLI 默认真实联网 runner 或 production broker connector；#1096 才是后续 concrete URLSession transport hardening slice |
| v0.15.1 URLSession Spot Testnet transport | `GH-1096-VERIFY-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT`；`TVM-RELEASE-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT`；`V0151-003-URLSESSION-SPOT-TESTNET-ALLOWLIST`；`V0151-003-SUBMIT-CANCEL-URLSESSION-TRANSPORT`；`V0151-003-REDACTED-RESPONSE-DIGEST`；`V0151-003-NO-SECRET-PERSISTENCE`；`V0151-003-PRODUCTION-ENDPOINT-REJECTED`；`V0151-003-NO-PRODUCTION-CUTOVER`；`Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetURLSessionTransport.swift`；`checks/verify-v0.15.1-urlsession-spot-testnet-transport.sh`；`testGH1096ReleaseV0151URLSessionSpotTestnetTransportUsesAllowlistAndRedaction`；只允许 Binance Spot Testnet `https://testnet.binance.vision/api/v3/order` submit / cancel URLSession transport；production host fail-closed；response body 降维为 `response-sha256` digest；API key、secret 和 raw order identity 不进入持久证据；不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order |
| v0.15.1 CLI testnet execution runtime | `GH-1097-VERIFY-V0151-CLI-TESTNET-EXECUTION-RUNTIME`；`TVM-RELEASE-V0151-CLI-TESTNET-EXECUTION-RUNTIME`；`V0151-004-CLI-GUARDED-RUNTIME-INVOKED`；`V0151-004-TESTNET-ONLY-CREDENTIAL-PROVIDER`；`V0151-004-SUBMIT-CANCEL-CANCEL-REPLACE-RUNTIME`；`V0151-004-EXPLICIT-OPERATOR-CONFIRMATION`；`V0151-004-REDACTED-OUTPUT`；`V0151-004-MISSING-CREDENTIAL-FAIL-CLOSED`；`V0151-004-RUN-ID-ARTIFACT-CHECKSUM`；`V0151-004-NO-PRODUCTION-CUTOVER`；`Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow.swift`；`checks/verify-v0.15.1-cli-testnet-execution-runtime.sh`；`testGH1097ReleaseV0151CLITestnetExecutionInvokesGuardedRuntime`；`mtpro testnet-execution` 只允许 `testnet-env` credential provider、显式 operator confirmation 和 redacted output；submit / cancel / cancel-replace 均调用 v0.15 guarded runtime，返回 run id、artifact path 和 checksum；缺少 testnet credential 或确认必须 fail-closed；不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order |
| v0.14.1 patch | `GH-1064-VERIFY-V0141-PATCH-AUDIT-RELEASE-NOTES`；`TVM-RELEASE-V0141-PATCH-AUDIT-RELEASE-NOTES`；`V0141-006-PATCH-AUDIT`；`docs/audit/mtpro-release-v0.14.1-local-execution-evidence-hardening-patch-stage-code-audit.md`；`docs/release/mtpro-release-v0.14.1-local-execution-evidence-hardening-patch-notes.md`；`checks/verify-v0.14.1-patch-audit-release-notes.sh`；patch closeout 不创建 tag / GitHub Release；不授权 production cutover |
| v0.13.0 | Historical `MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine` / `release/v0.13.0` queue；`#1003` ordered CLI execution lifecycle；`#1004` local evidence fixtures / regression suite；`#1005` Stage Code Audit / release docs closeout；`GH-1005-VERIFY-V0130-STAGE-AUDIT-RELEASE-DOCS`；`TVM-RELEASE-V0130-STAGE-AUDIT-RELEASE-DOCS`；`V0130-012-STAGE-CODE-AUDIT`；`docs/audit/mtpro-release-v0.13.0-local-evidence-driven-readiness-engine-stage-code-audit.md`；`docs/release/mtpro-release-v0.13.0-local-evidence-driven-readiness-engine-notes.md`；`docs/contracts/release-v0.13.0-local-evidence-driven-readiness-engine-contract.md`；`checks/verify-v0.13.0.sh`；construction closeout 不创建 tag / GitHub Release；不授权 production cutover |
| v0.12.0 | `GH-965-VERIFY-V0120-FINAL-AUDIT-DOCS-RUNBOOK`；`GH-965-RELEASE-V0120-FINAL-AUDIT-DOCS-RUNBOOK`；`TVM-RELEASE-V0120-FINAL-AUDIT-DOCS-RUNBOOK`；`docs/audit/mtpro-release-v0.12.0-readiness-assessment-sessions-stage-code-audit.md`；`docs/release/mtpro-release-v0.12.0-readiness-assessment-sessions-notes.md`；`docs/operators/release-v0.12.0-readiness-assessment-sessions-runbook.md`；`docs/contracts/release-v0.12.0-readiness-assessment-session-contract.md`；`checks/verify-v0.12.0.sh`；stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.12.0`；tag peeled commit：`25e31afd351db9a372db62222226b0a3db26c93a`；publication timestamp：`2026-06-20T01:11:22Z`；不授权 production cutover |
| v0.11.0 | `GH-924-VERIFY-V0110-FINAL-AUDIT-RELEASE-DOCS`；`docs/audit/mtpro-release-v0.11.0-production-readiness-evidence-runtime-integrity-hardening-stage-code-audit.md`；`docs/release/mtpro-release-v0.11.0-production-readiness-evidence-runtime-integrity-hardening-notes.md`；`checks/verify-v0.11.0.sh`；#924 construction closeout 本身不创建 public tag / GitHub Release；后续 Release Publication Gate 已发布 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.11.0`；tag peeled commit：`13f592d0710de91351286e5c5490bfacb63c19b0`；不授权 production cutover |
| v0.11.1 patch closeout | `GH-951-VERIFY-V0111-PATCH-AUDIT-RELEASE-NOTES`；`docs/audit/mtpro-release-v0.11.1-readiness-runtime-guard-patch-stage-code-audit.md`；`docs/release/mtpro-release-v0.11.1-readiness-runtime-guard-patch-notes.md`；`checks/verify-v0.11.1.sh`；v0.11.1 patch closeout 不创建 `v0.11.1` tag / GitHub Release，不移动、不覆盖、不重写 `v0.11.0` tag / GitHub Release，不推进 v0.12.0，不授权 production cutover |
| v0.12.0 baseline facts | `GH-953-VERIFY-V0120-V011X-RELEASE-PATCH-FACTS`；`docs/contracts/release-v0.12.0-readiness-assessment-session-contract.md`；`checks/verify-v0.12.0.sh`；`docs/release/release-publication-policy.md`；继承 v0.11.0 public GitHub Release fact 和 v0.11.1 patch closeout fact 作为 local readiness assessment provenance；不创建 / 移动 tag 或 release，不授权 production cutover |
| v0.10.0 | `GH-891-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK`；`docs/audit/mtpro-release-v0.10.0-production-cutover-readiness-gate-stage-code-audit.md`；`docs/operators/release-v0.10.0-production-cutover-readiness-gate-runbook.md`；`docs/release/mtpro-release-v0.10.0-production-cutover-readiness-gate-notes.md`；`checks/verify-v0.10.0.sh`；stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.10.0`；tag target commit：`7b0e1f8bb6a671cd3b96f7e7b020b803f8cea4b4`；construction closeout、public release publication 和 production cutover 仍是独立 gate；不授权 production cutover |
| v0.9.1 patch release | `V091-006-VERIFY-PATCH-AUDIT-DOCS-RUNBOOK`；`docs/audit/mtpro-release-v0.9.1-v090-audit-hardening-stage-code-audit.md`；`docs/release/mtpro-release-v0.9.1-v090-audit-hardening-notes.md`；`checks/verify-v0.9.1.sh`；stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.9.1`；tag peeled commit：`d041f0dd304075562a85e494695697290972288f`；不授权 production cutover |
| v0.9.0 | `GH-856-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK`；`docs/audit/mtpro-release-v0.9.0-testnet-no-order-observability-stage-code-audit.md`；`docs/operators/release-v0.9.0-testnet-no-order-observability-runbook.md`；`docs/release/mtpro-release-v0.9.0-testnet-no-order-observability-notes.md`；`checks/verify-v0.9.0.sh` |
| v0.8.1 patch evidence | `GH-841-RELEASE-V081-PATCH-AUDIT-DOCS-RELEASE-NOTES`；`docs/audit/mtpro-release-v0.8.1-release-publication-dashboard-guard-patch-stage-code-audit.md`；`docs/release/mtpro-release-v0.8.1-release-publication-dashboard-guard-patch-notes.md`；`checks/verify-v0.8.1.sh` |
| v0.8.0 | `GH-820-RELEASE-V080-FINAL-AUDIT-DOCS-RUNBOOK`；`docs/audit/mtpro-release-v0.8.0-persistent-operator-runtime-testnet-read-only-monitoring-stage-code-audit.md`；`docs/operators/release-v0.8.0-operator-persistent-runtime-testnet-readonly-monitoring-runbook.md`；`docs/operators/release-v0.8.0-validation-lanes-runbook.md`；`docs/release/mtpro-release-v0.8.0-persistent-operator-runtime-testnet-read-only-monitoring-notes.md`；`checks/verify-v0.8.0.sh` |
| v0.7.0 | `GH-792-RELEASE-V070-FINAL-AUDIT-DOCS-RUNBOOK`；`docs/audit/mtpro-release-v0.7.0-operator-runtime-session-testnet-read-only-connectivity-stage-code-audit.md`；`docs/operators/release-v0.7.0-operator-runtime-session-testnet-readonly-connectivity-runbook.md`；`docs/release/mtpro-release-v0.7.0-operator-runtime-session-testnet-read-only-connectivity-notes.md`；`checks/verify-v0.7.0.sh` |
| Release publication policy | `docs/release/release-publication-policy.md`；`GH-808-RELEASE-PUBLICATION-POLICY`；`GH-835-V081-V080-ACTUAL-GITHUB-RELEASE`；`GH-879-V0100-V091-ACTUAL-GITHUB-RELEASE`；v0.7.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.7.0`；v0.8.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.8.0`；v0.9.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.9.0`；v0.9.1 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.9.1`；v0.10.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.10.0`；v0.11.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.11.0`；v0.12.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.12.0`；construction closeout、public release publication 和 production cutover remain separate gates |
| v0.6.0 | Historical `MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening`；`GH-766-RELEASE-V060-FINAL-AUDIT-ROOT-DOCS`；`docs/audit/mtpro-release-v0.6.0-local-operational-runtime-testnet-read-only-probe-hardening-stage-code-audit.md`；`docs/operators/release-v0.6.0-operator-local-operational-runtime-testnet-readonly-probe-runbook.md`；`docs/release/mtpro-release-v0.6.0-local-operational-runtime-testnet-read-only-probe-hardening-notes.md`；`checks/verify-v0.6.0.sh` |
| v0.5.0 | Historical `MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge`；`GH-739-RELEASE-V050-FINAL-AUDIT-RELEASE-DOCS`；`docs/audit/mtpro-release-v0.5.0-guarded-testnet-runtime-foundation-stage-code-audit.md`；`docs/operators/release-v0.5.0-operator-guarded-testnet-runtime-foundation-runbook.md`；`docs/release/mtpro-release-v0.5.0-guarded-testnet-runtime-foundation-notes.md`；`checks/verify-v0.5.0.sh` |
| v0.4.0 | `GH-709-RELEASE-V040-FINAL-STAGE-AUDIT-RELEASE-DOCS`；Historical release v0.4.0 evidence anchor |
| v0.3.0 | `GH-670-RELEASE-V030-FINAL-STAGE-AUDIT-RELEASE-DOCS`；Historical release v0.3.0 Stage Code Audit Report |
| v0.2.0 | `GH-596-RELEASE-V020-ROOT-DOCS-REFRESH`；`GH-564-RELEASE-V020-ROOT-DOCS-BOUNDARY-REFRESH`；Historical Latest completed release construction scope: `MTPRO Release v0.2.0`；`docs/audit/mtpro-release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-stage-code-audit.md` |

## 代码结构

`Sources/` 以 module boundary 组织：`DomainModel`、`MessageBus`、`DataClient`、`DataEngine`、`Cache`、`Database`、`Trader`、`Portfolio`、`RiskEngine`、`ExecutionEngine`、`ExecutionClient` 和 `Dashboard`。详细依赖方向、数据流和禁止边界见 `architecture.md`。

## 本地验证

```bash
bash checks/run.sh
```

轻量当前 release guard：

```bash
bash checks/verify-v0.14.1-patch-audit-release-notes.sh
bash checks/verify-v0.15.0-contract-preflight.sh
bash checks/verify-v0.15.0-testnet-credential-signed-request.sh
bash checks/verify-v0.15.0-real-spot-testnet-submit-runtime.sh
bash checks/verify-v0.15.0-network-execution-event-log.sh
bash checks/verify-v0.15.0-real-spot-testnet-cancel-runtime.sh
bash checks/verify-v0.15.0-real-spot-testnet-cancel-replace-runtime.sh
bash checks/verify-v0.15.1-v0150-release-fact-sync.sh
bash checks/verify-v0.12.0.sh
bash checks/verify-v0.13.0.sh
bash checks/verify-v0.11.0.sh
bash checks/verify-v0.10.0.sh
bash checks/verify-v0.9.1.sh
bash checks/verify-v0.9.0.sh
bash checks/verify-v0.8.1.sh
bash checks/verify-v0.8.0.sh
```

历史 v0.7 release guard：

```bash
bash checks/verify-v0.7.0.sh
```

`checks/run.sh` 串联 whitespace、automation readiness、release verifiers、Dashboard build / smoke 和 Swift tests。

## AEP 方法论

执行链路固定为 Human planning -> live queue source -> Parent Codex queue preflight -> unique Todo -> Codex Execution Agent -> GitHub PR Automation -> Stage Code Audit -> Root Docs / release docs refresh -> next Human planning。规则落点见 `AGENTS.md`、`docs/domain/context.md` 和 `docs/automation/agent-engineering-practices.md`。
