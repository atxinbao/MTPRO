# MTPRO Linear 草案

日期：2026-05-18

执行者：Codex

状态：已写入 Linear；保留为规划证据。

本文档最初是 MTPRO 的 Linear 规划草案。用户确认后，已按本文档创建 Linear Project、里程碑和 issues。后续以 Linear、PR evidence 和 `verification.md` 作为执行事实源。

本文档不授权 Codex 执行，不授权 symphony-issue，不授权 Graphify update，不授权 Binance、策略、UI 或数据库适配器实现。

## 来源

- 仓库：`/Users/mac/Documents/MTPRO`
- `GOAL.md`
- `ARCHITECTURE.md`
- `ROADMAP.md`
- AI Engineering Protocol：`/Users/mac/code/ai-engineering-protocol`

## 目标 Linear 团队

- 团队名称：Macostrader Pro
- 团队标识：MTP
- 团队 ID：MTP
- Linear 返回显示名称：Macostrader Pro

## 工作流状态映射

| 协议状态 | Linear 状态 | 说明 |
| --- | --- | --- |
| configured executable issue | `Todo` | 运行时从 Linear 查询，不在文档中固定具体 issue |
| in progress | `In Progress` | 由 symphony-issue 推进 |
| review | `In Review` | PR handoff 后由 symphony-issue 推进 |
| done | `Done` | PR merge 后由 Linear bot 或证据修正 |
| canceled | `Canceled` | 不可执行 |

## 流程边界

- Linear 已成为执行事实源。
- 当前执行门槛是同一 Project 中唯一 configured executable issue。
- 已写入 Linear 的 issue 内容是 Codex Execution Agent 的执行合同。
- 子 Codex 按 Linear issue 模板字段执行，不二次确认 issue scope，不重新定义边界。
- Human 确认 Project / Issue plan 并写入 Linear 后，Parent Codex 负责把 eligible issue 自动推进为唯一 `Todo`。
- symphony-issue 只能调度唯一 `Todo` issue。
- Codex Execution Agent 只创建 PR 和 auto-merge handoff，不直接 merge PR。
- GitHub PR Automation 负责 required checks、squash auto-merge、branch cleanup 和 Linear bot auto Done。
- Graphify 默认是 resource relationship graph，不是 source code graph。
- `ROADMAP.md` 不授权执行。

## AEP v2 流程映射

| AEP 阶段 | MTPRO 映射 |
| --- | --- |
| Project Planning Facilitator / Human Project Planning | Human 确认阶段目标；Planning Facilitator 整理 Project / Issue 草案、顺序、依赖、validation、evidence 和 first executable candidate |
| Parent Codex Automation Supervision | queue preview、child Codex 监控、代码审查、host-side fallback、stage audit |
| symphony-issue | 唯一 `Todo` issue 的执行调度 |
| GitHub PR Automation | checks、auto-merge、squash merge、branch cleanup、Linear bot auto Done |
| Next Human Project Planning | 当前 Project 全部 Done 后的新阶段规划 |

## 三角色职责边界

| 角色 | 负责 | 不负责 |
| --- | --- | --- |
| Project Planning Facilitator | 基于 Stage Code Audit、Human 目标和 AEP 模板整理 `MTPRO Runtime Research Workbench v1` 的 Project / Issue 草案；Human 授权后可写入 Linear Project / Issues | 不执行 issue，不操作 `Backlog` -> `Todo`，不启动 symphony-issue，不创建 PR |
| Parent Codex Automation Supervision | 在 Linear 写入后核对 Project / Issue 执行合同格式，做 queue preview，自动将唯一 eligible issue 从 `Backlog` 推进为 `Todo` | 不默认写业务代码，不创建新 Project / Issue，不决定下一阶段目标，不直接 merge PR |
| Child Codex Execution Agent | 被 symphony-issue 调度后，只执行当前唯一 Linear issue scope，运行 validation，做 PR 前代码审查，创建 PR 和 auto-merge handoff | 不修改 Linear status，不操作 `Backlog` -> `Todo`，不决定下一 issue，不合并自己 PR |

