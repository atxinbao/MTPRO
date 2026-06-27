# BLUEPRINT.md

日期：2026-05-20

执行者：Human + `@000 / AIE`

## 定位

本文档是 MTPRO 的 canonical Root / Complete Blueprint：Root Blueprint 负责项目总览、默认读取顺序和 Current / Future 边界；Complete Blueprint 负责 Product Blueprint、Architecture Blueprint、Design Blueprint、Infrastructure Blueprint、Trading Capability Blueprint、Live Gate Blueprint 和 Blueprint -> Architecture -> Roadmap Handoff。

蓝图本体只维护在根目录 `BLUEPRINT.md`。不再维护 `docs/design/` 下的兼容蓝图入口，避免双写漂移。

本文档不授权执行，不推进 `Todo`，不启动额外调度 / 图谱服务，不写业务代码。只有 Linear live-read 中唯一 configured executable issue 可以进入正式开发。

## 默认读取顺序

1. `README.md`
2. `AGENTS.md`
3. `GOAL.md`
4. `BLUEPRINT.md`
5. `environment.md`
6. `architecture.md`
7. `docs/roadmap.md`
8. `docs/domain/context.md`
9. `docs/validation/latest-verification-summary.md`

执行或验证时，再按当前 issue scope 读取 `docs/contracts/`、`docs/product/`、`docs/validation/`、`docs/automation/agent-engineering-practices.md`、Stage Code Audit Report 和 issue body。完整 `verification.md` 只在审计、追溯或 debug 时读取。

## Root Docs Responsibility Contract

| 文件 | 只回答 | 不负责 |
| --- | --- | --- |
| `GOAL.md` | 为什么建、服务谁、硬边界、成功标准 | 不展开完整系统结构，不决定下一阶段 Project |
| `BLUEPRINT.md` | 最终产品要建成什么，Product / Architecture / Design Blueprint 如何组织，Current / Future 如何分界 | 不记录完成进度条，不替代 `docs/roadmap.md`，不授权 Linear execution |
| `environment.md` | 当前环境、验证入口、外部系统使用边界和禁区 | 不定义工程模块，不决定施工顺序 |
| `architecture.md` | Engineering Module Map / 工程模块地图：承接 `BLUEPRINT.md`，把蓝图翻译为工程模块、模块边界、数据流、接口、约束和技术分层 | 不重新定义产品目标，不记录 Stage Audit 流水账 |
| `docs/roadmap.md` | 根据蓝图和工程模块定义施工顺序、当前已批准阶段、目标切片、Project closure、下一步 planning handoff | 不替代蓝图，不创建 Linear，不推进 `Todo` |

`architecture.md`、`environment.md` 是根目录高权重承接文档，`docs/roadmap.md` 是施工路线文档。目标冲突先看 `GOAL.md`；终局设计和 Future Construction Zones / 未来建设区先看 `BLUEPRINT.md`；施工进度先看 `docs/roadmap.md`。

## 来源

| 来源层 | 代表文件 / 目录 | 用途 |
| --- | --- | --- |
| Root docs | `GOAL.md`、`environment.md`、`architecture.md`、`docs/roadmap.md` | Project Charter、环境边界、工程模块地图和施工路线 |
| Domain / practices | `docs/domain/context.md`、Agent Engineering Practices | shared language、执行纪律、验证约定 |
| Reference / delta | `docs/reference/nautilus-trader/`、Root Docs Delta Proposal | NautilusTrader 参考研究和 delta proposal |
| Product / design | `docs/product/`、`docs/design/` | Product surface、interaction model、Workbench dashboard、Live readiness、screen layout 和 visual rules |
| Planning / audit | `docs/planning/projects/`、`docs/audit/`、`docs/validation/trading-validation-matrix.md` | Project Planning Record、Stage Code Audit Reports 和交易语义验证证据 |

保留的机器锚点：`docs/domain/context.md`；Agent Engineering Practices；Root Docs Delta Proposal；`docs/audit/mtpro-l4-live-production-trading-commands-v1-stage-code-audit.md`；`docs/audit/mtpro-production-cutover-readiness-real-broker-enablement-gate-v1-stage-code-audit.md`；`docs/audit/mtpro-release-v0.1.0-binance-ema-runtime-stage-code-audit.md`；`docs/product/mtpro-paper-trading-runtime-foundation-blueprint-v1.md`；`docs/product/mtpro-core-engine-architecture-module-maturity-map-v1.md`；`docs/product/mtpro-live-readiness-roadmap-v1.md`。

## Blueprint Design Lenses / 蓝图设计视角

| 视角 | 需要回答 | 落到本文档 |
| --- | --- | --- |
| Product / 产品 | 服务谁、解决什么问题、主路径是什么、为什么用户可信 | Product Blueprint、Final Product Goal Slices、Product Workflow Blueprint |
| Architecture / 架构 | 什么系统能力支撑最终产品、模块怎么分层、Paper / Live 怎么隔离 | Architecture Blueprint、Infrastructure Blueprint、Trading Capability Blueprint、Live Gate Blueprint |
| Design / 工作台设计 | 用户在界面中看到什么、怎么理解状态、怎么操作、如何避免误触实盘 | Design Blueprint、Current / Future Boundary、Live Gate Blueprint |

Product 定义服务对象和工作流；Architecture 定义系统承载能力；Design 定义用户如何看见 evidence、状态、操作和禁区。Goal / Blueprint / Engineering Module / Roadmap 分工明确；Product / Architecture / Design Blueprint 三线明确。

