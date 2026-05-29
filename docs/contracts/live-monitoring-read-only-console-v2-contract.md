# Live Monitoring Read-only Console v2 Contract

日期：2026-05-30

执行者：Codex

本文档定义 `MTPRO Live Monitoring Read-only Console v2` 的 MTP-147 合同入口：L3.3 Live Monitoring Read-only Console v2 terminology、monitoring evidence source boundary、Read Model / ViewModel consumption boundary、L3.3 handoff boundary、first executable candidate non-authorization、forbidden capability baseline 和 validation anchors。

本文档只服务 `MTP-147 Define Live Monitoring Read-only Console v2 terminology and boundary` 的术语 / 边界 / 验证锚点。它不实现 monitoring evidence surface，不实现 live readiness runtime，不接 signed endpoint、account endpoint / listenKey，不实现 private WebSocket runtime、private stream runtime、account snapshot runtime，不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL；不连接 broker，不实现 broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form；不运行 Graphify，不修改 Figma。

## MTP-147 Live Monitoring Read-only Console v2 terminology

`MTP-147-LIVE-MONITORING-READ-ONLY-CONSOLE-V2-TERMINOLOGY`

MTP-147 只允许定义以下 L3.3 术语，不允许把术语升级为 runtime、connection 或 UI command：

| 术语 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `Live Monitoring Read-only Console v2` | L3.3 只读 monitoring evidence console 的合同名称，用来组织 L3.0 / L3.1 / L3.2 已完成 evidence 的 monitoring 解释层 | 不等于 Live Monitoring runtime、Live readiness runtime、Live PRO Console、broker console 或交易控制台 |
| `monitoring evidence` | 由已完成 read-model-only、fixture、paper、simulated 或 future-gated source label 派生的只读观察证据 | 不等于 runtime telemetry、account endpoint payload、private stream event、broker state 或 production monitoring agent |
| `monitoring source boundary` | 说明 monitoring evidence 只能来自 L3.0 / L3.1 / L3.2 已完成证据链的来源边界 | 不等于 source adapter、connection manager、private stream runtime 或 account snapshot runtime |
| `read-only monitoring state` | blocked、stale、missing、simulated、fixture、future-gated 等只读状态解释 | 不等于实时连接状态、自动恢复动作、交易授权或 live command enablement |
| `monitoring boundary entry` | Workbench / Report / Events 后续可引用的 boundary anchor、source anchor 和 validation anchor | 不等于 Dashboard surface、Swift ViewModel implementation 或 Event Timeline item implementation |
| `L3.3 monitoring handoff` | MTP-147 把 terminology / boundary 交给 MTP-148 至 MTP-153 的范围边界 | 不自动推进后续 issue，不授权 monitoring source identity、health evidence、connection explanation、forbidden tests、surface 或 stage closeout |

## MTP-147 monitoring evidence source boundary

`MTP-147-MONITORING-EVIDENCE-SOURCE-BOUNDARY`

MTP-147 固定 Live Monitoring Read-only Console v2 的 source boundary：

1. L3.0 `Live Read-only Readiness Boundary` 是 monitoring evidence 的 readiness / endpoint / adapter capability baseline。它只提供 future gates、forbidden capability baseline 和 read-model-only boundary，不提供 live runtime 或 real connection。
2. L3.1 `Account / Position / Balance Read-model-only` 是 monitoring evidence 的 account / position / balance vocabulary input。它只提供 fixture / paper / simulated / future-gated real source label、snapshot identity、freshness / stale / blocked / missing 解释和 read-model-only surface，不读取真实账户。
3. L3.2 `Private Stream / Account Snapshot Simulation Gate` 是 monitoring evidence 的 private stream / account snapshot simulation input。它只提供 local fixture / simulated source identity、snapshot input、update fixture、freshness evidence 和 read-model-only surface，不创建 listenKey、不连接 private WebSocket、不运行 account snapshot runtime。
4. L3.3 只能在后续 issue 中把上述 evidence 组织为 monitoring source identity、health / freshness evidence、connection readiness explanation、forbidden runtime / endpoint / UI command tests、Workbench / Report / Events read-model-only surface 和 stage closeout。

MTP-147 不新增 source implementation，不新增 fixture payload，不新增 Swift production code，不新增 focused XCTest，不新增 Dashboard smoke handle。

