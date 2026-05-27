# Account / Position / Balance Read-model-only Contract

日期：2026-05-28

执行者：Codex

本文档定义 `MTPRO Account / Position / Balance Read-model-only v1` 的 MTP-133 合同入口：L3.1 account / position / balance read-model-only terminology、source semantics boundary、evidence interpretation boundary、L3.1 / L3.2 handoff、first executable candidate non-authorization、forbidden capability baseline 和 validation anchors。

本文档只服务 `MTP-133 Define account / position / balance read-model-only terminology and boundary` 的术语 / 边界 / 验证锚点。它不实现 account / position / balance runtime，不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL；不接 signed endpoint、account endpoint / listenKey；不创建 private WebSocket runtime、account snapshot runtime、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form；不运行 Graphify，不修改 Figma。

## MTP-133 Account / Position / Balance read-model-only terminology

`MTP-133-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY-TERMINOLOGY`

MTP-133 只允许定义以下 L3.1 术语，不允许把术语升级为 runtime：

| 术语 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `account read-model-only evidence` | 本地 / fixture / paper / simulated 来源的账户证据解释层，用来说明 account identity、source 和 readiness boundary | 不等于真实 account endpoint payload、account snapshot runtime、broker account sync 或可交易账户状态 |
| `position read-model-only evidence` | 本地 / fixture / paper / simulated 来源的仓位证据解释层，用来说明 position identity、exposure 和 stale / blocked 状态 | 不等于 broker position、margin position、leverage position、real portfolio sync 或 broker risk input |
| `balance read-model-only evidence` | 本地 / fixture / paper / simulated 来源的余额证据解释层，用来说明 paper cash、paper equity、simulated balance 和 future-gated real balance 的解释边界 | 不等于真实账户余额、buying power、margin、leverage、real PnL 或可下单资金 |
| `read-model-only source` | 证据来源标签，当前只允许 fixture / paper / simulated / future-gated real label | 不等于 account endpoint、listenKey、private stream、broker adapter 或真实账户连接 |
| `future real source` | 未来可能接入真实账户只读能力前的门禁标签 | 不等于当前已实现真实账户读取、secret storage、signed request 或 private WebSocket |

## MTP-133 Source semantics boundary

`MTP-133-SOURCE-SEMANTICS-BOUNDARY`

MTP-133 将 L3.1 source semantics 固定为只读解释层：

1. `fixture source` 表示 deterministic local fixture，可用于后续 MTP-134 / MTP-137 的 checksum、freshness 和 validation anchor；它不等于真实 account payload。
2. `paper source` 表示 paper runtime / paper portfolio 产生的本地证据；它不等于真实账户、broker position 或 real PnL。
3. `simulated source` 表示 scenario replay / simulated exchange / backtest parity 产生的本地证据；它不等于 broker fill、execution report 或 reconciliation。
4. `future-gated real source` 只能作为未来门禁标签出现；当前不读取 real account，不调用 signed endpoint，不创建 listenKey，不运行 account snapshot runtime。

后续 MTP-134 / MTP-135 / MTP-136 可以分别深化 account snapshot identity、position snapshot identity 和 balance snapshot identity，但必须继续保持 source semantics 为 read-model-only evidence，不得把身份字段写成 runtime connector。

## MTP-133 Evidence interpretation boundary

`MTP-133-EVIDENCE-INTERPRETATION-BOUNDARY`

MTP-133 固定以下解释边界：

- account evidence 只能说明 evidence identity、source identity、freshness / stale 状态和 blocked reason，不表达真实账户资产。
- position evidence 只能说明 symbol / side / quantity / exposure 的 read-model-only interpretation，不表达 broker position sync。
- balance evidence 只能说明 paper / simulated / fixture balance interpretation，不表达真实资金可用性、buying power、margin、leverage 或 real PnL。
- Workbench / Report / Events 后续只能展示 Read Model / ViewModel evidence，不提供 API key input、account connect、broker connect、Live PRO Console、trading button、live command 或 order form。

