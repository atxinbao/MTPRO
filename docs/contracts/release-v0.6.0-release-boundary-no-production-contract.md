# Release v0.6.0 Boundary / No-production Contract

日期：2026-06-14

执行者：Codex

本文档服务 GitHub fallback issue `GH-755 V060-001 Release boundary / no-production contract`。

本文档定义 `MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening` 的第一层 release boundary、WIP=1 queue rule、allowed construction scope 和 no-production acceptance gate。它只授权后续 V060 issues 在 GitHub fallback queue 中按依赖顺序推进；不实现 runtime、不读取 secret、不连接 endpoint、不提交 / 取消 / 替换真实订单、不授权 production cutover。

## V060-001-RELEASE-BOUNDARY-NO-PRODUCTION-CONTRACT

`V060-001-RELEASE-BOUNDARY-NO-PRODUCTION-CONTRACT`

GH-755 是 V060 queue `GH-755..GH-766` 的第一个 gate。当前权威 source anchor：

- `docs/contracts/release-v0.6.0-release-boundary-no-production-contract.md`
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RELEASE-V060-BOUNDARY-NO-PRODUCTION-CONTRACT`
- `checks/verify-v0.6.0-boundary.sh`

合同固定：

- release version 固定为 `v0.6.0`
- project name 固定为 `MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening`
- active venue 只能是 `Binance`
- active product types 只能是 `spot` 和 `usdsPerpetual`
- active strategies 只能是 `EMA` 和 `RSI`
- queue range 固定为 `GH-755..GH-766`
- downstream issue 固定为 `GH-756` 至 `GH-766`
- 后续 issue 执行前必须通过 GitHub fallback queue preflight
- production capability defaults 必须继续关闭。

## V060-001-LOCAL-OPERATIONAL-RUNTIME-SCOPE

`V060-001-LOCAL-OPERATIONAL-RUNTIME-SCOPE`

v0.6.0 的定位是 local operational runtime 加 guarded testnet read-only probe hardening。允许的 construction scope 只包括：

- local dry-run runner
- local run journal
- sha256 manifest and artifact checksum
- Dashboard / CLI run detail observer
- testnet read-only probe

GH-755 本身只定义 release boundary 和 no-production contract，不实现 LocalRunJournalWriter、manifest writer、RuntimeMessageBus sha256 migration、DataEngine runner、Strategy runner、RiskEngine runner、ExecutionEngine / OMS runner、Portfolio projection、Dashboard / CLI observer 或 testnet read-only probe。

## V060-001-NO-PRODUCTION-ACCEPTANCE-GATE

`V060-001-NO-PRODUCTION-ACCEPTANCE-GATE`

V060 release line 必须持续保留以下 machine-readable acceptance gate：

- `productionTradingEnabledByDefault=false`
- `productionSecretResolutionEnabled=false`
- `productionEndpointConnectionEnabled=false`
- `realOrderAuthorizationEnabled=false`
- `productionCutoverAuthorized=false`

以上字段是 release v0.6.0 的 hard contract。后续 issue 可以定义 local operational runtime 或 guarded testnet read-only evidence，但不得把任一字段切换为 `true`，不得通过环境变量、CLI flag、Dashboard control、run journal replay、testnet probe 或 operator shortcut 绕过这些默认关闭语义。

## V060-001-DOWNSTREAM-QUEUE-ORDER

`V060-001-DOWNSTREAM-QUEUE-ORDER`

V060 GitHub fallback queue 必须保持 WIP=1，且每个 issue 独立分支、独立 PR、独立验证、独立 merge：

1. `GH-755` / `V060-001`：Release boundary / no-production contract
2. `GH-756` / `V060-002`：Add LocalRunJournalWriter
3. `GH-757` / `V060-003`：Add run manifest and artifact checksum
4. `GH-758` / `V060-004`：Migrate RuntimeMessageBus checksum to sha256
5. `GH-759` / `V060-005`：Add DataEngine real local dry-run runner
6. `GH-760` / `V060-006`：Add EMA / RSI strategy runtime runner
7. `GH-761` / `V060-007`：Add RiskEngine runtime runner
8. `GH-762` / `V060-008`：Add ExecutionEngine / OMS dry-run runner
9. `GH-763` / `V060-009`：Add Portfolio projection from real journal
10. `GH-764` / `V060-010`：Add Dashboard / CLI run detail observer
11. `GH-765` / `V060-011`：Add testnet read-only probe with no-order boundary
12. `GH-766` / `V060-012`：Close CI / release hardening and stage audit

后续 issue 执行前必须确认 dependencies closed / done、current issue body 已读取、`main == origin/main`、worktree clean、open PR=0，且没有其他 open issue 带 `todo` / `in-progress` / `in-review` label。

## V060-001-FORBIDDEN-PRODUCTION-CAPABILITIES

`V060-001-FORBIDDEN-PRODUCTION-CAPABILITIES`

GH-755 和整个 V060 release line 都不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- production trading。
- production secret read or resolution。
- production endpoint connection。
- production broker connection。
- production order submission。
- production cutover authorization。
- signed production account endpoint。
- listenKey runtime。
- private WebSocket production runtime。
- broker adapter。
- production OMS。
- real submit / cancel / replace path。
- Dashboard production command。
- Live PRO Console runtime authorization。
- trading button / live command / order form。
- non-Binance venue。
- non-Spot / non-USDSM active product。
- non-EMA / non-RSI active strategy。

## TVM-RELEASE-V060-BOUNDARY-NO-PRODUCTION-CONTRACT

`TVM-RELEASE-V060-BOUNDARY-NO-PRODUCTION-CONTRACT`

Required validation：

- `bash checks/verify-v0.6.0-boundary.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

后续 V060 issues 必须逐项回填：

- V060-002 LocalRunJournalWriter。
- V060-003 run manifest and artifact checksum。
- V060-004 RuntimeMessageBus sha256 checksum。
- V060-005 DataEngine real local dry-run runner。
- V060-006 EMA / RSI strategy runtime runner。
- V060-007 RiskEngine runtime runner。
- V060-008 ExecutionEngine / OMS dry-run runner。
- V060-009 Portfolio projection from real journal。
- V060-010 Dashboard / CLI run detail observer。
- V060-011 testnet read-only probe with no-order boundary。
- V060-012 CI / release hardening and stage audit。

## V060-001 Non-authorization

GH-755 不创建下一 Project / Issue，不推进 release v0.6.0 之后的阶段，不发布 tag，不修改 root latest completed release statement，不把 v0.6.0 标记为 completed，不授权 production cutover。
