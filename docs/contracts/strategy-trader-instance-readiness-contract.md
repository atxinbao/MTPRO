# Strategy / Trader Instance Readiness Contract

日期：2026-05-31

执行者：Codex

本文档定义 `MTPRO Strategy / Trader Instance Readiness v1` 的 MTP-154 合同入口：L3.4 Strategy / Trader Instance readiness terminology、readiness-only boundary、proposal / readiness evidence baseline、L3.4 handoff boundary、first executable candidate non-authorization、forbidden capability baseline 和 validation anchors。

本文档只服务 `MTP-154 Define Strategy / Trader Instance readiness terminology and boundary` 的术语 / 边界 / 验证锚点。它不实现 Strategy runtime，不实现 Trader runtime，不允许 strategy 直连 Execution Client，不输出 broker command，不实现 OMS、Live PRO Console、trading button、live command 或 order form；不接 signed endpoint、account endpoint / listenKey，不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation；不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL；不运行 Graphify，不修改 Figma。

## MTP-154 Strategy / Trader Instance readiness terminology

`MTP-154-STRATEGY-TRADER-INSTANCE-READINESS-TERMINOLOGY`

MTP-154 只允许定义以下 L3.4 术语，不允许把术语升级为 runtime、execution 或 UI command：

| 术语 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `Strategy Instance` | L3.4 中可被识别、审查和追溯的策略结构实例，只代表配置、角色、输入引用、proposal boundary 和 readiness evidence identity | 不等于 Strategy runtime、scheduler、order generation engine、Execution Client caller 或 broker command producer |
| `Trader Instance` | L3.4 中可被识别、审查和追溯的交易者结构实例，只代表一个 future trader context 的只读 readiness shell | 不等于 Trader runtime、process manager、account session、broker session、OMS 或 live command actor |
| `strategy / trader readiness` | Strategy Instance / Trader Instance 是否具备后续合同深化所需的 terminology、identity、role、input、proposal isolation 和 forbidden capability evidence | 不等于运行中、可交易、可连接 broker、可提交订单或可进入 Live Production |
| `proposal` | Strategy / Trader 后续可能输出的 paper/live-neutral intent evidence，用来连接 read-model input、role responsibility 和 blocked / simulated / future-gated decision trace | 不等于 executable order command、broker command、Execution Client request、OMS order 或 UI order form payload |
| `readiness evidence` | 用于证明 Strategy / Trader Instance 仍停留在只读 readiness contract 内的 evidence anchor、source anchor、blocked reason 和 validation anchor | 不等于 runtime telemetry、broker acknowledgement、execution report、broker fill、reconciliation fact 或 production audit event |
| `paper/live-neutral proposal` | 不绑定真实账户、真实 broker、signed endpoint、account endpoint / listenKey 或 live venue 的 proposal 解释层 | 不等于 paper order execution path 的自动授权，也不等于 live order command 的预览或 beta |
| `non-execution baseline` | MTP-154 固定的基础约束：所有 Strategy / Trader 术语只能表达 readiness，不得创建执行路径 | 不等于 feature flag、local fallback、mock broker、behind flag execution 或 partial live support |

## MTP-154 readiness-only boundary

`MTP-154-READINESS-ONLY-BOUNDARY`

MTP-154 固定 Strategy / Trader Instance 只能进入 readiness contract：

1. Strategy Instance / Trader Instance 只能作为 future Strategy Engine / Trader context 的结构性 readiness vocabulary，不是运行时对象。
2. Readiness 只描述 identity、role、read-model input、proposal isolation、blocked evidence 和 validation anchors 的合同入口；不描述 strategy scheduler、trader process manager、live session 或 broker connection。
3. Proposal 只能作为后续 MTP-158 深化的 paper/live-neutral evidence；MTP-154 不定义可执行 order command shape，不定义 submit / cancel / replace，不定义 broker request。
4. Readiness evidence 只能进入 contract、domain context、validation matrix、validation plan、latest summary 和 automation readiness；MTP-154 不新增 Swift production code、focused XCTest、App read model、Dashboard surface 或 Dashboard smoke handle。

## MTP-154 proposal / readiness evidence baseline

`MTP-154-PROPOSAL-READINESS-EVIDENCE-BASELINE`

MTP-154 将 proposal / readiness evidence 的 baseline 固定为术语层：

