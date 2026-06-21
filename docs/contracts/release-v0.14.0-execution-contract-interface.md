# Release v0.14.0 Execution Contract Interface

日期：2026-06-21  
执行者：Codex

## Scope

本文档服务 GitHub fallback issue `GH-1027 V140-003 Define Execution Contract interface`。

本 issue 固定 ExecutionEngine 消费、dry-run / Binance testnet adapter 实现的接口合同：

- `GH-1027-EXECUTION-CONTRACT-INTERFACE`
- `GH-1027-EXECUTION-CONTRACT-STAGE-SEPARATION`
- `GH-1027-EXECUTION-CONTRACT-NO-PRODUCTION-ADAPTER`
- `TVM-RELEASE-V0140-EXECUTION-CONTRACT-INTERFACE`

## Contract

`ExecutionContractAdapter` 只定义 interface，不提供 production adapter implementation。合同把执行路径拆成八个阶段：

1. `intent`
2. `requestMapping`
3. `submissionResult`
4. `acknowledgement`
5. `rejection`
6. `cancel`
7. `replace`
8. `auditEvidence`

`ExecutionContractInterface` 要求实现模式只包含：

- `dry-run`
- `binance-testnet`

`ExecutionContractRequestMapping` 只能消费已经满足 v0.14.0 边界的 `OrderIntent`，并绑定 `ExecutionContractOperation`、`ExecutionContractAdapterMode` 与 `OrderLifecycleState`。该 mapping 不包含 endpoint path、credential material、signature、listenKey、account endpoint 或 broker endpoint。

## Boundary

GH-1027 不实现：

- production adapter；
- production trading；
- production secret read；
- production / broker endpoint connection；
- submit / cancel / replace runtime；
- broker gateway；
- signed endpoint；
- account endpoint；
- listenKey；
- private WebSocket runtime；
- production OMS；
- real order lifecycle；
- Dashboard trading button；
- live command；
- production cutover。

`productionTradingEnabledByDefault` 必须保持 `false`。`ExecutionContractInterface`、request mapping、submission result、acknowledgement、rejection、cancel、replace 和 audit evidence 都必须拒绝 production authorization 或 production endpoint touch。

## Validation

- `Sources/ExecutionClient/ExecutionContract/ExecutionContractInterface.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift`
- `checks/verify-v0.14.0-execution-contract.sh`
- `checks/run.sh`

专项验证命令：

```bash
bash checks/verify-v0.14.0-execution-contract.sh
```

完整验证仍使用：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Next Boundary

GH-1028 可以在本合同基础上定义 Binance testnet adapter boundary，但仍不得打开 production trading、读取 production secret、连接 production endpoint 或发送真实订单。
