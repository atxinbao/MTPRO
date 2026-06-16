# Release v0.9.0 Testnet No-order Observability Contract

日期：2026-06-17

执行者：Codex

本文档服务 GitHub fallback issue `GH-843 V090-001 Define v0.9.0 testnet no-order observability contract`。

本文档定义 `MTPRO Release v0.9.0 Testnet No-order Observability + Reconciliation Hardening` 的第一层 release contract。它只授权后续 V090 issues 在 GitHub fallback queue 中按依赖顺序推进 testnet read-only observability、freshness / staleness monitoring、recovery evidence、Dashboard / CLI observability timeline、alert read-model、Portfolio reconciliation hardening、Risk policy application audit、export bundle 和 validation lane split；不实现 production runtime、不读取 production secret、不连接 production endpoint / broker、不提交 / 取消 / 替换 testnet 或 production 订单、不授权 production cutover。

## V090-001-TESTNET-NO-ORDER-OBSERVABILITY-CONTRACT

`V090-001-TESTNET-NO-ORDER-OBSERVABILITY-CONTRACT`

GH-843 是 V090 queue `GH-843..GH-856` 的第一个 gate。当前权威 source anchor：

- `docs/contracts/release-v0.9.0-testnet-no-order-observability-contract.md`
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RELEASE-V090-TESTNET-NO-ORDER-OBSERVABILITY-CONTRACT`
- `checks/verify-v0.9.0-contract.sh`

合同固定：

- release version 固定为 `v0.9.0`
- project name 固定为 `MTPRO Release v0.9.0 Testnet No-order Observability + Reconciliation Hardening`
- active venue 只能是 `Binance`
- active product types 只能是 `spot` 和 `usdsPerpetual`
- active strategies 只能是 `EMA` 和 `RSI`
- queue range 固定为 `GH-843..GH-856`
- downstream issue 固定为 `GH-844` 至 `GH-856`
- 后续 issue 执行前必须通过 GitHub fallback queue preflight
- 所有 testnet observability evidence 必须保持 no-order posture。

## V090-002-V080-PUBLICATION-ALIGNMENT-CARRYFORWARD

`V090-002-V080-PUBLICATION-ALIGNMENT-CARRYFORWARD`

GH-844 只把 v0.8.0 stable GitHub Release publication 的已完成事实作为 v0.9.0 carry-forward dependency 固定下来。v0.8.1 已通过 `GH-835-V081-V080-ACTUAL-GITHUB-RELEASE` 和 `V081-001-V080-PUBLICATION-DOCS-ALIGNMENT` 修复 v0.8.0 publication wording，v0.9.0 只继承已完成 publication evidence，不移动 tag、不重写 release、不创建新 release、不授权 production cutover。

Carry-forward evidence 固定为：

- `GH-844-VERIFY-V090-V080-PUBLICATION-ALIGNMENT-CARRYFORWARD`
- `TVM-RELEASE-V090-V080-PUBLICATION-ALIGNMENT-CARRYFORWARD`
- `checks/verify-v0.9.0-v080-publication-alignment.sh`
- `checks/verify-v0.8.1-v080-release-publication-docs.sh`
- v0.8.0 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.8.0`
- v0.8.0 tag peeled commit：`d83b3b564096a5427db15a437921fc797b22564d`

v0.9.0 后续文档可以引用 v0.8.0 status，但必须保留以下边界：

- construction closeout、public GitHub Release publication 和 production cutover 仍是三个独立 gate。
- 不得把 v0.8.0 stable GitHub Release publication 当作 production cutover authorization。
- 不得把 v0.8.1 patch evidence 当作 v0.9.0 runtime capability。
- 不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production submit / cancel / replace order，不创建交易按钮、order form、Live PRO Console production command 或 production OMS。

## V090-003-TESTNET-READONLY-MONITOR-SESSION

`V090-003-TESTNET-READONLY-MONITOR-SESSION`

GH-845 新增 TestnetReadOnlyMonitorSession 本地 artifact store。该 store 只把 testnet read-only monitor lifecycle 写入 `.local/mtpro/runs/<runID>/testnet-readonly-monitor/` 下的三个本地文件，不启动 runtime、不连接 endpoint、不读取 secret、不提交订单。

Required artifact 固定为：

- `V090-003-MONITOR-SESSION-JSON`：`monitor_session.json`
- `V090-003-MONITOR-EVENTS-JSONL`：`monitor_events.jsonl`
- `V090-003-MONITOR-STATUS-JSON`：`monitor_status.json`