- `strategy proposal` 和 `trader proposal` 在 MTP-154 中只是候选术语，后续 MTP-158 才能定义 paper/live-neutral proposal contract。
- `readiness evidence` 必须可追溯到 contract anchor、domain shared language、validation matrix row、validation plan entry、latest summary evidence 和 automation readiness mechanical check。
- `paper/live-neutral proposal` 必须保持 account / broker neutral，不包含 account id、broker account id、API key、secret、listenKey、private stream cursor、adapter request、Runtime object、OMS order id、order form payload 或 executable order command field。
- 后续 lifecycle、role、input、proposal、forbidden tests 和 Workbench surface 只能在 MTP-155 至 MTP-160 的各自 Linear issue scope 内深化。

## MTP-154 L3.4 handoff boundary

`MTP-154-L34-HANDOFF-BOUNDARY`

MTP-154 的 handoff 只交付 terminology / boundary input：

1. MTP-155 才能定义 strategy / trader lifecycle 和 instance identity contract。
2. MTP-156 才能定义 quoter / hedger role taxonomy 和 responsibility boundary。
3. MTP-157 才能定义 account / portfolio / risk read-model input contract。
4. MTP-158 才能定义 paper/live-neutral proposal contract 和 execution command isolation。
5. MTP-159 才能定义 forbidden Strategy -> Execution / broker / UI command tests。
6. MTP-160 才能 add Workbench / Report / Events strategy readiness read-model-only evidence surface。
7. MTP-161 才能 close validation matrix / automation readiness / stage audit input。
8. L4 Live Production / Trading Commands 保持 Future Gated；MTP-154 不授权 Strategy Instance -> Execution Client、broker command、OMS、Live PRO Console、trading button、live command 或 order form。

MTP-154 完成后不得自动推进 MTP-155。MTP-155 至 MTP-161 必须继续保持 Backlog / non-executable，直到各自成为 Linear live-read 中唯一 eligible issue。

## MTP-154 first executable candidate non-authorization

`MTP-154-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`

Project Planning Record、Linear Project issue order、next eligible candidate、Backlog issue、label、priority、assignee 或 estimate 都不构成执行授权。MTP-154 只有在 Linear live-read 中经 Parent Codex queue preflight 和 symphony-issue 调度后，作为唯一 active configured executable issue 时才可以执行。

该事实不改变以下规则：

- `docs/product/mtpro-live-readiness-roadmap-v1.md` 不授权 execution。
- `docs/planning/projects/*` 不授权 execution。
- MTP-154 完成后不得自动推进 MTP-155。
- MTP-155 至 MTP-161 必须继续保持 Backlog / non-executable，直到各自成为 live-read 中唯一 eligible issue。

## MTP-154 forbidden capability baseline

`MTP-154-FORBIDDEN-CAPABILITY-BASELINE`

MTP-154 必须保持以下 forbidden capabilities：

- Strategy runtime
- Trader runtime
- strategy scheduler
- trader process manager
- direct Strategy Instance -> Execution Client path
- broker command
- executable order command
- OMS
- real order lifecycle
- real submit / cancel / replace
- execution report
- broker fill
- reconciliation
- signed endpoint
- account endpoint / listenKey
- listenKey create / keepalive
- private WebSocket runtime
- private stream runtime
- account snapshot runtime
- real account read
- broker position sync
- real account balance
- real position
- margin / leverage
- real PnL runtime
- broker action
- broker integration
- broker adapter
- broker / exchange execution adapter
- `LiveExecutionAdapter`
- Live PRO Console
- trading button
- live command
- order form
- emergency stop / shutdown / restore executable action
- production operations command
- Graphify update
- Figma change

这些能力只能作为 forbidden / Future Gated boundary 出现，不能写成当前支持、beta preview、local fallback、behind flag、partially implemented 或后续 issue自动授权。

## MTP-154 validation anchors

`MTP-154-STRATEGY-TRADER-INSTANCE-READINESS-VALIDATION`

