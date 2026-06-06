# L4 Live Production Command Contract

日期：2026-06-07

执行者：Codex

本文档服务 GitHub fallback issue `GH-452 L4: 01/21 Define L4 live production command contract and acceptance matrix`。

本文档定义 `MTPRO L4 Live Production / Trading Commands v1` 的顶层命令合同、read-only -> guarded command 转换规则、sandbox / production gate、command authorization、evidence identity、rollback evidence 和 acceptance matrix。它不授权 Linear，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不读取 secret，不连接 production endpoint，不实现 signed endpoint、private stream、ExecutionClient adapter、OMS、RiskEngine live runtime、Live PRO Console、trading button、live command 或 order form。

## GH-452-L4-LIVE-PRODUCTION-COMMAND-CONTRACT

`GH-452-L4-LIVE-PRODUCTION-COMMAND-CONTRACT`

L4 command contract 是 GH-452 至 GH-472 的共同上层合同。后续 issue 只能在自己的 scope 内逐项补齐 gate，不得用一个 issue 越级打开 production trading。

当前权威 source anchor：

- `Sources/ExecutionClient/FutureGate/L4LiveProductionCommandContract.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH452L4LiveProductionCommandContractDefinesDisabledProductionMatrix`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH452L4LiveProductionCommandContractRejectsProductionBypass`

合同固定：

- queue range：`GH-452..GH-472`
- maturity slice：`MTPRO L4 Live Production / Trading Commands v1`
- production 默认禁用。
- sandbox gate 必须先于 command。
- command authorization 必须先于 submit / cancel / replace。
- RiskEngine pre-trade gate 必须先于 execution。
- OMS lifecycle gate 必须先于 ExecutionClient outbound path。
- audit trail 和 rollback evidence 必须进入 acceptance matrix。
- no-default-real-trading policy 必须在 #471 前保持关闭状态。

## GH-452-READONLY-TO-GUARDED-COMMAND-RULE

`GH-452-READONLY-TO-GUARDED-COMMAND-RULE`

read-only evidence 只能在满足所有 gate 后转成 guarded command input：

```text
read-only evidence
-> command authorization evidence
-> sandbox gate
-> RiskEngine pre-trade gate
-> OMS lifecycle gate
-> ExecutionClient sandbox adapter gate
-> audit trail evidence
-> rollback evidence
```

当前 GH-452 只定义顺序，不实现转换 runtime。任何后续 issue 如要实现某个步骤，必须先完成依赖 issue、保持 GitHub fallback WIP=1，并在 PR 中证明 production 仍默认禁用。

## GH-452-SANDBOX-PRODUCTION-GATE

`GH-452-SANDBOX-PRODUCTION-GATE`

L4 允许后续 issue 逐步定义 sandbox-gated 能力，但 production gate 默认关闭：

| Gate | 当前 GH-452 状态 | 后续 issue |
| --- | --- | --- |
| credential / environment | contract only | GH-453 |
| signed endpoint / private stream boundary | contract only | GH-454 |
| signed account read-only runtime behind disabled production gate | blocked until explicit issue | GH-455 |
| private stream / account snapshot read-only runtime | blocked until explicit issue | GH-456 |
| ExecutionClient sandbox submit / cancel / replace | blocked until contract + adapter gate | GH-458 / GH-459 |
| production cutover | forbidden before full matrix closure | GH-471 |

GH-452 本身不读取 API key，不打印 secret，不连接 sandbox 或 production 网络。

## GH-452-COMMAND-AUTHORIZATION-EVIDENCE-IDENTITY

`GH-452-COMMAND-AUTHORIZATION-EVIDENCE-IDENTITY`

后续 guarded command 必须携带可审计 evidence identity：

- queue issue anchor：例如 `GH-459`。
- command gate anchor：例如 `sandbox gate`、`command authorization`。
- risk gate anchor：例如 `RiskEngine pre-trade gate`。
- OMS / execution anchor：例如 `OMS lifecycle state machine`、`ExecutionClient venue adapter contract`。
- audit / rollback anchor：例如 `audit trail evidence`、`rollback evidence`。

Evidence identity 不能包含 secret value、API key value、signed request payload、account endpoint payload、listenKey value、broker payload 或 production endpoint credential。

## GH-452-ACCEPTANCE-MATRIX

`GH-452-ACCEPTANCE-MATRIX`

GH-452 的 acceptance matrix 必须覆盖：

| Domain | Required gates | Issue anchors | Current forbidden capability |
| --- | --- | --- | --- |
| command | GitHub fallback WIP=1、sandbox gate、command authorization | GH-452、GH-459、GH-469 | real submit / cancel / replace、direct Dashboard broker command、parallel active issue |
| risk | RiskEngine pre-trade gate、kill switch / incident stop gate | GH-464、GH-465、GH-470 | RiskEngine bypass、production trading enabled by default |
| execution | ExecutionClient venue adapter contract、OMS lifecycle state machine、signed endpoint boundary | GH-458、GH-459、GH-460、GH-461、GH-462、GH-463 | unguarded signed endpoint、OMS bypass、production execution report / broker fill ingestion |
| audit | audit trail evidence、kill switch / incident stop gate | GH-465、GH-467、GH-472 | Live PRO Console command surface、production broker endpoint |
| rollback | rollback evidence、kill switch / incident stop gate | GH-465、GH-466、GH-467、GH-470 | reconciliation production runtime、production trading enabled by default |
| credential | credential / environment gate、production disabled by default | GH-453、GH-454、GH-455 | credential value print、production broker endpoint |
| private stream | private stream boundary、signed endpoint boundary | GH-454、GH-456、GH-457 | unguarded private stream、unguarded signed endpoint |
| dashboard command surface | command authorization、RiskEngine pre-trade gate、audit trail evidence | GH-468、GH-469 | direct Dashboard broker command、Live PRO Console command surface、order form |
| production cutover | production disabled by default、no-default-real-trading policy、rollback evidence | GH-470、GH-471、GH-472 | production trading enabled by default、production broker endpoint |

该矩阵由 `L4LiveProductionCommandContract.requiredAcceptanceMatrix` 和 TargetGraph focused tests 机械验证。

## GH-452-NO-DEFAULT-REAL-TRADING-POLICY

`GH-452-NO-DEFAULT-REAL-TRADING-POLICY`

L4 不允许默认打开 real trading：

- `productionTradingEnabledByDefault == false`
- `connectsProductionEndpoint == false`
- `usesSignedEndpoint == false`
- `opensPrivateStream == false`
- `implementsExecutionClientAdapter == false`
- `implementsOMS == false`
- `submitsRealOrder == false`
- `cancelsRealOrder == false`
- `replacesRealOrder == false`
- `consumesExecutionReport == false`
- `recordsBrokerFill == false`
- `performsReconciliation == false`
- `exposesLiveProConsoleCommandSurface == false`
- `exposesOrderForm == false`

这些 false flags 是 GH-452 的验收边界，不是隐藏 feature flag。#471 之前不得通过配置、环境变量或 UI 默认启用 production trading。

## GH-452-VALIDATION-ANCHORS

`GH-452-VALIDATION-ANCHORS`

Required anchors：

- `GH-452-L4-LIVE-PRODUCTION-COMMAND-CONTRACT`
- `GH-452-READONLY-TO-GUARDED-COMMAND-RULE`
- `GH-452-SANDBOX-PRODUCTION-GATE`
- `GH-452-COMMAND-AUTHORIZATION-EVIDENCE-IDENTITY`
- `GH-452-ACCEPTANCE-MATRIX`
- `GH-452-NO-DEFAULT-REAL-TRADING-POLICY`
- `TVM-L4-LIVE-PRODUCTION-COMMANDS`

Required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## GH-452-NON-AUTHORIZATION

`GH-452-NON-AUTHORIZATION`

GH-452 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- production trading。
- secret value read / print。
- signed endpoint / account endpoint / listenKey。
- private WebSocket runtime。
- ExecutionClient adapter implementation。
- OMS implementation。
- RiskEngine live runtime。
- submit / cancel / replace。
- execution report / broker fill production ingestion。
- reconciliation production runtime。
- Dashboard direct broker command。
- Live PRO Console command surface。
- order form / trading button。
