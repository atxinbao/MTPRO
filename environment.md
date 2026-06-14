# environment.md

本文档是运行 / 验证 / 外部系统边界文档。它是根目录高权重承接文档，只定义当前本地环境、验证入口和外部系统使用禁区，不定义产品目标、工程模块或施工路线。

本文档不能推翻 `BLUEPRINT.md`，也不授权 Linear Project / Issue、`Todo` 推进、额外调度服务启动或业务代码修改。

## Environment Responsibility / 环境职责

`environment.md` 只回答三个问题：

1. 当前本地开发和验证需要什么环境。
2. 哪些验证命令是必跑门槛，哪些只是可选人工证据。
3. 外部系统可以用到什么程度，哪些能力在当前 scope 内禁止。

它不回答“最终产品做成什么样”，也不回答“下一阶段做什么”。这些分别由 `BLUEPRINT.md` 和 `docs/roadmap.md` 承担。

## Baseline Runtime / 基线运行环境

- macOS：14+
- Swift：6+
- 构建系统：SwiftPM-first
- UI：SwiftUI
- 并发：Swift actor / AsyncSequence
- 网络：URLSession / URLSessionWebSocketTask
- 本地事实源：append-only Event Log
- 本地投影：SQLite runtime projection、DuckDB analytical projection
- 默认运行形态：local-first macOS workstation，不依赖云端服务

## Required Validation / 必跑验证

```bash
bash checks/run.sh
```

`checks/run.sh` 串联：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- macOS 本地：`swift build --product Dashboard`
- macOS 本地：`DASHBOARD_SMOKE=1 swift run Dashboard`
- Linux CI：跳过 macOS-only SwiftUI shell build / smoke，并继续运行 SwiftPM tests
- `swift test`

任何 PR 在进入 GitHub PR Automation 前，都必须能说明 `bash checks/run.sh` 的结果。若某项无法执行，必须在 PR evidence 或验证摘要中明确记录原因、风险和替代证据。

## Optional Evidence / 可选证据

以下证据可以在明确任务需要时补充，但不能替代必跑验证：

- GitHub Actions required check `checks`。
- macOS 本地手动 smoke run。
- Linear live-read queue preview。
- Binance public market data 人工 smoke。该项只能是可选人工证据，不能成为自动验证前置条件。

## Platform Boundary / 平台边界

| 平台 | 当前用途 | 边界 |
| --- | --- | --- |
| macOS 本地 | SwiftPM build、SwiftUI Dashboard build / smoke、Swift tests | 当前最完整验证入口 |
| GitHub Ubuntu runner | required check、SwiftPM tests、文档 / readiness 检查 | 不要求构建 macOS-only SwiftUI shell |
| Binance public network | 可选人工 smoke | 不进入 required validation，不需要 API key |
| 云端部署 / production runtime | 当前不使用 | 属于 Future Construction Zones / 未来建设区 |

## External System Capability Matrix / 外部系统能力矩阵

允许在明确授权任务中使用：

- GitHub PR Automation。
- Linear 只读查询。
- Human 授权后的 Linear issue 状态推进。
- Parent Codex queue preflight 和 Project supervision。
- Post-Issue Ledger 本地只读摘要。

默认禁止：

- Binance signed endpoint。
- API key。
- account endpoint。
- order submit / cancel / replace。
- listenKey user data stream。
- LiveExecutionAdapter。
- 未经 Human 授权创建 Linear Project / Issue。
- 启动 Symphony、Graphify 或任何替代调度 / 图谱服务。
- 提交 `.codex/*`。

## Secrets / Local State Boundary

- 当前 required validation 不需要 Binance API key。
- 当前 required validation 不需要 broker credential。
- 若任务需要检查本地 secret 配置，只能报告路径、存在性和脱敏状态，不能打印 secret。
- `.codex/*` 和本地编辑器目录不得进入 PR。
- MTPRO 不再维护 Symphony active Project pointer 或 Graphify resource graph 作为本地运行状态。

历史 readiness evidence 的环境含义：

| 阶段 | 只证明 | 不授权 |
| --- | --- | --- |
| `MTPRO Workbench Beta Readiness v1` | SwiftPM local build、Dashboard smoke、deterministic demo scenario、本地 operator acceptance 可复现 | production release、notarization、auto-update、production operations、signed endpoint、broker adapter、OMS、real order lifecycle、Live PRO Console、trading button、live command |
| `MTPRO Live Read-only Readiness Boundary v1` | L3.0 terminology、credential / secret policy、endpoint taxonomy、adapter capability matrix、future gates、read-model-only boundary | required validation 需要 secret、真实 Live read-only runtime、account endpoint / listenKey、private WebSocket runtime、real account read、broker position sync、broker adapter、`LiveExecutionAdapter`、OMS |
| `MTPRO Account / Position / Balance Read-model-only v1` | L3.1 account / position / balance terminology、snapshot identity、freshness evidence、deterministic fixture、forbidden real account tests、read-model-only surface | account / position / balance runtime、real account read、broker position sync、real balance、margin、leverage、real PnL runtime、signed endpoint、listenKey、trading command |
| `MTPRO Private Stream / Account Snapshot Simulation Gate v1` | L3.2 simulated private event source identity、simulated account snapshot input、fresh / stale / blocked / missing evidence、forbidden endpoint tests | private stream runtime、account snapshot runtime、Live read-only runtime、signed endpoint、account endpoint / listenKey、private WebSocket runtime、broker adapter、OMS、Live PRO Console、trading button |

## Automation Boundary / 自动化边界

- `@001 / PLN` 负责 Human Project Planning，不推进 `Backlog -> Todo`。
- `@002 / PAR` 只在 Project 已写入 Linear 后执行 startup gate、queue preflight 和 Project supervision。
- Codex Execution Agent 只执行 Parent Codex queue preflight 推进后的唯一 `Todo` issue。
- Stage Code Audit Report 必须在 Project 全部 Done 后由 Parent Codex 单独输出并落仓。
- Root Docs Refresh Gate 只同步已发生事实，不授权下一阶段 execution。