Required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-154 terminology、readiness-only boundary、proposal / readiness evidence baseline、L3.4 handoff boundary、first executable candidate non-authorization、forbidden capability baseline 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-154 Strategy / Trader Instance Readiness shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-STRATEGY-TRADER-INSTANCE-READINESS` 和 MTP-154 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-154 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-154 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Strategy / Trader Instance readiness terminology anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-154 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、planning record、Linear write evidence 和 forbidden capability boundary strings。

MTP-154 不新增 Swift production code，不新增 focused XCTest，不新增 Dashboard smoke handle，不新增 App read model，不新增 Core / Runtime / Dashboard behavior，不新增 stage audit input；Project stage closeout 仍归属 MTP-161。

## MTP-155 strategy / trader lifecycle and instance identity

`MTP-155-STRATEGY-TRADER-LIFECYCLE-IDENTITY`

MTP-155 只定义 Strategy Instance / Trader Instance 的 lifecycle、identity 和只读状态语义，不实现 lifecycle runtime、strategy scheduler、trader process manager、broker session、real account session 或 executable command。

| 术语 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `strategy instance identity` | Strategy Instance 的 deterministic readiness identity，由本地 contract anchor、strategy role placeholder、read-model reference placeholder、proposal boundary reference 和 evidence trace reference 组成 | 不等于 runtime object id、broker account id、API key、secret、listenKey、adapter request id、OMS order id 或 executable order command id |
| `trader instance identity` | Trader Instance 的 deterministic readiness identity，由本地 contract anchor、future trader context placeholder、role reference、read-model reference boundary 和 evidence trace reference 组成 | 不等于 trader process id、broker session id、account session id、private stream cursor、LiveExecutionAdapter handle 或 live command actor id |
| `configured` | identity / lifecycle contract 已被文档和 validation anchors 描述，可以作为后续 read-model-only evidence 的配置态 | 不等于 runtime configured、broker configured、credential configured 或 executable strategy configured |
| `ready` | readiness evidence 已满足当前 issue 的 terminology / identity / lifecycle anchor 要求，且仍保持 read-model-only / non-execution boundary | 不等于 live ready、broker ready、account ready、execution ready 或 can trade |
| `blocked` | identity 或 lifecycle 因 forbidden capability、missing read-model reference、future-gated proposal 或 upstream issue 未完成而保持阻断 | 不等于 broker reject、risk reject、execution failure、runtime error 或 production incident |
| `inactive` | Strategy / Trader readiness shell 当前不参与后续 evidence surface 或 proposal interpretation | 不等于 stopped runtime、disconnected broker、disabled trading session 或 deallocated process |
| `simulation-only` | identity / lifecycle 只能指向 deterministic local / simulated / fixture evidence，不允许连接真实账户或 broker | 不等于 paper order execution authorization、live simulation mode、sandbox broker 或 hidden live mode |

## MTP-155 instance identity boundary

`MTP-155-INSTANCE-IDENTITY-BOUNDARY`

Strategy Instance / Trader Instance identity 只能由 local deterministic readiness fields 组成：

1. `contractAnchor`：指向 `MTP-154` / `MTP-155` contract anchor。
2. `instanceLabel`：用于 read-model-only display / trace 的本地标签，不承载 credential、account id 或 broker account id。
3. `roleReference`：只指向后续 MTP-156 role taxonomy，不提前定义 quoter / hedger runtime。
4. `readModelReference`：只指向后续 MTP-157 account / portfolio / risk read-model input contract，不读取真实 account payload、schema、adapter request 或 broker state。
5. `proposalBoundaryReference`：只指向后续 MTP-158 paper/live-neutral proposal isolation，不输出 executable order command。
6. `evidenceTraceReference`：只用于 validation / report / audit trace，不等于 runtime telemetry、execution report、broker fill 或 reconciliation fact。

## MTP-155 lifecycle readiness state semantics

`MTP-155-LIFECYCLE-READINESS-STATE-SEMANTICS`

Lifecycle state 只能表达 readiness evidence，不表达交易运行时：

- `configured` 表示 identity contract 和 source anchors 已存在。
- `ready` 表示 MTP-154 / MTP-155 的 terminology、identity、lifecycle 和 forbidden boundary anchors 已满足。
- `blocked` 表示当前 evidence 被 forbidden capability、future-gated dependency 或 missing read-model reference 阻断。
- `inactive` 表示该 readiness shell 不参与当前 evidence surface。
- `simulation-only` 表示该 identity 只能消费 deterministic local / simulated / fixture evidence。

这些状态不得写成 live runtime state、account connection state、broker session state、strategy scheduler state、trader process state、OMS state、order lifecycle state 或 UI command state。

## MTP-155 read-model reference boundary

`MTP-155-READ-MODEL-REFERENCE-BOUNDARY`

MTP-155 只定义 identity 与后续 account / portfolio / risk read model 的引用边界：

- Identity 可以记录 `readModelReference` 占位符，但不得定义真实 account schema、portfolio schema、risk runtime schema、SQLite / DuckDB schema 或 adapter payload。
- Identity 可以引用 freshness / blocked / simulated / future-gated semantics，但不得读取真实 balance、position、margin、leverage、real PnL 或 broker position。
- Identity 可以被后续 Workbench / Report / Events read-model-only surface 展示，但不得暴露 Runtime object、Adapter request、account payload、broker payload、private stream cursor 或 listenKey。

## MTP-155 no lifecycle runtime boundary

`MTP-155-NO-LIFECYCLE-RUNTIME-BOUNDARY`

MTP-155 不实现 lifecycle runtime，不实现 strategy scheduler，不实现 trader process manager，不创建 Strategy runtime、Trader runtime、broker connection、account session、private WebSocket runtime、private stream runtime、account snapshot runtime、OMS、Execution Client caller、broker command producer、Live PRO Console、trading button、live command 或 order form。

Lifecycle / identity 只能进入 contract、domain context、validation matrix、validation plan、latest summary、automation readiness 和 mechanical checks；MTP-155 不新增 Swift production code、focused XCTest、App read model、Dashboard surface 或 Dashboard smoke handle。

## MTP-155 identity sensitive field guard

`MTP-155-IDENTITY-SENSITIVE-FIELD-GUARD`

Strategy / Trader identity 不得包含 credential、secret、API key、listenKey、account id、broker account id、private stream cursor、adapter request、Runtime object、broker payload、account endpoint payload、SQLite / DuckDB schema、OMS order id、order form payload、executable order command field、real account balance、real position、margin、leverage 或 real PnL。

## MTP-155 validation anchors

`MTP-155-STRATEGY-TRADER-LIFECYCLE-VALIDATION`

Required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-155 lifecycle / identity、instance identity boundary、lifecycle readiness state semantics、read-model reference boundary、no lifecycle runtime boundary、identity sensitive field guard 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-155 Strategy / Trader lifecycle / identity shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-155 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-155 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-155 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Strategy / Trader lifecycle identity anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-155 contract、domain context、matrix、validation plan、latest summary、automation readiness doc 和 forbidden runtime / sensitive field boundary strings。

MTP-155 不新增 Swift production code，不新增 focused XCTest，不新增 Dashboard smoke handle，不新增 App read model，不新增 Core / Runtime / Dashboard behavior，不新增 stage audit input；Project stage closeout 仍归属 MTP-161。

## MTP-156 quoter / hedger role taxonomy

`MTP-156-QUOTER-HEDGER-ROLE-TAXONOMY`

MTP-156 只定义 Strategy / Trader readiness 内的 role taxonomy 和 responsibility boundary。Role 是 structural readiness language，不是 execution behavior、live strategy process、order generation engine、broker actor 或 UI command actor。

| Role | 当前职责语言 | 禁止混用 |
| --- | --- | --- |
| `quoter` | 只表示后续 strategy / trader readiness 可能需要解释 quote intent、market reference、spread rationale、proposal candidate 和 blocked evidence 的结构性角色 | 不等于 market making runtime、quote engine、order generation engine、Execution Client caller、broker command producer、live quote stream 或 order form actor |
| `hedger` | 只表示后续 strategy / trader readiness 可能需要解释 hedge intent、risk offset rationale、portfolio / risk read-model reference、proposal candidate 和 blocked evidence 的结构性角色 | 不等于 hedge runtime、position sync、broker hedge order、portfolio rebalancer、risk engine runtime、OMS actor 或 live command actor |
| `role responsibility` | 角色可以声明只读职责、allowed evidence references、blocked evidence 和 forbidden output boundary | 不等于 permission、authorization、capability flag、execution mode、broker entitlement 或 trading role assignment |
| `role readiness evidence` | 用于证明 role taxonomy 仍停留在 structural readiness 内的 contract anchor、source anchor、read-model reference、proposal boundary reference 和 validation anchor | 不等于 runtime telemetry、quote update、hedge execution report、broker fill、reconciliation fact 或 production audit event |

## MTP-156 role responsibility boundary

`MTP-156-ROLE-RESPONSIBILITY-BOUNDARY`

Role responsibility 只能包含以下 deterministic / local / read-model-only fields：

1. `roleName`：`quoter`、`hedger` 或后续 issue 明确允许的 readiness role label。
2. `responsibilitySummary`：只描述结构性职责，不描述 runtime behavior。
3. `allowedReadModelReferences`：只引用后续 MTP-157 account / portfolio / risk read-model input contract，不读取真实 account、position、balance、margin、leverage、real PnL、broker state 或 schema。
4. `allowedProposalReferences`：只引用后续 MTP-158 paper/live-neutral proposal contract，不输出 executable order command。
5. `blockedEvidenceReferences`：只解释 role 为什么仍被 forbidden capability、future-gated dependency、missing read-model input 或 missing proposal contract 阻断。
6. `forbiddenOutputs`：必须明确 role 不能输出 broker command、order-level live command、OMS order、Execution Client request、trading button action、live command 或 order form payload。

## MTP-156 role proposal / read-model / blocked evidence relationship

`MTP-156-ROLE-PROPOSAL-READ-MODEL-BLOCKED-EVIDENCE`

MTP-156 将 role 与 proposal、read-model input 和 blocked evidence 的关系固定为只读引用：

- Quoter role 可以引用 market / quote rationale placeholder、read-model reference placeholder 和 proposal boundary reference；不得创建 quote runtime、live quote stream、order book writer、Execution Client request 或 broker command。
- Hedger role 可以引用 portfolio / risk rationale placeholder、read-model reference placeholder 和 proposal boundary reference；不得创建 hedge runtime、broker hedge order、position sync、risk engine runtime 或 live command。
- Role 可以输出 blocked evidence language，例如 `missingReadModelInput`、`proposalContractPending`、`executionForbidden`、`brokerForbidden`、`uiCommandForbidden`；这些只是解释，不是 runtime state、broker reject、risk reject、incident 或 command result。
- Role 与 MTP-157 / MTP-158 的关系只能是 handoff reference；MTP-156 不提前定义 account / portfolio / risk input shape，不定义 proposal attributes，不定义 proposal status。

## MTP-156 no role execution behavior

`MTP-156-NO-ROLE-EXECUTION-BEHAVIOR`

Role taxonomy 不得实现或暗示 quoter runtime、hedger runtime、strategy marketplace、strategy manager、strategy scheduler、trader process manager、order generation engine、Execution Client direct path、broker connection、signed endpoint、account endpoint / listenKey、private WebSocket runtime、private stream runtime、account snapshot runtime、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、broker adapter、`LiveExecutionAdapter`、Live PRO Console、trading button、live command 或 order form。

## MTP-156 forbidden role command surface

`MTP-156-FORBIDDEN-ROLE-COMMAND-SURFACE`

Quoter / hedger role 不得暴露以下 output / action / command surfaces：

- broker command
- order-level live command
- executable order command
- Execution Client request
- OMS order
- quote order request
- hedge order request
- submit / cancel / replace command
- trading button action
- live command
- order form payload
- broker adapter request
- account endpoint payload
- signed request
- listenKey create / keepalive
- Runtime object
- Adapter request
- SQLite / DuckDB schema
- credential / secret / API key

这些 surface 只能作为 forbidden boundary string 出现，不能写成 current support、beta preview、local fallback、behind flag、partially implemented 或后续 issue自动授权。

## MTP-156 validation anchors

`MTP-156-ROLE-TAXONOMY-VALIDATION`

Required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-156 quoter / hedger role taxonomy、role responsibility boundary、role proposal / read-model / blocked evidence relationship、no role execution behavior、forbidden role command surface 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-156 role taxonomy shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-156 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-156 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-156 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 quoter / hedger role taxonomy anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-156 contract、domain context、matrix、validation plan、latest summary、automation readiness doc、forbidden role command surface 和 no execution behavior boundary strings。

MTP-156 不新增 Swift production code，不新增 focused XCTest，不新增 Dashboard smoke handle，不新增 App read model，不新增 Core / Runtime / Dashboard behavior，不新增 stage audit input；Project stage closeout 仍归属 MTP-161。

## MTP-157 account / portfolio / risk read-model input contract

`MTP-157-ACCOUNT-PORTFOLIO-RISK-READ-MODEL-INPUT`

MTP-157 只定义 Strategy / Trader Instance 可以消费的 account / portfolio / risk read-model input contract。Input 是 readiness evidence 的只读输入，不是真实账户输入、broker state、live risk runtime input 或 order command precondition。

| Input | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `account read-model input` | Strategy / Trader readiness 可以引用的 account evidence summary，只能来自既有 Read Model / ViewModel 或 deterministic fixture evidence | 不等于 real account payload、account endpoint response、listenKey stream、broker account statement、account session 或 credential-bound account state |
| `portfolio read-model input` | Strategy / Trader readiness 可以引用的 paper / simulated / fixture portfolio evidence，用于解释 role rationale 和 proposal boundary | 不等于 broker position sync、real position, margin / leverage state、real PnL、portfolio rebalance command 或 hedge order command |
| `risk read-model input` | Strategy / Trader readiness 可以引用的 risk evidence summary，用于解释 blocked / simulated / future-gated readiness | 不等于 live risk engine input、real pre-trade allow / reject runtime、circuit breaker command、stop trading command 或 execution gate |
| `input provenance` | 每条 input 必须携带 source layer、source anchor、scenario / fixture reference、observedAt / watermark 和 evidence trace | 不等于 broker audit event、execution report、broker fill、reconciliation record 或 production monitoring telemetry |
| `read-model input freshness` | `fresh` / `stale` / `missing` / `blocked` / `simulated` / `future-gated` 只解释 evidence freshness 和可用性 | 不等于 account connection health、private stream health、live readiness implementation 或 broker connectivity |

## MTP-157 input provenance and evidence trace

`MTP-157-INPUT-PROVENANCE-EVIDENCE-TRACE`

Account / portfolio / risk input 必须保持可追溯但不可执行：

1. `sourceLayer` 只能指向 existing read-model-only evidence layer，例如 L3.1 account / position / balance read-model-only evidence、L3.2 private stream / account snapshot simulation gate evidence、L3.3 monitoring read-model-only evidence 或本 Project 内合同锚点。
2. `sourceAnchor` 只能指向 contract / validation / automation readiness anchor，不得指向 signed endpoint route、account endpoint route、listenKey、private WebSocket cursor、adapter request、Runtime object 或 database schema。
3. `scenarioReference` 只能解释 deterministic local / paper / simulated / fixture evidence，不得解释为真实账户、真实持仓、真实余额或 broker portfolio snapshot。
4. `evidenceTrace` 只能用于 Report / audit / validation trace，不得成为 OMS order id、execution id、broker fill id、reconciliation id、order form payload 或 executable command id。

## MTP-157 freshness / blocked / simulated / future-gated input semantics

`MTP-157-FRESHNESS-BLOCKED-SIMULATED-FUTURE-GATED-SEMANTICS`

MTP-157 固定 input status semantics：

- `fresh` 表示 read-model-only evidence 在当前 deterministic validation window 内可解释。
- `stale` 表示 read-model evidence 已超过 source watermark 或 validation window，只能展示为 stale evidence。
- `missing` 表示当前 Strategy / Trader readiness 没有所需 input evidence。
- `blocked` 表示 input 被 forbidden capability、missing upstream evidence、future gated source 或 no-real-account boundary 阻断。
- `simulated` 表示 input 只来自 deterministic local / fixture / simulated evidence。
- `future-gated` 表示真实账户、真实 portfolio 或 live risk input 仍在 Future Gated scope，当前不可读取、不可连接、不可执行。

这些状态不得写成 real account health、broker position health、private stream status、live risk status、pre-trade allow / reject result、order lifecycle state 或 UI command state。

## MTP-157 read-model / ViewModel boundary

`MTP-157-READ-MODEL-VIEWMODEL-BOUNDARY`

Strategy / Trader readiness 只能通过 Read Model / ViewModel 消费 account / portfolio / risk input：

- 允许引用既有 account / position / balance read-model-only evidence、paper portfolio projection evidence、private stream / account snapshot simulation gate evidence、Live Monitoring v2 read-model-only evidence 和 contract anchors。
- 不允许读取 real account payload、broker state、account endpoint payload、private stream payload、Runtime object、Adapter request、SQLite / DuckDB schema、credential、secret、API key 或 listenKey。
- 不允许绕过 Read Model / ViewModel 直接访问 Persistence schema、Runtime actor、Adapter boundary、Execution Client、broker connector、private WebSocket 或 signed endpoint。
- Workbench / Report / Events surface 只能在 MTP-160 scope 内展示该 input evidence；MTP-157 不新增 App read model、Dashboard surface 或 Dashboard smoke handle。

## MTP-157 no real account / live risk runtime boundary

`MTP-157-NO-REAL-ACCOUNT-RISK-RUNTIME`

MTP-157 不读取真实账户，不同步 broker position，不读取真实 balance、real position、margin、leverage、buying power 或 real PnL；不实现 live risk engine、real pre-trade allow / reject runtime、circuit breaker runtime、stop trading command、account snapshot runtime、private stream runtime、signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button、live command 或 order form。

Account / portfolio / risk input 只能进入 contract、domain context、validation matrix、validation plan、latest summary、automation readiness 和 mechanical checks；Project stage closeout 仍归属 MTP-161。

## MTP-157 broker state / payload / schema exposure guard

`MTP-157-BROKER-STATE-PAYLOAD-SCHEMA-EXPOSURE-GUARD`

MTP-157 input contract 不得暴露以下内容：

- real account payload
- account endpoint payload
- broker payload
- broker state
- broker position
- real balance / real position / margin / leverage / buying power / real PnL
- Runtime object
- Adapter request
- SQLite / DuckDB schema
- API key / secret / credential / listenKey
- private WebSocket cursor
- execution report
- broker fill
- reconciliation record
- executable order command
- broker command
- OMS order
- UI order form payload

这些内容只能作为 forbidden boundary string 出现，不能写成 current support、beta preview、local fallback、behind flag、partially implemented 或后续 issue自动授权。

## MTP-157 validation anchors

`MTP-157-READ-MODEL-INPUT-VALIDATION`

Required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-157 account / portfolio / risk read-model input contract、input provenance / evidence trace、freshness / blocked / simulated / future-gated semantics、Read Model / ViewModel boundary、no real account / live risk runtime boundary、broker state / payload / schema exposure guard 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-157 account / portfolio / risk read-model input shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-157 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-157 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-157 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 account / portfolio / risk read-model input anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-157 contract、domain context、matrix、validation plan、latest summary、automation readiness doc、Read Model / ViewModel boundary、no real account / live risk runtime boundary 和 broker state / payload / schema exposure guard。

MTP-157 不新增 Swift production code，不新增 focused XCTest，不新增 Dashboard smoke handle，不新增 App read model，不新增 Core / Runtime / Dashboard behavior，不新增 stage audit input；Project stage closeout 仍归属 MTP-161。

## MTP-158 paper/live-neutral proposal contract

`MTP-158-PAPER-LIVE-NEUTRAL-PROPOSAL-CONTRACT`

MTP-158 只定义 Strategy / Trader readiness 中的 paper/live-neutral proposal contract。Proposal 是 read-model-only / evidence-only 的 intent evidence，用于解释 strategy / trader 结构、role rationale、read-model input reference 和 blocked / simulated / future-gated decision trace；它不是 executable order command、Execution Client request、broker command、OMS order 或 UI order form payload。

| Proposal | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `strategy proposal` | Strategy Instance 可生成的只读 readiness / intent evidence，用于解释策略方向、role rationale、read-model input reference 和 blocked reason | 不等于 order command、strategy runtime output、Execution Client request、broker command、OMS order、live command 或 order form payload |
| `trader proposal` | Trader Instance 可引用的只读 readiness / intent evidence，用于解释 trader context、role responsibility、proposal status 和 evidence trace | 不等于 trader process command、broker session action、account session action、submit / cancel / replace command 或 UI command |
| `paper/live-neutral proposal` | 明确不绑定真实账户、真实 broker、signed endpoint、account endpoint / listenKey 或 live venue 的 proposal evidence | 不等于 paper order execution authorization、live preview、sandbox broker order 或 hidden live mode |
| `proposal evidence` | proposal 的 contract anchor、role reference、read-model input reference、status、blocked reason 和 validation trace | 不等于 broker acknowledgement、execution report、broker fill、reconciliation fact 或 production audit event |

## MTP-158 proposal attributes and status semantics

`MTP-158-PROPOSAL-ATTRIBUTES-STATUS-SEMANTICS`

MTP-158 只允许 proposal 包含以下 non-executable attributes：

1. `proposalId`：本地 deterministic evidence id，不是 order id、broker order id、client order id、OMS id 或 execution id。
2. `proposalKind`：`strategy proposal`、`trader proposal` 或 `paper/live-neutral proposal`。
3. `sourceInstanceReference`：只引用 MTP-155 Strategy / Trader identity，不引用 runtime object、account session 或 broker session。
4. `roleReference`：只引用 MTP-156 quoter / hedger role taxonomy，不授权 role runtime 或 role command。
5. `readModelInputReference`：只引用 MTP-157 account / portfolio / risk read-model input，不读取真实 account payload、broker state 或 schema。
6. `intentSummary`：只写业务意图摘要，不包含 price、quantity、side、timeInForce、orderType、venue、account id、broker account id 或 execution destination。
7. `proposalStatus`：只能是 `draft`、`blocked`、`simulated`、`future-gated` 或 `rejected-by-boundary`。
8. `blockedReason`：只解释 forbidden capability、missing read-model input、future-gated source 或 proposal-to-command isolation，不是 broker reject、risk reject、exchange reject 或 runtime failure。
9. `evidenceTrace`：只服务 Report / audit / validation trace，不等于 broker fill id、execution id、reconciliation id 或 production audit event。

这些 attributes 不得组合成 executable order command shape。

## MTP-158 proposal to command isolation

`MTP-158-PROPOSAL-TO-COMMAND-ISOLATION`

Proposal 与 command 必须保持机械隔离：

- Proposal 不得包含 `submit`、`cancel`、`replace`、`amend`、`route`、`execute`、`sendOrder`、`placeOrder`、`closePosition` 或 `rebalance` 等 command verb。
- Proposal 不得包含可直接执行订单所需的完整字段组合，例如 account id、symbol、side、quantity、price、order type、time in force、venue、client order id 或 broker route。
- Proposal 不得被 Execution Client、broker adapter、OMS、Runtime actor、UI button、order form、live command handler 或 production operations command 直接消费。
- Proposal 只能被后续 MTP-160 Workbench / Report / Events read-model-only surface 展示，或被 MTP-159 forbidden tests 作为 non-executable evidence 检查。

## MTP-158 no Execution Client / broker / OMS boundary

`MTP-158-NO-EXECUTION-CLIENT-BROKER-OMS`

MTP-158 不实现 Execution Client，不实现 broker command，不实现 OMS，不实现 order generation engine，不实现 real order lifecycle，不实现 real submit / cancel / replace，不实现 execution report、broker fill 或 reconciliation；不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`，不调用 signed endpoint、account endpoint / listenKey，不读取真实账户、broker position、margin、leverage、real PnL，不新增 Live PRO Console、trading button、live command 或 order form。

