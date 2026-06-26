# GOAL.md

本文档是 MTPRO 的 Project Charter，不是完整蓝图，不是工程模块地图，不是施工计划。

它只回答四个问题：为什么建、服务谁、当前阶段硬边界 / 永久硬边界是什么、怎样判断项目仍然朝正确方向推进。完整产品 / 系统 / 设计蓝图见 `BLUEPRINT.md`；当前施工阶段、目标切片和进度条见 `docs/roadmap.md`。

## 项目使命

MTPRO 的目标是构建一个 local-first 的 macOS 原生专业交易工作台。它先以 Research -> Backtest -> Report -> Paper 建立可追溯、可回放、可验证的交易证据链，再逐步演进为支持 Live trading、实盘监控、实盘执行控制、实盘风险控制和实盘审计 / 事故回放 / 停机控制的专业版本产品。

MTPRO 不是 NautilusTrader 的 Swift 包装，也不是 `macos-trader` 的整仓迁移。它把参考项目和既有产品经验收敛成自己的 SwiftPM-first、macOS-native、evidence-first、local-first 工作台。

## 服务对象

MTPRO 首先服务个人专业交易者 / 独立策略研究者：在本机 Mac 上研究策略、回测策略、生成报告，使用 Binance public market data 建立可追溯 evidence chain，并在不触碰真实交易的前提下观察 Backtest / Paper / Risk / Portfolio consistency。

## 核心承诺

| 承诺 | 含义 |
| --- | --- |
| Local-first | 核心研究、回测、Paper、报告和审计优先在本地工作台闭环完成。 |
| Evidence chain first | 工作台导航以 Research -> Backtest -> Report -> Paper -> Events 为主，不以交易按钮为中心。 |
| 少量可解释策略优先 | 当前 active strategy scope 是 EMA + RSI；其他策略只能作为 future candidate。 |
| Binance boundary | Binance 是当前 active venue；production secret / endpoint / broker / real order 当前默认关闭，但不是永久禁止；后续只能按 readiness gates 逐层放权。 |
| Paper / Live 隔离 | Paper 证据不能被解释为真实订单、真实成交或 broker action。 |
| Live gated | Live trading 是最终产品目标的一部分，但只能在独立 Human decision、独立 Project Definition、signed endpoint / broker / risk / operations gates 之后进入执行范围。 |

因此，`productionTradingEnabledByDefault == false` 表示当前版本线默认 fail-closed；它不是“永远禁止实盘”。MTPRO 的 live 能力路线是先完成本地 evidence-driven readiness，再进入 testnet closed loop、production read-only / signed endpoint、shadow live、controlled canary，最后才可能由 Human approval 授权真实生产交易。

## 当前成功标准

- `BLUEPRINT.md` 保持最终产品 / 系统 / 设计蓝图清楚。
- `architecture.md` 保持工程模块地图、边界、数据流和不变量清楚。
- `docs/roadmap.md` 保持已批准阶段、目标切片和两层进度条清楚。
- Linear / PR / Stage Code Audit evidence 能追溯每个已完成建设阶段。
- SwiftPM baseline、Dashboard smoke 和统一验证入口 `bash checks/run.sh` 持续可运行。
- 正式开发只从唯一 live queue source 中的 configured executable issue 进入。
- Project closure 后必须完成 Stage Code Audit Report 和 Root Docs Refresh Gate closure。

## 当前目标进度

MTPRO 采用两层进度口径：Current Foundation Progress 和 Final Product Goal Progress。截至 2026-06-14：

```text
Current Foundation Progress: 4 / 4 (100%)
Foundation Progress: [##########] 100%

Final Product Goal Progress: 9 / 9 (100%)
Final Product Progress: [##########] 100%

Engine Maturity Roadmap Progress: 4 / 4 (100%)
Engine Maturity Progress: [##########] 100%
```

Current Foundation 已完成 Research / Backtest / Report / Paper readiness、Paper-only execution evidence、Workbench evidence navigation、本地控制壳和 market data replay operations。

Final Product slice anchors：实盘交易基础边界、实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制。Final Product 已完成全部 9 项目标切片；第 5 至第 9 项只代表 boundary、contract、blocked evidence 或 read-model-only evidence surface，不代表真实 Live trading、signed/account endpoint、broker adapter、real order lifecycle、production OMS、Live PRO Console command、trading button 或 production operations 已实现或获授权。

完整 9 项目标切片、状态和证据口径见 `docs/roadmap.md`。`GOAL.md` 不复制维护详细进度表。

