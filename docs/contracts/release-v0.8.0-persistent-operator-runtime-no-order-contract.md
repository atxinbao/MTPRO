# Release v0.8.0 Persistent Operator Runtime No-order Contract

日期：2026-06-15

执行者：Codex

本文档服务 GitHub fallback issue `GH-807 V080-001 Define v0.8.0 persistent operator runtime no-order contract`。

本文档定义 `MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring` 的第一层 release contract。它只授权后续 V080 issues 在 GitHub fallback queue 中按依赖顺序推进 persistent local operator runtime、run registry store、session store、safe local controls、manual Binance testnet read-only monitoring、Portfolio reconciliation review 和 deterministic / manual evidence split；不实现 production runtime、不读取 production secret、不连接 production endpoint / broker、不提交 / 取消 / 替换 testnet 或 production 订单、不授权 production cutover。

## V080-001-PERSISTENT-OPERATOR-RUNTIME-NO-ORDER-CONTRACT

`V080-001-PERSISTENT-OPERATOR-RUNTIME-NO-ORDER-CONTRACT`

GH-807 是 V080 queue `GH-807..GH-820` 的第一个 gate。当前权威 source anchor：

- `docs/contracts/release-v0.8.0-persistent-operator-runtime-no-order-contract.md`
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RELEASE-V080-PERSISTENT-OPERATOR-RUNTIME-NO-ORDER-CONTRACT`
- `checks/verify-v0.8.0-contract.sh`

合同固定：

- release version 固定为 `v0.8.0`
- project name 固定为 `MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring`
- active venue 只能是 `Binance`
- active product types 只能是 `spot` 和 `usdsPerpetual`
- active strategies 只能是 `EMA` 和 `RSI`
- queue range 固定为 `GH-807..GH-820`
- downstream issue 固定为 `GH-808` 至 `GH-820`
- 后续 issue 执行前必须通过 GitHub fallback queue preflight
- 所有 persistent operator runtime evidence 必须保持 no-order posture。

## V080-001-ALLOWED-MODES

`V080-001-ALLOWED-MODES`

v0.8.0 允许的 mode 固定为：

- `local-persistent-operator-runtime`
- `testnet-read-only-monitoring`
- `manual-network-proof`
- `recovery-review`
- `production-blocked`

`local-persistent-operator-runtime` 是默认 operational mode，只允许本地 run registry、session store、event log、manifest、read-only observer 和 safe local controls evidence。`testnet-read-only-monitoring` 只允许显式 operator confirmation 下的 Binance testnet signed account / private stream read-only monitoring evidence，不允许 testnet submit / cancel / replace。`manual-network-proof` 只能记录 operator 提供的手动网络证明摘要与红acted artifact reference，不得把 manual proof 升级为 deterministic CI proof。`recovery-review` 只允许 operator 观察、恢复分类、incomplete run 识别和 read-only replay evidence。`production-blocked` 只表示生产路径阻断证据，不是 production runtime、production endpoint connector、production broker adapter 或 production order authorization。

## V080-001-PERSISTENT-LOCAL-ARTIFACTS

`V080-001-PERSISTENT-LOCAL-ARTIFACTS`

V080 persistent local artifact boundary 固定为：

- `run-registry.json`
- `operator-session-store.json`
- `events.jsonl`
- `manifest.json`
- `status.json`
- `reconciliation-review.json`
- `risk-policy-profile.json`
- `dashboard-readonly-snapshot.json`

这些 artifact 只允许存储 local runtime state、redacted testnet read-only status、manual proof reference、read-only reconciliation review 和 no-order boundary evidence。它们不得存储 production credential value、raw listenKey、raw private stream payload、broker command payload、order request payload 或 production endpoint secret。

## V080-003-RUN-REGISTRY-STORE

`V080-003-RUN-REGISTRY-STORE`

GH-809 把 v0.7 deterministic in-memory registry 推进为 persistent local `RunRegistryStore`。该 store 只写入 `.local/mtpro/runs/registry.json`，并使用 `.local/mtpro/runs/registry.lock` 作为本地 registry lock evidence。

Required anchors：

- `V080-003-REGISTRY-JSON-PATH`
- `V080-003-REGISTRY-LOCK`
- `V080-003-REGISTRY-CHECKSUM`
- `V080-003-LIST-INSPECT-ARCHIVE-RECOVER`
- `V080-003-MISSING-CORRUPTED-FAILS-CLOSED`
- `V080-003-NO-PRODUCTION-BROKER-ORDER-FIELDS`

Registry entry 必须记录 runID、state、artifact paths、lifecycle、timestamps 和 checksum。`list`、`inspect`、`archive` 和 `recover` 只修改本地 registry metadata。missing / corrupted registry、checksum mismatch、lock unavailable 或 archived mutation 必须 fail closed。Registry state 不得打开 production trading、production secret read、production endpoint / broker connection、testnet order routing、testnet order submission、real order、production OMS、Dashboard production command、trading button、order form 或 production cutover。

## V080-004-CLI-LOCAL-SESSION-ACTIONS

`V080-004-CLI-LOCAL-SESSION-ACTIONS`

GH-810 把 top-level `mtpro run` / `mtpro status` / `mtpro stop` / `mtpro recover` 绑定到本地 persistent no-order session artifact。该绑定只使用 `.local/mtpro/runs` 或 `MTPRO_LOCAL_RUNS_ROOT` 指向的本地目录，并复用 GH-809 的 persistent `RunRegistryStore`。

Required anchors：

- `V080-004-RUN-CREATES-LOCAL-ARTIFACTS`
- `V080-004-STATUS-READS-REGISTRY`
- `V080-004-STOP-RECOVER-LOCAL-ONLY`
- `V080-004-NO-ENDPOINT-BROKER-ORDER-PATH`

`mtpro run --mode dry-run` 必须创建 local runID、`registry.json` entry、per-run `_RUN_STATUS.json`、`status.json`、`events.jsonl` 和 `manifest.json`。`mtpro status` 只能读取 registry / status artifact。`mtpro stop` 和 `mtpro recover` 只能把本地 session evidence 更新为 stopped / recovered，不得触发 endpoint、broker、ExecutionClient、OMS、submit / cancel / replace、testnet order 或 production order path。

## V080-005-OPERATIONAL-RUN-SESSION-STORE

`V080-005-OPERATIONAL-RUN-SESSION-STORE`

GH-811 新增 `OperationalRunSessionStore`，把 operator run lifecycle state 和 event history 固定到 `.local/mtpro/runs/<runID>/` 本地证据文件。该 store 只写本地 session 文件，不启动 runtime、不读取 secret、不连接 endpoint / broker、不提交 testnet 或 production order、不授权 production cutover。

Required anchors：

- `V080-005-SESSION-JSON`
- `V080-005-SESSION-EVENTS-JSONL`
- `V080-005-SESSION-STATUS-JSON`
- `V080-005-INVALID-TRANSITION-FAILS-CLOSED`
- `V080-005-RECOVERY-PRESERVES-HISTORY`

`session.json` 必须保存 runID、state、timestamps、event checksum chain、failure / recovery reason 和 no-order boundary evidence。`session_events.jsonl` 必须保存 created / start / running / stop / stopped / failed / recovered / completed lifecycle event history。`session_status.json` 必须保存轻量状态快照。无效状态迁移必须 fail closed，且不能写入新事件或新状态。recovered run 必须保留恢复前 event history 并记录 recovery reason。

## V080-006-EVENT-LOG-WRITER-CRASH-RECOVERY

`V080-006-EVENT-LOG-WRITER-CRASH-RECOVERY`

GH-812 加固 `EventLogWriter` 的本地 crash recovery：继续复用 `events.jsonl` append-only runtime event log，但要求 event schema version 显式、multi-batch append 后 checksum chain 可验证、duplicate run / event evidence fail closed、partial line 在下一次 append 前 deterministic truncate，完整但损坏的 line 必须 quarantine 或 fail closed，不能 silent loss。

Required anchors：

- `V080-006-EVENT-SCHEMA-VERSION`
- `V080-006-CORRUPTED-LINE-QUARANTINE`
- `V080-006-NO-COMPACTION-POLICY`
- `V080-006-DUPLICATE-RUN-EVENT-FAILS-CLOSED`

`events.jsonl.quarantine` 只保存完整损坏 line 的本地 quarantine evidence，必须记录 runID、原始行号、原始 line、quarantine reason 和 checksum。v0.8.0 不执行 log compaction；compaction policy 固定为 append-only no-compaction。该能力不得连接 endpoint / broker，不得读取 secret，不得提交 testnet 或 production order，不得授权 production cutover。

## V080-007-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF

`V080-007-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF`

GH-813 将 operator 已执行的 Binance Spot testnet signed account read-only network proof 压成 redacted proof artifact。该 artifact 只能消费 GH-786 `networkReadOnly` signed account read-only source artifact，并记录 `networkAttempted=true`、`signedAccountSnapshotRead=true`、endpoint host `testnet.binance.vision`、endpoint path `/api/v3/account`、manual proof reference、operator confirmation id 和 redacted credential reference。

Required anchors：

- `GH-813-VERIFY-V080-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF`
- `TVM-RELEASE-V080-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF`
- `V080-007-NETWORK-ATTEMPTED-AND-SNAPSHOT-READ`
- `V080-007-REDACTED-CREDENTIAL-REFERENCE`
- `V080-007-CI-DETERMINISTIC-NO-NETWORK-SECRET`
- `V080-007-NO-TESTNET-ORDER-ROUTING`
- `V080-007-NO-PRODUCTION-CUTOVER`

CI 只验证 deterministic mock source artifact、redaction、合同字段和 no-order boundary；CI 不读取真实 credential value，不要求 network，不把手动 proof 升级为 deterministic CI proof。GH-813 artifact 不保存 raw account payload、API key、secret、production endpoint、broker state、order request、testnet submit / cancel / replace 或 production cutover authorization。

## V080-008-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING

`V080-008-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING`

GH-814 将 operator 已执行的 Binance Spot testnet private stream open / observe / close read-only monitoring proof 压成 redacted proof artifact。该 artifact 只能消费 GH-787 `networkReadOnly` private stream read-only source artifact，并记录 listenKey lifecycle、account / balance / position read-model 摘要、freshness statuses、manual proof reference、operator confirmation id、redacted credential reference 和 redacted listenKey reference。

Required anchors：

- `GH-814-VERIFY-V080-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING`
- `TVM-RELEASE-V080-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING`
- `V080-008-LISTENKEY-LIFECYCLE-OPEN-OBSERVE-CLOSE`
- `V080-008-ACCOUNT-BALANCE-POSITION-READMODEL`
- `V080-008-REDACTED-LISTENKEY-CREDENTIAL-REFERENCE`
- `V080-008-EXECUTIONREPORT-COMMAND-PATH-REJECTION`
- `V080-008-NO-TESTNET-ORDER-ROUTING`
- `V080-008-NO-PRODUCTION-CUTOVER`

CI 只验证 deterministic mock source artifact、redaction、合同字段、executionReport command path rejection 和 no-order boundary；CI 不读取真实 credential value，不要求 network，不把手动 proof 升级为 deterministic CI proof。GH-814 artifact 不保存 raw listenKey、raw private payload、API key、secret、production endpoint、broker state、executionReport command、order request、testnet submit / cancel / replace 或 production cutover authorization。

## V080-009-DASHBOARD-TESTNET-READONLY-MONITOR-SURFACE

`V080-009-DASHBOARD-TESTNET-READONLY-MONITOR-SURFACE`

GH-815 将 GH-813 signed account proof 和 GH-814 private stream monitoring proof 的 Dashboard-safe 摘要展示为只读 monitor surface。Dashboard 可以展示 account snapshot freshness、private stream freshness、listenKey lifecycle、last observed event、stale / disconnected / recovered state、credential redaction status 和 listenKey redaction status，但不得显示 credential value、raw listenKey、raw private payload、runtime object、adapter request、transport request、broker state 或订单命令。

Required anchors：

- `GH-815-VERIFY-V080-DASHBOARD-TESTNET-READONLY-MONITOR`
- `TVM-RELEASE-V080-DASHBOARD-TESTNET-READONLY-MONITOR`
- `V080-009-ACCOUNT-SNAPSHOT-FRESHNESS`
- `V080-009-PRIVATE-STREAM-FRESHNESS`
- `V080-009-LISTENKEY-LIFECYCLE-VISIBLE`
- `V080-009-STALE-DISCONNECTED-RECOVERED-STATES`
- `V080-009-CREDENTIAL-LISTENKEY-REDACTION-STATUS`
- `V080-009-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND`
- `V080-009-NO-TESTNET-ORDER-ROUTING`
- `V080-009-NO-PRODUCTION-CUTOVER`

Dashboard target 必须继续消费 App / Dashboard 层 read model，不得新增 DataClient target dependency，不得直接调用 Binance signed account runtime、private stream runtime、credential provider、listenKey lifecycle transport、WebSocket event source 或 endpoint URL。CI 只验证 deterministic read model / ViewModel contract、smoke summary、文档锚点和 no-order boundary；CI 不读取真实 credential value，不要求 network，不连接 testnet / production endpoint，不提交 testnet 或 production order，不授权 production cutover。

## V080-010-RISK-POLICY-PROFILE-MANAGEMENT

`V080-010-RISK-POLICY-PROFILE-MANAGEMENT`

GH-816 将 v0.7 local Risk policy config 提升为 operator-managed `risk_policy.json` profile evidence。Profile 必须携带 version、deterministic policy hash、operator change metadata、allowed symbols / product types、applied run IDs 和 run manifest policy reference，并通过 CLI `risk-policy show`、`risk-policy validate`、`risk-policy diff` 暴露只读管理面。

Required anchors：

- `GH-816-VERIFY-V080-RISK-POLICY-PROFILE-MANAGEMENT`
- `TVM-RELEASE-V080-RISK-POLICY-PROFILE-MANAGEMENT`
- `V080-010-RISK-POLICY-JSON-VERSION-HASH`
- `V080-010-DETERMINISTIC-POLICY-DIFF`
- `V080-010-OPERATOR-CHANGE-METADATA`
- `V080-010-RUN-APPLICATION-POLICY-REFERENCE`
- `V080-010-CLI-SHOW-VALIDATE-DIFF`
- `V080-010-NO-BROKER-ENDPOINT-OMS-ORDER-PATH`

Risk policy profile management 不得打开 broker、production endpoint、OMS bypass、order command path、testnet order routing、production trading、production secret auto-read 或 production cutover。CLI 只能输出 deterministic local evidence，不读取 credential value、不连接 testnet / production endpoint、不提交 testnet 或 production order、不授权 production cutover。

## V080-011-PORTFOLIO-REVIEW-WORKFLOW

`V080-011-PORTFOLIO-REVIEW-WORKFLOW`

GH-817 将 GH-790 read-only reconciliation diff 提升为本地 operator review workflow。该 workflow 只消费 explain-only reconciliation evidence，生成 matched / delta / missing / stale status、`review_required`、`operator_note`、`acknowledged_at`、`acknowledged_by`、stale observed state 和 audit trail artifact。

Required anchors：

- `GH-817-VERIFY-V080-PORTFOLIO-RECONCILIATION-REVIEW-WORKFLOW`
- `TVM-RELEASE-V080-PORTFOLIO-RECONCILIATION-REVIEW-WORKFLOW`
- `V080-011-RECONCILIATION-STATUS-MATCHED-DELTA-MISSING-STALE`
- `V080-011-REVIEW-REQUIRED-OPERATOR-NOTE-ACK`
- `V080-011-STALE-OBSERVED-STATE`
- `V080-011-AUDIT-TRAIL-ARTIFACTS`
- `V080-011-NO-CORRECTION-COMMAND-BROKER-WRITE`
- `V080-011-PORTFOLIO-REVIEW-WORKFLOW`

Operator acknowledgement 只能作为 audit-only metadata。`matched` 不要求 review；`delta`、`missing` 和 `stale` 必须要求 review，并记录 operator note / acknowledgement metadata。Audit trail artifact 只落在本地 `.local/mtpro/runs/<runID>/reconciliation-review/` 语义下，不保存 raw broker payload、account endpoint payload、credential value、order request 或 production endpoint。

Portfolio reconciliation review workflow 不得创建 correction command、broker write path、account mutation、trading adjustment command、testnet order routing、production trading、production secret auto-read、production endpoint / broker connection、production order submission 或 production cutover。

## V080-001-TESTNET-READONLY-MONITORING

`V080-001-TESTNET-READONLY-MONITORING`

v0.8.0 可以把 `testnetReadOnlyMonitoringAllowed=true` 写入合同和 evidence，但必须同时固定：

- `testnetOrderSubmissionAllowed=false`
- `testnetOrderRoutingAllowed=false`
- `testnetCancelReplaceAllowed=false`
- `testnetBrokerCommandAllowed=false`
- `testnetListenKeyRawPersistenceAllowed=false`
- `testnetCredentialValuePersistenceAllowed=false`

testnet read-only monitoring 只允许被 GH-813、GH-814 和 GH-815 后续 issue 在当前合同边界内扩展。它不得连接 production endpoint，不得使用 production secret，不得提交、取消或替换 testnet / production order。

## V080-001-SAFE-OPERATOR-CONTROLS

`V080-001-SAFE-OPERATOR-CONTROLS`

v0.8.0 safe local controls 固定为：

- `start-local-session`
- `stop-local-session`
- `recover-local-session`
- `archive-local-session`
- `refresh-readonly-monitor`
- `record-manual-proof-summary`
- `open-reconciliation-review`

这些 controls 只作用于本地 persistent operator runtime state 和 read-only evidence surface。它们不得触发 ExecutionClient、broker adapter、OMS production handoff、signed production endpoint、submit / cancel / replace、trading button、order form、live command 或 Live PRO Console production command。

## V080-001-DOWNSTREAM-QUEUE-ORDER

`V080-001-DOWNSTREAM-QUEUE-ORDER`

V080 GitHub fallback queue 必须保持 WIP=1，且每个 issue 独立分支、独立 PR、独立验证、独立 merge：

1. `GH-807` / `V080-001`：Define v0.8.0 persistent operator runtime no-order contract
2. `GH-808` / `V080-002`：Align v0.7.0/v0.8.0 release publication docs and policy
3. `GH-809` / `V080-003`：Add persistent RunRegistryStore
4. `GH-810` / `V080-004`：Bind top-level CLI actions to local run session creation
5. `GH-811` / `V080-005`：Add OperationalRunSessionStore
6. `GH-812` / `V080-006`：Harden EventLogWriter local crash recovery
7. `GH-813` / `V080-007`：Add manual Binance testnet signed-account read-only network proof
8. `GH-814` / `V080-008`：Add manual Binance testnet private-stream read-only monitoring
9. `GH-815` / `V080-009`：Add Dashboard testnet read-only monitor surface
10. `GH-816` / `V080-010`：Add local Risk policy profile management
11. `GH-817` / `V080-011`：Add Portfolio reconciliation review workflow
12. `GH-818` / `V080-012`：Wire Dashboard safe local controls to session store
13. `GH-819` / `V080-013`：Split deterministic CI proof from manual operator network proof
14. `GH-820` / `V080-014`：Close v0.8.0 final audit / docs / runbook

后续 issue 执行前必须确认 dependencies closed / done、current issue body 已读取、`main == origin/main`、worktree clean、open PR=0，且没有其他 open issue 带 `todo` / `in-progress` / `in-review` label。

## V080-001-FORBIDDEN-CAPABILITIES

`V080-001-FORBIDDEN-CAPABILITIES`

GH-807 和整个 V080 release line 都不授权：

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
- testnet order routing。
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

## V080-001-EVIDENCE-ENVELOPE

`V080-001-EVIDENCE-ENVELOPE`

每个 V080 persistent operator runtime evidence envelope 必须保留：

- `releaseVersion=v0.8.0`
- `runID`
- `sessionMode`
- `operatorConfirmation`
- `venue=Binance`
- `productTypes=spot,usdsPerpetual`
- `strategies=EMA,RSI`
- `noOrder=true`
- `persistentLocalRuntime=true`
- `testnetReadOnlyMonitoringAllowed=true`
- `productionTradingEnabledByDefault=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `productionBrokerConnected=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`
- `testnetOrderSubmissionAllowed=false`
- `testnetOrderRoutingAllowed=false`

以上字段是 v0.8.0 hard contract。后续 issue 可以定义 persistent store、manual testnet read-only proof、Dashboard monitor、Risk policy profile、Portfolio reconciliation review 和 safe local controls，但不得把任一 forbidden capability 字段切换为 `true`。

## TVM-RELEASE-V080-PERSISTENT-OPERATOR-RUNTIME-NO-ORDER-CONTRACT

`TVM-RELEASE-V080-PERSISTENT-OPERATOR-RUNTIME-NO-ORDER-CONTRACT`

Required validation：

- `bash checks/verify-v0.8.0-contract.sh`
- `swift test --filter TargetGraphTests/testGH807ReleaseV080PersistentOperatorRuntimeNoOrderContractDefinesAllowedModesAndForbiddenCapabilities`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## V080-001 Non-authorization

GH-807 不创建下一 Project / Issue，不推进 release v0.8.0 之后的阶段，不发布 tag，不修改 root latest completed release statement，不把 v0.8.0 标记为 completed，不实现 runtime，不授权 production cutover。
