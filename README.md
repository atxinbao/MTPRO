# MTPRO

MTPRO 是 SwiftPM-first、local-first 的 macOS 原生专业交易工作台。它以 Research -> Backtest -> Report -> Paper -> guarded runtime evidence 的可追溯链路为基础，最终目标是专业版交易工作台：Live trading、实盘监控、实盘执行控制、实盘风险控制、实盘审计、事故回放和停机控制。

Latest completed release construction scope: `MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine`。

Latest completed patch scope: `MTPRO Release v0.14.1 Local Execution Evidence Hardening Patch`。

Current GitHub fallback queue: `MTPRO Release v0.15.0 Real Binance Testnet Execution MVP`。

Historical guard retains previous Latest completed release construction scope: `MTPRO Release v0.12.0 Readiness Assessment Sessions`。
Historical guard retains previous Latest completed release construction scope: `MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening`。
Historical guard retains previous Latest completed release construction scope: `MTPRO Release v0.10.0 Production Cutover Readiness Gate`。
Historical guard retains previous Latest completed release construction scope: `MTPRO Release v0.9.0 Testnet No-order Observability`。
Historical guard retains previous Latest completed release construction scope: `MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring`。

当前最新完成范围：`MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine`。它收口真实 local evidence root intake、schema / checksum / content policy validation、Manifest V2、Bundle V2、local registry lifecycle、full evidence-chain validate、redacted audit export package、evidence-level diff / compare、transaction recovery forensic snapshot、generation ID collision-proofing、ordered readiness CLI lifecycle、local evidence fixtures / regression suite，以及 final Stage Code Audit / release docs closure。#1005 construction closeout 只收口本地 evidence engine、audit、release notes、root docs refresh 和 validation anchors；不创建 `v0.13.0` tag，不创建 GitHub Release，不授权 production cutover；production trading 仍默认关闭。

最新完成 patch scope：`MTPRO Release v0.14.1 Local Execution Evidence Hardening Patch`。它收口 GitHub fallback queue `#1059..#1064`：release CI / Dashboard evidence、Codable decode validation、submit evidence network guards、golden JSON contract tests、Dashboard local artifact loading，以及 #1064 Stage Code Audit / release notes closeout。v0.14.1 的工程语义是 local execution evidence chain / testnet evidence only，不是真实 signed Binance testnet execution release，不代表真实 Binance testnet order execution；#1064 本身不创建 `v0.14.1` tag，不创建 GitHub Release，不授权 production cutover。

当前 GitHub fallback queue 为 `release/v0.15.0` issues `#1065..#1076`。#1066 已通过 `GH-1066-VERIFY-V0150-CONTRACT-PREFLIGHT` 定义 v0.15.0 Real Binance Testnet Execution MVP 的 release contract、v0.14.1 preflight gate、Binance Spot Testnet only boundary 和 no-production fail-closed gate。#1067 已通过 `GH-1067-VERIFY-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST` 固定 Binance Spot Testnet credential reference、短生命周期 credential material 和 HMAC-SHA256 signed request construction evidence。#1068 已通过 `GH-1068-VERIFY-V0150-REAL-SPOT-TESTNET-SUBMIT-RUNTIME` 固定 OrderIntent -> signed Spot Testnet submit request -> injected transport -> redacted response evidence 的 guarded submit runtime。当前 WIP=1 issue 是 #1071：`GH-1071-VERIFY-V0150-NETWORK-EXECUTION-EVENT-LOG`，只把已完成的 Spot Testnet network action evidence 写入 append-only redacted checksum event log；#1069 因 V150-006 dependency 仍保持 backlog / non-executable。v0.15.0 MVP 的执行边界是 `activeVenue == Binance`、`v0150ExecutionProductScope == Binance Spot Testnet only`、`productionTradingEnabledByDefault=false`，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。