## Product Blueprint / 产品蓝图

MTPRO 最终要成为一个 local-first 的 macOS 原生专业交易工作台。它先完成 Research -> Backtest -> Report -> Paper 的本地证据链，再演进为支持 Live trading、实盘监控、实盘执行控制、实盘风险控制和实盘审计 / 事故回放 / 停机控制的专业版本产品。

产品可信度来自 evidence chain：数据来源、策略信号、回测结果、Paper 行为、风险证据、组合变化、事件时间线和报告 artifact 都必须可追溯、可回放、可验证。Future Live 必须作为独立 Future Construction Zones / 未来建设区进入，不能从 paper-only 能力偷渡。

## Final Product Goal Slices

| # | 目标切片 | 当前状态 |
| --- | --- | --- |
| 1 | Research / Backtest / Report foundation | Complete |
| 2 | Paper execution foundation | Complete |
| 3 | Workbench evidence navigation and local control shell | Complete |
| 4 | Market data replay operations | Complete |
| 5 | 实盘交易基础边界 | Complete / boundary + blocked evidence |
| 6 | 实盘监控台 | Complete / read-model-only evidence surface |
| 7 | 实盘执行控制 | Complete / contract + blocked evidence |
| 8 | 实盘风险控制 | Complete / contract + blocked evidence |
| 9 | 实盘审计 / 事故回放 / 停机控制 | Complete / contract + blocked evidence |

Current Foundation Progress 已完成 4 / 4；Final Product Goal Progress 当前为 9 / 9。完整进度口径由 `docs/roadmap.md` 维护，蓝图只定义目标结构。

## Target Users / Jobs

| 用户 | 核心任务 | MTPRO 应提供 |
| --- | --- | --- |
| 个人专业交易者 / 独立策略研究者 | 用 Binance public market data 研究策略和市场状态 | Research / Backtest / Report / Paper evidence 工作台 |
| 策略验证用户 | 确认 backtest、paper、risk、cost、portfolio evidence 是否一致 | trading validation matrix、report artifact、event timeline |
| Paper readiness 用户 | 在不触碰真实交易的前提下观察 paper workflow | paper-only session、order intent、simulated fill、portfolio projection |
| 未来实盘准备用户 | 判断何时可以独立进入 Live 规划 | Live future zone、blocked gates、禁区说明和风险条件 |

## Complete Capability Map

当前 foundation 已覆盖 Binance public read-only ingest、Event Log / Replay、Research / Backtest / Report、Trading Validation、Paper Session Runtime、Paper Execution Workflow、Dashboard / Workbench、Market Data Replay Operations、Portfolio / Risk paper-only evidence。Release line 已推进到 v0.15.0 Real Binance Testnet Execution MVP stable GitHub Release，最新 hardening patch queue 为 MTPRO Release v0.15.1 Real Testnet Execution Hardening Patch closed / done；production trading disabled by default，production cutover not authorized。

Release v0.14.1 patch line anchor retained：MTPRO Release v0.14.1 Local Execution Evidence Hardening Patch 已完成 local execution evidence chain wording、decode validation、network-attempt evidence guard、golden JSON contract、Dashboard local artifact loading、Stage Code Audit 和 release notes closeout。它是 local execution evidence chain / testnet evidence only，不是真实 signed Binance testnet execution release，不代表真实 Binance testnet order execution，不新增 runtime pipeline，不创建 tag / GitHub Release，不授权 production cutover。

Release v0.15.0 publication anchor：`MTPRO Release v0.15.0 Real Binance Testnet Execution MVP` 已完成 #1065..#1076，并通过独立 Release Publication Gate 发布 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.15.0`，tag peeled commit `1590b6c40e6ca7887cff0ca59b2f74e4fe7e3ece`，publication timestamp `2026-06-23T01:26:30Z`。v0.15.0 completion 固定 Binance Spot Testnet only、productionTradingEnabledByDefault=false、operatorConfirmationRequired=true、testnetEndpointAllowlistOnly=true、guarded submit / cancel / cancel-replace evidence、append-only network event log、OMS state sync / reconciliation、CLI operator flow、Dashboard read-only status 和 failure simulation。该 publication 不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。

