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

## MTP-136 balance snapshot identity

`MTP-136-BALANCE-SNAPSHOT-IDENTITY`

MTP-136 只定义 balance snapshot identity 和 balance evidence identity 的只读字段合同，不创建 live account balance runtime、real PnL runtime 或 broker cash sync。Identity 必须能被后续 Workbench / Report / Events 作为 Read Model / ViewModel 输入引用，但不得被解释为真实账户资金、broker cash statement、buying power、margin availability 或可交易余额。

| 字段 | 含义 | 禁止解释 |
| --- | --- | --- |
| `balanceSnapshotId` | 稳定 balance snapshot identity，由 source identity、balance kind、scenario / fixture version、observedAt 和 freshness status 组合生成 | 不等于 real account balance id、broker cash statement id、buying power id 或 account endpoint payload id |
| `balanceEvidenceId` | 可追溯 evidence identity，用于连接 balance snapshot、source identity、paper-vs-real interpretation 和 stale / blocked reason | 不等于 ledger statement、execution report、broker fill、reconciliation id 或真实资金流水 |
| `balanceSourceIdentity` | 允许值只能是 `fixture`、`paper`、`simulated`、`future-gated-real` | 不等于 signed endpoint、account endpoint、listenKey、private stream、broker adapter 或 account snapshot runtime |
| `balanceKind` | 只允许 `paper-cash`、`paper-equity`、`simulated-balance`、`fixture-balance`、`future-gated-real-balance` | 不等于 real cash、broker equity、margin balance、leverage balance、buying power 或 real PnL |
| `observedAt` / `sourceWatermark` | 本地 evidence timestamp 和 freshness watermark | 不等于 broker server balance timestamp、private stream update time 或 reconciliation watermark |

Canonical identity example 只能作为 deterministic string shape 使用：

`balance-snapshot|paper-cash|mtp-136-local-balance-evidence|1704067500|fresh`

该 example 不包含真实账户余额、broker cash statement、margin、leverage、buying power、real PnL、account endpoint payload 或 private stream update。

## MTP-136 paper / simulated / future real balance terminology

`MTP-136-PAPER-SIMULATED-FUTURE-REAL-BALANCE-TERMINOLOGY`

MTP-136 固定以下 balance terminology：

- `paper cash`：paper runtime / paper portfolio 的本地 sandbox cash interpretation，不是真实账户 cash。
- `paper equity`：paper-only equity interpretation，不是 broker equity、margin equity 或 buying power。
- `simulated balance`：simulated exchange / scenario replay / backtest parity 的本地 balance interpretation，不是 broker cash statement。
- `fixture balance`：deterministic local fixture 的 balance evidence shape，不是真实 account payload。
- `future-gated real balance`：未来门禁标签，不包含 account endpoint、listenKey、private stream、broker cash statement 或真实资金字段。

命名必须保留 `paper`、`simulated`、`fixture` 或 `future-gated` source label，不得使用会暗示真实资金可用性的字段名或 UI 文案。

## MTP-136 paper-vs-real interpretation boundary

`MTP-136-PAPER-VS-REAL-INTERPRETATION-BOUNDARY`

MTP-136 的 paper-vs-real boundary 固定如下：

1. Paper account model 输出只能解释为 paper balance evidence，不是 live account balance。
2. Simulated exchange balance 只能解释为 simulated balance evidence，不是 broker cash、broker margin 或 real PnL。
3. Fixture balance 只能解释为 deterministic local evidence，不是真实账户资金。
4. Future-gated real balance 只能作为未来门禁标签，不表示当前已读取真实账户资金。

Balance evidence 不得驱动 order sizing、buying power check、live risk engine、OMS decision、trading button、live command、emergency stop 或 broker sync。

## MTP-136 real PnL / margin / leverage / buying power forbidden baseline

`MTP-136-REAL-PNL-MARGIN-LEVERAGE-BUYING-POWER-FORBIDDEN`

