# Release v0.7.0 No-order Runtime Session Contract

日期：2026-06-15

执行者：Codex

本文档服务 GitHub fallback issue `GH-779 V070-001 Define v0.7.0 no-order runtime session contract`。

本文档定义 `MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity` 的第一层 release contract。它只授权后续 V070 issues 在 GitHub fallback queue 中按依赖顺序推进 no-order runtime session、real Binance testnet read-only probe、operator observe / recovery 和 read-only evidence surface；不实现 runtime、不读取 production secret、不连接 production endpoint / broker、不提交 / 取消 / 替换订单、不授权 production cutover。

## V070-001-NO-ORDER-RUNTIME-SESSION-CONTRACT

`V070-001-NO-ORDER-RUNTIME-SESSION-CONTRACT`

GH-779 是 V070 queue `GH-779..GH-792` 的第一个 gate。当前权威 source anchor：

- `docs/contracts/release-v0.7.0-no-order-runtime-session-contract.md`
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RELEASE-V070-NO-ORDER-RUNTIME-SESSION-CONTRACT`
- `checks/verify-v0.7.0-contract.sh`

合同固定：

- release version 固定为 `v0.7.0`
- project name 固定为 `MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity`
- active venue 只能是 `Binance`
- active product types 只能是 `spot` 和 `usdsPerpetual`
- active strategies 只能是 `EMA` 和 `RSI`
- queue range 固定为 `GH-779..GH-792`
- downstream issue 固定为 `GH-780` 至 `GH-792`
- 后续 issue 执行前必须通过 GitHub fallback queue preflight
- 所有 runtime session 必须保持 no-order posture。

## V070-001-ALLOWED-MODES

`V070-001-ALLOWED-MODES`

v0.7.0 允许的 mode 固定为：

- `local-dry-run`
- `testnet-read-only-probe`
- `recovery-observe`
- `production-blocked`

`local-dry-run` 是默认 operational mode，只允许本地 run journal / manifest / observer evidence。`testnet-read-only-probe` 只允许显式 operator confirmation 下的 Binance testnet read-only connectivity evidence，不允许 testnet submit / cancel / replace。`recovery-observe` 只允许 operator 观察、恢复分类、incomplete run 识别和 read-only replay evidence。`production-blocked` 只表示生产路径阻断证据，不是 production runtime、production endpoint connector、production broker adapter 或 production order authorization。

## V070-001-CANONICAL-MODULE-SEQUENCE

`V070-001-CANONICAL-MODULE-SEQUENCE`

V070 no-order runtime session 的 canonical module sequence 固定为：

1. CLI / Operator starts a no-order runtime session.
2. RunRegistry / RunSupervisor assigns one run identity.
3. EventLogWriter appends local runtime evidence.
4. DataEngine publishes read-only market evidence.
5. Trader / Strategy produces EMA / RSI intent evidence without execution authority.
6. RiskEngine emits allow / reject / blocked policy evidence.
7. ExecutionEngine / OMS remains no-order and records blocked / simulated evidence only.
8. Portfolio projects read-only reconciliation evidence.
9. Dashboard / CLI observes session state, run details, risk state and probe state.
10. Testnet probes remain read-only and redacted.

该 sequence 是证据链顺序，不授权任何 strategy 直连 ExecutionClient、broker、OMS production path、Dashboard command surface、trading button、live command 或 order form。

## V070-001-EVIDENCE-ENVELOPE

`V070-001-EVIDENCE-ENVELOPE`

每个 V070 runtime session evidence envelope 必须保留：

- `releaseVersion=v0.7.0`
- `runID`
- `sessionMode`
- `operatorConfirmation`
- `venue=Binance`
- `productTypes=spot,usdsPerpetual`
- `strategies=EMA,RSI`
- `noOrder=true`
- `productionTradingEnabledByDefault=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `productionBrokerConnected=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`
- `testnetOrderSubmissionAllowed=false`

以上字段是 v0.7.0 hard contract。后续 issue 可以定义 runtime session lifecycle、real testnet signed account read-only probe、private stream read-only probe、Dashboard read-only operations、Risk policy config 和 Portfolio read-only reconciliation projection，但不得把任一 forbidden capability 字段切换为 `true`。

## V070-001-DOWNSTREAM-QUEUE-ORDER

`V070-001-DOWNSTREAM-QUEUE-ORDER`

V070 GitHub fallback queue 必须保持 WIP=1，且每个 issue 独立分支、独立 PR、独立验证、独立 merge：

1. `GH-779` / `V070-001`：Define v0.7.0 no-order runtime session contract
2. `GH-780` / `V070-002`：Harden testnet read-only endpoint canonical policy
3. `GH-781` / `V070-003`：Realign top-level CLI run / status / verify
4. `GH-782` / `V070-004`：Add v0.7.0 Dashboard / macOS CI focused guards
5. `GH-783` / `V070-005`：Add OperationalRunSession lifecycle
6. `GH-784` / `V070-006`：Harden EventLogWriter for runtime append / recovery
7. `GH-785` / `V070-007`：Add RunRegistry / RunSupervisor
8. `GH-786` / `V070-008`：Add real Binance testnet signed account read-only probe
9. `GH-787` / `V070-009`：Add testnet private stream read-only probe
10. `GH-788` / `V070-010`：Add Dashboard read-only run operations
11. `GH-789` / `V070-011`：Add local Risk policy config
12. `GH-790` / `V070-012`：Add Portfolio read-only reconciliation projection
13. `GH-791` / `V070-013`：Add v0.7.0 CI / release validation gate
14. `GH-792` / `V070-014`：Close v0.7.0 final audit / docs / runbook

后续 issue 执行前必须确认 dependencies closed / done、current issue body 已读取、`main == origin/main`、worktree clean、open PR=0，且没有其他 open issue 带 `todo` / `in-progress` / `in-review` label。

## V070-001-FORBIDDEN-CAPABILITIES

`V070-001-FORBIDDEN-CAPABILITIES`

GH-779 和整个 V070 release line 都不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- production trading。
- production secret read or resolution。
- production endpoint connection。
- production broker connection。
- production order submission。
- testnet order submission。
- production cutover authorization。
- signed production account endpoint。
- production listenKey runtime。
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

## TVM-RELEASE-V070-NO-ORDER-RUNTIME-SESSION-CONTRACT

`TVM-RELEASE-V070-NO-ORDER-RUNTIME-SESSION-CONTRACT`

Required validation：

- `bash checks/verify-v0.7.0-contract.sh`
- `swift test --filter TargetGraphTests/testGH779ReleaseV070NoOrderRuntimeSessionContractDefinesAllowedModesAndForbiddenCapabilities`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## V070-001 Non-authorization

GH-779 不创建下一 Project / Issue，不推进 release v0.7.0 之后的阶段，不发布 tag，不修改 root latest completed release statement，不把 v0.7.0 标记为 completed，不实现 runtime，不授权 production cutover。
