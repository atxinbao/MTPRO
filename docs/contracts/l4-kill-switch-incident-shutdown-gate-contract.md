# L4 Kill Switch / Incident Shutdown Gate Contract

日期：2026-06-07  
执行者：Codex

## Scope

`GH-465-KILL-SWITCH-INCIDENT-SHUTDOWN-GATE` 固定 `MTPRO L4 Live Production / Trading Commands v1`
第 14/21 个 GitHub fallback queue item 的 kill switch / incident stop / command shutdown gate evidence。

本合同只实现 deterministic local shutdown gate：source identity、incident stop 激活、submit / cancel /
replace shutdown rules、Dashboard / audit explainable evidence，以及 no automatic recovery boundary。
它不实现 production operations runbook，不调用真实 emergency broker API，不打开 L4 production，不提供 Live PRO Console
command surface、order form 或 trading button。

## GH-465 Incident Stop Source Identity

`GH-465-INCIDENT-STOP-SOURCE-IDENTITY` 固定：

- source identity 必须绑定 GH-464 incident stop decision。
- source identity 必须记录 source kind、source id、incident id、reason 和 upstream risk decision id。
- source identity 不能授权 auto recovery。
- source identity 不能触碰 Live command surface、production operations runtime 或 broker gateway。

## GH-465 Submit / Cancel / Replace Shutdown Rules

`GH-465-SUBMIT-CANCEL-REPLACE-SHUTDOWN-RULES` 固定：

- incident stop active 后，submit / cancel / replace 都必须被 `blocked by command shutdown` 阻断。
- 每个 command decision 必须携带 source identity 和 upstream GH-464 risk decision identity。
- 每个 command decision 必须保留 `incident stop active`、`command shutdown active`、`manual recovery required`
  和 `production trading disabled` reason。
- shutdown decision 不执行 command，不调用 ExecutionClient，不触碰 broker gateway，不提交真实订单。

## GH-465 Dashboard / Audit Shutdown Evidence

`GH-465-DASHBOARD-AUDIT-SHUTDOWN-EVIDENCE` 固定 shutdown evidence 可以被 Dashboard / audit 解释，但只能作为
read-model / audit evidence。该 evidence 不创建 Dashboard command button，不创建 Live PRO Console，不升级为 production
operations runtime。

## GH-465 No Automatic Recovery

`GH-465-NO-AUTOMATIC-RECOVERY` 固定恢复条件：

- no automatic recovery。
- requires manual review evidence。
- requires fresh RiskEngine gate。
- requires future production cutover gate。

这些恢复条件只作为边界证据；本 issue 不实现 restore command，不实现 production cutover，也不允许绕过 shutdown gate。

## Validation

`TVM-L4-KILL-SWITCH-INCIDENT-SHUTDOWN-GATE` 对应验证：

- `testGH465KillSwitchIncidentShutdownGateBlocksAllCommandsAndDefinesRecoveryBoundary`
- `testGH465KillSwitchIncidentShutdownGateRejectsAutoRecoveryAndCommandBypass`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Non-authorization

`GH-465-NON-AUTHORIZATION`：本合同不授权 GH-466 reconciliation，不授权 GH-468 Dashboard / Live PRO Console command split，
不授权 GH-469 guarded submit / cancel / replace UI，不授权 GH-471 production cutover。合并本 issue 后，MTPRO 仍没有
production trading、real order lifecycle、broker gateway、Live PRO Console command surface、order form 或 trading button。
