# Release v0.14.0 Binance Testnet Cancel / Replace Path

日期：2026-06-21
执行者：Codex

## 范围

本文档记录 GH-1030 / V140-006 `Add testnet cancel / replace execution` 的合同证据。

本 issue 只增加 Binance testnet cancel / replace 的可审计 evidence surface。cancel / replace 必须先证明已有本地 OMS order identity，再证明 adapter approval 明确绑定 Binance testnet endpoint。该链路不发送网络请求，不读取 credential，不连接 production endpoint，也不授权 production cutover。

## 合同

`ReleaseV0140LocalOMSOrderIdentity` 要求：

- 本地 order identity 必须从 GH-1029 submit request / response / path evidence 派生。
- 本地 lifecycle state 只能是 `accepted`、`partiallyFilled` 或 `replaced`。
- exchange order identity 必须 redacted。
- 不包含 broker fill，不包含 reconciliation。

`ReleaseV0140BinanceTestnetCancelReplaceAdapterApproval` 要求：

- approval 必须绑定本地 OMS order identity。
- endpoint 必须是 GH-1028 允许的 Binance testnet endpoint。
- cancel / replace 都必须显式允许为 testnet evidence。
- approval evidence 必须 redacted。

`ReleaseV0140BinanceTestnetCancelReplaceRequestEvidence` 要求：

- mapping 必须是 `ExecutionContractRequestMapping` 的 `cancel` 或 `replace`。
- mode 必须是 `binance-testnet`。
- mapping lifecycle state 必须等于本地 OMS order lifecycle state。
- target lifecycle state 必须分别是 `cancelRequested` 或 `replaceRequested`。
- request body 与 credential material 必须 redacted。

`ReleaseV0140BinanceTestnetCancelReplaceActionEvidence` 要求：

- cancel request 只能绑定 `ExecutionContractCancel`。
- replace request 只能绑定 `ExecutionContractReplace`。
- response body 与 exchange order identity 必须 redacted。
- 不包含 broker fill，不包含 reconciliation。

`ReleaseV0140BinanceTestnetCancelReplacePath` 汇总完整 evidence chain：

`GH-1029 submit evidence -> local OMS order identity -> testnet adapter approval -> cancel request/action -> replace request/action`

## 验证锚点

- `GH-1030-BINANCE-TESTNET-CANCEL-REPLACE-PATH`
- `GH-1030-LOCAL-OMS-ORDER-IDENTITY-REQUIRED`
- `GH-1030-TESTNET-ADAPTER-APPROVAL-REDACTED`
- `TVM-RELEASE-V0140-BINANCE-TESTNET-CANCEL-REPLACE`

## 禁止项

本合同不实现或授权：

- production trading
- real-money order
- production secret read
- production endpoint / broker endpoint connection
- network cancel / replace
- broker fill
- reconciliation
- production cutover authorization
- non-Binance venue
- non-EMA / non-RSI active strategy
- Dashboard trading button
- production order form

## 验证命令

```bash
bash checks/verify-v0.14.0-binance-testnet-cancel-replace.sh
```

focused test：

```bash
swift test --filter TargetGraphTests/testGH1030ReleaseV0140BinanceTestnetCancelReplaceRequiresLocalOMSIdentity
```