Release v0.15.1 queue anchor：`MTPRO Release v0.15.1 Real Testnet Execution Hardening Patch` 已由 GitHub fallback issues #1094..#1100 收口。#1094 使用 `GH-1094-VERIFY-V0151-V0150-RELEASE-FACT-SYNC` 同步 v0.15.0 已发布事实并已 closed / done；#1095 使用 `GH-1095-VERIFY-V0151-INJECTED-TRANSPORT-WORDING` 固定 injected transport wording 并已 closed / done：v0.15.0 提供 signed execution runtime contracts、injected Spot Testnet transport protocol evidence、mock/manual proof split 和 redacted artifacts，不表示内置 URLSession runner、CLI 默认真实联网 runner 或 production broker connector；#1096 已 closed / done，使用 `GH-1096-VERIFY-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT` 增加 concrete URLSession Spot Testnet transport guard，只允许 `https://testnet.binance.vision/api/v3/order` submit / cancel request、production host fail-closed、response-sha256 脱敏和 no secret persistence；#1097 已 closed / done，使用 `GH-1097-VERIFY-V0151-CLI-TESTNET-EXECUTION-RUNTIME` 增加 CLI guarded runtime wiring：`mtpro testnet-execution` submit / cancel / cancel-replace 均调用 v0.15 guarded runtime，credential provider 固定 `testnet-env`，缺少 testnet credential 或 operator confirmation 时 fail-closed，输出只返回 redacted run id、artifact path 和 checksum；#1098 已 closed / done，使用 `GH-1098-VERIFY-V0151-RUNTIME-INTERNAL-GATES` 增加 runtime internal gate：submit / cancel / cancel-replace runtime 在触达 transport 前重新检查 RiskEngine allow、kill switch inactive、no-trade inactive 和 operator confirmation，rejected risk、active kill switch、active no-trade 或缺失确认必须在 transport invocation 前 fail-closed；#1099 已 closed / done，使用 `GH-1099-VERIFY-V0151-CLIENT-ORDER-IDENTITY-CHAIN` 增加 deterministic client order identity chain：submit evidence 生成 deterministic redacted `newClientOrderId` reference，cancel identity 从 submit evidence 派生短生命周期 material，raw / untracked order id fail-closed；#1100 codable decode closeout closed / done，使用 `GH-1100-VERIFY-V0151-CODABLE-DECODE-CLOSEOUT` 给 submit / cancel / cancel-replace evidence、network event log、OMS snapshot 和 reconciliation report 增加 decode-time validation，损坏 JSON、checksum mismatch、production host mutation 和 production boundary mutation 必须 fail-closed。release/v0.15.1 queue closed。该 hardening queue 不创建下一 Project / Issue，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。

Release v0.15.1 #1098 retained validation anchors：`GH-1098-VERIFY-V0151-RUNTIME-INTERNAL-GATES`、`TVM-RELEASE-V0151-RUNTIME-INTERNAL-GATES`、`V0151-005-RISKENGINE-GATE-IN-RUNTIME`、`V0151-005-KILL-SWITCH-GATE-IN-RUNTIME`、`V0151-005-NO-TRADE-GATE-IN-RUNTIME`、`V0151-005-OPERATOR-CONFIRMATION-IN-RUNTIME`、`V0151-005-TRANSPORT-NOT-INVOKED-WHEN-BLOCKED`、`V0151-005-NO-PRODUCTION-CUTOVER`。

Release v0.15.1 #1099 validation anchors：`GH-1099-VERIFY-V0151-CLIENT-ORDER-IDENTITY-CHAIN`、`TVM-RELEASE-V0151-CLIENT-ORDER-IDENTITY-CHAIN`、`V0151-006-DETERMINISTIC-NEW-CLIENT-ORDER-ID`、`V0151-006-REDACTED-CLIENT-ORDER-REFERENCE`、`V0151-006-SUBMIT-TO-CANCEL-IDENTITY-HANDOFF`、`V0151-006-RAW-UNTRACKED-ORDER-ID-REJECTED`、`V0151-006-NO-PRODUCTION-CUTOVER`。

Release v0.15.1 #1100 validation anchors：`GH-1100-VERIFY-V0151-CODABLE-DECODE-CLOSEOUT`、`TVM-RELEASE-V0151-CODABLE-DECODE-CLOSEOUT`、`V0151-007-CODABLE-DECODE-VALIDATION`、`V0151-007-CORRUPTED-JSON-FAILS-CLOSED`、`V0151-007-CHECKSUM-MISMATCH-FAILS-CLOSED`、`V0151-007-PRODUCTION-HOST-MUTATION-REJECTED`、`V0151-007-NO-PRODUCTION-CUTOVER`。

Release v0.16.0 operator beta queue anchor：`MTPRO Release v0.16.0 Binance Spot Testnet Operator Execution Beta` 使用 GitHub fallback issues #1101..#1112，现已 complete / closed / done。#1101..#1111 分别固定 operator beta contract、run model、CLI submit、CLI cancel、signed status query、local artifact store、OMS observed-status reconciliation、Dashboard read-only artifact view、failure recovery、beta safety guards 和 manual testnet validation workflow。#1112 使用 `GH-1112-VERIFY-V0160-STAGE-AUDIT-RELEASE-DOCS`、`TVM-RELEASE-V0160-STAGE-AUDIT-RELEASE-DOCS`、`V0160-012-STAGE-CODE-AUDIT`、`V0160-012-RELEASE-NOTES`、`V0160-012-OPERATOR-RUNBOOK`、`V0160-012-VALIDATION-MATRIX`、`V0160-012-STALE-WORDING-GUARD`、`V0160-012-NO-PRODUCTION-CUTOVER` 和 `V0160-012-NO-TAG-OR-RELEASE-PUBLICATION` 收口 Stage Code Audit、release notes、operator runbook、validation matrix 和 stale wording guard。v0.16.0 construction closeout 本身不创建 tag / GitHub Release；随后独立 Release Publication Gate 已发布 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.16.0`，tag peeled commit：`28779236262bd7ffaf71e286b27b95854c5cd3e1`，publication timestamp：`2026-06-26T01:29:21Z`。该 publication 不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order，不授权 production cutover。