## MTP-147 Read Model / ViewModel consumption boundary

`MTP-147-READ-MODEL-VIEWMODEL-CONSUMPTION-BOUNDARY`

MTP-147 固定后续 Workbench / Report / Events 的消费边界：

- Workbench 只能消费后续 MTP-152 允许的 Read Model / ViewModel，不直接读取 adapter request、Runtime object、SQLite / DuckDB schema、account payload、broker payload、secret config 或 broker state。
- Report 只能汇总 monitoring evidence、source anchors、validation anchors 和 boundary notes，不生成 live readiness runtime report。
- Events 只能展示 read-model-only evidence trace，不打开 query console、runtime inspector、connection debugger 或 production operations panel。
- Dashboard / App 不得提供 API key input、secret storage、account connect、broker connect、private stream connect、reconnect command、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore command。

## MTP-147 L3.3 handoff boundary

`MTP-147-L33-HANDOFF-BOUNDARY`

MTP-147 的 handoff 只交付 terminology / boundary input：

1. MTP-148 才能定义 monitoring source identity from L3.0 / L3.1 / L3.2 evidence。
2. MTP-149 才能定义 account snapshot / private stream simulation gate health and freshness evidence。
3. MTP-150 才能定义 connection readiness / stale / blocked / missing explanation without runtime connection。
4. MTP-151 才能定义 forbidden Live Monitoring runtime / endpoint / UI command tests。
5. MTP-152 才能 add Workbench / Report / Events Live Monitoring v2 read-model-only evidence surface。
6. MTP-153 才能 close validation matrix / automation readiness / stage audit input。
7. L3.4 Strategy / Trader Instance Readiness 和 L4 Live Production / Trading Commands 保持 Future Gated；MTP-147 不授权 strategy-to-broker command path、broker command、OMS、Live PRO Console 或 live command。

MTP-147 完成后不得自动推进 MTP-148。MTP-148 至 MTP-153 必须继续保持 Backlog / non-executable，直到各自成为 Linear live-read 中唯一 eligible issue。

## MTP-147 first executable candidate non-authorization

`MTP-147-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`

Project Planning Record、Linear Project issue order、next eligible candidate、Backlog issue、label、priority、assignee 或 estimate 都不构成执行授权。MTP-147 只有在 Linear live-read 中经 Parent Codex queue preflight 和 symphony-issue 调度后，作为唯一 active configured executable issue 时才可以执行。

该事实不改变以下规则：

- `docs/product/mtpro-live-readiness-roadmap-v1.md` 不授权 execution。
- `docs/planning/projects/*` 不授权 execution。
- MTP-147 完成后不得自动推进 MTP-148。
- MTP-148 至 MTP-153 必须继续保持 Backlog / non-executable，直到各自成为 live-read 中唯一 eligible issue。

## MTP-147 forbidden capability baseline

`MTP-147-FORBIDDEN-CAPABILITY-BASELINE`

MTP-147 必须保持以下 forbidden capabilities：

- signed endpoint
- account endpoint / listenKey
- listenKey create / keepalive
- private WebSocket runtime
- private stream runtime
- account snapshot runtime
- live readiness runtime
- Live Monitoring runtime
- account / position / balance runtime
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
- production operations command
- Graphify update
- Figma change

这些能力只能作为 forbidden / Future Gated boundary 出现，不能写成当前支持、beta preview、local fallback、behind flag、partially implemented 或后续 issue 自动授权。

## MTP-147 validation anchors

`MTP-147-LIVE-MONITORING-READ-ONLY-CONSOLE-V2-VALIDATION`

Required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 MTP-147 terminology、monitoring evidence source boundary、Read Model / ViewModel consumption boundary、L3.3 handoff boundary、first executable candidate non-authorization、forbidden capability baseline 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-147 Live Monitoring Read-only Console v2 shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-LIVE-MONITORING-READ-ONLY-CONSOLE-V2` 和 MTP-147 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-147 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-147 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring Read-only Console v2 terminology anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-147 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、planning record 和 forbidden capability boundary strings。

MTP-147 不新增 Swift production code，不新增 focused XCTest，不新增 Dashboard smoke handle，不新增 App read model，不新增 Core / Runtime / Dashboard behavior，不新增 stage audit input；Project stage closeout 仍归属 MTP-153。
