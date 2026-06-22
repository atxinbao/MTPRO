# MTPRO Release v0.15.0 Real Binance Spot Testnet Execution MVP Contract

日期：2026-06-22

执行者：Codex

## Purpose

`GH-1066-VERIFY-V0150-CONTRACT-PREFLIGHT`

`TVM-RELEASE-V0150-CONTRACT-PREFLIGHT`

`V0150-001-RELEASE-CONTRACT`

本合同定义 `MTPRO Release v0.15.0 Real Binance Testnet Execution MVP` 的第一道执行门槛。它只允许从 v0.14.x 的 local execution evidence chain 进入受控、可审计、explicit operator confirmation 的 Binance Spot Testnet 签名执行规划；它本身不实现 credential provider、signed request builder、submit、cancel、cancel-replace、OMS sync、Dashboard command surface 或 release closeout。

## v0.14.1 Preflight Gate

`V0150-001-V0141-PREFLIGHT-GATE`

进入任何 v0.15.0 子任务前，Parent Codex 必须确认：

- #1059、#1060、#1061、#1062、#1063、#1064 已 closed / done。
- PR #1077、#1078、#1079、#1080、#1081、#1082 已 merged，并且 required check `checks` 为 SUCCESS。
- `v0.14.1` stable GitHub Release 已存在：`https://github.com/atxinbao/MTPRO/releases/tag/v0.14.1`。
- `v0.14.1` tag peeled commit 为 `92cd3d5cf00e85c43ef99d9f204cca97347c79ff`。
- `main == origin/main` 后才允许执行 #1066；#1067 至 #1076 仍需等待 #1066 PR merge / checks / issue close 后逐个 queue preflight。

## Product Boundary

`V0150-001-BINANCE-SPOT-TESTNET-ONLY`

Release v0.15.0 的 execution MVP 只覆盖：

- `activeVenue == Binance`
- `v0150ExecutionProductScope == Binance Spot Testnet only`
- `Binance Spot Testnet` signed execution path

Release v0.15.0 MVP 不覆盖 USDⓈ-M Perpetual execution、不覆盖 non-Binance venue、不覆盖 production endpoint、不覆盖 broker endpoint、不覆盖 real-money order。

## Signed Testnet Boundary

`V0150-001-SIGNED-TESTNET-BOUNDARY`

后续签名执行子任务只能在各自 issue 合同授权后逐步启用：

- #1067：testnet credential provider + signed request builder，只能读取显式 testnet credential source，禁止 production secret auto-read。
- #1068：real Spot Testnet submit runtime，只能在 operator confirmation、RiskEngine allow、kill switch allow、testnet endpoint allowlist 和 redacted evidence writer 全部通过后进入 network submit path。
- #1069：real Spot Testnet cancel runtime，只能取消 v0.15 event log / OMS 已记录的 testnet order identity。
- #1070：real Spot Testnet cancel-replace runtime，只能基于 #1068/#1069 的 order identity、OMS state 和 risk re-check 执行。
- #1071：append-only network execution event log + artifacts 必须对每个 signed network action 产生 redacted append-only checksummed evidence。
- #1072：OMS state sync + real testnet reconciliation 必须把 broker report / event log / OMS / Portfolio projection 对齐，mismatch 必须 fail closed。
- #1073：CLI operator flow 只允许 explicit operator confirmation，不允许默认自动执行。
- #1074：Dashboard 只展示 read-only testnet execution status，不提供 trading button、live command 或 order form。
- #1075：failure simulation 必须覆盖签名 transport、endpoint、timestamp、risk、kill switch、event log 和 reconciliation fail-closed。
- #1076：release CI + manual testnet workflow + audit evidence 只收口验证、manual workflow 和 audit evidence，不授权 production cutover。

## Production Fail-Closed Gate

`V0150-001-PRODUCTION-FAIL-CLOSED`

必须保持以下事实：

- `productionTradingEnabledByDefault=false`
- `operatorConfirmationRequired=true`
- `testnetEndpointAllowlistOnly=true`
- `productionEndpointConnected=false`
- `productionSecretRead=false`
- `productionOrderSubmitted=false`
- `brokerEndpointConnected=false`
- `dashboardCommandSurfaceEnabled=false`
- `orderFormEnabled=false`
- `productionCutoverAuthorized=false`

任何 production host、production credential、broker endpoint、real-money order 或 production cutover wording 都不能作为 v0.15.0 的默认可执行能力出现。

## Queue Discipline

`V0150-001-CHILDREN-BACKLOG-NON-EXECUTABLE`

V150 children remain backlog / non-executable：#1067、#1068、#1069、#1070、#1071、#1072、#1073、#1074、#1075、#1076 必须在 #1066 merged / checks SUCCESS / issue done 前保持 backlog / non-executable。后续只能按 WIP=1 和 dependency order 逐个从 backlog / non-executable promote 到 todo / in-progress。

## Forbidden Capability Audit

`V0150-001-NO-PRODUCTION-CUTOVER`

`V0150-001-NO-DASHBOARD-COMMAND-SURFACE`

Release v0.15.0 contract/preflight 不允许：

- production cutover
- production secret auto-read
- production endpoint connection
- broker endpoint connection
- production order submit / cancel / replace
- USDⓈ-M Perpetual execution in v0.15.0 MVP
- non-Binance venue
- Dashboard trading button
- live command
- order form
- Linear / Symphony / Graphify / code-index / Figma

## Acceptance Matrix

| Issue | Gate | Acceptance |
| --- | --- | --- |
| #1066 | Contract + v0.14.1 preflight | 本文件、validation plan、trading matrix、automation readiness、TargetGraph focused test 和 `checks/verify-v0.15.0-contract-preflight.sh` 固定 v0.15.0 queue 的 no-production / Spot Testnet only contract。 |
| #1067 | Credential + signing | 后续 issue 独立实现 explicit testnet credential provider 和 signed request builder；不得读取 production secret。 |
| #1068 | Submit | 后续 issue 独立实现 Binance Spot Testnet submit，并在 operator / risk / kill switch / endpoint allowlist / event log gate 通过前 fail closed。 |
| #1069 | Cancel | 后续 issue 独立实现 testnet cancel，只能使用已记录 testnet order identity。 |
| #1070 | Cancel-replace | 后续 issue 独立实现 cancel-replace，必须复用 OMS state、risk re-check 和 event evidence。 |
| #1071 | Event log | 后续 issue 独立实现 append-only redacted checksummed network event log。 |
| #1072 | OMS / reconciliation | 后续 issue 独立实现 OMS state sync 与 reconciliation fail-closed evidence。 |
| #1073 | CLI | 后续 issue 独立实现 explicit operator confirmation CLI flow。 |
| #1074 | Dashboard | 后续 issue 独立实现 read-only status surface，不提供 command surface。 |
| #1075 | Failure simulation | 后续 issue 独立实现 signed transport failure simulation。 |
| #1076 | CI / manual workflow / audit | 后续 issue 独立收口 release CI、manual workflow 和 audit evidence；不授权 production cutover。 |

## Validation

本合同由以下 evidence 固定：

- `checks/verify-v0.15.0-contract-preflight.sh`
- `checks/automation-readiness.sh`
- `checks/run.sh`
- `docs/automation/automation-readiness.md`
- `docs/validation/latest-verification-summary.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `Tests/TargetGraphTests/TargetGraphTests.swift::testGH1066ReleaseV0150ContractAndV0141PreflightGate`

`GH-1066` 合同通过后只说明 v0.15.0 queue 可以继续逐项 preflight，不代表 #1067..#1076 已完成，不代表 v0.15.0 可发布，也不授权 production cutover。
