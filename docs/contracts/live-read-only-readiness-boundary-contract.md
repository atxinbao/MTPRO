# Live Read-only Readiness Boundary Contract

日期：2026-05-27

执行者：Codex

本文档定义 `MTPRO Live Read-only Readiness Boundary v1` 的 MTP-126 合同入口：Live read-only readiness terminology、target engines / layers、L3.0 与后续 L3.1 / L3.2 / L3.3 的 handoff boundary、forbidden capability baseline、first executable candidate non-authorization 和 validation anchors。

本文档只服务 `MTP-126 Define Live read-only readiness terminology and boundary` 的术语 / 边界 / 验证锚点。它不实现 endpoint、secret、adapter、account read model、UI 或 live runtime；不读取本地 secret；不实现 signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button 或 live command；不运行 Graphify，不修改 Figma。

## MTP-126 Live read-only readiness terminology

`MTP-126-LIVE-READ-ONLY-READINESS-TERMINOLOGY`

MTP-126 只允许定义以下 L3.0 术语，不允许把术语升级为实现：

| 术语 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `Live read-only readiness` | L3.0 只读准备边界，用来说明靠近真实账户只读能力前需要的 terminology、future gates、validation anchors 和 forbidden baseline | 不等于真实账户读取、private stream、broker connection、Live Monitoring v2 或 Live Production |
| `read-only readiness boundary` | 当前 Project 的边界合同，固定哪些能力只能作为 future gate / forbidden capability 出现 | 不等于 adapter capability implementation、account endpoint runtime 或 Workbench UI surface |
| `target engine / layer boundary` | L3.0 涉及 Connectivity / Adapter Engine、Data Engine / future private stream boundary、Evidence Read Model Layer、Workbench Interface / Live Readiness surface 和 Docs / Validation / Automation readiness layer 的职责地图 | 不等于新增 SwiftPM target、Runtime actor、App read model 或 Dashboard behavior |
| `L3.0 handoff boundary` | 把 L3.0 术语 / 验证锚点交给后续 L3.1 / L3.2 / L3.3 的范围边界 | 不自动授权后续 Linear issue，不推进 Backlog，不实现后续 runtime |
| `read-only future gate` | 后续 account / position / balance read-model-only、private stream / account snapshot simulation gate、Live Monitoring read-only Console v2 进入 planning 前必须满足的 gate | 不等于当前已允许读取真实账户或创建 listenKey |
| `forbidden live capability baseline` | MTP-126 固定本 Project 期间必须持续禁止的 live capability 清单 | 不得写成 partially supported、preview enabled、behind flag available 或 local fallback |

## MTP-126 Target engine / layer boundary

`MTP-126-TARGET-ENGINE-LAYER-BOUNDARY`

MTP-126 只定义以下 target engines / layers 的边界语言，不新增实现：

| Target Engine / Layer | L3.0 允许定义 | L3.0 明确禁止 |
| --- | --- | --- |
| Connectivity / Adapter Engine | public market data allowed、future private read-only gate、forbidden write capability baseline | 不实现 credential provider、signed request、account endpoint、listenKey、broker adapter、exchange execution adapter 或 `LiveExecutionAdapter` |
| Data Engine / future private stream boundary | private stream / account snapshot 只能作为后续 simulation gate input material | 不创建 private WebSocket、不创建 listenKey、不运行 account snapshot runtime、不运行 production stream |
| Evidence Read Model Layer | 只定义后续 read-model-only evidence 的 source boundary 和 validation anchors | 不新增 account / position / balance read model，不读取 real account，不同步 broker position |
| Workbench Interface / Live Readiness surface | 只定义 Workbench 后续只能展示 read-model-only boundary evidence | 不新增 API key 输入、broker connect、order form、Live PRO Console、trading button 或 live command |
| Docs / Validation / Automation readiness layer | 记录 contract、domain terms、validation plan、matrix、latest summary 和 automation readiness anchors | 不运行 Graphify、不修改 Figma、不创建 Stage Code Audit Report、不修改 Linear status |

## MTP-126 L3.0 / L3.1 / L3.2 / L3.3 handoff boundary

