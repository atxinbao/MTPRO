# Workbench Beta Readiness Contract

日期：2026-05-27

执行者：Codex

本文档定义 `MTPRO Workbench Beta Readiness v1` 的 MTP-118 合同入口：Workbench beta readiness terminology、beta acceptance boundary、local-only beta demo path、L1 / L1.5 / L2 到 L2+ 的 handoff boundary、forbidden capability baseline、first executable candidate non-authorization 和 validation anchors。

本文档只服务 `MTP-118 Define Workbench beta readiness contract and acceptance boundary` 的合同 / 边界定义。它不实现 install / run 逻辑，不新增 engine core capability，不新增 Dashboard / App / Runtime / Core 行为，不创建发布包，不实现 production release、notarization、App Store distribution、auto-update 或 production operations，不接 signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、Live PRO Console、trading button 或 live command，不运行 Graphify，不修改 Figma。

MTP-118 的 beta readiness 是 local macOS Workbench demo / acceptance path，不是 production release 或 live readiness。MTP-119 在该边界内补充 local launch / install / environment verification path，只定义本地 SwiftPM 安装、Dashboard 启动、smoke expectation、可复现启动证据和失败排查入口，不创建 production installer 或 release pipeline。

## MTP-118 Workbench beta readiness terminology

`MTP-118-WORKBENCH-BETA-READINESS-TERMINOLOGY`

MTP-118 只允许定义以下术语，不允许把术语升级为实现：

| 术语 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `Workbench beta readiness` | L2+ maturity slice 的本地 macOS Workbench demo / acceptance 准备度 | 不等于 production release、live readiness、App Store release、notarization 或 production operations |
| `beta acceptance path` | operator 按后续 issue 固定路径验收 local Workbench demo 的证据链 | 当前不实现 launch / install / run 逻辑，也不替代 `bash checks/run.sh` |
| `local macOS Workbench demo` | 只在本机 macOS Workbench 中展示已完成 L1 / L1.5 / L2 evidence 的 demo 目标 | 不等于 cloud service、production deployment、Live PRO Console 或真实交易工作台 |
| `demo workflow` | 后续 issue 逐步固定 demo scenario、first-run state、Report / Dashboard / Events evidence 和 checklist 的流程语言 | 当前不选择 fixture、不写启动脚本、不新增 UI 或 runtime behavior |
| `acceptance boundary` | 判定 beta readiness 时必须满足的边界：local-only、read-model-only、no live / broker / signed / account / OMS / trading button | 不授权下一 issue 自动执行，不授权 live / broker / production release |
| `local-only beta definition` | beta readiness 只代表本地可演示 / 可验收，不代表生产发布或 live 准入 | 不等于 production installer、auto-update、notarized build 或 real account readiness |
| `forbidden capability baseline` | MTP-118 固定本 Project 期间必须持续禁止的能力基线 | 不得写成 partially supported、preview enabled 或 behind flag available |

## MTP-118 beta acceptance boundary

`MTP-118-BETA-ACCEPTANCE-BOUNDARY`

MTP-118 的 beta acceptance boundary：

- `Local macOS boundary`：Workbench beta readiness 只表示本地 macOS Workbench demo / acceptance path；不得写成 cloud deployment、production release、notarization、App Store distribution、auto-update 或 production operations。
- `Evidence-first boundary`：beta acceptance path 必须继续以 Research -> Backtest -> Report -> Paper -> Events evidence chain 为主，不以 trading button、order form 或 Live PRO Console 为中心。
- `Read-model-only boundary`：后续 Report / Dashboard / Events beta acceptance path 只能消费 Read Model / ViewModel；不得读取 Runtime object、Persistence schema、Adapter request、secret、signed endpoint、account endpoint、listenKey、broker payload 或 live state。
- `No engine-core expansion boundary`：MTP-118 只定义合同和验收边界；不得实现 install / run 逻辑，不得新增 Core / Runtime / App / Dashboard capability。
- `No live readiness boundary`：beta readiness 不是 live readiness，不表示真实账户、broker、OMS、real order lifecycle、Live PRO Console、trading button 或 live command 已进入当前 scope。

