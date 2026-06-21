# Release v0.14.0 Binance Testnet Submit Path

日期：2026-06-21
执行者：Codex

## 范围

本文档记录 GH-1029 / V140-005 `Add Binance testnet order submit` 的合同证据。

该合同只增加 Binance testnet submit path 的可审计 evidence surface：`OrderIntent` 必须先进入 `ExecutionContractRequestMapping`，mapping 必须处于 `riskAccepted`，mode 必须是 `binance-testnet`，再由显式 operator gate 生成脱敏 request / response evidence。

## 合同

`ReleaseV0140BinanceTestnetSubmitOperatorGate` 要求：

- 显式 testnet mode。
- operator 已确认本次只允许 testnet submit evidence。
- operator 明确确认不授权 production trading。
- credential reference 必须保持 redacted。
- production trading / production secret / production endpoint / production cutover 全部保持 false。

`ReleaseV0140BinanceTestnetSubmitRequestEvidence` 要求：

- 绑定 `OrderIntent.intentID`、`strategyRunID`、`sourceSequence` 和 `ExecutionContractRequestMapping.mappingID`。
- 只允许 Binance Spot 与 USDⓈ-M Perpetual。
- 只允许 EMA / RSI 来源的 pre-RiskEngine intent。
- endpoint host 必须来自 GH-1028 的 testnet endpoint policy。
- request body 与 credential material 必须 redacted。
- 本 issue 不执行网络 submit，不包含 cancel / replace。

`ReleaseV0140BinanceTestnetSubmitResponseEvidence` 要求：

- 绑定 request、submission result 和 acknowledgement。
- lifecycle state 必须是 `accepted` evidence。
- exchange order identity 与 response payload 必须 redacted。
- 不代表 broker fill、OMS reconciliation 或 production order acceptance。

`ReleaseV0140BinanceTestnetSubmitPath` 汇总完整 evidence chain：

`OrderIntent -> ExecutionContractRequestMapping -> operator gate -> redacted request evidence -> submission result -> acknowledgement -> redacted response evidence`

## 验证锚点

- `GH-1029-BINANCE-TESTNET-SUBMIT-PATH`
- `GH-1029-BINANCE-TESTNET-OPERATOR-GATE`
- `GH-1029-BINANCE-TESTNET-REDACTED-REQUEST-RESPONSE`
- `TVM-RELEASE-V0140-BINANCE-TESTNET-SUBMIT`

## 边界

本 issue 不授权：

- production trading
- real-money order
- production secret read
- production endpoint / broker endpoint connection
- production cutover
- network submit performed
- cancel / replace
- broker fill parser
- OMS reconciliation
- non-Binance venue
- non-EMA / non-RSI active strategy
- Dashboard trading button 或 production order form

## 验证

本 issue 的 focused validation：

```bash
swift test --filter TargetGraphTests/testGH1029ReleaseV0140BinanceTestnetSubmitPathIsOperatorGatedAndRedacted
bash checks/verify-v0.14.0-binance-testnet-submit.sh
```

完整 closeout validation：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```