Project Planning Facilitator 已完成本轮 Project / Issue 写入后，所有 `MTP-16` 至 `MTP-23` 必须初始保持 `Backlog`。进入 Parent Codex 后，父 Codex 按 queue preview、WIP=1、依赖、previous issue Done 和执行合同格式 Gate 自动推进唯一 eligible issue 进入 `Todo`。

## Linear Project

- 名称：MTPRO 引导
- 目标：完成项目定义、SwiftPM baseline、Core / Adapter / Persistence / App 契约、验证和自动化就绪。
- 当前执行事实源：Linear。
- 阶段审计：`docs/audit/mtpro-guidance-stage-code-audit.md`。

## 当前下一阶段 Project Planning Record

- 名称：`MTPRO Trading Validation and Parity Hardening`
- 记录文件：`docs/planning/mtpro-trading-validation-and-parity-hardening-plan.md`
- 来源审计：`docs/audit/mtpro-runtime-research-workbench-v1-stage-code-audit.md`
- 状态：写入 Linear 前的 Project Planning Record。
- First executable issue candidate：定义 Trading Validation Matrix 和验收证据边界。
- WIP=1：所有候选 issue 写入 Linear 后必须初始保持 `Backlog / non-executable`。

该记录只保存 Project 级计划摘要、issue 列表摘要、依赖、验证要求、证据要求、Linear 写入边界和仓库记录边界。

完整 issue execution contract 以 Linear 为准。仓库只保存 Project 级计划摘要和格式门槛，不复制维护完整 issue 正文。

本文档和 Project Planning Record 不授权执行，不创建 Linear Project / Issues，不修改 Linear status，不启动 symphony-issue，不推进任何 issue 到 `Todo`。

## 下一阶段 Linear Project

- 名称：`MTPRO Runtime Research Workbench v1`
- 状态：已写入 Linear，Project status 为 `Planned`。
- Issue range：`MTP-16` 到 `MTP-23`。
- Current Todo：从 Linear 实时读取。
- Next eligible candidate：由 Parent Codex queue preview 从 Linear 实时判断；`MTP-16` 已完成后，应优先检查 `MTP-17`。
- 格式 Gate：Linear Project / Issue 正文必须在第一个 `Todo` 前统一为 Codex Execution Agent 执行合同格式，并由父 Codex 做只读核对。

该 Project 目标是把 `MTPRO 引导` 阶段形成的契约优先基线推进为阶段性研究工作台闭环：核心领域边界、追加式事件日志、投影适配器、只读行情入口、ingest / replay / projection 串联、macOS 看板壳和“研究 -> 回测 -> 报告”最小路径。

该 Project 不授权 Live trading，不实现 `LiveExecutionAdapter`，不接 signed endpoint，不做真实 broker action，不把数据库 schema 暴露给 UI。

### 下一阶段 issue 顺序

| 顺序 | Linear issue | 目标 |
| --- | --- | --- |
| 1 | `MTP-16` | 按领域边界拆分 `Core.swift`，不改变行为 |
| 2 | `MTP-17` | 新增追加式事件日志文件持久化和重放冒烟测试 |
| 3 | `MTP-18` | 新增 SQLite 运行时投影适配器最小闭环 |
| 4 | `MTP-19` | 新增 DuckDB 分析投影适配器最小闭环 |
| 5 | `MTP-20` | 新增 Binance 公开只读行情客户端边界 |
| 6 | `MTP-21` | 串联行情 ingest -> event log -> replay -> projection snapshots |
| 7 | `MTP-22` | 新增绑定视图模型快照的 macOS 看板壳 |
| 8 | `MTP-23` | 新增“研究 -> 回测 -> 报告”最小路径和阶段证据就绪 |

### 下一阶段依赖

- `MTP-17` blocked by `MTP-16`。
- `MTP-18` blocked by `MTP-17`。
- `MTP-19` blocked by `MTP-17`。
- `MTP-20` blocked by `MTP-16`。
- `MTP-21` blocked by `MTP-17`, `MTP-18`, `MTP-19`, `MTP-20`。
- `MTP-22` blocked by `MTP-18`, `MTP-19`, `MTP-21`。
- `MTP-23` blocked by `MTP-21`, `MTP-22`。