Historical completed release construction scope：`MTPRO Release v0.12.0 Readiness Assessment Sessions`。它收口本地 readiness assessment session contract、v0.11.x publication / patch fact baseline、assessment registry store、transaction lock / generation control、Manifest V2 / provenance schema、artifact content-policy / redaction validator、immutable readiness bundle snapshot、kill switch / no-trade trustworthy observations、approval role / quorum separation、shadow parity source snapshot binding、readiness assessment diff / compare、assessment-scoped CLI lifecycle、Dashboard assessment history / adversarial CI，以及 final audit / release docs / operator runbook closure。#965 construction closeout 只收口 evidence / docs / runbook；后续独立 Release Publication Gate 已发布 v0.12.0 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.12.0`，tag peeled commit：`25e31afd351db9a372db62222226b0a3db26c93a`，publication timestamp：`2026-06-20T01:11:22Z`。该 publication 不授权 production cutover；production trading 仍默认关闭。

Historical completed release construction scope：`MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening`。它收口本地 readiness artifact store、manifest atomic IO、canonical JSON SHA256、bundle validation、shadow dry-run parity、Dashboard real artifact state、readiness CLI local artifact commands、fixed-point capital / exposure policy、kill switch / no-trade state model、auditable approval workflow transitions 和 final audit / release docs closure。#924 construction closeout 本身不创建 public tag / GitHub Release；后续独立 Release Publication Gate 已发布 v0.11.0 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.11.0`，tag peeled commit：`13f592d0710de91351286e5c5490bfacb63c19b0`，publication timestamp：`2026-06-19T01:20:58Z`。该 publication 不授权 production cutover；production cutover 仍未授权。v0.10.0 已通过独立 public release publication gate 发布 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.10.0`，tag target commit：`7b0e1f8bb6a671cd3b96f7e7b020b803f8cea4b4`。该 publication 不授权 production cutover。

Historical completed release construction scope：`MTPRO Release v0.9.0 Testnet No-order Observability`。它是 testnet read-only no-order observability、persistent monitor session、signed account snapshot freshness、private stream heartbeat / staleness、monitor recovery observe、Dashboard observability timeline、alert read-model、Portfolio reconciliation timeline、Risk policy application audit、run monitor export bundle、validation lanes split、Dashboard / CLI operator UX 和 final audit / docs / runbook closure。v0.7.0 和 v0.8.0 均已通过各自独立 release publication gate 发布 stable GitHub Release；v0.8.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.8.0`。v0.9.0 也已通过独立 release publication gate 发布 stable GitHub Release；v0.9.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.9.0`，target commit：`4296bf73673fe0fd8f09e34c40ef2a3a9ba7e55c`。v0.9.1 patch evidence 收口 v0.9.0 audit hardening：Dashboard macOS v0.9 focused guard、`mtpro verify v0.9.0` wording、monitor store binding 和 probe / monitor naming；v0.9.1 已通过独立 release publication gate 发布 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.9.1`，tag peeled commit：`d041f0dd304075562a85e494695697290972288f`。v0.8.1 patch evidence 只收口 release publication docs alignment、Dashboard macOS guard、CLI wording、local session wording、status artifact role、private stream redaction 和 patch docs；v0.9.0 construction closeout、v0.9.0 / v0.9.1 public GitHub Release publication 和 production cutover 仍是独立 gate；已发布事实、patch evidence、v0.9.0 construction evidence 和 v0.10.0 readiness evidence 均不授权 production cutover。

Historical completed release construction scope：`MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring`。

Historical completed release construction scope：`MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity`。

MTPRO 借鉴 `nautilus_trader` 的 Kernel / MessageBus / Cache / Engine / Adapter 分层思想，也参考 `macos-trader` 的产品语义；不引入 NautilusTrader 作为运行依赖，不复制 `macos-trader` 整仓代码。

## 当前边界

| 项 | 当前事实 |
| --- | --- |
| Current maturity statement | `MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine complete with production trading disabled by default and production cutover not authorized` |
| Latest patch statement | `MTPRO Release v0.14.1 Local Execution Evidence Hardening Patch complete as local execution evidence hardening patch without tag publication and without production cutover authorization` |
| Current v0.15.0 queue | `MTPRO Release v0.15.0 Real Binance Testnet Execution MVP`；current issue `#1071`；`GH-1071-VERIFY-V0150-NETWORK-EXECUTION-EVENT-LOG`；`#1069` remains backlog / non-executable until V150-006 done |
| Active venue / products / strategies | `activeVenue == Binance`；`activeProductTypes == [spot, usdsPerpetual]`；`activeStrategies == [ema, rsi]` |
| Runtime modes | `runtimeModes == [local-dry-run, testnet-read-only-monitor, recovery-observe, production-blocked]` |
| Production default | `productionTradingEnabledByDefault == false`；这是当前 release line 的默认关闭策略，不是永久禁止实盘。 |
| Production capability | `productionCapabilityGatedNotMissing == true` |
| Historical boundary | `oldPublicReadOnlyPaperOnlyEMAOnlyIsHistorical == true` |

