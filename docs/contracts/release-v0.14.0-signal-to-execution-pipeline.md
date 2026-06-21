# Release v0.14.0 Signal to Execution Pipeline Contract

日期：2026-06-21  
执行者：Codex

## Scope

`GH-1037-SIGNAL-TO-EXECUTION-PIPELINE` 固定 v0.14.0 的本地闭环证据路径：

Strategy Signal -> OrderIntent -> RiskEngine -> ExecutionContract -> Binance testnet adapter evidence -> OMS local order store -> Order Event Log -> OMS State Sync -> Reconciliation。

该合同只覆盖 Binance、Spot + USDⓈ-M Perpetual、EMA + RSI。它不创建生产交易授权，不读取生产 secret，不连接 production / broker endpoint，也不发送真实订单。

## Rules

- `GH-1037-STRATEGY-NO-DIRECT-EXECUTIONCLIENT`：EMA / RSI strategy signal 只能生成 pre-risk `OrderIntent`，不能直连 `ExecutionClient`、OMS、broker command 或 production endpoint。
- `GH-1037-RISK-TO-RECONCILIATION-EVIDENCE`：只有 RiskEngine accepted decision 才能继续进入 ExecutionContract、testnet submit evidence、OMS event log、state sync 和 reconciliation。
- rejected / blocked decision 必须停在 RiskEngine，report 为 `failedClosed`，且不得产生 adapter / OMS / reconciliation evidence ID。
- passed report 必须覆盖全部 pipeline stage，并且 reconciliation report status 必须为 `passed`。

## Boundary

- `productionTradingEnabledByDefault=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `productionSubmitCancelReplace=false`
- testnet submit 只生成 redacted evidence；`networkOrderActionPerformed` 保持 false。
- 不新增 Dashboard trading button、order form、production cutover 或 real-money order path。

## Validation Anchors

- `GH-1037-SIGNAL-TO-EXECUTION-PIPELINE`
- `GH-1037-STRATEGY-NO-DIRECT-EXECUTIONCLIENT`
- `GH-1037-RISK-TO-RECONCILIATION-EVIDENCE`
- `TVM-RELEASE-V0140-SIGNAL-EXECUTION-PIPELINE`

## Verification

- `checks/verify-v0.14.0-signal-to-execution-pipeline.sh`
- `TargetGraphTests/testGH1037ReleaseV0140SignalToExecutionPipelineLinksAcceptedSignalAndFailsClosedRejectedSignal`