`MTP-126-L30-L31-L32-L33-HANDOFF`

MTP-126 固定 L3.0 的 handoff 规则：

1. `L3.0 Live Read-only Readiness Boundary` 只定义 terminology、target engines、future gates、forbidden baseline 和 validation anchors。
2. `L3.1 Account / Position / Balance Read-model-only` 后续才允许定义 account / position / balance read-model-only future gates；MTP-126 不实现 read model、ViewModel、fixture 或 runtime。
3. `L3.2 Private Stream / Account Snapshot Simulation Gate` 后续才允许定义 private stream / account snapshot simulation gate input material；MTP-126 不创建 listenKey、不连接 private WebSocket、不运行 account snapshot runtime。
4. `L3.3 Live Monitoring Read-only Console v2` 后续才允许规划 upgraded monitoring read-only evidence surface；MTP-126 不实现 Live Monitoring v2、不改 Dashboard、不新增 Workbench surface。
5. `L4 Live Production / Trading Commands` 保持 Future Gated；MTP-126 不授权 real execution、OMS、broker fill、reconciliation、live risk runtime、ops / incident / stop 或 Live PRO Console。

L3.0 完成后不得自动推进 MTP-127。MTP-127 至 MTP-132 仍必须分别等待 Parent Codex queue preflight 在 WIP=1、依赖满足、无 active conflict、execution contract 完整时判断。

## MTP-126 forbidden capability baseline

`MTP-126-FORBIDDEN-CAPABILITY-BASELINE`

MTP-126 必须保持以下 forbidden capabilities：

- API key / secret storage implementation
- local secret read
- signed endpoint
- account endpoint
- listenKey user data stream
- private WebSocket runtime
- account snapshot runtime
- broker integration
- broker execution adapter
- exchange execution adapter
- `LiveExecutionAdapter`
- OMS
- real order lifecycle
- real submit / cancel / replace
- execution report
- broker fill
- reconciliation
- real account / broker position / margin / leverage runtime
- account / position / balance read model implementation
- Live Monitoring Console v2 implementation
- Live PRO Console
- trading button
- live command
- order form
- emergency stop / shutdown / restore executable action
- Graphify update
- Figma change

这些能力只能作为 forbidden / Future Gated boundary 出现，不能写成当前支持、beta preview、local fallback、behind flag、partially implemented 或后续 issue 自动授权。

## MTP-126 first executable candidate non-authorization

`MTP-126-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`

Project Planning Record 中的 first executable issue candidate 只是候选，不构成执行授权。MTP-126 只有在 Linear live-read 中经 Parent Codex queue preflight 和 symphony-issue 调度后，作为唯一 active configured executable issue 时才可以执行。

该事实不改变以下规则：

- `docs/product/mtpro-live-readiness-roadmap-v1.md` 不授权 execution。
- `docs/planning/projects/mtpro-live-read-only-readiness-boundary-v1-plan.md` 不授权 execution。
- Backlog issue、label、priority、assignee 或 estimate 不授权 execution。
- MTP-126 完成后不得自动推进 MTP-127。
- MTP-127 至 MTP-132 必须继续保持 Backlog / non-executable，直到各自成为 live-read 中唯一 eligible issue。

## MTP-126 validation anchors

`MTP-126-LIVE-READ-ONLY-READINESS-VALIDATION`

Required validation：

- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

Focused validation anchors：

- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 MTP-126 terminology、target engine / layer boundary、L3.0 / L3.1 / L3.2 / L3.3 handoff、forbidden capability baseline、first executable candidate non-authorization 和 validation anchors。
- `docs/domain/context.md` 必须包含 Live read-only readiness terms 和 MTP-126 anchors。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-LIVE-READ-ONLY-READINESS` 和 MTP-126 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-126 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-126 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Read-only Readiness contract anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-126 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、planning record 和 forbidden capability boundary strings。

MTP-126 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard smoke handle、不新增 App read model、不新增 Core / Runtime / Dashboard behavior、不新增 stage audit input；Project stage closeout 仍归属 MTP-132。