这些边界必须在后续 MTP-134 至 MTP-138 中继续保持；当前 MTP-133 不新增 App surface、不新增 Dashboard smoke handle、不新增 Core runtime。

## MTP-133 L3.1 / L3.2 handoff boundary

`MTP-133-L31-L32-HANDOFF-BOUNDARY`

MTP-133 的 handoff 只交付 L3.1 terminology / contract input：

1. MTP-134 才能定义 account snapshot identity 和 source / freshness evidence。
2. MTP-135 才能定义 position snapshot identity 和 exposure evidence。
3. MTP-136 才能定义 balance snapshot identity 和 paper-vs-real interpretation boundary。
4. MTP-137 才能定义 deterministic fixture contract 和 forbidden real account tests。
5. MTP-138 才能定义 Workbench / Report / Events read-model-only evidence surface。
6. MTP-139 才能做 validation matrix、automation readiness 和 stage audit input closeout。
7. L3.2 Private Stream / Account Snapshot Simulation Gate 仍是 future gate；MTP-133 不创建 listenKey、不连接 private WebSocket、不运行 account snapshot runtime。

MTP-133 完成后不得自动推进 MTP-134。MTP-134 至 MTP-139 仍必须分别等待 Parent Codex queue preflight 在 WIP=1、依赖满足、无 active conflict、execution contract 完整时判断。

## MTP-133 forbidden capability baseline

`MTP-133-FORBIDDEN-CAPABILITY-BASELINE`

MTP-133 必须保持以下 forbidden capabilities：

- signed endpoint
- account endpoint / listenKey
- private WebSocket runtime
- account snapshot runtime
- broker / exchange execution adapter
- `LiveExecutionAdapter`
- OMS
- real order lifecycle
- real submit / cancel / replace
- execution report
- broker fill
- reconciliation
- real account / broker position / margin / leverage
- real PnL runtime
- Live PRO Console
- trading button
- live command
- order form
- emergency stop / shutdown / restore executable action
- Graphify update
- Figma change

这些能力只能作为 forbidden / Future Gated boundary 出现，不能写成当前支持、beta preview、local fallback、behind flag、partially implemented 或后续 issue 自动授权。

## MTP-133 first executable candidate non-authorization

`MTP-133-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`

Project Planning Record 中的 first executable candidate 只是候选，不构成执行授权。MTP-133 只有在 Linear live-read 中经 Parent Codex queue preflight 推进为唯一 active issue 后才可执行。

该事实不改变以下规则：

- `docs/product/mtpro-live-readiness-roadmap-v1.md` 不授权 execution。
- `docs/planning/projects/mtpro-account-position-balance-read-model-only-v1-plan.md` 不授权 execution。
- Backlog issue、label、priority、assignee 或 estimate 不授权 execution。
- MTP-133 完成后不得自动推进 MTP-134。
- MTP-134 至 MTP-139 必须继续保持 Backlog / non-executable，直到各自成为 live-read 中唯一 eligible issue。

## MTP-133 validation anchors

`MTP-133-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY-VALIDATION`

