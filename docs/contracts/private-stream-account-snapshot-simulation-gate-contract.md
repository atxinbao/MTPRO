# Private Stream / Account Snapshot Simulation Gate Contract

日期：2026-05-29

执行者：Codex

本文档定义 `MTPRO Private Stream / Account Snapshot Simulation Gate v1` 的 MTP-140 合同入口：L3.2 private stream / account snapshot simulation gate terminology、account snapshot simulation gate terminology、fixture / simulated / future real private stream 语义分界、L3.1 APB read-model-only evidence 与 L3.2 simulation gate 的关系、first executable candidate non-authorization、forbidden capability baseline 和 validation anchors。

本文档只服务 `MTP-140 Define private stream / account snapshot simulation gate terminology and boundary` 的术语 / 边界 / 验证锚点。它不实现 private WebSocket runtime，不实现 account snapshot runtime，不创建 listenKey，不调用 signed endpoint 或 account endpoint，不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL；不实现 broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button、live command 或 order form；不运行 Graphify，不修改 Figma。

## MTP-140 private stream simulation gate terminology

`MTP-140-PRIVATE-STREAM-SIMULATION-GATE-TERMINOLOGY`

MTP-140 只允许定义以下 L3.2 private stream simulation gate 术语，不允许把术语升级为 runtime：

| 术语 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `private stream simulation gate` | 本地 deterministic fixture / simulated event 进入后续 L3.2 evidence chain 前的语义门禁 | 不等于 listenKey、private WebSocket、user data stream runtime 或 broker stream |
| `simulated private account event` | 本地 fixture 描述的账户相关事件语义，用来支撑后续 source identity / snapshot input / update fixture | 不等于真实 Binance user data event、account endpoint payload、execution report 或 broker account event |
| `private stream fixture source` | 只读 fixture source label，说明 event 来自本地模拟输入 | 不等于 exchange connection、broker connection、secret-backed session 或 private account stream |
| `fixture replay cursor` | 本地 fixture / scenario replay 可复现 cursor，用于说明 deterministic ordering | 不等于 live stream offset、listenKey lifecycle、production stream watermark 或 network checkpoint |
| `future real private stream label` | 未来真实 private stream 进入独立 Project 前的门禁标签 | 不等于当前已实现真实 private stream、secret storage、signed request 或 account stream |

## MTP-140 account snapshot simulation gate terminology

`MTP-140-ACCOUNT-SNAPSHOT-SIMULATION-GATE-TERMINOLOGY`

MTP-140 只允许定义以下 account snapshot simulation gate 术语：

| 术语 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `account snapshot simulation gate` | 本地 simulated account snapshot 输入进入后续 L3.2 evidence chain 前的语义门禁 | 不等于 account snapshot runtime、account endpoint client、real account sync 或 broker portfolio sync |
| `simulated account snapshot input` | 后续 MTP-142 才能深化的本地模拟快照输入 shape | 不等于真实 account endpoint response、broker account payload、SQLite / DuckDB schema 或 Runtime object |
| `account snapshot fixture` | deterministic local fixture 中的 account snapshot evidence | 不等于真实账户余额、margin、leverage、buying power、real PnL 或可交易账户状态 |
| `snapshot observedAt` | fixture 观察时间语义，用于 freshness / stale 判断 | 不等于 exchange server time、broker account state timestamp 或 live stream last event |
| `source watermark` | fixture / replay source 的本地 watermark 语义 | 不等于 private stream watermark、listenKey keepalive state 或 production checkpoint |
| `freshness / stale / blocked / missing evidence` | 后续 MTP-144 才能深化的 simulation gate 状态分类 | 不等于真实账户健康状态、broker connectivity 或 live monitoring runtime |

## MTP-140 fixture / simulated / future real private stream boundary

`MTP-140-FIXTURE-SIMULATED-FUTURE-REAL-PRIVATE-STREAM-BOUNDARY`

MTP-140 将 L3.2 source semantics 固定为术语层：