Production trading、production secret、production endpoint、production broker connection、testnet / production submit / cancel / replace、production OMS 和 production cutover 都没有默认启用，也没有被 v0.13.0 授权。这里的“不授权 / 默认关闭”是当前阶段的 readiness gate，不是 MTPRO 的永久产品限制。MTPRO 的长期目标仍包含受控 Live trading；后续只能在 evidence-driven readiness、signed endpoint / credential、OMS、pre-trade / post-trade risk、kill switch、reconciliation、audit trail、operator runbook 和 Human approval 全部满足后，按唯一 live queue source 逐层启用。

最新完成的 GitHub fallback queue 为 `release/v0.13.0` issues `#994..#1005`。`#994` 至 `#1004` 已完成 local evidence-driven readiness engine 的 contract、intake、synthetic provenance rejection、build pipeline、evidence-chain validate、redacted export、evidence-level diff、transaction recovery、generation ID collision-proofing、ordered CLI lifecycle 和 fixture regression gates；其中 `#1003` 是 ordered CLI lifecycle gate，`#1004` 是 local evidence fixtures / regression suite gate，`#1005` 收口 Stage Code Audit、release notes、root docs refresh 和 validation anchors。v0.13.0 construction closeout 不创建下一 Project / Issue，不授权 production cutover。

