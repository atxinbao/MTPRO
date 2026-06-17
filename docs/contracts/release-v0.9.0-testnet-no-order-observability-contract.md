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

## V090-004-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS

`V090-004-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS`

GH-846 在 GH-845 的 TestnetReadOnlyMonitorSession 本地 artifact store 之上新增 signed account snapshot freshness evidence。该 evidence 只写入 `.local/mtpro/runs/<runID>/testnet-readonly-monitor/account-snapshot-freshness.json`，并绑定同一 `runID` 与 `monitor_session.json` checksum；它不保存 raw account payload、不保存 credential value、不连接 endpoint、不提交订单。

Required artifact 固定为：

- `V090-004-ACCOUNT-SNAPSHOT-FRESHNESS-JSON`：`account-snapshot-freshness.json`

`account-snapshot-freshness.json` 必须保存 snapshotObservedAt、recordedAt、latencyMilliseconds、ageSeconds、staleThresholdSeconds、freshnessStatus、ageBucket、staleReason、redactedCredentialReference、monitorSessionChecksum 和 fail-closed checksum。Freshness status 必须复用 `V090-001-FRESHNESS-STALENESS-SEMANTICS` 中的 taxonomy；当前 deterministic store 只从 signed account snapshot timestamp 计算 `fresh` / `stale`，其余状态保留给后续 read-only monitor evidence，不授权 reconnect 或 command。

`V090-004-REDACTED-CREDENTIAL-REFERENCE` 要求 artifact 只保存逻辑 credential profile reference 的 redacted 形式，例如 `<profile-reference>:<redacted>`。明显 raw secret、API key、token、listenKey、signature 或长随机 credential material 必须 fail closed，不得写入 artifact。

`V090-004-NO-RAW-PAYLOAD-PERSISTENCE` 要求 artifact 明确保持 `rawPayloadPersisted=false`、`rawAccountPayloadPersisted=false` 和 `credentialValuePersisted=false`。读取损坏、checksum mismatch、monitorSessionChecksum 不匹配或 redaction guard 失败时只返回本地错误证据，不触发 network refresh、broker write、testnet order routing、testnet order submission、production order 或 production cutover。

Carry-forward evidence 固定为：

- `GH-846-VERIFY-V090-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS`
- `TVM-RELEASE-V090-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS`
- `checks/verify-v0.9.0-snapshot-freshness-monitor.sh`
- `ReleaseV090AccountSnapshotFreshnessDocument`

GH-846 保持 no-order / no-production boundary：不读取 production secret，不连接 production endpoint / broker，不保存 raw account payload，不提交 testnet 或 production submit / cancel / replace order，不创建 trading button、order form、Live PRO Console production command、production OMS 或 production cutover authorization。

## V090-005-PRIVATE-STREAM-HEARTBEAT-STALENESS

`V090-005-PRIVATE-STREAM-HEARTBEAT-STALENESS`

GH-847 在 GH-845 的 TestnetReadOnlyMonitorSession 本地 artifact store 之上新增 private stream heartbeat / staleness evidence。该 evidence 只写入 `.local/mtpro/runs/<runID>/testnet-readonly-monitor/private-stream-heartbeat.json`，并绑定同一 `runID` 与 `monitor_session.json` checksum；它不保存 raw listenKey、不保存 raw private stream payload、不保存 credential value、不连接 endpoint、不提交订单。

Required artifact 固定为：

- `V090-005-PRIVATE-STREAM-HEARTBEAT-JSON`：`private-stream-heartbeat.json`

`private-stream-heartbeat.json` 必须保存 lastEventObservedAt、heartbeatRecordedAt、heartbeatIntervalSeconds、lastEventAgeSeconds、staleThresholdSeconds、listenKeyCreatedAt、listenKeyExpiresAt、listenKeyAgeSeconds、listenKeySecondsUntilExpiry、listenKeyAgeBucket、heartbeatStatus、streamStale、streamRecovered、disconnectedReason、recoveryReason、redactedListenKeyReference、listenKeyReferenceHash、monitorSessionChecksum 和 fail-closed checksum。Heartbeat status 必须覆盖 `healthy`、`stale`、`disconnected`、`recovering`、`recovered`、`expired` 和 `unavailable`，但这些状态只允许作为 read-only evidence，不授权 automatic reconnect 或 command。

`V090-005-REDACTED-LISTENKEY-REFERENCE` 要求 artifact 只保存逻辑 stream lease reference 的 redacted 形式和 stable hash，例如 `<stream-lease-reference>:<redacted>` 与 `sha256:<hash>`。明显 raw listenKey、secret、API key、token、signature 或长随机 credential material 必须 fail closed，不得写入 artifact。

`V090-005-NO-RAW-PRIVATE-PAYLOAD-PERSISTENCE` 要求 artifact 明确保持 `rawListenKeyPersisted=false`、`rawPrivatePayloadPersisted=false` 和 `credentialValuePersisted=false`。读取损坏、checksum mismatch、monitorSessionChecksum 不匹配或 redaction guard 失败时只返回本地错误证据，不触发 network refresh、automatic reconnect、broker write、testnet order routing、testnet order submission、production order 或 production cutover。

Carry-forward evidence 固定为：

- `GH-847-VERIFY-V090-PRIVATE-STREAM-HEARTBEAT-STALENESS`
- `TVM-RELEASE-V090-PRIVATE-STREAM-HEARTBEAT-STALENESS`
- `checks/verify-v0.9.0-private-stream-heartbeat-monitor.sh`
- `ReleaseV090PrivateStreamHeartbeatDocument`