Proposal 只能进入 contract、domain context、validation matrix、validation plan、latest summary、automation readiness 和 mechanical checks；Project stage closeout 仍归属 MTP-161。

## MTP-158 proposal forbidden command field guard

`MTP-158-PROPOSAL-FORBIDDEN-COMMAND-FIELD-GUARD`

MTP-158 proposal contract 不得暴露以下 command / execution fields：

- executable order command
- broker command
- Execution Client request
- OMS order
- submit / cancel / replace command
- order id / client order id / broker order id
- account id / broker account id
- account endpoint payload
- signed request
- listenKey
- Runtime object
- Adapter request
- broker adapter request
- SQLite / DuckDB schema
- price / quantity / side / timeInForce / orderType / venue as executable order tuple
- trading button action
- live command
- order form payload
- execution report
- broker fill
- reconciliation record

这些字段只能作为 forbidden boundary string 出现，不能写成 current support、beta preview、local fallback、behind flag、partially implemented 或后续 issue自动授权。

## MTP-158 validation anchors

`MTP-158-PROPOSAL-CONTRACT-VALIDATION`

Required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-158 paper/live-neutral proposal contract、proposal attributes / status semantics、proposal-to-command isolation、no Execution Client / broker / OMS boundary、proposal forbidden command field guard 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-158 paper/live-neutral proposal shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-158 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-158 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-158 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 paper/live-neutral proposal command isolation anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-158 contract、domain context、matrix、validation plan、latest summary、automation readiness doc、proposal-to-command isolation、no Execution Client / broker / OMS boundary 和 forbidden command field guard。

MTP-158 不新增 Swift production code，不新增 focused XCTest，不新增 Dashboard smoke handle，不新增 App read model，不新增 Core / Runtime / Dashboard behavior，不新增 stage audit input；Project stage closeout 仍归属 MTP-161。
