# Release v0.10.0 Production Cutover Readiness Contract

日期：2026-06-18

执行者：Codex

本文档服务 GitHub fallback issue `GH-878 V0100-001 Define v0.10.0 production cutover readiness no-authorization contract`。

本文档只定义 `MTPRO Release v0.10.0 Production Cutover Readiness Gate` 的 readiness assessment / 生产切换就绪评估边界。它不授权 production cutover，不读取 production secret value，不连接 production endpoint 或 broker endpoint，不提交、取消或替换 testnet / production order，不启用 production OMS、trading button、order form 或 live command。

## V0100-001-PRODUCTION-READINESS-NO-AUTHORIZATION-CONTRACT

`V0100-001-PRODUCTION-READINESS-NO-AUTHORIZATION-CONTRACT`

GH-878 是 V0100 queue `GH-878..GH-891` 的第一个 gate。当前权威 source anchor：

- `docs/contracts/release-v0.10.0-production-readiness-contract.md`
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RELEASE-V0100-PRODUCTION-READINESS-NO-AUTHORIZATION-CONTRACT`
- `checks/verify-v0.10.0-contract.sh`

合同固定：

- release version 固定为 `v0.10.0`
- project name 固定为 `MTPRO Release v0.10.0 Production Cutover Readiness Gate`
- queue range 固定为 `GH-878..GH-891`
- readiness assessment 允许值固定为 `productionReadinessAssessmentAllowed=true`
- production cutover 必须另走独立批准，固定为 `productionCutoverRequiresSeparateApproval=true`
- 后续 issue 执行前必须通过 GitHub fallback queue preflight
- 所有 v0.10.0 evidence 只能证明 readiness posture，不得转换为 trading permission。

## V0100-001-READINESS-ASSESSMENT-NOT-CUTOVER

`V0100-001-READINESS-ASSESSMENT-NOT-CUTOVER`

v0.10.0 的核心语义是“生产切换就绪评估”，不是“生产切换”。Allowed readiness work 只能输出 policy、profile、gate、audit、runbook、Dashboard readiness center 和 final audit evidence；不得把任何 approval-ready、pass、ready 或 operator acknowledged 字段解释为 production trading authorization。

Allowed readiness flags 固定为：

- `productionReadinessAssessmentAllowed=true`
- `productionCutoverRequiresSeparateApproval=true`
- `readinessEvidenceOnly=true`
- `manualApprovalEvidenceAllowed=true`
- `readinessDashboardReadModelAllowed=true`

Forbidden authorization flags 固定为：

- `productionTradingEnabledByDefault=false`
- `productionCutoverAuthorized=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `productionBrokerConnected=false`
- `productionOrderSubmitted=false`
- `realOrderSubmissionEnabled=false`
- `testnetOrderSubmissionAllowed=false`
- `testnetOrderRoutingAllowed=false`

## V0100-001-DOWNSTREAM-QUEUE-ORDER

`V0100-001-DOWNSTREAM-QUEUE-ORDER`

V0100 canonical queue 固定为：

1. `GH-878 V0100-001 Define v0.10.0 production cutover readiness no-authorization contract`
2. `GH-879 V0100-002 Align v0.9.1 / v0.10.0 release publication docs and version policy`
3. `GH-880 V0100-003 Add ProductionEnvironmentProfile contract`
4. `GH-881 V0100-004 Add SecretProviderReadinessGate`
5. `GH-882 V0100-005 Add EndpointPolicyReadinessGate`
6. `GH-883 V0100-006 Add capital and exposure limit readiness gate`
7. `GH-884 V0100-007 Add kill switch / no-trade readiness gate`
8. `GH-885 V0100-008 Add production command surface disabled proof`
9. `GH-886 V0100-009 Add shadow dry-run parity assessment`
10. `GH-887 V0100-010 Add production readiness audit bundle`
11. `GH-888 V0100-011 Add production cutover approval workflow, still disabled`
12. `GH-889 V0100-012 Add production incident / rollback readiness runbook`
13. `GH-890 V0100-013 Add Dashboard Production Readiness Center`
14. `GH-891 V0100-014 Close v0.10.0 final audit / docs / runbook`

WIP=1 仍是强制规则。只有当前 issue PR merged、required `checks` SUCCESS、issue closed/done、本地 `main == origin/main` 且 worktree clean 后，才能 preflight 下一个 issue。

## V0100-001-FORBIDDEN-CAPABILITIES

`V0100-001-FORBIDDEN-CAPABILITIES`

v0.10.0 readiness gate 明确禁止：

- 默认开启 production trading
- 读取 production secret value
- 自动连接 production endpoint
- 自动连接 production broker endpoint
- 启用 real order submit / cancel / replace
- 启用 testnet order routing 或 testnet order submission
- 启用 production OMS
- 启用 trading button、order form 或 live command
- 把 readiness approval 当成 production cutover authorization

## V0100-001-RELEASE-VALIDATION-MATRIX

`V0100-001-RELEASE-VALIDATION-MATRIX`

本 issue 的最小验证链为：

- `GH-878-VERIFY-V0100-PRODUCTION-READINESS-NO-AUTHORIZATION-CONTRACT`
- `TVM-RELEASE-V0100-PRODUCTION-READINESS-NO-AUTHORIZATION-CONTRACT`
- `checks/verify-v0.10.0-contract.sh`
- `testGH878ReleaseV0100ProductionReadinessContractDoesNotAuthorizeCutover`

Validation 必须证明：

- v0.10.0 readiness assessment 被允许；
- production cutover 仍要求 separate approval；
- production trading、secret read、endpoint / broker connection、testnet / production order path 全部保持 disabled / false；
- readiness wording 不创建 production trading permission。