1. `fixture private stream source` 表示 deterministic local fixture；它不等于真实 private stream payload。
2. `simulated private stream source` 表示 scenario replay / simulated input 产生的本地事件语义；它不等于 listenKey user data stream、execution report、broker fill 或 reconciliation。
3. `future real private stream label` 只能作为未来门禁标签出现；当前不读取 secret，不创建 listenKey，不调用 signed endpoint，不打开 private WebSocket，不运行 account snapshot runtime。
4. `account snapshot fixture` 只能表达 simulation gate 输入，不得被解释为真实 account snapshot、broker account object 或 real account balance。

后续 MTP-141 / MTP-142 / MTP-143 / MTP-144 可以分别深化 source identity、snapshot input contract、balance / position update fixture semantics 和 freshness / blocked / forbidden tests，但必须继续保持 fixture / simulated / future real label 与 live runtime implementation 隔离。

## MTP-140 L3.1 APB / L3.2 simulation gate relationship

`MTP-140-L31-APB-L32-SIMULATION-GATE-RELATIONSHIP`

MTP-140 固定 L3.1 APB read-model-only evidence 与 L3.2 simulation gate 的关系：

- L3.1 APB 已完成 account / position / balance read-model-only terminology、snapshot identity、source / freshness evidence、deterministic fixture、forbidden real account tests 和 Workbench / Report / Events read-model-only surface。
- L3.2 simulation gate 可以复用 L3.1 APB 的 read-model-only vocabulary，例如 evidence id、source identity、freshness / stale / blocked / missing 状态和 fixture-to-read-model mapping boundary。
- L3.2 不得把 L3.1 APB read-model-only evidence 反向升级为 account snapshot runtime、private stream runtime、real account read、broker position sync、real balance、margin、leverage 或 real PnL。
- L3.2 不得把 Workbench / Report / Events APB surface 写成 account connect、broker connect、Live PRO Console、trading button、live command 或 order form。

## MTP-140 first executable candidate non-authorization

`MTP-140-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`

Project Planning Record、Linear Project issue order、next eligible candidate、Backlog issue、label、priority、assignee 或 estimate 都不构成执行授权。MTP-140 只有在 Linear live-read 中经 Parent Codex queue preflight 推进为唯一 active issue 后才可执行。

该事实不改变以下规则：

- `docs/product/mtpro-live-readiness-roadmap-v1.md` 不授权 execution。
- `docs/planning/projects/*` 不授权 execution。
- MTP-140 完成后不得自动推进 MTP-141。
- MTP-141 至 MTP-146 必须继续保持 Backlog / non-executable，直到各自成为 live-read 中唯一 eligible issue。

## MTP-140 forbidden capability baseline

`MTP-140-FORBIDDEN-CAPABILITY-BASELINE`

MTP-140 必须保持以下 forbidden capabilities：

- signed endpoint
- account endpoint / listenKey
- listenKey create / keepalive
- private WebSocket runtime
- private stream runtime
- account snapshot runtime
- account / position / balance runtime
- real account read
- broker position sync
- real account balance
- margin / leverage
- real PnL runtime
- broker / exchange execution adapter
- `LiveExecutionAdapter`
- OMS
- real order lifecycle
- real submit / cancel / replace
- execution report
- broker fill
- reconciliation
- Live PRO Console
- trading button
- live command
- order form
- emergency stop / shutdown / restore executable action
- Graphify update
- Figma change

这些能力只能作为 forbidden / Future Gated boundary 出现，不能写成当前支持、beta preview、local fallback、behind flag、partially implemented 或后续 issue 自动授权。

## MTP-140 validation anchors

`MTP-140-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE-VALIDATION`

Required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 MTP-140 private stream terminology、account snapshot terminology、fixture / simulated / future real boundary、L3.1 APB / L3.2 relationship、first executable candidate non-authorization、forbidden capability baseline 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-140 private stream / account snapshot simulation gate shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE` 和 MTP-140 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-140 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-140 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate terminology anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-140 contract、matrix、validation plan、domain context、latest summary、automation readiness doc 和 forbidden capability boundary strings。

MTP-140 不新增 Swift production code，不新增 focused XCTest，不新增 Dashboard smoke handle，不新增 stage audit input；Project stage closeout 仍归属 MTP-146。
