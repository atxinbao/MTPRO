# Release v0.10.0 Command Surface Disabled Proof Contract

日期：2026-06-18

执行者：Codex

本文档服务 GitHub fallback issue `GH-885 V0100-008 Add production command surface disabled proof`。

本文档只定义 `MTPRO Release v0.10.0 Production Cutover Readiness Gate` 的 Dashboard / CLI production command surface disabled proof。它证明 Dashboard 与 CLI 均不暴露 production trading entry point，并固定 production cutover blocked evidence。它不连接 production endpoint 或 broker endpoint，不读取 production secret value，不提交、取消或替换 testnet / production order，不启用 production OMS、trading button、order form 或 live command，也不授权 production cutover。

## V0100-008-PRODUCTION-COMMAND-SURFACE-DISABLED-PROOF

`V0100-008-PRODUCTION-COMMAND-SURFACE-DISABLED-PROOF`

GH-885 的 ProductionCommandSurfaceDisabledProof schema 固定为：

- `dashboard_production_surface_disabled.json`
- `cli_production_surface_disabled.json`
- `dashboardProductionSurfaceDisabled=true`
- `cliProductionSurfaceDisabled=true`
- `production_cutover_blocked=true`
- `productionCutoverBlocked=true`
- `productionCutoverUnblocked=false`
- `cutoverAuthorized=false`

该 proof 只能作为 readiness evidence 输入，不能被解释为 production cutover approval、broker connection permission 或 trading permission。

## V0100-008-DASHBOARD-PRODUCTION-SURFACE-DISABLED-JSON

`V0100-008-DASHBOARD-PRODUCTION-SURFACE-DISABLED-JSON`

GH-885 必须定义 Dashboard production surface disabled evidence 文件名：

- `dashboard_production_surface_disabled.json`
- `dashboard_production_surface_disabled_evidence_exists=true`
- `dashboard_production_surface_disabled_contains_broker_or_account_response=false`
- `dashboard_production_surface_disabled_produced_by_endpoint_connection=false`
- `dashboard_production_surface_disabled_contains_order_payload=false`

## V0100-008-CLI-PRODUCTION-SURFACE-DISABLED-JSON

`V0100-008-CLI-PRODUCTION-SURFACE-DISABLED-JSON`

GH-885 必须定义 CLI production surface disabled evidence 文件名：

- `cli_production_surface_disabled.json`
- `cli_production_surface_disabled_evidence_exists=true`
- `cli_production_surface_disabled_contains_broker_or_account_response=false`
- `cli_production_surface_disabled_produced_by_endpoint_connection=false`
- `cli_production_surface_disabled_contains_order_payload=false`

这些 evidence 不包含 broker response、account response、secret、listenKey、endpoint payload 或 order response。

## V0100-008-TRADING-BUTTON-VISIBLE-FALSE

`V0100-008-TRADING-BUTTON-VISIBLE-FALSE`

Dashboard trading button 必须不可见：

- `tradingButtonVisible=false`

该字段只证明 UI 不暴露 production trading entry point，不代表隐藏了某个已存在的真实交易 runtime。

## V0100-008-ORDER-FORM-VISIBLE-FALSE

`V0100-008-ORDER-FORM-VISIBLE-FALSE`

Dashboard order form 必须不可见：

- `orderFormVisible=false`

## V0100-008-LIVE-COMMAND-ENABLED-FALSE

`V0100-008-LIVE-COMMAND-ENABLED-FALSE`

Live command 必须保持 disabled：

- `liveCommandEnabled=false`

## V0100-008-SUBMIT-CANCEL-REPLACE-COMMANDS-DISABLED

`V0100-008-SUBMIT-CANCEL-REPLACE-COMMANDS-DISABLED`

Submit / cancel / replace command 必须全部 disabled：

- `submitCommandEnabled=false`
- `cancelCommandEnabled=false`
- `replaceCommandEnabled=false`
- `testnetOrderSubmissionEnabled=false`
- `productionOrderSubmissionEnabled=false`

## V0100-008-PRODUCTION-COMMAND-ENABLED-FALSE

`V0100-008-PRODUCTION-COMMAND-ENABLED-FALSE`

Production command 必须 disabled：

- `productionCommandEnabled=false`
- `commandBypassEnabled=false`

## V0100-008-PRODUCTION-CUTOVER-BLOCKED

`V0100-008-PRODUCTION-CUTOVER-BLOCKED`

Production cutover 在 GH-885 中固定 blocked：

- `production_cutover_blocked=true`
- `productionCutoverBlocked=true`
- `productionCutoverUnblocked=false`

任何 Dashboard / CLI disabled evidence 都不能转换成 production trading permission。

## V0100-008-PRODUCTION-CAPABILITIES-DISABLED

`V0100-008-PRODUCTION-CAPABILITIES-DISABLED`

Production capability 在 GH-885 中固定 disabled：

- `productionEndpointConnectionEnabled=false`
- `productionBrokerConnectionEnabled=false`
- `productionSecretValueRead=false`
- `productionOMSRuntimeEnabled=false`
- `tradingButtonVisible=false`
- `orderFormVisible=false`
- `liveCommandEnabled=false`
- `submitCommandEnabled=false`
- `cancelCommandEnabled=false`
- `replaceCommandEnabled=false`
- `productionCommandEnabled=false`
- `commandBypassEnabled=false`

## V0100-008-VALIDATION-MATRIX

`V0100-008-VALIDATION-MATRIX`

本 issue 的最小验证链为：

- `GH-885-VERIFY-V0100-COMMAND-SURFACE-DISABLED`
- `TVM-RELEASE-V0100-COMMAND-SURFACE-DISABLED`
- `checks/verify-v0.10.0-command-surface-disabled.sh`
- `testGH885ProductionCommandSurfaceDisabledProofKeepsDashboardAndCLIReadOnly`

Validation 必须证明：

- `dashboard_production_surface_disabled.json` 和 `cli_production_surface_disabled.json` evidence 文件名存在；
- `tradingButtonVisible=false`、`orderFormVisible=false`、`liveCommandEnabled=false`；
- `submitCommandEnabled=false`、`cancelCommandEnabled=false`、`replaceCommandEnabled=false`、`productionCommandEnabled=false`；
- `production_cutover_blocked=true`；
- endpoint connection、broker connection、secret read、cutover、testnet / production order submission、production OMS 和 command bypass 全部保持 false。