### Project / Issue 格式统一 Gate

Linear 写入后、任何 issue 进入 `Todo` 前，必须先统一 Project / Issue 描述格式。

Project description 必须包含：

- `Goal`
- `Scope`
- `Non-goals`
- `Issue Order`
- `Dependencies`
- `Validation Requirements`
- `Evidence Requirements`
- `WIP=1`
- `Current State`

`MTP-16` 到 `MTP-23` 的 Linear issue 正文统一使用以下字段：

- `Goal`
- `Scope`
- `Non-goals`
- `Codex Instructions`
- `Validation`
- `Boundary`
- `PR Requirements`
- `Dependencies`
- `Initial Linear State`

每个 issue 固定包含：

- `This issue is executable only when Parent Codex queue preflight passes and it is the unique eligible Todo candidate.`
- `Run bash checks/run.sh.`
- `Do not submit .codex/*.`
- `Do not submit graphify-out/*.`
- `Run Pre-PR Codex Code Review.`
- `Use GitHub PR Automation.`
- `If executed by symphony-issue, provide handoff marker evidence.`

涉及生产代码的 issue 要求 touched production code 必须包含详细中文注释。涉及交易、Binance、persistence 或 report 的 issue 要求不触碰 Live trading、signed endpoint、broker action 或真实订单行为。

格式统一只保证 Linear issue 可作为 Codex Execution Agent 的执行合同，不授权执行，不修改 Linear status，不启动 symphony-issue。

## Todo 激活规则

`MTP-16` 是本 Project 的第一个可执行候选，现已完成。后续 `Todo` 由父 Codex 按 Linear 实时状态、依赖和 queue preflight 自动判断。

进入 `Todo` 的顺序必须是：

```text
Project / Issue 格式统一
-> 父 Codex queue preview
-> 父 Codex 确认 WIP=1 / dependencies / previous issue Done / execution contract
-> 父 Codex 自动执行 eligible Backlog -> Todo
-> symphony-issue 调度唯一 Todo
```

只有父 Codex 可以操作 `Backlog` -> `Todo`。该操作不需要每个 issue 再等待 Human 授权，但必须发生在 Human-approved Project / Issue plan 内，并通过 queue preflight。

Human Planning Facilitator、child Codex、symphony-issue、GitHub PR Automation、Post-Issue Ledger 都不得操作第一个或后续 issue 的 `Backlog` -> `Todo`。

## 里程碑和 issues

| 顺序 | Linear issue | 目标 |
| --- | --- | --- |
| 0 | `MTP-7` 记录引导基线 | 记录项目定义和 SwiftPM baseline |
| 1 | `MTP-8` 核心领域模型与事件日志契约 | 建立 Core 领域模型、事件、命令、查询和 event log contract |
| 2 | `MTP-9` Binance 公开只读行情适配器契约 | 建立 public read-only market data adapter contract 和 fixture decoder |
| 3 | `MTP-10` 交易内核、数据引擎与缓存边界 | 建立 actor kernel、MessageBus、DataEngine、Cache |
| 4 | `MTP-11` EMA 回测与 Paper 一致性契约 | 建立 EMA strategy、backtest / paper event flow 和 parity contract |
| 5 | `MTP-12` 订单簿失衡策略研究链路 | 建立 order book imbalance research contract |
| 6 | `MTP-13` SQLite / DuckDB 投影与重放边界 | 建立 replay、runtime projection 和 analytical projection |
| 7 | `MTP-14` Trader Workstation 看板 ViewModel 契约 | 建立 Dashboard read model 和 ViewModel contract |
| 8 | `MTP-15` 验证加固与自动化就绪 | 固化 validation matrix、PR evidence、WIP=1、Graphify 和 automation readiness |

## 当前使用方式

- 本文档只作为已写入 Linear 的 planning evidence。
- 当前 issue 状态必须从 Linear 查询。
- 历史执行记录见 `verification.md`。
- Project 完成后的阶段质量判断见 `docs/audit/mtpro-guidance-stage-code-audit.md`。