Release v0.16.1 patch queue anchor：`MTPRO Release v0.16.1 Operator Beta Evidence Hardening Patch` 是 v0.16.0 后的 evidence hardening patch queue，现已 closed / done。GH-1133 使用 `GH-1133-VERIFY-V0161-V0160-RELEASE-FACT-SYNC`、`V0161-001-V0160-RELEASE-FACT-SYNC-GUARD`、`TVM-RELEASE-V0161-V0160-RELEASE-FACT-SYNC`、`V0161-001-V0160-TAG-FIXED`、`V0161-001-PATCH-QUEUE-NOT-PUBLICATION` 和 `V0161-001-NO-PRODUCTION-CUTOVER` 同步并守护 v0.16.0 publication facts：stable GitHub Release `https://github.com/atxinbao/MTPRO/releases/tag/v0.16.0`、tag peeled commit `28779236262bd7ffaf71e286b27b95854c5cd3e1`、publication timestamp `2026-06-26T01:29:21Z`。GH-1138 使用 `GH-1138-VERIFY-V0161-PATCH-AUDIT-RELEASE-NOTES`、`TVM-RELEASE-V0161-PATCH-AUDIT-RELEASE-NOTES`、`V0161-006-PATCH-AUDIT`、`V0161-006-RELEASE-NOTES`、`V0161-006-VALIDATION-MATRIX`、`V0161-006-PUBLICATION-GUIDANCE`、`V0161-006-NO-PRODUCTION-CUTOVER` 和 `V0161-006-NO-TAG-OR-RELEASE-PUBLICATION` 收口 patch audit、release notes、validation matrix 和 publication guidance。v0.16.1 patch queue 不移动 v0.16.0 tag、不覆盖 release、不创建 v0.16.1 tag / GitHub Release、不授权 production cutover；production cutover not authorized。

Release v0.17.0 operator beta hardening queue anchor：`MTPRO Release v0.17.0 Operator Beta Artifact + Status Runtime Hardening` 使用 GitHub fallback issues GH-1139 至 GH-1148。GH-1139 是 contract / preflight issue，使用 `GH-1139-VERIFY-V0170-OPERATOR-BETA-RUNTIME-HARDENING-CONTRACT`、`TVM-RELEASE-V0170-OPERATOR-BETA-RUNTIME-HARDENING-CONTRACT`、`V0170-001-V0161-PREFLIGHT-GATE`、`V0170-001-ARTIFACT-STATUS-RUNTIME-HARDENING-SCOPE`、`V0170-001-BINANCE-SPOT-TESTNET-ONLY`、`V0170-001-REDACTED-ARTIFACT-EVIDENCE-REQUIRED`、`V0170-001-QUEUE-ORDER` 和 `V0170-001-NO-PRODUCTION-CUTOVER` 固定 #1139..#1148 的 operator beta artifact / status runtime hardening scope。该合同只授权后续 WIP=1 issue 在 Binance Spot Testnet operator beta 范围内逐步强化 artifact ingest、status retry、resume、reconciliation、Dashboard / CLI evidence 和 beta safety profile；GH-1139 本身不读取 credential value，不连接 testnet / production endpoint，不提交 testnet / production order，不创建 tag / GitHub Release，不授权 production cutover。

Release v0.17.0 artifact bundle replay validator anchor：GH-1140 使用 `GH-1140-VERIFY-V0170-ARTIFACT-BUNDLE-REPLAY-VALIDATOR`、`TVM-RELEASE-V0170-ARTIFACT-BUNDLE-REPLAY-VALIDATOR`、`V0170-002-REAL-ARTIFACT-BUNDLE-INGEST`、`V0170-002-SCHEMA-CHECKSUM-REPLAY-VALIDATION`、`V0170-002-ACTION-SEQUENCE-VALIDATION`、`V0170-002-RECONCILIATION-ARTIFACT-REQUIRED`、`V0170-002-DETERMINISTIC-PASS-FAIL-RESULT` 和 `V0170-002-NO-PRODUCTION-CUTOVER` 将本地 redacted operator artifact bundle replay 收敛为 deterministic pass/fail evidence。它只校验 schema / checksum / action sequence / reconciliation；不读取 credential value，不连接 endpoint，不提交订单，不授权 production cutover。

Release v0.17.0 signed status query retry / timeout failure model anchor：GH-1141 使用 `GH-1141-VERIFY-V0170-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL`、`TVM-RELEASE-V0170-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL`、`V0170-003-BOUNDED-STATUS-QUERY-RETRY`、`V0170-003-PER-ATTEMPT-TIMEOUT`、`V0170-003-CLASSIFIED-FAILURE-EVIDENCE`、`V0170-003-RETRY-LIMIT-FAIL-CLOSED`、`V0170-003-REDACTED-FAILURE-EVIDENCE` 和 `V0170-003-NO-PRODUCTION-CUTOVER` 将 signed status query 的 retry、timeout 和 failure classification 固定为 fail-closed evidence。它只包装 Binance Spot Testnet status query；不读取 credential value，不连接 production endpoint / broker endpoint，不提交订单，不授权 production cutover。

Release v0.17.0 operator run resume from artifact store anchor：GH-1142 使用 `GH-1142-VERIFY-V0170-OPERATOR-RUN-RESUME-FROM-ARTIFACT-STORE`、`TVM-RELEASE-V0170-OPERATOR-RUN-RESUME-FROM-ARTIFACT-STORE`、`V0170-004-LOCAL-ARTIFACT-STORE-RESUME`、`V0170-004-REPLAY-VALIDATION-REQUIRED`、`V0170-004-AUDIT-CONTINUITY-PRESERVED`、`V0170-004-NO-RESUBMIT-ON-RESUME`、`V0170-004-REDACTED-RESUME-EVIDENCE` 和 `V0170-004-NO-PRODUCTION-CUTOVER` 将本地 artifact store replay 结果恢复成 append-only resume cursor。它只读取 redacted manifest / record checksum 与 GH-1140 validation evidence；不读取 credential value，不连接 endpoint，不重提订单，不授权 production cutover。

