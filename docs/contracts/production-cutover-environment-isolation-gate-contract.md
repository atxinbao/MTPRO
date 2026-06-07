# Production Cutover Environment Isolation Gate Contract

日期：2026-06-07

执行者：Codex

本文档服务 GitHub fallback issue `GH-504 Define production environment isolation gate`。

本文档定义 `MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1` 的 environment isolation gate。它只记录 local、fixture、dry-run、shadow、production-blocked 和 future-production 的 readiness evidence，不实现 production runtime，不自动切换环境，不读取真实 secret，不连接 broker，不实现 broker adapter / OMS / LiveExecutionAdapter，不实现真实 submit / cancel / replace。

## GH-504-PRODUCTION-ENVIRONMENT-ISOLATION-GATE

`GH-504-PRODUCTION-ENVIRONMENT-ISOLATION-GATE`

GH-504 依赖 GH-503 credential / secret policy gate。当前权威 source anchor：

- `Sources/ExecutionClient/FutureGate/ProductionCutoverEnvironmentIsolationGate.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH504ProductionEnvironmentIsolationGateDefinesBlockedDryRunDefault`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH504ProductionEnvironmentIsolationGateRejectsAutomaticSwitchAndBrokerBypass`

合同固定：

- upstream issue：`GH-503`
- queue range：`GH-503..GH-510`
- `credentialPolicyGateRequired == true`
- `productionNoDefaultTradingRequired == true`
- `sandboxCommandProductionCommandIsolationRequired == true`
- `manualApprovalCannotBeBypassed == true`
- `productionBlockedDryRunDefault == true`

## GH-504-ENVIRONMENT-TAXONOMY

`GH-504-ENVIRONMENT-TAXONOMY`

| Scope | 含义 | 当前允许 |
| --- | --- | --- |
| local | 本地开发环境 identity | 只产生 deterministic evidence |
| fixture | 本地 fixture / scenario evidence | 不读取 secret、不联网 |
| dry-run | no-trading 演练路径 | 不连接 broker、不提交订单 |
| shadow | future shadow evidence | 当前不执行真实 shadow trading |
| production blocked | production 被阻断状态 | 默认 blocked / no-trading |
| future production | 后续 cutover gate 输入 | GH-504 不授权执行 |

## GH-504-PRODUCTION-NO-DEFAULT-TRADING

`GH-504-PRODUCTION-NO-DEFAULT-TRADING`

Production 默认必须保持：

- no-trading
- blocked
- dry-run only
- no automatic broker connection
- no default secret read
- no real submit / cancel / replace

## GH-504-SANDBOX-DRYRUN-PRODUCTION-COMMAND-ISOLATION

`GH-504-SANDBOX-DRYRUN-PRODUCTION-COMMAND-ISOLATION`

Sandbox command、dry-run evidence 和 future production command 必须保持隔离。任何 sandbox command 都不能通过配置默认值、环境变量、脚本、UI 或 fixture 升级为 production command。

## GH-504-MANUAL-APPROVAL-SWITCH-EVIDENCE

`GH-504-MANUAL-APPROVAL-SWITCH-EVIDENCE`

环境切换 evidence 必须显式、可审计，并保持 manual approval gate：

- `requiresManualApproval == true`
- `allowsAutomaticSwitch == false`
- `connectsBroker == false`
- `readsSecretValue == false`
- `submitsRealOrder == false`

Required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS
