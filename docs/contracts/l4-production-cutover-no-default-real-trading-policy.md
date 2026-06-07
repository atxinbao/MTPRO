# L4 Production Cutover Gate and No-default-real-trading Policy

日期：2026-06-07

执行者：Codex

本文档服务 GitHub fallback issue `GH-471 L4: 20/21 Define production cutover gate and no-default-real-trading policy`。

本文档定义 `MTPRO L4 Live Production / Trading Commands v1` 从 sandbox evidence 进入 future production cutover 的人工和技术门槛。它不执行 production cutover，不读取 secret，不连接 production endpoint，不启用 broker gateway，不实现 order form、trading button 或真实 submit / cancel / replace。

## GH-471 Production Cutover Future Gate

`GH-471-PRODUCTION-CUTOVER-FUTURE-GATE`

Production cutover 必须是独立 future gate，不能由本地验证、CI、环境变量默认值、隐藏 flag、Dashboard 控件或 Live PRO Console shortcut 自动打开。当前权威 source anchor：

- `Sources/ExecutionClient/FutureGate/L4ProductionCutoverGatePolicy.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH471ProductionCutoverGatePolicyDefinesNoDefaultRealTradingBoundary`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH471ProductionCutoverGatePolicyRejectsAutomaticCutoverAndProductionBypass`

Required prerequisites：

- `sandbox validation matrix closed`
- `human project approval`
- `manual production confirmation`
- `credential isolation`
- `environment isolation`
- `incident stop ready`
- `rollback plan ready`
- `audit trail ready`
- `reconciliation evidence ready`
- `stage audit input ready`
- `no-default-real-trading policy`

## GH-471 No-default-real-trading Policy

`GH-471-NO-DEFAULT-REAL-TRADING-POLICY`

No-default-real-trading policy 固定以下 flags 必须保持 false：

- `productionTradingEnabledByDefault`
- `automaticProductionCutoverEnabled`
- `automationOnlyCutoverAllowed`
- `readsCredentialValue`
- `storesSecret`
- `callsSignedEndpoint`
- `connectsProductionEndpoint`
- `enablesBrokerGateway`
- `submitsRealOrder`
- `cancelsRealOrder`
- `replacesRealOrder`
- `exposesDashboardCommandBypass`
- `exposesLiveProConsoleProductionCommand`
- `exposesOrderForm`
- `exposesTradingButton`

这些 false flags 是合同边界，不是可由配置开启的 feature flag。GH-471 合并后，MTPRO 仍没有 production trading。

## GH-471 Human Acceptance Criteria

`GH-471-HUMAN-ACCEPTANCE-CRITERIA`

Future production cutover 的 acceptance criteria 必须全部要求 Human acceptance：

| Criterion | Evidence anchor | Required issue anchors |
| --- | --- | --- |
| sandbox matrix closure | `GH-470-SANDBOX-VALIDATION-MATRIX-CLOSEOUT` | `GH-470` |
| manual production approval | `GH-471-HUMAN-ACCEPTANCE-CRITERIA` | `GH-470`、`GH-471` |
| credential and environment isolation | `GH-471-ENVIRONMENT-CREDENTIAL-INCIDENT-STOP-GATES` | `GH-453`、`GH-454`、`GH-470`、`GH-471` |
| incident stop and rollback readiness | `GH-471-NO-DEFAULT-REAL-TRADING-POLICY` | `GH-465`、`GH-466`、`GH-467`、`GH-470`、`GH-471` |
| stage audit input handoff | `GH-472-STAGE-AUDIT-INPUT-REQUIRED` | `GH-470`、`GH-471`、`GH-472` |

`allowsAutomationOnlyCutover` 必须保持 false。`requiresHumanAcceptance` 必须保持 true。

## GH-471 Environment / Credential / Incident-stop Gates

`GH-471-ENVIRONMENT-CREDENTIAL-INCIDENT-STOP-GATES`

Production cutover gate 需要以下 evidence 同时存在后才能交给未来阶段讨论：

- credential identity 只能引用 key name / source identity，不能读取或保存 API key / secret value；
- sandbox 与 production environment 必须隔离，production endpoint 不得默认连接；
- incident stop / kill switch evidence 必须可审计；
- rollback plan 和 reconciliation evidence 必须完成；
- audit trail / incident replay evidence 必须可追溯；
- Stage Audit input 必须由 GH-472 收口。

## GH-471 Validation Anchors

`TVM-L4-PRODUCTION-CUTOVER-GATE`

Required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## GH-471 Non-authorization

`GH-471-NON-AUTHORIZATION`

GH-471 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- production cutover execution。
- production endpoint connection。
- API key / secret read or storage。
- signed endpoint / account endpoint / listenKey。
- private WebSocket runtime。
- broker gateway enablement。
- production command。
- Dashboard command bypass。
- Live PRO Console production command。
- order form / trading button。
- real submit / cancel / replace。
- GH-472 Stage Code Audit input closure 之外的下一 Project / Issue。