Release v0.17.0 cancel/status reconciliation recovery path anchor：GH-1143 使用 `GH-1143-VERIFY-V0170-CANCEL-STATUS-RECONCILIATION-RECOVERY-PATH`、`TVM-RELEASE-V0170-CANCEL-STATUS-RECONCILIATION-RECOVERY-PATH`、`V0170-005-CANCEL-STATUS-MISMATCH-CLASSIFICATION`、`V0170-005-INTERRUPTED-STATUS-EVIDENCE-RECOVERY`、`V0170-005-RESUME-CURSOR-CONTINUITY-REQUIRED`、`V0170-005-STATUS-COMPENSATION-REQUIRED`、`V0170-005-NO-AUTOMATIC-ORDER-RETRY`、`V0170-005-REDACTED-RECOVERY-EVIDENCE` 和 `V0170-005-NO-PRODUCTION-CUTOVER` 将 cancel/status mismatch、interrupted status evidence 和 resume cursor continuity 收敛成本地 fail-closed recovery report。它只消费 GH-1142 resume cursor、GH-1107 reconciliation report 和 GH-1141 signed status query failure evidence；不读取 credential value，不连接 endpoint，不重提订单，不授权 production cutover。

Release v0.17.0 Dashboard artifact validation error surface anchor：GH-1144 使用 `GH-1144-VERIFY-V0170-DASHBOARD-ARTIFACT-VALIDATION-ERROR-SURFACE`、`TVM-RELEASE-V0170-DASHBOARD-ARTIFACT-VALIDATION-ERROR-SURFACE`、`V0170-006-ARTIFACT-VALIDATION-STATUS-VISIBLE`、`V0170-006-FAILURE-REASONS-VISIBLE`、`V0170-006-RECOVERY-CASE-SUMMARY-VISIBLE`、`V0170-006-DASHBOARD-READ-ONLY-NO-COMMANDS` 和 `V0170-006-NO-PRODUCTION-CUTOVER` 将 GH-1140 artifact validation result 与 GH-1143 recovery report 映射为 Dashboard 只读错误面。它只展示 artifact validation status、failure reasons 和 recovery case summary；不新增 command handler、trading button、order form、live command，不连接 endpoint，不发送订单，不授权 production cutover。

Release v0.17.0 CLI artifact verify command anchor：GH-1145 使用 `GH-1145-VERIFY-V0170-CLI-ARTIFACT-VERIFY-COMMAND`、`TVM-RELEASE-V0170-CLI-ARTIFACT-VERIFY-COMMAND`、`V0170-007-LOCAL-ARTIFACT-BUNDLE-VERIFY`、`V0170-007-LOCAL-ONLY-NO-NETWORK`、`V0170-007-DETERMINISTIC-VALIDATION-REPLAY-OUTPUT`、`V0170-007-REDACTED-OUTPUT` 和 `V0170-007-NO-PRODUCTION-CUTOVER` 将 GH-1140 artifact bundle replay validator 暴露为本地 `mtpro verify-operator-beta-artifact-bundle <storageRoot> <runID>` 命令。它只读取本地 redacted artifact store 并输出 pass/fail、checksum、action sequence、reconciliation 和 failure reason 摘要；不读取 credential value，不连接 endpoint，不发送订单，不授权 production cutover。

Release v0.16.0 #1101 validation anchors：`GH-1101-VERIFY-V0160-OPERATOR-BETA-CONTRACT`、`TVM-RELEASE-V0160-OPERATOR-BETA-CONTRACT`、`V0160-001-V0151-PREFLIGHT-GATE`、`V0160-001-BINANCE-SPOT-TESTNET-ONLY`、`V0160-001-OPERATOR-CONFIRMATION-REQUIRED`、`V0160-001-REDACTED-EVIDENCE-REQUIRED`、`V0160-001-QUEUE-ORDER`、`V0160-001-NO-PRODUCTION-CUTOVER`。

Release v0.16.0 #1102 validation anchors：`GH-1102-VERIFY-V0160-OPERATOR-RUN-MODEL`、`TVM-RELEASE-V0160-OPERATOR-RUN-MODEL`、`V0160-002-RUN-ID-LIFECYCLE`、`V0160-002-ACTION-SEQUENCE`、`V0160-002-ARTIFACT-LINKAGE`、`V0160-002-INVALID-TRANSITION-FAILS-CLOSED`、`V0160-002-REDACTED-METADATA`、`V0160-002-NO-NETWORK-BY-THIS-ISSUE`、`V0160-002-NO-PRODUCTION-CUTOVER`。

Release v0.16.0 #1103 validation anchors：`GH-1103-VERIFY-V0160-CLI-SUBMIT-FLOW`、`TVM-RELEASE-V0160-CLI-SUBMIT-FLOW`、`V0160-003-STABLE-CLI-SUBMIT`、`V0160-003-V0151-RUNTIME-DELEGATION`、`V0160-003-EXPLICIT-OPERATOR-CONFIRMATION`、`V0160-003-TESTNET-CREDENTIAL-PROFILE`、`V0160-003-REDACTED-OUTPUT-ARTIFACT-CHECKSUM`、`V0160-003-MISSING-GATE-CREDENTIAL-CONFIRMATION-FAILS-CLOSED`、`V0160-003-NO-PRODUCTION-CUTOVER`。