## MTP-118 local-only beta demo path

`MTP-118-LOCAL-ONLY-BETA-DEMO-PATH`

MTP-118 只定义 local-only beta demo path 的验收语言：

1. 后续 `MTP-119` 才能定义 local launch / install / environment verification path。
2. 后续 `MTP-120` 才能选择 demo scenario 和 fixture wiring。
3. 后续 `MTP-121` 才能定义 Workbench first-run / default demo state。
4. 后续 `MTP-122` 才能串联 Report / Dashboard / Events beta acceptance path。
5. 后续 `MTP-123` 才能增加可复现 beta acceptance checklist / script。
6. 后续 `MTP-124` 才能增加 docs index 和 operator guide。
7. 后续 `MTP-125` 才能收口 automation readiness / validation evidence / stage audit input material。

MTP-118 不提前实现上述任何后续 issue 的 install / run、fixture wiring、first-run state、UI surface、script、operator guide 或 stage audit input。

## MTP-118 L1 / L1.5 / L2 / L2+ handoff boundary

`MTP-118-L1-L15-L2-L2PLUS-HANDOFF`

MTP-118 固定 L2+ Workbench Beta Readiness 的 handoff boundary：

- `L1 Paper Runtime handoff`：只能复用 TradingClock、paper-only routing、Paper Pre-trade RiskEngine、local lifecycle、simulated fill、paper account / portfolio projection 和 Event Log / Replay / Report / Dashboard evidence 的已完成事实；不得升级为 production trading engine、OMS 或 real order lifecycle。
- `L1.5 Data Catalog / Scenario Replay handoff`：只能复用 local manifest、deterministic fixture、replay window / cursor、checksum / freshness evidence、quality gates、report input versioning 和 Workbench / Report / Events read-model evidence；不得升级为 production data platform、large-scale ingestion pipeline 或 automatic downloader。
- `L2 Simulated Exchange / Backtest Parity handoff`：只能复用 shared backtest-paper order semantics、deterministic matching、market / limit simulated execution、partial fill / latency / fee / slippage parity、portfolio projection parity 和 Report / Dashboard / Events read-model-only evidence；不得升级为 production matching runtime、真实 exchange runtime、broker adapter、execution report、broker fill 或 reconciliation。
- `L2+ Workbench Beta Readiness target`：后续 Project issue queue 只能把上述 evidence productize 成 local macOS Workbench demo / acceptance path；不得把 beta readiness 写成 live readiness 或 production release completion。

## MTP-118 forbidden capability baseline

`MTP-118-FORBIDDEN-CAPABILITY-BASELINE`

MTP-118 必须保持以下 forbidden capabilities：

- engine core capability expansion
- install / run implementation
- release package creation
- production release
- notarization
- App Store distribution
- auto-update
- production operations
- signed endpoint
- account endpoint
- listenKey
- API key / secret read
- broker integration
- broker execution adapter
- exchange execution adapter
- `LiveExecutionAdapter`
- OMS
- real order lifecycle
- real submit / cancel / replace
- execution report
- broker fill
- reconciliation
- real account / broker position / margin / leverage read
- live readiness
- live runtime
- Live PRO Console
- trading button
- live command
- emergency stop / shutdown / restore
- Graphify update
- Figma change

这些能力只能作为 forbidden / Future Gated boundary 出现，不能写成当前支持、beta preview、behind flag、partially implemented 或后续 issue 自动授权。

## MTP-118 first executable candidate non-authorization

`MTP-118-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`

MTP-118 已经由 Parent Codex queue preflight 确认为当前唯一 Todo / configured executable issue，因此 MTP-118 可以执行。