GH-847 保持 no-order / no-production boundary：不读取 production secret，不连接 production endpoint / broker，不保存 raw listenKey 或 raw private stream payload，不提交 testnet 或 production submit / cancel / replace order，不创建 trading button、order form、Live PRO Console production command、production OMS 或 production cutover authorization。

## V090-006-MONITOR-RECOVERY-WORKFLOW

`V090-006-MONITOR-RECOVERY-WORKFLOW`

GH-848 在 GH-845 / GH-846 / GH-847 的本地 monitor evidence 之上新增 no-order recovery workflow artifact。该 workflow 只允许从 `stale` 或 `disconnected` 状态进入 `recovering`，再回到 `observing`；它只是记录 operator 手动恢复、listenKey evidence reopen 和 read-model rebuild evidence，不启动 automatic reconnect，不调用 network，不写 broker，不提交订单。

Required artifact 固定为：

- `V090-006-MONITOR-RECOVERY-JSON`：`monitor-recovery.json`

`monitor-recovery.json` 必须保存 recoveryAction、fromState、intermediateState、toState、recoveryReason、preRecoveryMonitorSessionChecksum、recoveredMonitorSessionChecksum、previousEventChecksums、recoveredEventChecksums、eventHistoryPreserved、redactedListenKeyReference、listenKeyReferenceHash、reopenedListenKeyEvidence、rebuiltReadModelEvidence、rebuiltReadModelEvidenceChecksum 和 fail-closed checksum。

`V090-006-PRESERVE-MONITOR-EVENT-HISTORY` 要求 recovery artifact 的 `recoveredEventChecksums` 必须以前序事件 checksum 作为完整前缀，并且只追加 `recover` 与 `observe` 两个本地事件。任何事件历史丢失、checksum mismatch、非法状态迁移、损坏 `monitor-recovery.json` 或 recovered monitor session checksum 不匹配都必须 fail closed。

`V090-006-LOCAL-MANUAL-RECOVERY-ONLY` 要求 recovery 只表达本地手动 operator recovery evidence。Artifact 必须保持 `manualLocalRecovery=true`、`automaticReconnectCommand=false`、`rawListenKeyPersisted=false`、`rawPrivatePayloadPersisted=false`、`credentialValuePersisted=false`、`ciNetworkRequired=false`、`ciSecretRead=false` 和 `ciOrderSubmissionAllowed=false`。

Carry-forward evidence 固定为：

- `GH-848-VERIFY-V090-MONITOR-RECOVERY-WORKFLOW`
- `TVM-RELEASE-V090-MONITOR-RECOVERY-WORKFLOW`
- `checks/verify-v0.9.0-monitor-recovery-workflow.sh`
- `ReleaseV090MonitorRecoveryDocument`

GH-848 保持 no-order / no-production boundary：不读取 production secret，不连接 production endpoint / broker，不保存 raw listenKey 或 raw private stream payload，不提交 testnet 或 production submit / cancel / replace order，不创建 trading button、order form、Live PRO Console production command、production OMS 或 production cutover authorization。

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

## V090-007-DASHBOARD-OBSERVABILITY-TIMELINE

`V090-007-DASHBOARD-OBSERVABILITY-TIMELINE`

`GH-849-VERIFY-V090-DASHBOARD-OBSERVABILITY-TIMELINE`

`TVM-RELEASE-V090-DASHBOARD-OBSERVABILITY-TIMELINE`

GH-849 Dashboard observability timeline 只允许消费 GH-845..GH-848 的本地 monitor/session artifact 摘要：

- `monitor_session.json`
- `monitor_events.jsonl`
- `monitor_status.json`
- `account-snapshot-freshness.json`
- `private-stream-heartbeat.json`
- `monitor-recovery.json`

`V090-007-MONITOR-SESSION-ARTIFACTS-ONLY`

Dashboard 不直接依赖 DataClient target，不直接依赖 Database runtime，不读取 `.local/mtpro/runs/...` raw payload，不打开 network，不读取 secret，不连接 endpoint，也不调用 recovery / reconnect command。Dashboard 只能展示 artifact source、source issue、checksum reference、redaction status、no-order status 和 read-model summary。

`V090-007-SNAPSHOT-PRIVATE-STREAM-FRESHNESS-TIMELINES`

Dashboard 必须同时展示：

- account snapshot timeline；
- private stream timeline；
- freshness timeline。

`V090-007-STALE-DISCONNECTED-RECOVERED-EVENTS`

Dashboard 必须展示 `stale`、`disconnected` 和 `recovered` 事件，但这些事件只表示已落仓 evidence 的状态，不授权 automatic reconnect、listenKey refresh、broker command 或 order routing。

`V090-007-LAST-OBSERVED-EVENT-KIND`

Dashboard 必须展示 last observed event kind，且该字段只能来自 redacted monitor artifact summary，不能来自 raw private stream payload。

`V090-007-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND`

Dashboard observability timeline 不得包含 trading button、order form、live command、submit / cancel / replace、testnet order routing、production trading、production secret auto-read、production endpoint / broker connection、production order submission 或 production cutover authorization。

`V090-007-NO-TESTNET-ORDER-ROUTING`

`V090-007-NO-PRODUCTION-CUTOVER`

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