Release v0.16.0 #1104 validation anchors：`GH-1104-VERIFY-V0160-CLI-CANCEL-FLOW`、`TVM-RELEASE-V0160-CLI-CANCEL-FLOW`、`V0160-004-STABLE-CLI-CANCEL`、`V0160-004-SUBMIT-ARTIFACT-IDENTITY`、`V0160-004-V0151-RUNTIME-DELEGATION`、`V0160-004-EXPLICIT-OPERATOR-CONFIRMATION`、`V0160-004-TESTNET-CREDENTIAL-PROFILE`、`V0160-004-REDACTED-ORDER-REFERENCE`、`V0160-004-APPEND-ONLY-EVENT-EVIDENCE`、`V0160-004-MISSING-PRIOR-ARTIFACT-FAILS-CLOSED`、`V0160-004-NO-PRODUCTION-CUTOVER`。

Historical release line anchor retained：Release line 已推进到 v0.12.0 readiness assessment sessions。
Historical patch line anchor retained：Release v0.12.1 已完成 readiness assessment provenance hardening patch。
Historical release line anchor retained：Release line 已推进到 v0.11.0 production readiness evidence runtime + integrity hardening。
Historical release line anchor retained：Release line 已推进到 v0.10.0 production cutover readiness gate。
Historical release line anchor retained：Release line 已推进到 v0.9.0 testnet no-order observability。
Historical release line anchor retained：Release line 已推进到 v0.8.0 persistent operator runtime + testnet read-only monitoring。
Historical release line anchor retained：Release line 已推进到 v0.7.0 operator runtime session + real testnet read-only connectivity。
Historical release line anchor retained：Release line 已推进到 v0.6.0 local operational runtime + testnet read-only probe hardening。

Future / gated capability 必须独立规划：实盘交易基础边界、实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制、OMS / broker integration、real portfolio / account、deployment / operations 和 advanced research platform。这些能力是受控启用路线，不是永久禁区；进入任何实盘能力前必须先证明 readiness evidence、credential / signed endpoint policy、OMS、pre-trade / post-trade risk、kill switch、reconciliation、audit trail、operator runbook 和 rollback gate。

## Product Workflow Blueprint

```text
Market Data -> Research -> Backtest -> Report -> Paper Session
-> Paper Execution Evidence -> Portfolio / Risk / Events
-> Future gated Live trading foundation
-> Completed read-model-only Live monitoring
-> Future gated live execution control / risk control / audit
-> Stage Audit -> Controlled Live enablement decision
```

Workbench 的主导航以 evidence navigation 为中心，不以交易按钮为中心。用户看到的是工作区、状态、证据、回放和阻断原因；不能看到可执行的实盘下单入口。Figma / product / design 文档只作为产品、交互、布局、视觉和 dashboard 参考，不是 SwiftUI 实现稿、组件库、Live PRO Console、实盘操作台或 Linear execution 授权。

Strategy / Trader layout machine anchors：`Sources/Trader/Strategies/<strategy>` 是 forward-looking canonical layout；旧 `Sources/Strategies/<strategy>` 只能作为 historical / compatibility / superseded path；当前 closure 口径为 `Trader = Accounts + Strategies + Coordination`，binding / adapter 语义归入 `Trader/Coordination`。

## Architecture Blueprint / 架构蓝图

本节承接 Product Blueprint，把最终产品要求翻译为系统结构原则。具体模块边界、数据流、接口、约束和技术分层由 `architecture.md` 维护。

```text
Adapters -> Runtime ingest -> Core domain / kernel -> MessageBus / Cache
-> Strategy -> Risk -> Paper / future Live execution boundary
-> Portfolio -> Event Log -> Replay -> Projections -> Read Models
-> ViewModels -> Workbench -> Report / Audit
```

核心原则：Core 保存稳定领域语义；Adapter 能力必须显式声明；Event Log 是 append-only facts source；Replay 是跨 Research / Backtest / Paper / future Live 的审计能力；SQLite / DuckDB 是 projection，不是 UI contract；App / Dashboard 只消费 ViewModel / Read Model；Future Live 必须有独立 adapter capability、risk gate、reconciliation evidence、operations readiness 和 audit trail。

## Design Blueprint / 工作台设计蓝图

MTPRO Workbench surface：Overview、Research、Backtest、Report、Paper、Portfolio、Risk、Events、Operations、Live Readiness、Live Monitoring 和 Future Live placeholder。当前 UI 仍保持 read-model-only，不提供真实交易按钮，不直接读取 database schema、adapter request 或 runtime object。

产品层交互模型、screen layout、UI/UX rules、component layout、visual style、dashboard high-fidelity 和 reference gap map 由 `docs/product/`、`docs/design/`、`docs/reference/` 承接。它们只定义用户动线、页面角色、信息优先级、状态边界和禁止动作，不授权 SwiftUI implementation、Live PRO Console、broker adapter、OMS、real order lifecycle、live risk runtime、reconciliation runtime、incident replay runtime 或 production operations。

## Infrastructure Blueprint / 基础设施蓝图

长期 evidence chain：

```text
Market event -> Strategy signal -> Backtest / Paper parity evidence
-> Cost assumption -> Risk decision -> Paper order intent
-> Simulated fill evidence -> Portfolio projection -> Report artifact
-> Event log / replay evidence -> Stage Code Audit
```