MTP-136 必须固定以下 forbidden baseline：

- no real PnL runtime
- no margin read
- no leverage read
- no buying power read
- no real account balance read
- no broker cash statement
- no signed endpoint / account endpoint / listenKey
- no private WebSocket runtime
- no account snapshot runtime
- no broker / exchange execution adapter
- no `LiveExecutionAdapter`
- no OMS / real order lifecycle
- no Live PRO Console / trading button / live command / order form

这些能力只能作为 forbidden / Future Gated boundary 出现，不能写成 current preview、fallback、behind flag、local beta 或 partial implementation。

## MTP-136 balance stale / blocked evidence

`MTP-136-BALANCE-STALE-BLOCKED-EVIDENCE`

MTP-136 balance evidence status 只描述 evidence 可用性：

- `stale` 表示本地 paper / simulated / fixture balance evidence 超出 freshness expectation，但不触发 account endpoint refresh。
- `blocked` 表示 evidence 因 forbidden real balance interpretation 被拒绝，例如 real account balance、margin、leverage、buying power、real PnL、signed endpoint、account endpoint、listenKey、private stream 或 broker cash statement。

Stale / blocked state 不得自动升级为 balance refresh command、private stream reconnect、broker sync、buying power check、Live PRO Console action、trading button、live command 或 order form。

## MTP-136 validation anchors

`MTP-136-BALANCE-SNAPSHOT-IDENTITY-VALIDATION`

Required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- Contract 必须包含 balance snapshot identity、paper / simulated / future real balance terminology、paper-vs-real interpretation boundary、real PnL / margin / leverage / buying power forbidden baseline、balance stale / blocked evidence 和 validation anchors。
- Domain context 必须包含 MTP-136 balance snapshot identity shared language。
- Trading validation matrix 必须回填 MTP-136 issue evidence。
- Latest verification summary 必须记录 MTP-136 当前 issue evidence。
- Automation readiness 必须新增 MTP-136 balance snapshot identity / paper-vs-real boundary anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-136 anchors。

MTP-136 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard smoke handle、不新增 balance fixture payload、不新增 App read model、不新增 Core / Runtime / Dashboard behavior；deterministic fixture contract 仍归属 MTP-137，Workbench / Report / Events surface 仍归属 MTP-138。

## MTP-137 deterministic fixture shape

`MTP-137-DETERMINISTIC-FIXTURE-SHAPE`

MTP-137 定义 account / position / balance 的 deterministic local fixture shape。该 fixture 只用于 L3.1 read-model-only evidence，不是真实账户导入器，不导入 broker payload，不读取 account endpoint，不创建 listenKey，不运行 private WebSocket 或 account snapshot runtime。

Fixture 必须包含以下三类 component：

| Component | Snapshot identity | Evidence identity | Read Model mapping |
| --- | --- | --- | --- |
| `account snapshot` | `account-snapshot|fixture|mtp-137-local-account-evidence|1704067500|fresh` | `account-evidence|fixture|mtp-137|1704067500|fresh` | `accountSnapshotId`、`accountEvidenceId`、`sourceIdentity`、`observedAt`、`sourceWatermark`、`freshnessStatus` |
| `position snapshot` | `position-snapshot|fixture|mtp-137-local-position-evidence|BTCUSDT|1704067500|fresh` | `position-evidence|fixture|mtp-137|BTCUSDT|long|1704067500|fresh` | `positionSnapshotId`、`positionEvidenceId`、`symbol`、`side`、`quantity`、`exposureNotional`、`sourceIdentity`、`freshnessStatus` |
| `balance snapshot` | `balance-snapshot|fixture|mtp-137-local-balance-evidence|USD|1704067500|fresh` | `balance-evidence|fixture|mtp-137|paper-simulated|1704067500|fresh` | `balanceSnapshotId`、`balanceEvidenceId`、`currency`、`paperCash`、`paperEquity`、`simulatedBalance`、`sourceIdentity`、`freshnessStatus` |

