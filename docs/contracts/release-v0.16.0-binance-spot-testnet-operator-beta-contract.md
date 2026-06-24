# Release v0.16.0 Binance Spot Testnet Operator Execution Beta Contract

日期：2026-06-24

执行者：Codex

本文档服务 GitHub fallback issue `GH-1101 V160-001 Define Binance Spot Testnet Operator Execution Beta contract`。

本文档定义 `MTPRO Release v0.16.0 Binance Spot Testnet Operator Execution Beta` 的第一层 release boundary、queue preflight、allowed modes、validation anchors 和 forbidden production capabilities。GH-1101 只定义合同，不实现 submit / cancel / status runtime，不读取 credential value，不连接 testnet 或 production endpoint，不发送 testnet 或 production order，不授权 production cutover。

## V0160-001-V0151-PREFLIGHT-GATE

`V0160-001-V0151-PREFLIGHT-GATE`

GH-1101 必须在 v0.15.1 hardening patch queue 完成后才可执行。前置事实：

- Blocking issue：`GH-1100`
- Required prior state：`GH-1100 closed / done`
- Required prior release line：`release/v0.15.1 queue closed`
- Required Parent Codex state：open PR = 0，open `todo` / `in-progress` / `in-review` issue = 0

## V0160-001-BINANCE-SPOT-TESTNET-ONLY

`V0160-001-BINANCE-SPOT-TESTNET-ONLY`

v0.16.0 operator beta 的 active venue 和 product scope 固定为：

- `allowedVenue == Binance`
- `allowedProductTypes == [spot]`
- `canonicalQueueRange == GH-1101..GH-1112`

任何非 Binance venue、Spot 之外 product type、production endpoint 或 production broker endpoint 都不属于 v0.16.0 operator beta scope。

## V0160-001-OPERATOR-CONFIRMATION-REQUIRED

`V0160-001-OPERATOR-CONFIRMATION-REQUIRED`

v0.16.0 后续 issue 可在严格 gate 下逐步实现 Binance Spot Testnet operator flows，但所有 testnet submit / cancel / status query 都必须保留显式 operator confirmation。GH-1101 本身不读取 testnet credential value、不连接 testnet network、不提交 testnet order。

Allowed modes：

- `contract-only`
- `operator-run-model`
- `spot-testnet-submit`
- `spot-testnet-cancel`
- `spot-testnet-status-query`
- `local-artifact-store`
- `oms-reconciliation`
- `dashboard-read-only-review`
- `failure-recovery`
- `manual-redacted-evidence`
- `audit-runbook-release-docs`

## V0160-001-REDACTED-EVIDENCE-REQUIRED

`V0160-001-REDACTED-EVIDENCE-REQUIRED`

v0.16.0 evidence 必须默认脱敏。API key、secret、raw request payload、raw response payload、raw broker payload 和 raw order identity 不得进入文档、test fixture、Dashboard surface、CLI output 或持久 artifact。后续 issue 如果需要手工 testnet proof，只能记录 redacted credential reference、run id、artifact path、checksum 和 operator confirmation metadata。

## V0160-001-QUEUE-ORDER

`V0160-001-QUEUE-ORDER`

Canonical queue order：

1. `GH-1101` Define Binance Spot Testnet Operator Execution Beta contract
2. `#1102 / GH-1102` Add operator run model and run id lifecycle
3. `#1103 / GH-1103` Add CLI submit execution flow
4. `#1104 / GH-1104` Add CLI cancel execution flow
5. `#1105 / GH-1105` Add signed order status query
6. `#1106 / GH-1106` Add local execution artifact store
7. `#1107 / GH-1107` Add OMS reconciliation from real testnet observed status
8. `#1108 / GH-1108` Add Dashboard read-only artifact-backed execution view
9. `#1109 / GH-1109` Add failure recovery workflow
10. `#1110 / GH-1110` Add quantity / order-count / cooldown / symbol allowlist guards
11. `#1111 / GH-1111` Add manual testnet validation workflow and redacted evidence bundle
12. `#1112 / GH-1112` Close v0.16.0 audit / runbook / release docs

Each issue remains `backlog` / `non-executable` until Parent Codex queue preflight promotes it. WIP=1 remains mandatory.

## V0160-001-NO-PRODUCTION-CUTOVER

`V0160-001-NO-PRODUCTION-CUTOVER`

GH-1101 keeps these flags closed:

- `productionTradingEnabledByDefault=false`
- `productionSecretReadEnabled=false`
- `productionEndpointConnectionEnabled=false`
- `productionBrokerConnectionEnabled=false`
- `productionOrderSubmitCancelReplaceEnabled=false`
- `productionCutoverAuthorized=false`
- `startsNextMilestone=false`

Forbidden capabilities：

- production cutover authorization
- production trading enabled by default
- production secret read
- production endpoint connection
- production broker connection
- production submit / cancel / replace
- production OMS
- Dashboard trading button
- Dashboard order form
- Live PRO Console command
- non-Binance venue
- non-spot product type
- raw secret persistence
- raw broker payload persistence
- next milestone auto-start

## TVM-RELEASE-V0160-OPERATOR-BETA-CONTRACT

`TVM-RELEASE-V0160-OPERATOR-BETA-CONTRACT`

Validation anchors：

- `GH-1101-VERIFY-V0160-OPERATOR-BETA-CONTRACT`
- `TVM-RELEASE-V0160-OPERATOR-BETA-CONTRACT`
- `V0160-001-V0151-PREFLIGHT-GATE`
- `V0160-001-BINANCE-SPOT-TESTNET-ONLY`
- `V0160-001-OPERATOR-CONFIRMATION-REQUIRED`
- `V0160-001-REDACTED-EVIDENCE-REQUIRED`
- `V0160-001-QUEUE-ORDER`
- `V0160-001-NO-PRODUCTION-CUTOVER`

Required validation：

- `swift test --filter TargetGraphTests/testGH1101ReleaseV0160OperatorBetaContractBlocksProductionCutover`
- `bash checks/verify-v0.16.0-operator-beta-contract.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## Non-authorization

GH-1101 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- runtime implementation。
- testnet credential value read。
- testnet network connection。
- testnet order submission。
- production trading。
- production secret read。
- production endpoint / broker endpoint connection。
- production submit / cancel / replace。
- production cutover。
- next milestone / next Project auto-start。
