# Release v0.5.0 Run Observer Surface Contract

日期：2026-06-14
执行者：Codex

## Anchors

- `V050-12-DASHBOARD-CLI-RUN-OBSERVER`
- `V050-12-RUNID-STATUS-EVENTS-PROJECTION-RISK`
- `V050-12-DASHBOARD-SECTIONS-CONSUME-RUN-JOURNAL`
- `V050-12-BLOCKED-REJECTED-BOUNDARY-EVIDENCE`
- `V050-12-NO-PRODUCTION-COMMAND-SURFACE`
- `TVM-RELEASE-V050-DASHBOARD-CLI-RUN-OBSERVER`

## Scope

GH-737 将 Dashboard 和 CLI 固定为 v0.5.0 run observer surface。observer 只读取 runID 关联的 durable run journal、risk decisions、OMS dry-run timeline、Execution dry-run evidence、Portfolio projection 和 boundary evidence。

实现入口：

- `Sources/Portfolio/ReleaseV050RunObserverSurface.swift`
- `Sources/Dashboard/Report/ReleaseV050DashboardRunObserverSurface.swift`
- `Sources/MTPROCLI/main.swift`

CLI 只暴露显式 observer 命令：

- `mtpro run-observer list`
- `mtpro run-observer status [runID]`
- `mtpro run-observer events [runID]`
- `mtpro run-observer projection [runID]`
- `mtpro run-observer risk [runID]`

Dashboard 只消费 `ReleaseV050RunObserverSurfaceEvidence` 并生成 read-model ViewModel。

## Required Evidence

- `ReleaseV050RunObserverSurfaceEvidence.issueID == GH-737`
- upstream issues 固定为 `GH-731`、`GH-735`、`GH-736`
- `previousIssueID == GH-736`
- downstream issues 固定为 `GH-738`、`GH-739`
- observer 由 run journal replay 和 GH-736 Portfolio projection evidence 派生
- Dashboard sections 固定覆盖 Run Overview、Data Freshness、Strategy Intents、Risk Decisions、OMS Timeline、Execution Dry-run Evidence、Portfolio Projection、Blocked / Rejected Reasons、Environment / Endpoint / Secret Boundary
- CLI command set 固定覆盖 list、status、events、projection、risk
- risk observer 必须展示 rejected / blocked reasons
- projection observer 必须展示 runID、projectionID、productTypes 和 exposure read model
- v0.5.0 path 不使用 default demo snapshot

## Boundary

GH-737 是 observer surface，不是 command surface。

必须保持：

- `tradingButtonExposed == false`
- `orderFormExposed == false`
- `liveCommandSurfaceExposed == false`
- `productionCommandSurfaceExposed == false`
- `brokerExecutionWriteEnabled == false`
- `productionTradingEnabledByDefault == false`
- `productionEndpointConnected == false`
- `productionSecretAutoReadEnabled == false`
- `productionOrderSubmitted == false`
- `productionCutoverAuthorized == false`

## Validation

- `swift test --filter TargetGraphTests/testGH737DashboardCLIRunObserverReadsJournalProjectionAndBoundaryByRunID`
- `bash checks/verify-v0.5.0-observer.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