这些字段只表达 read-model-only mapping，不包含真实 payload、schema、Runtime object、adapter request、broker state、account endpoint payload、listenKey 或 secret。

## MTP-137 fixture version / checksum / freshness / source identity

`MTP-137-FIXTURE-CHECKSUM-FRESHNESS-SOURCE`

MTP-137 的 fixture identity 固定为：

- `fixtureVersion`: `fixture-v1`
- `sourceIdentity`: `fixture:mtp-137-account-position-balance-read-model-only`
- `observedAt`: `1704067500`
- `sourceWatermark`: `fixture-watermark:mtp-137:2024-01-01T00:05:00Z`
- `freshnessStatus`: `fresh`
- `checksum`: 由 `AccountPositionBalanceReadModelOnlyFixtureContract.requiredChecksum` 对 canonical preimage 计算，算法复用 `ScenarioReplayChecksumEvidence.checksum(forCanonicalPreimage:)`

Checksum / freshness 只能证明本地 deterministic fixture parity，不代表真实账户 freshness、broker server timestamp、private stream cursor、listenKey keepalive 或 reconciliation watermark。

## MTP-137 forbidden real account tests

`MTP-137-FORBIDDEN-REAL-ACCOUNT-TESTS`

MTP-137 必须建立 deterministic forbidden tests，覆盖以下能力：

- signed endpoint
- account endpoint
- listenKey
- private WebSocket
- secret read
- broker adapter
- real account read
- real account payload
- broker payload import
- broker position sync
- real PnL runtime
- margin read
- leverage read
- account snapshot runtime
- payload / schema / runtime object exposure

Tests 必须证明 init 和 Codable decode 都拒绝这些 capability flags；测试不得依赖真实网络、真实 Binance private API、真实 credential、account endpoint、listenKey 或 broker account。

## MTP-137 fixture-to-read-model mapping isolation

`MTP-137-FIXTURE-TO-READ-MODEL-MAPPING-ISOLATION`

Fixture-to-read-model mapping 只能输出稳定 read model 字段。以下 token 不得进入 mapping 字段、summary 或 record identity：

- `payload`
- `schema`
- `runtime`
- `endpoint`
- `listenKey`
- `secret`
- `broker`
- `margin`
- `leverage`
- `realPnL`

任何尝试把 account endpoint payload、broker payload、schema、Runtime object 或 private stream object 放入 fixture mapping 的行为都必须被 deterministic tests 拒绝。MTP-137 不新增 App surface；Workbench / Report / Events 展示仍归属 MTP-138。

## MTP-137 real account payload isolation

`MTP-137-REAL-ACCOUNT-PAYLOAD-ISOLATION`

MTP-137 的 real account payload isolation 规则：

1. Fixture 只保存 snapshot identity、evidence identity、source identity、freshness identity 和 read model field names。
2. Fixture 不保存原始 account endpoint response、broker payload、private stream event、schema object、adapter request、Runtime object 或 account snapshot runtime handle。
3. Fixture 不提供 importer、parser、refresh、connect、sync、reconcile、submit、cancel、replace 或 live command。
4. Fixture 的 `future-gated` 语义只表示后续门禁，不表示当前已经连接真实账户。

## MTP-137 validation anchors

`MTP-137-FIXTURE-FORBIDDEN-REAL-ACCOUNT-VALIDATION`

Required validation：