## 当前模块成熟度

| 口径 | 当前结论 |
| --- | --- |
| Engine maturity | L1 Paper Runtime、L1.5 Data Catalog、L2 Simulated Exchange、L2+ Workbench、L3 read-model-only readiness、module boundary / target graph / Core envelope retirement 均 Done |
| L4 / production readiness | `L4 Live Production / Trading Commands v1 complete with no-default-production-trading policy`；Production Cutover Readiness / Real Broker Enablement Gate Done，但只代表 readiness-only / no-real-broker-authorization，不授权真实 broker |
| Releases | `MTPRO Release v0.1.0` Done / Binance + EMA runtime validation / production disabled by default；`MTPRO Release v0.2.0` Spot + USDⓈ-M Perpetual + EMA/RSI Done；`MTPRO Release v0.3.0 Testnet / Shadow Production Rehearsal` Done；`MTPRO Release v0.4.0 Unified Runtime Rehearsal Pipeline` Done；`MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge` Done；`MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening` Done；`MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity` Done；`MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring` Done；`MTPRO Release v0.9.0 Testnet No-order Observability` Done；`MTPRO Release v0.10.0 Production Cutover Readiness Gate` Done / readiness assessment only / no production cutover authorization；`MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening` Done / local readiness evidence runtime / no production cutover authorization；`MTPRO Release v0.12.0 Readiness Assessment Sessions` Done / local redacted readiness assessment evidence / no production cutover authorization；`MTPRO Release v0.12.1 Readiness Assessment Provenance Hardening Patch` Done / no tag or GitHub Release publication in patch closeout / no production cutover authorization；`MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine` Done / real local evidence root intake、validation、export、diff、recovery、fixtures and audit closeout / no tag or GitHub Release publication in construction closeout / no production cutover authorization；`MTPRO Release v0.14.1 Local Execution Evidence Hardening Patch` Done / local execution evidence chain wording、decode、JSON、Dashboard artifact、audit and release notes closeout / no tag or GitHub Release publication in patch closeout / no production cutover authorization；`MTPRO Release v0.15.0 Real Binance Testnet Execution MVP` Done / stable GitHub Release published at `https://github.com/atxinbao/MTPRO/releases/tag/v0.15.0` / tag peeled commit `1590b6c40e6ca7887cff0ca59b2f74e4fe7e3ece` / publication timestamp `2026-06-23T01:26:30Z` / no production cutover authorization；`MTPRO Release v0.16.0 Binance Spot Testnet Operator Execution Beta` Done / #1101..#1112 closed / done / `GH-1112-VERIFY-V0160-STAGE-AUDIT-RELEASE-DOCS` / no tag or GitHub Release publication in construction closeout / no production cutover authorization；production trading disabled by default |
| Latest v0.15.1 patch queue | `MTPRO Release v0.15.1 Real Testnet Execution Hardening Patch` complete as GitHub fallback queue；#1094 release fact sync guard closed / done；#1095 injected transport wording guard closed / done；#1096 concrete URLSession Spot Testnet transport closed / done；#1097 CLI guarded runtime wiring closed / done；#1098 runtime internal gate closed / done；#1099 deterministic client order identity chain closed / done；#1100 codable decode closeout closed / done；release/v0.15.1 queue closed |
| Latest v0.16.0 operator beta queue | `MTPRO Release v0.16.0 Binance Spot Testnet Operator Execution Beta` complete as GitHub fallback queue；#1101..#1112 closed / done；#1111 manual testnet validation workflow closed / done；#1112 audit / release docs closeout closed / done and uses `GH-1112-VERIFY-V0160-STAGE-AUDIT-RELEASE-DOCS`, `TVM-RELEASE-V0160-STAGE-AUDIT-RELEASE-DOCS`, `V0160-012-STAGE-CODE-AUDIT`, `V0160-012-RELEASE-NOTES`, `V0160-012-OPERATOR-RUNBOOK`, `V0160-012-VALIDATION-MATRIX`, `V0160-012-STALE-WORDING-GUARD`, `V0160-012-NO-PRODUCTION-CUTOVER` and `V0160-012-NO-TAG-OR-RELEASE-PUBLICATION`；construction closeout does not create tag / GitHub Release；production cutover not authorized |

