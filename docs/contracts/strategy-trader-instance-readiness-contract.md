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