最新完成的 patch queue 为 `release/v0.14.1` issues `#1059..#1064`。`#1059` 至 `#1063` 已完成 v0.14.1 release CI / Dashboard evidence、Codable decode validation、submit evidence network guards、golden JSON contracts 和 Dashboard local artifact loading；`#1064` 收口 Stage Code Audit、release notes、latest verification、automation readiness、release publication policy 和 root docs wording。v0.14.1 patch closeout 不创建下一 Project / Issue，不授权 production cutover。

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
| v0.15.0 network execution event log | `GH-1071-VERIFY-V0150-NETWORK-EXECUTION-EVENT-LOG`；`TVM-RELEASE-V0150-NETWORK-EXECUTION-EVENT-LOG`；`V0150-006-APPEND-ONLY-NETWORK-EVENT-LOG`；`V0150-006-REQUEST-RESPONSE-IDENTITY`；`V0150-006-CHECKSUM-CHAIN`；`V0150-006-RAW-SECRET-NOT-PERSISTED`；`V0150-006-NO-PRODUCTION-CUTOVER`；`docs/contracts/release-v0.15.0-network-execution-event-log-contract.md`；`checks/verify-v0.15.0-network-execution-event-log.sh`；`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog.swift`；`testGH1071ReleaseV0150NetworkExecutionEventLogChainsRedactedArtifacts`；appendOnlyNetworkExecutionEventLog=true；redactedRequestIdentity=true；redactedResponseIdentity=true；checksumChainVerified=true；rawSecretPersisted=false；production endpoint blocked；production order remains false |
| v0.15.0 real Spot Testnet submit runtime | `GH-1068-VERIFY-V0150-REAL-SPOT-TESTNET-SUBMIT-RUNTIME`；`TVM-RELEASE-V0150-REAL-SPOT-TESTNET-SUBMIT`；`V0150-003-ORDERINTENT-TO-SIGNED-SUBMIT`；`V0150-003-REDACTED-RESPONSE-EVIDENCE`；`V0150-003-TESTNET-NETWORK-SUBMIT-PERFORMED`；`V0150-003-PRODUCTION-ENDPOINT-BLOCKED`；`V0150-003-NO-PRODUCTION-CUTOVER`；`docs/contracts/release-v0.15.0-real-spot-testnet-submit-runtime-contract.md`；`checks/verify-v0.15.0-real-spot-testnet-submit-runtime.sh`；`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetSubmitRuntime.swift`；`testGH1068ReleaseV0150SpotTestnetSubmitRuntimeProducesRedactedNetworkEvidence`；testnetNetworkSubmitPerformed=true；append-only redacted response evidence；production endpoint blocked；production order remains false |
| v0.15.0 signed request builder | `GH-1067-VERIFY-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST`；`TVM-RELEASE-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST`；`V0150-002-CREDENTIAL-REFERENCE`；`V0150-002-HMAC-SHA256-SIGNED-REQUEST`；`V0150-002-BINANCE-SPOT-TESTNET-ONLY`；`docs/contracts/release-v0.15.0-testnet-credential-provider-signed-request-builder-contract.md`；`checks/verify-v0.15.0-testnet-credential-signed-request.sh`；HMAC signed request construction evidence only；production secret auto-read blocked；production endpoint blocked；no network action |
| v0.15.0 contract / preflight | `GH-1066-VERIFY-V0150-CONTRACT-PREFLIGHT`；`TVM-RELEASE-V0150-CONTRACT-PREFLIGHT`；`V0150-001-RELEASE-CONTRACT`；`V0150-001-V0141-PREFLIGHT-GATE`；`V0150-001-BINANCE-SPOT-TESTNET-ONLY`；`docs/contracts/release-v0.15.0-real-binance-spot-testnet-execution-mvp-contract.md`；`checks/verify-v0.15.0-contract-preflight.sh`；v0.15.0 is Binance Spot Testnet only；production trading disabled by default；#1066 closed / done before #1067 |
| v0.14.1 patch | `GH-1064-VERIFY-V0141-PATCH-AUDIT-RELEASE-NOTES`；`TVM-RELEASE-V0141-PATCH-AUDIT-RELEASE-NOTES`；`V0141-006-PATCH-AUDIT`；`docs/audit/mtpro-release-v0.14.1-local-execution-evidence-hardening-patch-stage-code-audit.md`；`docs/release/mtpro-release-v0.14.1-local-execution-evidence-hardening-patch-notes.md`；`checks/verify-v0.14.1-patch-audit-release-notes.sh`；patch closeout 不创建 tag / GitHub Release；不授权 production cutover |
| v0.13.0 | `GH-1005-VERIFY-V0130-STAGE-AUDIT-RELEASE-DOCS`；`TVM-RELEASE-V0130-STAGE-AUDIT-RELEASE-DOCS`；`V0130-012-STAGE-CODE-AUDIT`；`docs/audit/mtpro-release-v0.13.0-local-evidence-driven-readiness-engine-stage-code-audit.md`；`docs/release/mtpro-release-v0.13.0-local-evidence-driven-readiness-engine-notes.md`；`docs/contracts/release-v0.13.0-local-evidence-driven-readiness-engine-contract.md`；`checks/verify-v0.13.0.sh`；construction closeout 不创建 tag / GitHub Release；不授权 production cutover |
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