- `swift test --filter AccountPositionBalanceReadModelOnlyFixture`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `AccountPositionBalanceReadModelOnlyFixtureContract`、`AccountPositionBalanceReadModelOnlyFixtureRecord` 和 `AccountPositionBalanceReadModelOnlyForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-137 deterministic fixture、forbidden real account bypass 和 payload / schema / runtime mapping isolation tests。
- Contract 必须包含 deterministic fixture shape、fixture version / checksum / freshness / source identity、forbidden real account tests、fixture-to-read-model mapping isolation、real account payload isolation 和 validation anchors。
- Domain context 必须包含 MTP-137 fixture / forbidden real account tests shared language。
- Trading validation matrix 必须回填 MTP-137 issue evidence。
- Latest verification summary 必须记录 MTP-137 当前 issue evidence。
- Automation readiness 必须新增 Account / Position / Balance fixture / forbidden real account tests anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-137 source、test、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness anchors。

MTP-137 不新增 App surface、不新增 Dashboard smoke handle、不新增 account snapshot runtime、不导入真实账户 payload、不实现 signed endpoint、account endpoint、listenKey、private WebSocket、broker adapter、`LiveExecutionAdapter`、OMS、real PnL、margin、leverage、Live PRO Console、trading button、live command 或 order form；Workbench / Report / Events surface 仍归属 MTP-138。

## MTP-138 Workbench / Report / Events read-model-only surface

`MTP-138-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE`

MTP-138 只把 MTP-137 deterministic fixture contract 接入 App 层 `AccountPositionBalanceReadModelOnlySurfaceReadModel` / `AccountPositionBalanceReadModelOnlySurfaceViewModel`，并通过 Workbench、Report 和 Event Timeline 展示 read-model-only evidence。该 surface 只展示：

- `fixtureVersion`
- `checksum`
- `sourceIdentity`
- `sourceWatermark`
- `snapshotID`
- `evidenceID`
- `freshnessStatus`
- `readModelFields`
- blocked / stale / simulated state labels

MTP-138 不新增真实账户读取、不新增 Runtime / Adapter / DB schema、不解析 account endpoint payload、不同步 broker position、不读取 margin / leverage / real PnL，也不提供 account connect、broker connect、Live PRO Console、trading button、live command 或 order form。

## MTP-138 dashboard report events evidence

`MTP-138-DASHBOARD-REPORT-EVENTS-EVIDENCE`

MTP-138 的展示面必须同时覆盖三条只读路径：

1. Workbench：`DashboardShellWorkbenchSnapshot.accountPositionBalanceReadModelOnlySurfaceMetrics` 和 details 展示 APB records、fixture、freshness、Event trace、boundary、blocked states、stale states 和 simulated states。
2. Report：Report section 必须展示 `APB surface` 指标和 APB summary / components / evidence / freshness / forbidden flags / boundary details。
3. Events：`PaperWorkflowEvidenceExplorerSection.accountPositionBalanceReadModelOnlySurface` 必须生成三条 timeline item，分别对应 account snapshot、position snapshot 和 balance snapshot evidence，并只链接 evidence id 与 validation anchor。

Dashboard smoke 只能输出 `accountPositionBalanceEvidence=<record count>` 这类可定位 handle；不得输出 API key、secret、account endpoint response、broker payload、Runtime object、adapter request、order form 或 trading command。

## MTP-138 forbidden UI and runtime surface

`MTP-138-FORBIDDEN-UI-RUNTIME-SURFACE`

MTP-138 必须证明以下能力均为 `none` / `false`：

- API key input
- secret storage
- broker connect
- account connect
- Live PRO Console
- trading button
- live command
- order form
- signed endpoint
- account endpoint
- listenKey
- database schema
- Runtime object
- adapter request
- account payload
- broker state
- broker adapter
- `LiveExecutionAdapter`
- OMS
- real order lifecycle
- real account read
- broker position sync
- real PnL runtime
- margin / leverage read
- order-level command
- live trading authorization

MTP-138 的 forbidden UI / runtime surface 只用于 acceptance evidence，不代表 future live scope 被允许。

## MTP-138 validation anchors

`MTP-138-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-VALIDATION`

Required validation：

- `swift test --filter AccountPositionBalanceReadModelOnlySurface`
- `swift test --filter PaperWorkflowEvidenceExplorerTimelineSnapshotAggregatesReadModelOnlyEvidence`
- `swift test --filter DashboardShellWorkbenchSnapshotBindsControlsObservabilityAndExplorerReadOnly`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `Sources/Workbench/Report/AccountPositionBalanceReadModelOnlySurface.swift` 必须包含 `AccountPositionBalanceReadModelOnlySurfaceReadModel`、`AccountPositionBalanceReadModelOnlySurfaceViewModel` 和 `AccountPositionBalanceReadModelOnlySurfaceTraceItem`。
- `Sources/Workbench/ReadModels/App.swift` 必须把 APB surface 接入 `ReportReadModel` / `ReportViewModel` / `DashboardViewModel` 的 read-model-only source chain。
- `Sources/Workbench/Events/PaperWorkflowEvidenceExplorer.swift` 必须包含 `accountPositionBalanceReadModelOnlySurface` section、coverage flag 和三条 read-model-only timeline items。
- `Sources/Dashboard/DashboardShell.swift` 必须包含 Workbench metrics / details、Report APB surface details 和 smoke summary handle。
- `Tests/AppTests/AppTests.swift` 必须包含 MTP-138 ViewModel、DashboardShell、Report 和 Event Timeline focused assertions。
- Contract、Domain context、Trading validation matrix、Validation plan、Latest verification summary、Automation readiness doc 和 `checks/automation-readiness.sh` 必须包含 MTP-138 anchors。

MTP-138 不推进 MTP-139、不创建下一 Project / Issue、不运行 Graphify、不修改 Figma、不提交 `.codex/*` 或 `graphify-out/*`，也不实现 signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、Live PRO Console、trading button、live command 或 order form。

## MTP-139 stage closeout input

`MTP-139-ACCOUNT-POSITION-BALANCE-STAGE-CLOSEOUT`

MTP-139 只收口 `MTPRO Account / Position / Balance Read-model-only v1` 的 validation matrix、automation readiness anchors、forbidden capability evidence chain、read-model-only boundary evidence 和 Parent Codex Stage Code Audit input material。它汇总 MTP-133 至 MTP-138 的已落地 evidence，不输出最终 Stage Code Audit Report，不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进下一阶段，也不启动下一阶段 `symphony-issue`。

## MTP-139 stage audit input material

`MTP-139-STAGE-AUDIT-INPUT-MATERIAL`

MTP-139 的 stage audit input material 必须落仓到：

```text
docs/audit/inputs/mtpro-account-position-balance-read-model-only-v1-stage-audit-input.md
```

该输入材料必须覆盖：

1. MTP-133 至 MTP-138 的 issue / PR / merge / required check evidence。
2. `TVM-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY` 的 validation evidence chain。
3. account / position / balance terminology、snapshot identity、freshness、exposure、balance interpretation、fixture、forbidden real account tests 和 Workbench / Report / Events read-model-only surface。
4. signed endpoint、account endpoint / listenKey、private WebSocket、account snapshot runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real account / broker position / margin / leverage、real PnL、Live PRO Console、trading button、live command 和 order form 的 forbidden evidence chain。
5. Parent Codex final Stage Code Audit handoff checklist。

## MTP-139 no final Stage Code Audit

`MTP-139-NO-FINAL-STAGE-CODE-AUDIT`

MTP-139 不能输出最终 Stage Code Audit Report，不能创建 `docs/audit/mtpro-account-position-balance-read-model-only-v1-stage-code-audit.md`，不能把 Linear Project 标记为 `Completed`，不能写 Root Docs Refresh Gate，不能创建下一 Project / Issue，也不能把 L3.2 / L3.3 / L3.4 / L4 写成当前 execution scope。

最终 Stage Code Audit Report 必须在 `MTP-133`、`MTP-134`、`MTP-135`、`MTP-136`、`MTP-137`、`MTP-138` 和 `MTP-139` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed`、`type=completed`、`completedAt` 非空后，由 Parent Codex 单独输出。

## MTP-139 validation evidence chain

`MTP-139-VALIDATION-EVIDENCE-CHAIN`

MTP-139 必须把以下 evidence chain 固定为 Project closure 输入：

- MTP-133：L3.1 terminology、source semantics、evidence interpretation、L3.1 / L3.2 handoff、forbidden capability baseline 和 first executable candidate non-authorization。
- MTP-134：account snapshot identity、source identity、freshness evidence、stale / missing / blocked account evidence、adapter capability bypass guard 和 account snapshot not runtime。
- MTP-135：position snapshot identity、exposure evidence、paper / simulated / future real position isolation、stale / blocked / simulated position evidence 和 forbidden broker position interpretation。
- MTP-136：balance snapshot identity、paper / simulated / future real balance terminology、paper-vs-real interpretation boundary、real PnL / margin / leverage / buying power forbidden baseline 和 balance stale / blocked evidence。
- MTP-137：deterministic fixture shape、fixture checksum / freshness / source identity、forbidden real account tests、fixture-to-read-model mapping isolation 和 real account payload isolation。
- MTP-138：Workbench / Report / Events APB read-model-only surface、Dashboard smoke `accountPositionBalanceEvidence=3` handle、Event Timeline APB section 和 forbidden UI / runtime flags。

该 chain 只能作为 Stage Code Audit input，不授权真实账户读取、private stream、account snapshot runtime、broker runtime、Live PRO Console 或 trading command。

## MTP-139 forbidden capability evidence chain

`MTP-139-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`

MTP-139 必须继续证明以下能力在本 Project 中全部保持 forbidden / future gated：

- signed endpoint
- account endpoint / listenKey
- private WebSocket runtime
- account snapshot runtime
- account / position / balance runtime
- real account read
- broker position sync
- real account balance
- margin
- leverage
- real PnL runtime
- broker / exchange execution adapter
- `LiveExecutionAdapter`
- OMS
- real order lifecycle
- real submit / cancel / replace
- execution report
- broker fill
- reconciliation
- API key input / secret storage
- broker connect / account connect
- Live PRO Console
- trading button
- live command
- order form
- emergency stop / shutdown / restore executable action
- Graphify update
- Figma change

## MTP-139 automation readiness stage closeout

`MTP-139-AUTOMATION-READINESS-STAGE-CLOSEOUT`

MTP-139 必须让 `checks/automation-readiness.sh` 机械检查 MTP-139 stage audit input、contract anchors、domain context anchors、validation plan anchors、trading validation matrix backfill、latest verification summary、automation readiness doc anchor、MTP-133 至 MTP-138 source / test / surface anchors、PR #245 至 PR #250 evidence 和 Dashboard smoke `accountPositionBalanceEvidence=3` handle。

MTP-139 不修改 active Project pointer。Project closure、Linear Project `Completed` status、最终 Stage Code Audit Report、Root Docs Refresh Gate 和 final closure summary 仍归 Parent Codex closure flow。

## MTP-139 validation anchors

`MTP-139-ACCOUNT-POSITION-BALANCE-STAGE-CLOSEOUT-VALIDATION`

Required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- Contract 必须包含 MTP-139 stage closeout、stage audit input material、no final Stage Code Audit、validation evidence chain、forbidden capability evidence chain、automation readiness stage closeout 和 validation anchors。
- Domain context 必须包含 MTP-139 stage closeout shared language。
- Trading validation matrix 必须把 MTP-139 回填到 `TVM-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY`。
- Validation plan 必须包含 MTP-139 required validation 和禁止项。
- Latest verification summary 必须记录 MTP-139 当前 issue execution evidence。
- Automation readiness 必须新增 Account / Position / Balance stage audit input anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-139 anchors。

MTP-139 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard behavior、不输出最终 Stage Code Audit Report、不运行 Graphify、不修改 Figma、不提交 `.codex/*` 或 `graphify-out/*`，也不实现 signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、Live PRO Console、trading button、live command 或 order form。