基础设施必须覆盖 Data infrastructure、Trading evidence infrastructure、Read / command infrastructure、Audit infrastructure 和 Automation infrastructure。Linear、Parent Codex queue preflight、Codex Execution Agent、GitHub PR Automation、Post-Issue Ledger 和 Root Docs Refresh 只服务 evidence flow，不自动授权下一阶段。

## Trading Capability Blueprint / 交易能力蓝图

当前 paper-only 能力：

```text
Strategy signal -> Paper action proposal -> Risk blocker evidence
-> Paper order intent -> Simulated fill evidence -> Paper portfolio projection
-> Report / Dashboard / Event Timeline evidence
```

Future live 能力：

```text
Strategy signal -> Live risk decision -> Real order intent
-> Broker / exchange adapter -> Execution report / fill
-> Real portfolio / account state -> Reconciliation
-> Audit / incident replay / stop controls
```

Future live 能力必须作为独立 Project Definition 和独立 execution contract 进入，不能从 paper-only 类型、命令或 ViewModel 偷渡。Default-off 是当前安全姿态；满足 gate 后可以按 testnet closed loop、production read-only、shadow live、controlled canary 的顺序受控启用。

## Live Gate Blueprint / 实盘准入蓝图

进入 Live 前必须至少满足 Human 独立确认、独立 Project Definition、API key / secret policy、signed endpoint / account endpoint / listenKey capability contract、broker / exchange adapter capability contract、real order submit / cancel / replace contract、live risk gate、熔断、禁交易状态、stop controls、execution reconciliation、account / position sync、incident replay、operations readiness、monitoring、rollback / shutdown policy。

任何缺少上述 gate 的变更都只能作为 Future Construction Zone 记录在蓝图中，不能进入 execution。通过 gate 后，Live trading 可以作为后续版本的受控能力进入唯一 live queue source；未通过 gate 时继续保持 fail-closed。

## Current / Future Boundary / 当前与未来边界

当前 foundation / final product 采用两层进度口径：

- Current Foundation Progress：4 / 4（100%）。
- Final Product Goal Progress：9 / 9（100%）。
- Engine Maturity Roadmap Progress：4 / 4（100%）。
- Engine Maturity Roadmap Progress：4 / 4（100%）

当前完成事实压缩为阶段族，详细证据以 `docs/audit/`、`docs/roadmap.md` 和 `docs/validation/latest-verification-summary.md` 为准。

下表“仍不授权”表示当前阶段 / 当前 release line 不授权，不表示该能力被永久禁止。Live trading、signed endpoint、OMS、broker gateway、account / position sync 和 real order lifecycle 都属于受控启用能力；它们必须在独立 planning、GitHub / Linear live queue、WIP=1 preflight、Human approval 和 release validation 后逐层放开。

| 阶段族 | 已完成事实 | 仍不授权 |
| --- | --- | --- |
| Paper / data / parity / beta | `MTPRO Event-Driven Paper Trading Runtime v1`、`MTPRO Data Catalog / Scenario Replay v1` 已由 Parent Codex 完成 Project closure、`MTPRO Simulated Exchange / Backtest Parity v1` 已由 Parent Codex 完成 Project closure、`MTPRO Workbench Beta Readiness v1` 已由 Parent Codex 完成 Project closure | signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button、live command |
| L3 read-model readiness | `MTPRO Live Read-only Readiness Boundary v1`、`MTPRO Account / Position / Balance Read-model-only v1`、Private Stream / Snapshot simulation、Live Monitoring v2、Strategy / Trader readiness 已完成 | 真实 Live read-only runtime、private WebSocket runtime、real account read、broker position sync、real balance、real PnL、live command |
| Trader / target graph | `MTPRO Trader-Owned Strategies Layout Correction v1`、`MTPRO Trader EMA Strategy Layout Consolidation v1`、`MTPRO Trader Accounts / Coordination Compatibility Consolidation v1`、`MTPRO SwiftPM Target Graph Module Split v1` 已完成 Project closure、TargetGraph Anchor Retirement 已完成 | Strategy runtime、Trader runtime、SwiftPM target graph 再拆、ExecutionClient implementation、OMS、broker gateway、L4 implementation |
| Core envelope / L4 / production readiness | Core Envelope Retirement / Real Module Ownership Completion before L4 complete；`MTPRO L4 Live Production / Trading Commands v1` Done / no-default-production-trading；`MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1` Done / readiness-only | production cutover、production secret read、production endpoint、real broker gateway、real submit / cancel / replace、Live PRO Console production command、order form、trading button |
| Release line | `MTPRO Release v0.1.0` Done / Binance + EMA runtime validation / production disabled by default；`MTPRO Release v0.2.0`、v0.3.x、v0.4.0、v0.5.0、`MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening`、`MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity`、`MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring`、`MTPRO Release v0.9.0 Testnet No-order Observability`、`MTPRO Release v0.10.0 Production Cutover Readiness Gate`、`MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening`、`MTPRO Release v0.12.0 Readiness Assessment Sessions`、`MTPRO Release v0.12.1 Readiness Assessment Provenance Hardening Patch` 均作为后续 release evidence 记录；`MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine` 已完成 #994 至 #1005，覆盖 local evidence root intake、schema / checksum / policy validation、Manifest V2、Bundle V2、registry lifecycle、validate、redacted export、evidence-level diff、transaction recovery snapshot、generation ID collision-proofing、ordered CLI lifecycle / ordered CLI execution lifecycle、local evidence fixtures and regression suite 和 Stage Code Audit / release docs closeout；Current maturity statement：`MTPRO Release v0.13.0 Local Evidence-driven Readiness Engine complete with production trading disabled by default and production cutover not authorized` | 自动进入下一阶段、production cutover、production trading、non-gated broker connection、默认真实订单、testnet order routing |

