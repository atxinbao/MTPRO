# Release v0.14.0 Binance Testnet Adapter Boundary

日期：2026-06-21  
执行者：Codex

## 范围

本文档记录 GH-1028 / V140-004 `Add Binance testnet adapter boundary` 的合同证据。

该合同只定义 Binance testnet adapter boundary：Binance only、Spot + USDⓈ-M Perpetual only、EMA + RSI only，并把 `ExecutionContractAdapterMode.binanceTestnet` 与 testnet endpoint policy 绑定。

## 合同

`ReleaseV0140BinanceTestnetEndpointReference` 只允许两个 base URL：

- Spot: `https://testnet.binance.vision`
- USDⓈ-M Perpetual: `https://testnet.binancefuture.com`

endpoint reference 构造时必须拒绝：

- production host：`api.binance.com`、`fapi.binance.com`、`dapi.binance.com`
- 非 HTTPS URL
- userinfo
- path / query / fragment base URL
- 未显式声明 testnet mode
- fallback to production
- 当前 issue 内的 network submit / cancel / replace

`ReleaseV0140BinanceTestnetAdapterBoundary` 只证明 adapter boundary 与 v0.14.0 execution contract 对齐；它不实现网络 submit / cancel / replace，也不读取 credential 或创建 request。

## 验证锚点

- `GH-1028-BINANCE-TESTNET-ADAPTER-BOUNDARY`
- `GH-1028-BINANCE-TESTNET-ENDPOINT-POLICY`
- `GH-1028-BINANCE-TESTNET-NO-NETWORK-SUBMIT`
- `TVM-RELEASE-V0140-BINANCE-TESTNET-ADAPTER-BOUNDARY`

## 边界

本 issue 不授权：

- production trading
- production secret read
- production endpoint / broker endpoint connection
- production cutover
- network submit / cancel / replace
- real-money order
- non-Binance venue
- non-EMA / non-RSI active strategy
- Dashboard trading button 或 production order form

## 验证

本 issue 的 focused validation：

```bash
swift test --filter TargetGraphTests/testGH1028ReleaseV0140BinanceTestnetAdapterBoundaryRejectsProductionAndNetworkSubmit
bash checks/verify-v0.14.0-binance-testnet-adapter-boundary.sh
```

完整 closeout validation：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```