v0.16.0 queue guard phrases：#1101 contract / preflight closed / done；#1102 operator run model closed / done；#1103 CLI submit flow closed / done；#1104 CLI cancel flow closed / done；#1105 signed order status query closed / done；#1106 local execution artifact store closed / done；#1107 OMS observed status reconciliation closed / done；#1108 Dashboard artifact-backed execution view closed / done；#1109 failure recovery workflow closed / done；#1110 beta safety guards closed / done；#1111 manual testnet validation workflow closed / done；#1112 audit / release docs closeout closed / done。
| Current maturity statement | `MTPRO Release v0.16.0 Binance Spot Testnet Operator Execution Beta complete as construction closeout with production trading disabled by default and production cutover not authorized` |

Anchor facts retained for readiness guards:

- Core Envelope Retirement / Real Module Ownership Completion 的 post-audit hardening addendum 已在 PR #448 后完成最终只读审计：production executable `try!` = 0，`@unchecked Sendable` = 0，`bash checks/run.sh` 通过。
- `MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1` 已完成 readiness-only gate；不授权真实 broker、real order、production trading、secret read、production endpoint、broker adapter、LiveExecutionAdapter、production OMS、trading button、live command 或 order form。
- Historical maturity statement retained for release v0.6.0：`MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening complete with production trading disabled by default`。
- Historical maturity statement retained for release v0.7.0：`MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity complete with production trading disabled by default`。
- Historical maturity statement retained for release v0.8.0：`MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring complete with production trading disabled by default`。
- Historical maturity statement retained for release v0.9.0：`MTPRO Release v0.9.0 Testnet No-order Observability complete with production trading disabled by default`。
- Historical maturity statement retained for release v0.11.0：`MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening complete with production trading disabled by default and production cutover not authorized`。
- Historical patch statement retained for release v0.12.1：`MTPRO Release v0.12.1 Readiness Assessment Provenance Hardening Patch complete as patch closeout without tag publication and without production cutover authorization`。
- Historical maturity statement retained for release v0.13.0：`MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine complete with production trading disabled by default and production cutover not authorized`。
- Latest maturity statement retained for release v0.15.0：`MTPRO Release v0.15.0 Real Binance Testnet Execution MVP complete and published as stable GitHub Release with production trading disabled by default and production cutover not authorized`。
- Latest patch statement retained for release v0.15.1：`MTPRO Release v0.15.1 Real Testnet Execution Hardening Patch complete as real testnet execution hardening patch without tag publication and without production cutover authorization`。
- Latest v0.16.0 construction statement retained：`MTPRO Release v0.16.0 Binance Spot Testnet Operator Execution Beta complete as construction closeout without tag publication and without production cutover authorization`。
- 最新完成的 GitHub fallback `release/v0.13.0` queue 为 #994 至 #1005：#994 contract gate、#995 local evidence intake model、#996 synthetic provenance rejection、#997 build pipeline、#998 evidence-chain validate、#999 redacted audit export package、#1000 evidence-level diff / compare、#1001 transaction recovery forensic snapshot、#1002 generation ID collision-proofing、#1003 ordered CLI execution lifecycle、#1004 local evidence fixtures / regression suite 和 #1005 stage audit / release docs closeout 均已完成或由本 closeout PR 收口。Release v0.12.0 completion、v0.12.1 patch closeout 和 v0.13.0 local evidence-driven readiness engine 不授权 strategy 直连 ExecutionClient、broker command、production OMS、trading button、Live PRO Console production command、live command、real broker、real order、testnet order routing、production cutover 或任何 production trading。
- 最新完成的 GitHub fallback `release/v0.14.1` patch queue 为 #1059 至 #1064：#1059 release CI / Dashboard evidence、#1060 Codable decode validation、#1061 submit evidence network guards、#1062 golden JSON contracts、#1063 Dashboard local artifact loading 和 #1064 patch audit / release notes closeout 均已完成或由本 closeout PR 收口。v0.14.1 的工程语义是 local execution evidence chain / testnet evidence only，不是真实 signed Binance testnet execution release，不代表真实 Binance testnet order execution，不授权 production cutover 或任何 production trading。
- 已完成的 GitHub fallback `release/v0.15.0` queue 为 #1065 至 #1076：#1066 使用 `GH-1066-VERIFY-V0150-CONTRACT-PREFLIGHT` 定义 release contract、v0.14.1 preflight gate、Binance Spot Testnet only boundary 和 no-production fail-closed gate；#1067 至 #1076 已完成 signed request、guarded submit / cancel / cancel-replace、append-only event log、OMS reconciliation、CLI operator flow、Dashboard read-only status、failure simulation 和 release CI / manual workflow / audit evidence。后续独立 Release Publication Gate 已发布 `v0.15.0` stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.15.0`，tag peeled commit `1590b6c40e6ca7887cff0ca59b2f74e4fe7e3ece`，publication timestamp `2026-06-23T01:26:30Z`。v0.15.0 publication 不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。
- 已完成的 GitHub fallback `release/v0.15.1` queue 为 #1094 至 #1100：#1094 使用 `GH-1094-VERIFY-V0151-V0150-RELEASE-FACT-SYNC` 同步 v0.15.0 publication facts 并已 closed / done；#1095 injected transport wording guard is closed / done，并使用 `GH-1095-VERIFY-V0151-INJECTED-TRANSPORT-WORDING` 明确 v0.15.0 是 signed execution runtime contracts + injected Spot Testnet transport protocol evidence，不是仓库内置 URLSession runner、CLI 默认真实联网 runner 或 production broker connector；#1096 concrete URLSession Spot Testnet transport 已 closed / done，使用 `GH-1096-VERIFY-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT` 增加只允许 `testnet.binance.vision` `/api/v3/order` 的 submit / cancel URLSession transport、production host fail-closed、response-sha256 脱敏和 no secret persistence guard；#1097 CLI guarded runtime wiring 已 closed / done，使用 `GH-1097-VERIFY-V0151-CLI-TESTNET-EXECUTION-RUNTIME` 将 `mtpro testnet-execution` 的 submit / cancel / cancel-replace 接入 v0.15 guarded runtime、testnet-only credential provider、显式 operator confirmation、redacted output、run id、artifact path 和 checksum；#1098 runtime internal gate closed / done，使用 `GH-1098-VERIFY-V0151-RUNTIME-INTERNAL-GATES` 将 RiskEngine / kill switch / no-trade / operator confirmation gate 放入 submit / cancel / cancel-replace runtime 内部，blocked gate 必须在 transport invocation 前 fail-closed；#1099 deterministic client order identity chain closed / done，使用 `GH-1099-VERIFY-V0151-CLIENT-ORDER-IDENTITY-CHAIN` 让 submit evidence 生成 deterministic redacted `newClientOrderId` reference，并让 cancel 从 submit evidence 派生短生命周期 identity，拒绝 raw / untracked order id；#1100 codable decode closeout closed / done，使用 `GH-1100-VERIFY-V0151-CODABLE-DECODE-CLOSEOUT` 给 submit / cancel / cancel-replace evidence、network event log、OMS snapshot 和 reconciliation report 增加 decode-time validation，损坏 JSON、checksum mismatch、production host mutation 和 production boundary mutation 必须 fail-closed。release/v0.15.1 queue closed。
- #1098 retained validation anchors: `GH-1098-VERIFY-V0151-RUNTIME-INTERNAL-GATES`、`TVM-RELEASE-V0151-RUNTIME-INTERNAL-GATES`、`V0151-005-RISKENGINE-GATE-IN-RUNTIME`、`V0151-005-KILL-SWITCH-GATE-IN-RUNTIME`、`V0151-005-NO-TRADE-GATE-IN-RUNTIME`、`V0151-005-OPERATOR-CONFIRMATION-IN-RUNTIME`、`V0151-005-TRANSPORT-NOT-INVOKED-WHEN-BLOCKED`、`V0151-005-NO-PRODUCTION-CUTOVER`。
- #1099 validation anchors: `GH-1099-VERIFY-V0151-CLIENT-ORDER-IDENTITY-CHAIN`、`TVM-RELEASE-V0151-CLIENT-ORDER-IDENTITY-CHAIN`、`V0151-006-DETERMINISTIC-NEW-CLIENT-ORDER-ID`、`V0151-006-REDACTED-CLIENT-ORDER-REFERENCE`、`V0151-006-SUBMIT-TO-CANCEL-IDENTITY-HANDOFF`、`V0151-006-RAW-UNTRACKED-ORDER-ID-REJECTED`、`V0151-006-NO-PRODUCTION-CUTOVER`。
- #1100 validation anchors: `GH-1100-VERIFY-V0151-CODABLE-DECODE-CLOSEOUT`、`TVM-RELEASE-V0151-CODABLE-DECODE-CLOSEOUT`、`V0151-007-CODABLE-DECODE-VALIDATION`、`V0151-007-CORRUPTED-JSON-FAILS-CLOSED`、`V0151-007-CHECKSUM-MISMATCH-FAILS-CLOSED`、`V0151-007-PRODUCTION-HOST-MUTATION-REJECTED`、`V0151-007-NO-PRODUCTION-CUTOVER`。
- #1101 validation anchors: `GH-1101-VERIFY-V0160-OPERATOR-BETA-CONTRACT`、`TVM-RELEASE-V0160-OPERATOR-BETA-CONTRACT`、`V0160-001-V0151-PREFLIGHT-GATE`、`V0160-001-BINANCE-SPOT-TESTNET-ONLY`、`V0160-001-OPERATOR-CONFIRMATION-REQUIRED`、`V0160-001-REDACTED-EVIDENCE-REQUIRED`、`V0160-001-QUEUE-ORDER`、`V0160-001-NO-PRODUCTION-CUTOVER`。
- #1102 validation anchors: `GH-1102-VERIFY-V0160-OPERATOR-RUN-MODEL`、`TVM-RELEASE-V0160-OPERATOR-RUN-MODEL`、`V0160-002-RUN-ID-LIFECYCLE`、`V0160-002-ACTION-SEQUENCE`、`V0160-002-ARTIFACT-LINKAGE`、`V0160-002-INVALID-TRANSITION-FAILS-CLOSED`、`V0160-002-REDACTED-METADATA`、`V0160-002-NO-NETWORK-BY-THIS-ISSUE`、`V0160-002-NO-PRODUCTION-CUTOVER`。
- #1103 validation anchors: `GH-1103-VERIFY-V0160-CLI-SUBMIT-FLOW`、`TVM-RELEASE-V0160-CLI-SUBMIT-FLOW`、`V0160-003-STABLE-CLI-SUBMIT`、`V0160-003-V0151-RUNTIME-DELEGATION`、`V0160-003-EXPLICIT-OPERATOR-CONFIRMATION`、`V0160-003-TESTNET-CREDENTIAL-PROFILE`、`V0160-003-REDACTED-OUTPUT-ARTIFACT-CHECKSUM`、`V0160-003-MISSING-GATE-CREDENTIAL-CONFIRMATION-FAILS-CLOSED`、`V0160-003-NO-PRODUCTION-CUTOVER`。
- #1104 validation anchors: `GH-1104-VERIFY-V0160-CLI-CANCEL-FLOW`、`TVM-RELEASE-V0160-CLI-CANCEL-FLOW`、`V0160-004-STABLE-CLI-CANCEL`、`V0160-004-SUBMIT-ARTIFACT-IDENTITY`、`V0160-004-V0151-RUNTIME-DELEGATION`、`V0160-004-EXPLICIT-OPERATOR-CONFIRMATION`、`V0160-004-TESTNET-CREDENTIAL-PROFILE`、`V0160-004-REDACTED-ORDER-REFERENCE`、`V0160-004-APPEND-ONLY-EVENT-EVIDENCE`、`V0160-004-MISSING-PRIOR-ARTIFACT-FAILS-CLOSED`、`V0160-004-NO-PRODUCTION-CUTOVER`。
- #1105 validation anchors: `GH-1105-VERIFY-V0160-SIGNED-ORDER-STATUS-QUERY`、`TVM-RELEASE-V0160-SIGNED-ORDER-STATUS-QUERY`、`V0160-005-SIGNED-GET-ORDER-STATUS`、`V0160-005-TESTNET-ENDPOINT-ALLOWLIST`、`V0160-005-REDACTED-REQUEST-RESPONSE-EVIDENCE`、`V0160-005-NO-RAW-SECRET-PERSISTENCE`、`V0160-005-PRODUCTION-HOST-REJECTED`、`V0160-005-NO-PRODUCTION-CUTOVER`。

## 当前阶段硬边界与永久硬边界

下列前五项是当前 release stage 的默认关闭能力，不是 MTPRO 永久产品限制。它们只有在独立 Project Definition、唯一 live queue source、Parent Codex preflight、credential / signed endpoint / OMS / risk / reconciliation / audit / rollback gates 和 Human approval 全部满足后，才能按版本路线逐层放开。

- 当前阶段不实现真实 Live trading。
- 当前阶段不接 signed endpoint、account endpoint 或 listenKey。
- 当前阶段不连接 broker。
- 当前阶段不提交、撤销、替换真实订单。
- 当前阶段不实现真实账户余额、broker position sync 或 OMS。

以下是长期产品边界：

- 不迁移 `macos-trader` 整仓代码。
- 不引入 NautilusTrader 作为运行依赖。
- 不把 `BLUEPRINT.md` 中的 Future Construction Zones / 未来建设区自动转成当前 execution scope。

## 非授权边界

`GOAL.md` 不创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动额外调度服务，不授权 future capability 进入当前执行 scope。