`monitor_events.jsonl` 必须是 append-only monitor evidence chain。每一行必须保存 sequence、command、fromState、toState、observedAt、previousEventChecksum 和 eventChecksum；`monitor_session.json` 必须保存完整 event history、当前 state、artifact paths、checksum 和 no-order boundary evidence；`monitor_status.json` 只保存轻量状态快照、eventCount、lastEventChecksum 和 fail-closed status checksum。

`V090-003-MONITOR-STATE-TAXONOMY` 固定以下状态：

- `created`
- `connecting`
- `observing`
- `stale`
- `disconnected`
- `recovering`
- `stopped`
- `failed`

`V090-003-CORRUPTED-ARTIFACTS-FAIL-CLOSED` 要求读取 `monitor_session.json`、`monitor_events.jsonl` 或 `monitor_status.json` 任一损坏、checksum mismatch、event history 不一致或非法状态迁移时 fail closed。Fail closed 只返回本地错误证据，不触发 automatic reconnect、network refresh、broker write、testnet order routing、testnet order submission、production order 或 production cutover。

Carry-forward evidence 固定为：

- `GH-845-VERIFY-V090-TESTNET-MONITOR-SESSION-STORE`
- `TVM-RELEASE-V090-TESTNET-MONITOR-SESSION-STORE`
- `checks/verify-v0.9.0-monitor-session-store.sh`
- `ReleaseV090TestnetReadOnlyMonitorSessionStore`

GH-845 保持 `V090-003-NO-ORDER-PRODUCTION-CUTOVER`：不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production submit / cancel / replace order，不创建 trading button、order form、Live PRO Console production command、production OMS 或 production cutover authorization。

## V090-001-ALLOWED-MONITOR-MODES

`V090-001-ALLOWED-MONITOR-MODES`

v0.9.0 允许的 monitor mode 固定为：

- `testnet-read-only-observe`
- `snapshot-freshness-monitor`
- `private-stream-heartbeat-monitor`
- `reconciliation-review`
- `alert-read-model-only`
- `recovery-observe`
- `production-blocked`

`testnet-read-only-observe` 只允许显式 operator confirmation 下的 Binance testnet signed account / private stream read-only monitoring evidence，不允许 testnet submit / cancel / replace。`snapshot-freshness-monitor` 只允许 account snapshot freshness、age bucket 和 stale reason evidence。`private-stream-heartbeat-monitor` 只允许 heartbeat、last event age、disconnect / recovered state 和 redacted listenKey lifecycle evidence。`reconciliation-review` 只允许 explain-only reconciliation hardening，不允许 correction command 或 broker write。`alert-read-model-only` 只能输出 alert state / severity / acknowledgement read model，不允许 notification side effect、paging 或 incident command。`recovery-observe` 只允许 operator 观察和恢复分类，不允许 automatic reconnect 或 broker state mutation。`production-blocked` 只表示生产路径阻断证据，不是 production runtime、production endpoint connector、production broker adapter 或 production order authorization。

## V090-001-ARTIFACT-BOUNDARY

`V090-001-ARTIFACT-BOUNDARY`

V090 artifact boundary 固定为：

- `testnet-monitor-session.json`
- `account-snapshot-freshness.json`
- `private-stream-heartbeat.json`
- `monitor-recovery.json`
- `dashboard-observability-timeline.json`
- `alert-read-model.json`
- `reconciliation-timeline.json`
- `risk-policy-application-audit.json`
- `run-monitor-export-bundle.json`
- `validation-lanes.json`

这些 artifact 只允许存储 local run identity、redacted testnet read-only monitor summary、freshness / staleness evidence、read-only reconciliation review、Risk policy application audit、Dashboard / CLI observer projection 和 no-order boundary evidence。它们不得存储 production credential value、raw listenKey、raw private stream payload、broker command payload、order request payload、notification secret、production endpoint secret 或 production cutover authorization。

## V090-001-FRESHNESS-STALENESS-SEMANTICS

`V090-001-FRESHNESS-STALENESS-SEMANTICS`

v0.9.0 freshness / staleness taxonomy 固定为：

- `fresh`
- `stale`
- `disconnected`
- `recovering`
- `recovered`
- `blocked`
- `unavailable`

Freshness evidence 必须同时记录 source、observedAt、ageSeconds、thresholdSeconds、status、redactionHeld 和 noOrderHeld。`fresh` 只能表示 read-only monitor input 在阈值内；`stale` 只能表示 read-only input 超过阈值；`disconnected` 只能表示 read-only stream 或 monitor source 未连通；`recovering` / `recovered` 只表示 local recovery evidence，不授权 reconnect command；`blocked` 只表示 forbidden capability 被 gate 拒绝；`unavailable` 只表示当前 release 不包含该 capability。

