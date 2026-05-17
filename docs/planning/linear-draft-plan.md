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
- Parent Codex 只有在 Human 明确授权后，才可把 eligible issue 推进为唯一 `Todo`。
- symphony-issue 只能调度唯一 `Todo` issue。
- Codex Execution Agent 只创建 PR 和 auto-merge handoff，不直接 merge PR。
- GitHub PR Automation 负责 required checks、squash auto-merge、branch cleanup 和 Linear bot auto Done。
- Graphify 默认是 resource relationship graph，不是 source code graph。
- `ROADMAP.md` 不授权执行。

## AEP v2 流程映射

| AEP 阶段 | MTPRO 映射 |
| --- | --- |
| Human Project Planning | Human 确认 Linear Project、阶段目标和 issue 顺序 |
| Parent Codex Automation Supervision | queue preview、child Codex 监控、代码审查、host-side fallback、stage audit |
| symphony-issue | 唯一 `Todo` issue 的执行调度 |
| GitHub PR Automation | checks、auto-merge、squash merge、branch cleanup、Linear bot auto Done |
| Next Human Project Planning | 当前 Project 全部 Done 后的新阶段规划 |

## Linear Project

- 名称：MTPRO 引导
- 目标：完成项目定义、SwiftPM baseline、Core / Adapter / Persistence / App 契约、验证和自动化就绪。
- 当前执行事实源：Linear。
- 阶段审计：`docs/audit/mtpro-guidance-stage-code-audit.md`。

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