该事实不改变以下规则：

- Project Planning Record 中的 first executable issue candidate 只是候选，不构成执行授权。
- MTP-119 至 MTP-125 仍必须保持 Backlog / blocked，直到 MTP-118 独立完成 PR、required check、merge 和 Linear Done evidence 后，再由 Parent Codex queue preflight 单独判断。
- MTP-118 完成后不得自动推进 MTP-119。
- 任何 Backlog issue、planning record、roadmap text、label、priority 或 assignee 都不授权执行。

## MTP-118 validation anchors

`MTP-118-WORKBENCH-BETA-READINESS-VALIDATION`

Required validation：

- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

Focused validation anchors：

- `docs/contracts/workbench-beta-readiness-contract.md` 必须包含 MTP-118 terminology、acceptance boundary、local-only beta demo path、L1 / L1.5 / L2 / L2+ handoff、forbidden capability baseline、first executable candidate non-authorization 和 validation anchors。
- `docs/domain/context.md` 必须包含 Workbench Beta Readiness Terms。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-WORKBENCH-BETA-READINESS` 和 MTP-118 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-118 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-118 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-118 contract、matrix、validation plan、domain context、latest summary、automation readiness doc 和 forbidden capability boundary strings。

MTP-118 不新增 Dashboard smoke handle，不新增 App read model，不新增 Core / Runtime / Dashboard behavior，不新增 stage audit input；Project stage closeout 仍归属 `MTP-125`。

## MTP-119 local launch / install / environment verification path

`MTP-119-LOCAL-LAUNCH-INSTALL-ENVIRONMENT-PATH`

MTP-119 只把既有 macOS / SwiftPM / Dashboard path 固定为 local beta readiness 的可复现启动路径。该路径用于 operator 在本机确认 Workbench beta 可以安装依赖、构建 Dashboard、执行 smoke run 并进入统一验证，不表示 production release、notarization、App Store distribution、auto-update、production deployment 或 cloud operations 已进入当前 scope。

### MTP-119 local environment verification

`MTP-119-LOCAL-ENVIRONMENT-VERIFICATION`

Operator 在仓库根目录执行以下只读 / 本地命令确认环境：

```bash
uname -s
swift --version
swift package resolve
```

验收含义：

- `uname -s` 必须为 `Darwin`，因为 Dashboard SwiftUI shell 的完整 build / smoke path 是 macOS-only。
- `swift --version` 必须显示 Swift 6 或更高版本。
- `swift package resolve` 只解析 SwiftPM 依赖，不读取 secret，不连接 broker，不接 signed endpoint、account endpoint 或 listenKey。

### MTP-119 local install / run notes

`MTP-119-LOCAL-INSTALL-RUN-NOTES`

MTPRO 的 MTP-119 local install 只表示 SwiftPM 在本机解析依赖并生成 `.build` 下的本地构建产物：

```bash
swift build --product Dashboard
```

MTP-119 不创建 `.app` 安装包，不创建 `.pkg`、`.dmg`、notarized artifact、App Store build、auto-update channel、production deployment 或 cloud operations workflow。Dashboard 本地启动入口继续复用既有 SwiftPM executable：

```bash
swift run Dashboard
```

自动 smoke 启动入口必须使用：

```bash
DASHBOARD_SMOKE=1 swift run Dashboard
```

### MTP-119 launch command / runbook

`MTP-119-LAUNCH-COMMAND-RUNBOOK`

本地 beta launch runbook：

1. 从仓库根目录执行 `swift package resolve`。
2. 执行 `swift build --product Dashboard`，确认 Dashboard product 可构建。
3. 执行 `DASHBOARD_SMOKE=1 swift run Dashboard`，确认 Dashboard 可以本地启动并输出 smoke summary。
4. 执行 `bash checks/run.sh`，确认统一验证入口通过 automation readiness、Dashboard build、Dashboard smoke 和 Swift tests。

该 runbook 不替代后续 MTP-123 的 beta acceptance checklist / script，也不提前选择 MTP-120 demo scenario、不定义 MTP-121 first-run state、不串联 MTP-122 Report / Dashboard / Events acceptance path。

### MTP-119 Dashboard smoke expectation

`MTP-119-DASHBOARD-SMOKE-EXPECTATION`

当前 MTP-119 local launch smoke 的 expected output 必须保持 read-model-only boundary：

```text
Dashboard smoke: sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; simulatedParityEvidence=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events
```

验收含义：

- `sections=8` 和 section list 证明 Workbench shell 可启动到既有 Market / Strategy / Backtest / Report / Paper / Risk / Portfolio / Events。
- `readModelOnly=true` 与 `workbenchReadModelOnly=true` 证明 Dashboard 仍只消费 ViewModel / Read Model。
- `controls=start,pause,close,reset` 只表示 session-level local paper controls，不是 order-level command、live command 或 trading button。
- Live 相关字段必须保持 blocked evidence，不得变成 signed endpoint、account endpoint、broker adapter、OMS、real order lifecycle、Live PRO Console 或真实交易授权。

### MTP-119 reproducible launch evidence

`MTP-119-REPRODUCIBLE-LAUNCH-EVIDENCE`

MTP-119 的可复现启动证据由以下命令和输出组成：

- `uname -s`：确认 macOS / Darwin。
- `swift --version`：确认 Swift 6+。
- `swift build --product Dashboard`：确认本地 build artifact 可生成。
- `DASHBOARD_SMOKE=1 swift run Dashboard`：确认 Dashboard smoke output 与 MTP-119 expectation 对齐。
- `bash checks/run.sh`：确认最终本地 validation gate 通过。

这些证据可以写入 PR evidence、`.codex/testing.md` 和 `verification.md`，但 `.codex/*` 不进入 PR。

### MTP-119 troubleshooting boundary

`MTP-119-TROUBLESHOOTING-BOUNDARY`

失败排查入口：

- `swift package resolve` 失败：优先检查 SwiftPM 依赖解析和网络缓存，不读取 secret，不新增 credential。
- `swift build --product Dashboard` 失败：优先检查 SwiftPM target 依赖、macOS SwiftUI availability 和编译错误第一处。
- `DASHBOARD_SMOKE=1 swift run Dashboard` 失败：优先检查 Dashboard executable、App ViewModel assembly 和 smoke summary 断言。
- `bash checks/run.sh` 失败：按 `git diff --check`、`checks/automation-readiness.sh`、Dashboard build / smoke、`swift test` 顺序定位最小失败点。

排查不得引入 production operations、cloud deployment、notarization、App Store distribution、auto-update、signed endpoint、account endpoint、listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、live command 或 trading button。

### MTP-119 validation anchors

`MTP-119-LOCAL-LAUNCH-VALIDATION`

Required validation：

- `DASHBOARD_SMOKE=1 swift run Dashboard`
- `bash checks/run.sh`

Focused validation anchors：

- `docs/contracts/workbench-beta-readiness-contract.md` 必须包含 MTP-119 local launch / install / environment path、environment verification、install / run notes、launch command / runbook、Dashboard smoke expectation、reproducible launch evidence、troubleshooting boundary 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-119 local launch / install terms。
- `docs/validation/macos-build-run-loop.md` 必须包含 MTP-119 local beta launch / install / environment verification path。
- `docs/validation/validation-plan.md` 必须包含 MTP-119 required validation。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-119 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-119 当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-119 contract、domain context、macOS run-loop、validation plan、matrix、latest summary 和 automation readiness doc anchors。

MTP-119 不新增 Dashboard smoke handle、不新增 App read model、不新增 Core / Runtime / Dashboard behavior、不创建 release package、不新增 stage audit input；Project stage closeout 仍归属 `MTP-125`。