## V090-001-CI-MANUAL-LANE-SPLIT

`V090-001-CI-MANUAL-LANE-SPLIT`

v0.9.0 继续拆分 deterministic CI proof lane 和 manual operator lane。

CI lane 只能验证 deterministic fixture、contract anchors、redaction、artifact schema、freshness / staleness taxonomy、Dashboard / CLI read model 和 no-order boundary。CI lane 必须保持：

- `ciNetworkRequired=false`
- `ciSecretRead=false`
- `ciOrderSubmissionAllowed=false`

Manual operator lane 只能记录 operator 明确确认过的 Binance testnet read-only network proof 摘要和 redacted artifact reference。Manual lane 必须保持：

- `manualOperatorConfirmationRequired=true`
- `manualProofRedacted=true`
- `manualOrderSubmissionAllowed=false`

Manual proof 不能升级为 deterministic CI proof，不能保存 raw credential、raw listenKey、raw private payload、production endpoint、broker state、order request、testnet submit / cancel / replace 或 production cutover authorization。

## V090-001-RECONCILIATION-HARDENING-SCOPE

`V090-001-RECONCILIATION-HARDENING-SCOPE`

v0.9.0 reconciliation hardening 只允许 explain-only / review-only evidence。允许的 reconciliation status 固定为：

- `matched`
- `delta`
- `missing`
- `stale`
- `blocked`

Reconciliation hardening 可以串联 local run journal projection、testnet read-only monitor snapshot、operator acknowledgement、risk policy application audit 和 Dashboard / CLI timeline。它不得创建 correction command、broker write path、account mutation、portfolio mutation command、trading adjustment command、testnet order routing、testnet order submission、production trading、production secret auto-read、production endpoint / broker connection、production order submission 或 production cutover。

## V090-001-DOWNSTREAM-QUEUE-ORDER

`V090-001-DOWNSTREAM-QUEUE-ORDER`

V090 queue 顺序固定为：

- `GH-843` Define v0.9.0 testnet no-order observability contract
- `GH-844` Align v0.8.0 release publication docs if not patched
- `GH-845` Add persistent TestnetReadOnlyMonitorSession
- `GH-846` Add signed account snapshot freshness monitor
- `GH-847` Add private stream heartbeat and staleness detection
- `GH-848` Add monitor recovery workflow
- `GH-849` Add Dashboard observability timeline
- `GH-850` Add alerting read-model without notification side effects
- `GH-851` Harden Portfolio reconciliation timeline
- `GH-852` Add Risk policy profile application audit
- `GH-853` Add run and monitor export bundle
- `GH-854` Split CI and manual lanes further
- `GH-855` Harden Dashboard and CLI operator UX
- `GH-856` Close v0.9.0 final audit / docs / runbook

每个 issue 执行前必须由 Parent Codex / `@002 / PAR` 使用 GitHub fallback queue live state 重新确认 WIP=1、依赖完成、无 active conflict、worktree clean、`main == origin/main`。`first executable candidate` 只表示候选，不绕过 preflight。

## V090-001-FORBIDDEN-CAPABILITIES

`V090-001-FORBIDDEN-CAPABILITIES`

v0.9.0 contract 固定以下 release boundary：

- `venue=Binance`
- `productTypes=spot,usdsPerpetual`
- `strategies=EMA,RSI`
- `noOrder=true`
- `testnetReadOnlyObservabilityAllowed=true`
- `testnetOrderSubmissionAllowed=false`
- `testnetOrderRoutingAllowed=false`
- `testnetCancelReplaceAllowed=false`
- `productionTradingEnabledByDefault=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `productionBrokerConnected=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`

Forbidden capability list：

- production trading
- production secret read
- production endpoint / broker endpoint connection
- automatic broker connection
- testnet submit / cancel / replace
- production submit / cancel / replace
- real order lifecycle
- production OMS
- broker fill / production reconciliation runtime
- Live PRO Console production command
- trading button
- order form
- notification side effect
- automatic recovery command
- production cutover

## V090-001-RELEASE-VALIDATION-MATRIX

`V090-001-RELEASE-VALIDATION-MATRIX`

GH-843 required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/verify-v0.9.0-contract.sh`
- `swift test --filter GH843`
- `bash checks/run.sh`

`checks/verify-v0.9.0-contract.sh` 必须固定合同锚点、allowed monitor modes、artifact boundary、freshness / staleness semantics、CI / manual lane split、reconciliation hardening scope、downstream queue order 和 forbidden capabilities。`checks/run.sh` 必须串联该 verifier，使后续 release issues 无法移除 v0.9.0 contract gate。
