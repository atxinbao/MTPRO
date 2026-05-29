# MTPRO 自动化就绪状态

日期：2026-05-23

执行者：Codex

本文档只记录自动化能力是否可用，不记录 current issue。

每轮执行前必须从 Linear / Parent Codex queue preview 读取唯一 active configured executable issue，并确认 WIP=1。

## 已验证能力

| 能力 | 状态 | 证据入口 |
| --- | --- | --- |
| GitHub Actions required check | ready | `.github/workflows/checks.yml`，job name `checks` |
| GitHub PR Automation | ready | `protect-main`、required checks、squash auto-merge、branch cleanup |
| Local validation entrypoint | ready | `bash checks/run.sh` |
| Automation readiness shell gate | ready | `bash checks/automation-readiness.sh` |
| Linear issue execution contract | ready | Linear issue body 字段作为 child Codex 执行合同 |
| Parent Codex Automation Supervision | ready | queue preview、eligible issue 调度、child Codex 监控、host-side fallback、Stage Code Audit |
| symphony-issue path | ready | 唯一 `Todo` -> `In Progress` -> child Codex -> PR handoff -> `In Review` |
| Post-Issue Ledger | ready | PR merge / Linear bot Done 后刷新本地关系记账，输出 ignored summary |
| Graphify resource graph | ready | read context + scoped post-issue refresh；不提交 `graphify-out/*` |
| Codex use-cases alignment | ready | `docs/automation/codex-use-cases-alignment.md` |
| Verified operations | ready | `docs/automation/verified-operations.md` |
| Paper Execution Workflow stage audit input anchor | ready | `docs/audit/inputs/mtpro-paper-execution-workflow-v1-stage-audit-input.md` |
| Paper Workflow Control Shell stage audit input anchor | ready | `docs/audit/inputs/mtpro-paper-workflow-control-shell-v1-stage-audit-input.md` |
| Market Data Replay Operations stage audit input anchor | ready | `docs/audit/inputs/mtpro-market-data-replay-operations-v1-stage-audit-input.md` |
| Live Trading Boundary stage audit input anchor | ready | `docs/audit/inputs/mtpro-live-trading-boundary-definition-v1-stage-audit-input.md` |
| Live Monitoring Console stage audit input anchor | ready | `docs/audit/inputs/mtpro-live-monitoring-console-v1-stage-audit-input.md` |
| Live Execution Control stage audit input anchor | ready | `docs/audit/inputs/mtpro-live-execution-control-contract-v1-stage-audit-input.md` |
| Live Risk Gate stage audit input anchor | ready | `docs/audit/inputs/mtpro-live-risk-gate-contract-v1-stage-audit-input.md` |
| Live Audit Incident Stop stage audit input anchor | ready | `docs/audit/inputs/mtpro-live-audit-incident-stop-boundary-v1-stage-audit-input.md` |
| Event-Driven Paper Trading Runtime stage audit input anchor | ready | `docs/audit/inputs/mtpro-event-driven-paper-trading-runtime-v1-stage-audit-input.md` |
| Event-Driven Paper Trading Runtime stage code audit report anchor | ready | `docs/audit/mtpro-event-driven-paper-trading-runtime-v1-stage-code-audit.md` |
| Data Catalog / Scenario Replay stage audit input anchor | ready | `docs/audit/inputs/mtpro-data-catalog-scenario-replay-v1-stage-audit-input.md` |
| Data Catalog / Scenario Replay stage code audit report anchor | ready | `docs/audit/mtpro-data-catalog-scenario-replay-v1-stage-code-audit.md` |
| Simulated Exchange / Backtest Parity stage audit input anchor | ready | `docs/audit/inputs/mtpro-simulated-exchange-backtest-parity-v1-stage-audit-input.md` |
| Simulated Exchange / Backtest Parity stage code audit report anchor | ready | `docs/audit/mtpro-simulated-exchange-backtest-parity-v1-stage-code-audit.md` |
| Simulated Exchange / Backtest Parity root docs refresh anchor | ready | Historical Engine Maturity Roadmap Progress `3 / 4 (75%)`；historical maturity statement `L2 Simulated Exchange / Backtest Parity complete` |
| Workbench Beta Readiness contract anchor | ready | `docs/contracts/workbench-beta-readiness-contract.md`；MTP-118 只定义 local macOS Workbench demo / acceptance path，不实现 install / run、engine core、production release 或 live readiness |
| Workbench Beta Readiness local launch / install anchor | ready | `docs/validation/macos-build-run-loop.md`；MTP-119 只定义 SwiftPM local install、Dashboard launch / smoke、environment verification 和 troubleshooting path，不创建 production installer、notarization、App Store、auto-update、production deployment、cloud operations 或 live readiness |
| Workbench Beta Readiness demo scenario / fixture wiring anchor | ready | `Sources/Core/WorkbenchBetaDemoScenario.swift`；MTP-120 只固定 local deterministic demo scenario、dataset / fixture version、checksum / freshness evidence 和 L1.5 / L2 relationship，不新增网络下载、production data platform、Runtime replay job、first-run UI、Report / Dashboard / Events acceptance path、live readiness 或真实交易能力 |
| Workbench Beta Readiness first-run default demo anchor | ready | `Sources/App/WorkbenchBetaFirstRunState.swift`；MTP-121 只把 MTP-120 demo fixture 接入 App Read Model / ViewModel 和 Dashboard smoke default demo state，保留 empty / loading / error fallback，不新增 Live PRO Console、trading button、live command、Runtime replay job、Report / Dashboard / Events acceptance path 或真实交易能力 |
| Workbench Beta Readiness Report / Dashboard / Events beta acceptance path anchor | ready | `Sources/App/WorkbenchBetaAcceptancePath.swift`；MTP-122 只把同一 MTP-120 / MTP-121 demo fixture 串成 Report summary、Dashboard panels、Events trace 和 portfolio evidence 的 read-model-only acceptance path，不新增 Runtime replay job、stage audit input、Live PRO Console、trading button、live command 或真实交易能力 |
| Workbench Beta Readiness reproducible beta acceptance anchor | ready | `checks/workbench-beta-acceptance.sh` 和 `docs/validation/workbench-beta-acceptance-checklist.md`；MTP-123 只把既有 local commands、Dashboard smoke handles 和 `bash checks/run.sh` 串成 operator checklist / script，不新增 Graphify、Figma、production ops、release automation、Live PRO Console、trading button、live command 或真实交易能力 |
| Workbench Beta Readiness docs index / operator guide anchor | ready | `docs/index.md`、`docs/validation/workbench-beta-operator-guide.md` 和 `docs/validation/workbench-beta-demo-workflow-guide.md`；MTP-124 只把 MTP-119 至 MTP-123 的 local Workbench beta path 组织成 operator 可读文档，不新增 production code、stage audit input、production release、Live PRO Console、trading button、live command、Graphify 或 Figma |
| Workbench Beta Readiness stage audit input anchor | ready | `docs/audit/inputs/mtpro-workbench-beta-readiness-v1-stage-audit-input.md`；MTP-125 只收口 MTP-118 至 MTP-124 validation evidence、automation readiness、forbidden capability audit 和 Stage Code Audit 输入材料，不输出最终 Stage Code Audit Report、不修改 Linear status、不运行 Graphify、不修改 Figma、不授权下一阶段或 live readiness |
| Workbench Beta Readiness stage code audit report anchor | ready | `docs/audit/mtpro-workbench-beta-readiness-v1-stage-code-audit.md`；记录 MTP-118 至 MTP-125 Project closure、Linear Project `Completed/type=completed`、PR / merge / checks evidence、validation、Root Docs Delta 和 forbidden capability audit |
| Workbench Beta Readiness root docs refresh anchor | ready | Engine Maturity Roadmap Progress `4 / 4 (100%)`；current maturity statement `L2+ Workbench Beta Readiness complete`；L3 / L4 仍为 Future Gated，不计入当前 progress denominator，不授权下一 Project |
| Live Read-only Readiness contract anchor | ready | `docs/contracts/live-read-only-readiness-boundary-contract.md`；MTP-126 只定义 L3.0 terminology、target engines / layers、handoff boundary、forbidden capability baseline 和 validation anchors，不实现 endpoint、secret、adapter、account read model、UI、live runtime、Graphify 或 Figma |
| Live Read-only credential / endpoint taxonomy anchor | ready | `Sources/Core/LiveTradingBoundary.swift` 中的 `LiveReadOnlyCredentialEndpointTaxonomyBoundary`、`Tests/CoreTests/CoreTests.swift` focused tests 和 `docs/contracts/live-read-only-readiness-boundary-contract.md`；MTP-127 只定义 credential / secret policy future gate、endpoint capability taxonomy、public read-only / private endpoint isolation 和 forbidden capability tests，不实现 API key / secret storage、不读取本地 secret、不实现 signed/account/listenKey/private WebSocket/broker action/runtime |
| Live Read-only adapter capability matrix anchor | ready | `Sources/Core/LiveTradingBoundary.swift` 中的 `LiveReadOnlyAdapterCapabilityMatrixBoundary`、`Tests/CoreTests/CoreTests.swift` focused tests 和 `docs/contracts/live-read-only-readiness-boundary-contract.md`；MTP-128 只定义 public market data allowed、future private account read-only gated 和 forbidden adapter capability matrix，不创建 broker / exchange execution adapter、不实现 `LiveExecutionAdapter`、不把 public adapter 升级为 execution adapter、不实现 signed/account/listenKey/order write/runtime |
| Live Read-only account / position / balance future gate anchor | ready | `Sources/Core/LiveTradingBoundary.swift` 中的 `LiveReadOnlyAccountPositionBalanceFutureGateBoundary`、`Tests/CoreTests/CoreTests.swift` focused tests 和 `docs/contracts/live-read-only-readiness-boundary-contract.md`；MTP-129 只定义 account / position / balance read-model-only future gates、source identity、snapshot freshness、evidence identity 和 ViewModel boundary，不实现 account / position / balance runtime、不读取 real account、不同步 broker position、不读取 margin / leverage / real PnL、不实现 signed/account/listenKey/broker/runtime |
| Live Read-only private stream / account snapshot simulation gate anchor | ready | `Sources/Core/LiveTradingBoundary.swift` 中的 `LiveReadOnlyPrivateStreamAccountSnapshotSimulationGateBoundary`、`Tests/CoreTests/CoreTests.swift` focused tests 和 `docs/contracts/live-read-only-readiness-boundary-contract.md`；MTP-130 只定义 private stream / account snapshot simulation gate input material、future fixture requirements、listenKey forbidden tests 和 simulation gate / live stream isolation，不创建 listenKey、不连接 private WebSocket、不运行 account snapshot runtime、不实现 signed/account endpoint、broker adapter、`LiveExecutionAdapter`、OMS、trading button 或 live command |
| Live Read-only Workbench read-model-only boundary anchor | ready | `Sources/Core/LiveTradingBoundary.swift` 中的 `LiveReadOnlyWorkbenchReadModelBoundary`、`Sources/App/LiveReadOnlyWorkbenchBoundary.swift` 中的 `LiveReadOnlyWorkbenchBoundaryReadModel` / `LiveReadOnlyWorkbenchBoundaryViewModel`、`Sources/App/DashboardShell.swift` / `Sources/App/PaperWorkflowEvidenceExplorer.swift` read-only wiring、focused tests 和 `docs/contracts/live-read-only-readiness-boundary-contract.md`；MTP-131 只定义 Workbench / Dashboard / Report / Event Timeline 的 Live readiness read-model-only UI boundary、forbidden UI surface、detail / audit route 和 L3 handoff，不新增 API key input、secret storage、broker/account connect、Live PRO Console、trading button、live command、order form、signed/account/listenKey endpoint、Runtime object、database schema、adapter request、`LiveExecutionAdapter`、OMS 或真实订单动作 |
| Live Read-only Readiness stage audit input anchor | ready | `docs/audit/inputs/mtpro-live-read-only-readiness-boundary-v1-stage-audit-input.md`；MTP-132 只收口 MTP-126 至 MTP-131 validation evidence、automation readiness、forbidden capability audit、read-model-only boundary evidence 和 Stage Code Audit 输入材料，不输出最终 Stage Code Audit Report、不修改 Linear status、不运行 Graphify、不修改 Figma、不授权下一阶段或 live runtime |
| Live Read-only Readiness stage code audit report anchor | ready | `docs/audit/mtpro-live-read-only-readiness-boundary-v1-stage-code-audit.md`；记录 MTP-126 至 MTP-132 Project closure、Linear Project `Completed/type=completed`、PR / merge / checks evidence、validation、Root Docs Delta 和 forbidden capability audit |
| Live Read-only Readiness root docs refresh anchor | ready | Engine Maturity Roadmap Progress 保持 `4 / 4 (100%)`；current maturity statement `L3.0 Live Read-only Readiness Boundary complete`；L3.1 / L3.2 / L3.3 / L3.4 / L4 仍为 Future Gated，不计入旧 progress denominator，不授权下一 Project；L3.4 只记录 Strategy / Trader Instance readiness 候选，不授权 Execution Client、broker command、OMS、trading button 或 live command |
| Account / Position / Balance read-model-only terminology anchor | ready | `docs/contracts/account-position-balance-read-model-only-contract.md`；MTP-133 只定义 L3.1 account / position / balance read-model-only terminology、source semantics、evidence interpretation、L3.1 / L3.2 handoff、first executable candidate non-authorization 和 forbidden capability baseline，不实现 account / position / balance runtime、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、broker adapter、`LiveExecutionAdapter`、OMS、real PnL、Live PRO Console、trading button、live command 或 order form |
| Account snapshot identity / freshness evidence anchor | ready | `docs/contracts/account-position-balance-read-model-only-contract.md`；MTP-134 只定义 account snapshot identity、account evidence id、source identity、observedAt、source watermark、fresh / stale / missing / blocked freshness evidence、adapter capability bypass guard 和 account snapshot not runtime，不实现 account snapshot runtime、signed endpoint、account endpoint / listenKey、private WebSocket runtime、secret storage、credential provider、broker adapter、`LiveExecutionAdapter`、OMS、real account balance、margin、leverage、real PnL、Live PRO Console、trading button、live command 或 order form |
| Position snapshot identity / exposure evidence anchor | ready | `docs/contracts/account-position-balance-read-model-only-contract.md`；MTP-135 只定义 position snapshot identity、position evidence id、source identity、symbol / side / quantity、exposure evidence、scenario version、paper / simulated / future real position isolation、stale / blocked / simulated evidence 和 forbidden broker position interpretation，不同步 broker position，不实现 broker adapter、account endpoint、listenKey、private stream、`LiveExecutionAdapter`、OMS、real PnL runtime、Live PRO Console、trading button、live command 或 order form |
| Balance snapshot identity / paper-vs-real boundary anchor | ready | `docs/contracts/account-position-balance-read-model-only-contract.md`；MTP-136 只定义 balance snapshot identity、balance evidence id、paper cash、paper equity、simulated balance、fixture balance、future-gated real balance、paper-vs-real interpretation boundary、real PnL / margin / leverage / buying power forbidden baseline 和 balance stale / blocked evidence，不读取真实账户余额，不实现 real PnL runtime，不接 signed endpoint、account endpoint、listenKey、broker adapter、`LiveExecutionAdapter`、OMS、Live PRO Console、trading button、live command 或 order form |
| Account / Position / Balance fixture / forbidden real account tests anchor | ready | `Sources/Core/LiveTradingBoundary.swift` 中的 `AccountPositionBalanceReadModelOnlyFixtureContract`、`Tests/CoreTests/CoreTests.swift` focused tests 和 `docs/contracts/account-position-balance-read-model-only-contract.md`；MTP-137 只定义 deterministic local fixture shape、fixture version、checksum、freshness、source identity、forbidden real account tests、fixture-to-read-model mapping isolation 和 real account payload isolation，不实现真实账户 fixture importer、不导入 broker payload、不调用 signed endpoint、account endpoint / listenKey、不连接 private WebSocket、不实现 account snapshot runtime、broker adapter、`LiveExecutionAdapter`、OMS、real PnL、margin、leverage、Live PRO Console、trading button、live command 或 order form |
| Account / Position / Balance Workbench / Report / Events read-model-only surface anchor | ready | `Sources/App/AccountPositionBalanceReadModelOnlySurface.swift`、`Sources/App/DashboardShell.swift`、`Sources/App/PaperWorkflowEvidenceExplorer.swift` 和 `Tests/AppTests/AppTests.swift`；MTP-138 只把 MTP-137 deterministic fixture evidence 接入 Workbench / Report / Events read-model-only surface，展示 APB records、fixture、freshness、evidence id、blocked / stale / simulated states、Dashboard smoke handle 和三条 Event Timeline items，不实现 account / position / balance runtime、不读取真实账户、不调用 signed endpoint、account endpoint / listenKey、不连接 private WebSocket、不暴露 account payload、broker state、schema、Runtime object、adapter request，不新增 API key input、broker/account connect、Live PRO Console、trading button、live command 或 order form |
| Account / Position / Balance stage audit input anchor | ready | `docs/audit/inputs/mtpro-account-position-balance-read-model-only-v1-stage-audit-input.md`；MTP-139 只收口 MTP-133 至 MTP-138 validation matrix、automation readiness、forbidden capability evidence chain、read-model-only boundary evidence、Workbench / Report / Events APB surface evidence 和 Stage Code Audit 输入材料，不输出最终 Stage Code Audit Report、不设置 Linear Project `Completed`、不运行 Graphify、不修改 Figma、不授权下一阶段或 account / position / balance runtime |
| Account / Position / Balance stage code audit report anchor | ready | `docs/audit/mtpro-account-position-balance-read-model-only-v1-stage-code-audit.md`；记录 MTP-133 至 MTP-139 Project closure、Linear Project `Completed/type=completed`、PR / merge / checks evidence、validation、Root Docs Delta 和 forbidden capability audit |
| Account / Position / Balance root docs refresh anchor | ready | Engine Maturity Roadmap Progress 保持 `4 / 4 (100%)`；current maturity statement `L3.1 Account / Position / Balance Read-model-only complete`；Project Closure Count `18 / 18 (100%)`；L3.2 / L3.3 / L3.4 / L4 仍为 Future Gated，不计入旧 progress denominator，不授权下一 Project；不授权 private stream runtime、account snapshot runtime、signed endpoint、account endpoint / listenKey、broker adapter、OMS、Live PRO Console、trading button 或 live command |
| Private Stream / Account Snapshot Simulation Gate terminology anchor | ready | `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md`；MTP-140 只定义 L3.2 private stream / account snapshot simulation gate terminology、fixture / simulated / future real private stream boundary、L3.1 APB relationship、forbidden capability baseline 和 first executable candidate non-authorization，不实现 private stream runtime、account snapshot runtime、listenKey、signed/account endpoint、broker adapter、Live PRO Console、trading button、live command 或 order form |
| Private Stream / Account Snapshot Simulation Gate source identity anchor | ready | `Sources/Core/LiveTradingBoundary.swift` 中的 `SimulatedPrivateAccountEventSourceIdentityContract`、`Tests/CoreTests/CoreTests.swift` focused tests 和 `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md`；MTP-141 只定义 simulated private account event source identity、fixture source、scenario id、dataset / fixture version、checksum / freshness linkage、future real private stream future-gated label、forbidden live stream source tests 和 adapter capability matrix bypass guard，不创建 listenKey、不连接 private WebSocket、不调用 signed/account endpoint、不实现 private stream runtime 或 account snapshot runtime、不读取真实 account / broker payload、不暴露 adapter request、不新增 Live PRO Console、trading button、live command 或 order form |
| Private Stream / Account Snapshot Simulation Gate snapshot input anchor | ready | `Sources/Core/LiveTradingBoundary.swift` 中的 `SimulatedAccountSnapshotInputContract`、`Tests/CoreTests/CoreTests.swift` focused tests 和 `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md`；MTP-142 只定义 simulated account snapshot input shape、snapshot id、MTP-141 source identity、observedAt、freshness status、missing / blocked input state taxonomy、fixture version、checksum、deterministic replay linkage、fixture-to-read-model mapping boundary 和 account payload isolation tests，不实现 account snapshot runtime、不调用 signed/account endpoint、不创建 listenKey、不连接 private WebSocket、不实现 private stream runtime、不读取真实账户、真实余额、margin、leverage 或 real PnL、不暴露 account endpoint payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema、不新增 Live PRO Console、trading button、live command 或 order form |

## Project 切换规则

`symphony-issue active Project pointer` 属于本地 runtime 配置，不是仓库长期事实。

Parent Codex 切换 Project 时只更新：

- Project name
- Project ID / URL source
- Project slug
- issue range
- next eligible candidate hint

更新后必须再次 queue preview。不得因为 pointer 更新直接启动 `symphony-issue` 或推进 `Backlog -> Todo`。

## 必须保持

- WIP=1。
- `.github/pull_request_template.md` 保留 WIP=1、Graphify、handoff、Parent Codex、Post-Issue Ledger、GitHub PR Automation、Pre-PR Code Review 和 verified operations 证据项。
- Project Planning Facilitator 不操作 `Backlog -> Todo`。
- Human 确认 Project / Issue plan 并写入 Linear 后，父 Codex 在当前 Project 内按 WIP=1、依赖和执行合同 Gate 自动推进唯一 eligible issue。
- `symphony-issue` workflow 本体不得为每个 Linear Project 复制一套。
- `.gitignore` 排除 `.codex/` 和 `graphify-out/`。
- `.graphifyignore` 排除 `.codex/`、`graphify-out/`、`Sources/` 和 `Tests/`。
- Graphify 默认是 resource relationship graph，不是 source code graph。

## 禁止

- 不在文档中固定 current issue。
- 不自动创建新的 Linear Project / Issue。
- 不绕过 GitHub required checks。
- 不运行 Graphify full rebuild。
- 不提交 `.codex/*` 或 `graphify-out/*`。