Required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `docs/contracts/account-position-balance-read-model-only-contract.md` 必须包含 MTP-133 terminology、source semantics boundary、evidence interpretation boundary、L3.1 / L3.2 handoff、forbidden capability baseline、first executable candidate non-authorization 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-133 account / position / balance read-model-only shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY` 和 MTP-133 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-133 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-133 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Account / Position / Balance read-model-only terminology anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-133 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、planning record 和 forbidden capability boundary strings。

MTP-133 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard smoke handle、不新增 App read model、不新增 Core / Runtime / Dashboard behavior、不新增 stage audit input；Project stage closeout 仍归属 MTP-139。

## MTP-134 account snapshot identity

`MTP-134-ACCOUNT-SNAPSHOT-IDENTITY`

MTP-134 只定义 account snapshot identity 和 account evidence identity 的只读字段合同，不创建 account snapshot runtime。Identity 必须能被后续 Workbench / Report / Events 作为 Read Model / ViewModel 输入引用，但不得被解释为真实 account endpoint response、broker account object 或可交易账户状态。

| 字段 | 含义 | 禁止解释 |
| --- | --- | --- |
| `accountSnapshotId` | 稳定 account snapshot identity，由 source identity、observedAt、freshness status 和 deterministic fixture / paper / simulated identity 组合生成 | 不等于真实 account id、broker account id、account endpoint payload id 或 account snapshot runtime handle |
| `accountEvidenceId` | 可追溯 evidence identity，用于连接 snapshot identity、source identity、freshness evidence 和 stale / blocked reason | 不等于 execution report、broker fill、reconciliation id 或真实账户流水 |
| `accountSourceIdentity` | 允许值只能是 `fixture`、`paper`、`simulated`、`future-gated-real` | 不等于 signed endpoint、account endpoint、listenKey、private WebSocket、secret storage、credential provider 或 broker connection |
| `observedAt` | 本地 evidence observation timestamp，可来自 deterministic fixture / paper / simulated run metadata | 不等于实时账户订阅时间、broker server time 或 private stream update time |
| `sourceWatermark` | source freshness watermark，用于判断 fresh / stale / missing / blocked | 不等于 listenKey keepalive、private stream cursor 或 broker reconciliation watermark |

Canonical identity example 只能作为 deterministic string shape 使用：

`account-snapshot|fixture|mtp-134-local-account-evidence|1704067500|fresh`

该 example 不包含真实账户余额、margin、leverage、buying power、real PnL、account endpoint payload 或 broker account identifier。

## MTP-134 source identity / freshness evidence

`MTP-134-SOURCE-IDENTITY-FRESHNESS-EVIDENCE`

MTP-134 固定 account source identity 和 freshness evidence 的解释层：

1. `fixture` source 必须绑定 deterministic local fixture identity、fixture version、checksum / source watermark 和 observedAt；它不是真实 account payload。
2. `paper` source 只能引用 paper runtime / paper portfolio 本地 evidence identity；它不是真实账户余额、margin、leverage 或 broker statement。
3. `simulated` source 只能引用 scenario replay / simulated exchange / backtest parity evidence identity；它不是真实 broker position、execution report、broker fill 或 reconciliation。
4. `future-gated-real` source 只能作为未来门禁标签，不包含 endpoint URL、API key、secret、listenKey、private stream cursor、broker account id 或 account payload。

Freshness evidence 必须至少表达 `observedAt`、`sourceWatermark`、`freshnessStatus`、`freshnessReason` 和 `sourceBoundary`。`freshnessStatus` 只允许 `fresh`、`stale`、`missing`、`blocked`；`blocked` 必须说明 blocked reason 来自 forbidden capability boundary，而不是尝试连接真实账户。

## MTP-134 stale / missing / blocked account evidence

`MTP-134-STALE-MISSING-BLOCKED-ACCOUNT-EVIDENCE`

MTP-134 的 stale / missing / blocked 语义只描述 evidence 可用性：

- `stale` 表示本地 evidence 超出当前 read-model-only freshness expectation，但仍不触发网络刷新。
- `missing` 表示当前没有可展示的 deterministic account evidence，但仍不触发 account endpoint、listenKey 或 broker fallback。
- `blocked` 表示 evidence 因 forbidden capability boundary 被拒绝，例如 real account endpoint、private WebSocket、broker adapter、secret storage 或 signed request。

任何 stale / missing / blocked state 都不得自动升级为 recovery action、refresh command、private stream reconnect、broker sync、Live PRO Console action、trading button 或 live command。

## MTP-134 adapter capability bypass guard

`MTP-134-ADAPTER-CAPABILITY-MATRIX-BYPASS-GUARD`

Account source identity 不能绕过 adapter capability matrix。MTP-134 不允许通过以下方式把 source label 写成 runtime connector：

- 把 `future-gated-real` source 写成 account endpoint path、signed request descriptor、listenKey lease 或 private WebSocket channel。
- 把 fixture / paper / simulated source 写成 broker account payload、Runtime object、Adapter request 或 exchange private payload。
- 让 App / UI 直接消费 adapter request、exchange payload、broker payload、secret config 或 Runtime object。

后续 MTP-138 只能消费 Read Model / ViewModel evidence；MTP-134 不新增 App surface。

## MTP-134 account snapshot is not runtime

`MTP-134-ACCOUNT-SNAPSHOT-NOT-RUNTIME`

MTP-134 的 account snapshot identity 是 evidence identity，不是 runtime snapshot。它不授权：

- account snapshot runtime
- account endpoint / listenKey
- signed endpoint 或 signed request
- private WebSocket runtime
- secret storage / credential provider
- broker / exchange execution adapter
- real account balance、margin、leverage、buying power 或 real PnL
- OMS、real order lifecycle、real submit / cancel / replace
- Live PRO Console、trading button、live command 或 order form

## MTP-134 validation anchors

`MTP-134-ACCOUNT-SNAPSHOT-IDENTITY-VALIDATION`

Required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- Contract 必须包含 account snapshot identity、source identity / freshness evidence、stale / missing / blocked account evidence、adapter capability bypass guard、account snapshot not runtime 和 validation anchors。
- Domain context 必须包含 MTP-134 account snapshot identity shared language。
- Trading validation matrix 必须回填 MTP-134 issue evidence。
- Latest verification summary 必须记录 MTP-134 当前 issue evidence。
- Automation readiness 必须新增 MTP-134 account snapshot identity anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-134 anchors。

MTP-134 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard smoke handle、不新增 account fixture payload、不新增 App read model、不新增 Core / Runtime / Dashboard behavior；deterministic fixture contract 仍归属 MTP-137，Workbench / Report / Events surface 仍归属 MTP-138。

## MTP-135 position snapshot identity

`MTP-135-POSITION-SNAPSHOT-IDENTITY`

MTP-135 只定义 position snapshot identity 和 position evidence identity 的只读字段合同，不创建 broker position sync 或 real position runtime。Identity 必须能被后续 Workbench / Report / Events 作为 Read Model / ViewModel 输入引用，但不得被解释为 broker position、margin position、leverage position、real portfolio sync 或 live risk input。

| 字段 | 含义 | 禁止解释 |
| --- | --- | --- |
| `positionSnapshotId` | 稳定 position snapshot identity，由 source identity、symbol、side、scenario version、observedAt 和 freshness / simulation status 组合生成 | 不等于 broker position id、exchange position id、margin account position 或 live portfolio handle |
| `positionEvidenceId` | 可追溯 evidence identity，用于连接 position snapshot、source identity、exposure evidence 和 stale / blocked reason | 不等于 execution report、broker fill、reconciliation id、order id 或真实持仓流水 |
| `positionSourceIdentity` | 允许值只能是 `fixture`、`paper`、`simulated`、`future-gated-real` | 不等于 account endpoint、listenKey、private stream、broker adapter、OMS 或 real order lifecycle |
| `symbol` / `side` / `quantity` | read-model-only position facts，可来自 deterministic fixture、paper portfolio projection 或 simulated exchange evidence | 不等于 broker position、margin position、leverage position 或可交易持仓 |
| `scenarioVersion` | 本地 fixture / scenario / simulated evidence version | 不等于 broker statement version、exchange account update id 或 reconciliation cursor |

Canonical identity example 只能作为 deterministic string shape 使用：

`position-snapshot|simulated|mtp-135-local-position-evidence|BTCUSDT|long|1704067500|simulated`

该 example 不包含 broker position id、real account id、margin、leverage、real PnL、execution report、broker fill 或 reconciliation data。

## MTP-135 position exposure evidence

`MTP-135-POSITION-EXPOSURE-EVIDENCE`

MTP-135 exposure evidence 只表示 fixture / paper / simulated position 的 read-model-only interpretation：

- `symbol` 和 `side` 只能表达 evidence side，不授权 real position side。
- `quantity` 只能表达 local fixture / paper / simulated quantity，不授权 broker quantity。
- `exposureNotional` / `exposureQuoteValue` 只能表达 read-model-only exposure，不等于 margin exposure、leverage exposure、broker risk input 或 real PnL source。
- `scenarioVersion` 必须把 exposure 绑定到 deterministic local evidence，不得使用 broker statement、private stream sequence 或 reconciliation cursor。

Exposure evidence 不能驱动 live risk engine、order sizing、trading command、OMS decision、emergency stop 或 broker sync。

## MTP-135 paper / simulated / future real position isolation

`MTP-135-PAPER-SIMULATED-FUTURE-REAL-POSITION-ISOLATION`

Paper exposure、simulated exposure 和 future-gated real position 必须隔离：

1. `paper` exposure 可以引用 paper portfolio projection 或 paper account evidence，但不得升级为 real position。
2. `simulated` exposure 可以引用 simulated fill / simulated exchange / scenario replay evidence，但不得升级为 broker fill、execution report 或 broker position。
3. `future-gated-real` position 只能作为未来门禁标签，不包含 broker account id、position id、margin mode、leverage、private stream cursor 或 account endpoint payload。

任何 source label 都不得把 paper portfolio projection 或 simulated fill 直接解释为 real position、broker position sync、margin exposure 或 real PnL。

## MTP-135 stale / blocked / simulated position evidence

`MTP-135-STALE-BLOCKED-SIMULATED-POSITION-EVIDENCE`

MTP-135 的 position evidence status 只描述 evidence 可用性：

- `simulated` 表示来自 simulated exchange / scenario replay / deterministic fixture 的本地 evidence。
- `stale` 表示本地 evidence 超出 current freshness expectation，但不触发 broker refresh。
- `blocked` 表示 evidence 因 forbidden broker position interpretation 被拒绝，例如 broker adapter、account endpoint、listenKey、private stream、real account position、margin、leverage 或 real PnL。

这些状态不得自动升级为 broker position sync、private stream reconnect、margin refresh、live risk engine input、trading button、live command 或 order form。

## MTP-135 forbidden broker position interpretation

`MTP-135-FORBIDDEN-BROKER-POSITION-INTERPRETATION`

MTP-135 必须固定 forbidden broker position interpretation：

- position evidence 不是 broker position。
- paper portfolio projection 不是 real position。
- simulated fill / simulated exchange exposure 不是 broker fill、execution report 或 reconciliation。
- fixture position evidence 不是真实 account snapshot、broker portfolio、margin position 或 leverage position。
- App / UI 只能消费 Read Model / ViewModel evidence，不得展示 broker connect、account connect、Live PRO Console、trading button、live command 或 order form。

## MTP-135 validation anchors

`MTP-135-POSITION-SNAPSHOT-IDENTITY-VALIDATION`

Required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- Contract 必须包含 position snapshot identity、position exposure evidence、paper / simulated / future real isolation、stale / blocked / simulated status、forbidden broker position interpretation 和 validation anchors。
- Domain context 必须包含 MTP-135 position snapshot identity shared language。
- Trading validation matrix 必须回填 MTP-135 issue evidence。
- Latest verification summary 必须记录 MTP-135 当前 issue evidence。
- Automation readiness 必须新增 MTP-135 position snapshot identity / exposure evidence anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-135 anchors。

MTP-135 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard smoke handle、不新增 position fixture payload、不新增 App read model、不新增 Core / Runtime / Dashboard behavior；deterministic fixture contract 仍归属 MTP-137，Workbench / Report / Events surface 仍归属 MTP-138。
