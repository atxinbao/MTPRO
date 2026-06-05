# MTPRO Docs Index

日期：2026-05-27

执行者：Codex

## 定位

`MTP-124-DOCS-INDEX`

本文档是 MTPRO 仓库的文档入口，帮助 Human / operator 按正确顺序理解项目边界、local Workbench beta 启动路径、demo workflow、acceptance checklist 和 forbidden capabilities。

本文档不替代 Linear issue execution contract，不授权下一阶段执行，不创建 Linear Project / Issue，不修改 Linear status，不启动 Symphony，不运行 Graphify，不修改 Figma，不创建 production release，不授权 live readiness、Live PRO Console、signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、trading button 或 live command。

## 默认阅读顺序

| 顺序 | 文档 | 用途 |
| --- | --- | --- |
| 1 | `README.md` | 项目总览、当前边界和默认读取顺序 |
| 2 | `AGENTS.md` | Agent / Codex 工作边界、Linear execution contract 和 PR handoff 规则 |
| 3 | `GOAL.md` | Project Charter：为什么建、服务谁、永久硬边界和成功标准 |
| 4 | `BLUEPRINT.md` | canonical Root / Complete Blueprint，定义最终产品 / 系统 / 设计蓝图和 Future gates |
| 5 | `environment.md` | 本地环境、验证入口和外部系统禁区 |
| 6 | `architecture.md` | Engineering Module Map / 工程模块地图、依赖方向和 evidence data flow |
| 7 | `docs/roadmap.md` | Construction Plan、已完成阶段和下一轮 planning handoff |
| 8 | `docs/domain/context.md` | MTPRO shared language、domain terms 和 forbidden terms |
| 9 | `docs/validation/latest-verification-summary.md` | 最近验证摘要和当前边界轻量入口 |

完整 `verification.md` 只用于审计、追溯或 debug，不作为日常默认读取入口。

## Local Workbench Beta 入口

| 入口 | 文档 / 命令 | 使用场景 |
| --- | --- | --- |
| Operator guide | `docs/validation/workbench-beta-operator-guide.md` | Human / operator 按步骤完成 local Workbench beta 环境确认、启动、demo 和验收 |
| Demo workflow guide | `docs/validation/workbench-beta-demo-workflow-guide.md` | 理解 MTP-119 至 MTP-123 如何串成同一 deterministic demo evidence chain |
| Acceptance checklist | `docs/validation/workbench-beta-acceptance-checklist.md` | 查看 MTP-123 operator checklist、expected outputs、failure triage 和 boundary evidence |
| Acceptance script | `bash checks/workbench-beta-acceptance.sh` | 自动执行 local environment、Dashboard smoke 和 `bash checks/run.sh`，并写入 `.codex/beta-acceptance/<run-id>/` |
| Required validation | `bash checks/run.sh` | PR 前统一验证入口，串联 whitespace、automation readiness、Dashboard build / smoke 和 Swift tests |

## Workbench Beta Readiness 锚点

| Issue | 主要证据 | 说明 |
| --- | --- | --- |
| `MTP-118` | `docs/contracts/workbench-beta-readiness-contract.md` | Workbench beta readiness terminology、acceptance boundary 和 forbidden capability baseline |
| `MTP-119` | `docs/validation/macos-build-run-loop.md` | local launch / install / environment verification path |
| `MTP-120` | `Sources/Core/DashboardBetaDemoScenario.swift` | deterministic demo scenario、dataset / fixture version、checksum / freshness evidence |
| `MTP-121` | `Sources/App/DashboardBetaFirstRunState.swift` | first-run default demo state 和 fallback states |
| `MTP-122` | `Sources/App/DashboardBetaAcceptancePath.swift` | Report / Dashboard / Events beta acceptance path |
| `MTP-123` | `docs/validation/workbench-beta-acceptance-checklist.md`、`checks/workbench-beta-acceptance.sh` | reproducible beta acceptance checklist / script |
| `MTP-124` | `docs/index.md`、`docs/validation/workbench-beta-operator-guide.md`、`docs/validation/workbench-beta-demo-workflow-guide.md` | docs index、operator guide、demo workflow guide、known limitations、forbidden capabilities 和 troubleshooting pointers |

## Boundary Reading

`MTP-124-BETA-NOT-LIVE-READINESS`

Workbench beta readiness 只表示 local macOS Workbench demo / acceptance path 可被 operator 复现。它不表示 production release、notarization、App Store distribution、auto-update、production deployment、cloud operations、live readiness、Live PRO Console、真实账户准备、broker readiness 或真实交易授权。

需要判断 forbidden capabilities 时，优先读取：

- `docs/domain/context.md` 的 Forbidden Terms。
- `docs/contracts/workbench-beta-readiness-contract.md` 的 Workbench Beta Readiness forbidden capability anchors。
- `docs/validation/workbench-beta-operator-guide.md` 的 MTP-124 forbidden capability boundary。
- `docs/validation/workbench-beta-demo-workflow-guide.md` 的 demo workflow boundary。

## Troubleshooting Pointer

`MTP-124-TROUBLESHOOTING-POINTERS`

local Workbench beta 失败排查只沿以下路径收窄：

1. `uname -s` / `swift --version` / `swift package resolve`。
2. `swift build --product Dashboard`。
3. `DASHBOARD_SMOKE=1 swift run Dashboard`。
4. `bash checks/workbench-beta-acceptance.sh`。
5. `bash checks/run.sh`。

不得通过读取 secret、连接 signed endpoint / account endpoint / listenKey、接入 broker、实现 `LiveExecutionAdapter`、新增 OMS、启用 Live PRO Console、添加 trading button、运行 Graphify 或修改 Figma 来绕过 local beta failure。
