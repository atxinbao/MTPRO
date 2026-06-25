# Release v0.16.0 Dashboard Artifact-backed Execution View Contract

日期：2026-06-26  
执行者：Codex  
Issue：#1108 / GH-1108

## Goal

`GH-1108-VERIFY-V0160-DASHBOARD-ARTIFACT-BACKED-EXECUTION-VIEW`

在 Dashboard 中展示 v0.16.0 Binance Spot Testnet operator run 的本地 artifact-backed execution view。该视图只消费 #1106 local execution artifact store 和 #1107 OMS observed-status reconciliation 的脱敏 read model。

## Scope

- `TVM-RELEASE-V0160-DASHBOARD-ARTIFACT-BACKED-EXECUTION-VIEW`
- `V0160-008-LOCAL-ARTIFACT-BACKED-ROWS`
- `V0160-008-ACTION-SEQUENCE-VISIBLE`
- `V0160-008-CHECKSUMS-VISIBLE`
- `V0160-008-OMS-RECONCILIATION-RESULT-VISIBLE`

Dashboard 必须展示 submit / cancel / status action sequence、artifact record id、artifact checksum、本地 artifact path、observed status、failure reason 和 OMS reconciliation result。

## Non-goals

- 不启用 production trading。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不提交、撤销或替换 production order。
- 不授权 production cutover。
- 不增加 Dashboard trading button、order form、live command 或 command handler。
- 不扩大到非 Binance venue。

## Boundary

`V0160-008-DASHBOARD-READ-ONLY-NO-COMMANDS`

Dashboard target 只消费 read model artifact。它不依赖 ExecutionClient runtime，不读取 credential value，不连接 network，不构造 signed request，不提交 testnet 或 production order。

`V0160-008-NO-PRODUCTION-CUTOVER`

该 issue 只完成本地只读 evidence surface。Production cutover 仍未授权。

## Validation

- `swift test --filter AppTests/testGH1108DashboardArtifactBackedExecutionViewShowsLocalArtifactsWithoutCommands`
- `swift test --filter TargetGraphTests/testGH1108DashboardArtifactBackedExecutionViewIsAnchoredInV0160Guards`
- `bash checks/verify-v0.16.0-dashboard-artifact-backed-execution-view.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