Historical Core Envelope Retirement / Real Module Ownership Completion evidence 仍保留：PR #448 后完成 final residual hardening audit，确认 production executable `try!` = 0、`@unchecked Sendable` = 0、open GitHub issue / PR = 0。

## Future Construction Zones / 未来建设区

Future Construction Zones / 未来建设区指完整产品蓝图里明确需要但当前不施工的长期能力区。它们可以被蓝图描述，但不能自动变成当前 Project、Linear issue 或执行授权。主要 zones：实盘交易基础边界、实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制、OMS / Execution Management、Real Portfolio / Account、Deployment / Operations、Advanced Research Platform。

## Gated / Forbidden Capabilities / 受门禁保护或当前禁止的能力

Gated / Forbidden Capabilities / 受门禁保护或当前禁止的能力指未来可能需要，但当前必须被门禁或禁止的能力。进入这些能力前必须先有独立 Human decision、独立 Project Definition、清晰的 signed endpoint / broker / risk / operations gates，以及可审计的验证证据。Live / signed endpoint / broker / OMS 均属此类。

## Execution / Automation Blueprint

- Human + `@000 / AIE`：完整蓝图设计、docs-only PR、验证和边界守护。
- Human + `@001 / PLN`：蓝图确认后的下一阶段 Project / Issue 草案。
- `@002 / PAR`：Project 写入 Linear 后，执行 queue preflight、eligible issue 调度、child Codex 监督、Stage Code Audit。
- Codex Execution Agent：只执行 Parent Codex queue preflight 推进后的当前唯一 issue scope。
- GitHub PR Automation：required checks、auto-merge、squash merge、Linear bot auto Done。

完整蓝图不触发上述执行层。

## Blueprint -> Architecture -> Roadmap Handoff / 蓝图到架构和路线交接

```text
GOAL.md -> BLUEPRINT.md -> architecture.md -> docs/roadmap.md -> Linear Project / Issues
```

当前 handoff 状态：`MTPRO Release v0.1.0` 已完成 GitHub fallback issue chain、Final Stage Code Audit 和 Root Docs Refresh Gate。GH-521 至 GH-541 全部 closed / done，PR #542 至 #561 全部 merged 且 required check `checks` SUCCESS。该 release 完成 Binance + EMA runtime validation、public market data -> DataEngine / Cache、signed account read-only runtime、private stream / account snapshot read-model runtime、Trader / EMA / RiskEngine / ExecutionEngine / ExecutionClient testnet evidence、Dashboard release monitoring / controlled command surfaces、kill switch / no-trade / rollback controls、dry-run / testnet validation suite、no-default-production-trading automation guard、release docs / operator runbook、validation matrix closeout 和 final audit。结论为 `MTPRO Release v0.1.0 Binance + EMA runtime validation complete with production trading disabled by default`；production trading、production secret usage、production endpoint、production broker endpoint、automatic broker connection、non-Binance venue、non-EMA active strategy、Live PRO Console production command、live command、order form、trading button 和任何 default real trading 仍关闭。

Additional retained closure anchors：`docs/audit/mtpro-production-cutover-readiness-real-broker-enablement-gate-v1-stage-code-audit.md`；`mtpro-production-cutover-readiness-real-broker-enablement-gate-v1-stage-code-audit.md`；`docs/audit/mtpro-l4-live-production-trading-commands-v1-stage-code-audit.md`；`mtpro-l4-live-production-trading-commands-v1-stage-code-audit.md`；PR #448 后完成 final residual hardening audit；production executable `try!` = 0。

## Blueprint Update Rule

修改本文档时必须保持三条线分开：Product / Architecture / Design Blueprint 可以描述长期终局；Current Construction Scope 只能描述已经完成或 Human 明确允许进入 planning 的当前施工范围；Execution Authorization 只能来自 live queue source 中唯一 configured executable issue。

因此，本文档可以帮助 `@001 / PLN` 形成下一阶段 Project 草案，但不能直接创建 Linear Project / Issue，不能推进 `Todo`，不能启动 `@002 / PAR` 或任何额外 issue 调度服务。

## Validation Checklist

已确认：NautilusTrader reference study 和 `mattpocock/skills` 已收敛为 MTPRO 自己的蓝图、shared language、feedback loop、diagnosis 和 handoff 规则；Root Blueprint 和 Complete Blueprint 已统一到根目录 `BLUEPRINT.md`；Goal / Blueprint / Engineering Module / Roadmap 分工明确；Product / Architecture / Design Blueprint 三线明确；Infrastructure Blueprint、Trading Capability Blueprint、Live Gate Blueprint、Blueprint -> Architecture -> Roadmap Handoff、Future Construction Zones / 未来建设区均已明确；Live / signed endpoint / broker / OMS 被标记为 future / gated。

## 执行边界

`BLUEPRINT.md`、`docs/roadmap.md`、Project Planning Record、Backlog issue、label、priority 和 assignee 都不授权执行。只有 Linear live-read 中唯一 configured executable issue 可以进入正式开发。
