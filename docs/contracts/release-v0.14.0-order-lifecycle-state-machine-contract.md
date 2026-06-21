# MTPRO Release v0.14.0 Order Lifecycle State Machine Contract

日期：2026-06-21

执行者：Codex

## GH-1026-ORDER-LIFECYCLE-STATE-MACHINE

`OrderLifecycleStateMachine` 是 v0.14.0 testnet trading closed loop 的本地订单生命周期合同。

该合同只定义 Strategy Signal -> OrderIntent -> Risk Check -> Binance testnet / dry-run Execution evidence -> OMS Event Log -> Reconciliation -> Read-only Dashboard 之间可审计的本地状态迁移，不创建真实交易订单，不连接 broker，不读取 production secret，不连接 production endpoint，也不授权 production cutover。

状态覆盖：

- `created`
- `riskAccepted`
- `riskRejected`
- `submittedTestnet`
- `submittedDryRun`
- `accepted`
- `partiallyFilled`
- `filled`
- `cancelRequested`
- `cancelled`
- `replaceRequested`
- `replaced`
- `rejected`
- `expired`
- `failedClosed`

## GH-1026-ORDER-LIFECYCLE-INVALID-TRANSITION-FAIL-CLOSED

非法 transition 必须 fail closed：状态机通过 `OrderLifecycleContractError.invalidTransition` 抛错，调用方不能获得有效 `OrderLifecycleTransition`。

有效 transition 只允许：

- `created -> riskAccepted / riskRejected / failedClosed`
- `riskAccepted -> submittedTestnet / submittedDryRun / failedClosed`
- `riskRejected -> failedClosed`
- `submittedTestnet -> accepted / rejected / expired / failedClosed`
- `submittedDryRun -> accepted / rejected / expired / failedClosed`
- `accepted -> partiallyFilled / filled / cancelRequested / replaceRequested / rejected / expired / failedClosed`
- `partiallyFilled -> filled / cancelRequested / replaceRequested / expired / failedClosed`
- `cancelRequested -> cancelled / failedClosed`
- `replaceRequested -> replaced / failedClosed`
- `replaced -> accepted / partiallyFilled / filled / cancelRequested / replaceRequested / expired / failedClosed`

`filled`、`cancelled`、`rejected`、`expired`、`failedClosed` 不允许继续迁移。

## GH-1026-ORDER-LIFECYCLE-TESTNET-DRYRUN-BOUNDARY

v0.14.0 active scope 固定为：

- active venue: Binance
- active products: Spot、USDⓈ-M Perpetual
- active strategies: EMA、RSI

`OrderLifecycleStateMachine` 与 `OrderIntent` 共享 active scope，并强制：

- `productionTradingEnabledByDefault == false`
- `testnetOnly == true`
- `authorizesProductionTrading == false`
- `touchesProductionBrokerEndpoint == false`

`submittedTestnet` 和 `submittedDryRun` 只是本地证据状态。它们不等于 testnet request implementation，不发送 submit / cancel / replace，不读取 secret，不连接 broker endpoint，也不打开 Dashboard trading button、live command 或 order form。

## TVM-RELEASE-V0140-ORDER-LIFECYCLE-STATE-MACHINE

验证锚点要求：

- Swift focused test 覆盖所有状态。
- Swift focused test 覆盖有效 transition。
- Swift focused test 覆盖非法 transition fail-closed。
- Verifier 检查 `OrderLifecycle.swift`、Package wiring、contract anchors 和 `checks/run.sh` 接入。

## Validation

- `swift test --filter TargetGraphTests/testGH1026ReleaseV0140OrderLifecycleStateMachineFailsClosedInvalidTransitions`
- `bash checks/verify-v0.14.0-order-lifecycle.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
