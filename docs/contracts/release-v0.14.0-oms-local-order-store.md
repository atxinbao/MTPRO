# Release v0.14.0 OMS Local Order Store Contract

日期：2026-06-21  
执行者：Codex

## Scope

GH-1031 为 v0.14.0 增加本地 OMS order store evidence。该 store 只记录 Binance Spot / USDⓈ-M Perpetual、EMA / RSI 在 testnet / dry-run 路径中的本地订单 identity、append/update event 和 replay snapshot。

该合同只服务：

- `Strategy Signal -> OrderIntent -> Risk Check -> Binance testnet Execution -> OMS Event Log -> Reconciliation -> Read-only Dashboard`
- 本地 order identity append。
- 本地 lifecycle transition update。
- append-only event replay。

## GH-1031-OMS-LOCAL-ORDER-STORE

`ReleaseV0140OMSLocalOrderStore` 是纯本地、可重放、append-only evidence container。它不连接 broker，不读取 secret，不读取真实账户余额，不拥有 production position，也不表示 production OMS 已启用。

每个 record 必须保留：

- `localOrderID`
- `intentID`
- `strategyRunID`
- `productType`
- `symbol`
- `sourceSubmitPathID`
- 当前 `OrderLifecycleState`
- 对应 `eventIDs`

## GH-1031-OMS-APPEND-UPDATE-REPLAY

Store 的行为必须满足：

- append 只能追加新的 `localOrderID`。
- update 必须先找到已有 `localOrderID`。
- update 必须通过 `OrderLifecycleStateMachine.transition`。
- event sequence 必须从 1 连续递增。
- replay 必须使用已排序 event 重新构造 record snapshot。
- out-of-order event replay 必须 fail closed。

## GH-1031-OMS-NO-REAL-ACCOUNT-OR-PRODUCTION-POSITION

GH-1031 不允许引入：

- real account balance ownership。
- production position ownership。
- broker fill。
- reconciliation result。
- production trading default enablement。
- production secret read。
- production endpoint connection。
- production cutover authorization。

这些字段必须在 source、test 和 PR evidence 中保持 false。

## TVM-RELEASE-V0140-OMS-LOCAL-ORDER-STORE

Validation matrix anchor：

- focused test：`TargetGraphTests/testGH1031ReleaseV0140OMSLocalOrderStoreAppendsUpdatesAndReplaysLifecycleEvidence`
- verifier：`checks/verify-v0.14.0-oms-local-order-store.sh`
- aggregate：`checks/run.sh`

## Non-goals

- 不实现 production OMS。
- 不实现 broker adapter。
- 不发送 submit / cancel / replace。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不读取真实账户余额。
- 不拥有 production position。
- 不解析 broker fill。
- 不执行 reconciliation。
- 不创建 Dashboard trading button、live command 或 production order form。
