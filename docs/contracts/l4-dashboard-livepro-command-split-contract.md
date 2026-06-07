# L4 Dashboard / Live PRO Console Command Split Contract

日期：2026-06-07
执行者：Codex

## Scope

`GH-468-DASHBOARD-LIVEPRO-READONLY-COMMAND-SPLIT` 固定 `MTPRO L4 Live Production / Trading Commands v1`
第 17/21 个 GitHub fallback queue item 的 Dashboard / future Live PRO Console read-only-to-command split。

本合同只实现 deterministic Dashboard target ViewModel / command-gate evidence：Dashboard 继续 read-model-only，
submit / cancel / replace 只能作为未来 Live PRO Console 的 gated action labels 被描述，并且默认不可见或 disabled。
它不实现 guarded UI，不创建 order form，不打开 production command，不绕过 RiskEngine / OMS，不触碰 broker gateway。

## GH-468 Dashboard Read-model-only

`GH-468-DASHBOARD-READ-MODEL-ONLY` 固定 Dashboard 只能消费 ViewModel / ReadModel / CommandGate state。Dashboard
不能显示 submit / cancel / replace action，不能显示 trading button，不能显示 order form，不能提供 broker connect、
signed endpoint、account endpoint 或 private stream control。

## GH-468 Live PRO Console Command Gate

`GH-468-LIVEPRO-CONSOLE-COMMAND-GATE` 固定未来 command surface 的唯一位置是 Live PRO Console gate。GH-468
只定义 gate state 与 action labels，不渲染按钮，不启用 command，不提交 / 撤销 / 替换订单。真正 guarded UI surface
必须等 GH-469。

## GH-468 Read-only / Armed / Blocked / Incident States

`GH-468-READONLY-ARMED-BLOCKED-INCIDENT-STATES` 固定 command gate 必须表达：

- `read-only`：Dashboard read-model-only，command surface hidden。
- `armed`：future Live PRO Console gate 可描述，但 command disabled until GH-469。
- `blocked`：kill switch / command shutdown gate 阻断 command surface。
- `incident`：incident state 隐藏 command surface，并要求 audit review。

这些状态只进入 ViewModel evidence，不触发 runtime side effect。

## GH-468 No Dashboard Submit / Cancel / Replace

`GH-468-NO-DASHBOARD-SUBMIT-CANCEL-REPLACE` 固定 Dashboard 不提供 submit / cancel / replace。任何 Dashboard
visible action、enabled action、trading button、order form 或 Live command exposure 都必须被合同测试拒绝。

## Validation

`TVM-L4-DASHBOARD-LIVEPRO-COMMAND-SPLIT` 对应验证：

- `testGH468DashboardLivePROConsoleSplitKeepsDashboardReadModelOnly`
- `testGH468DashboardLivePROConsoleSplitRejectsDashboardCommandsAndGateBypass`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Non-authorization

`GH-468-NON-AUTHORIZATION`：本合同不授权 GH-469 guarded submit / cancel / replace UI，不授权 GH-470 sandbox
validation matrix closure，不授权 GH-471 production cutover。合并本 issue 后，MTPRO 仍没有 production command、
real broker gateway、Live PRO Console executable command surface、order form、trading button 或 real submit / cancel /
replace。
