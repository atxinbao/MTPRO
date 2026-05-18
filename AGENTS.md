# AGENTS.md

本文件定义 MTPRO 仓库内 Agent / Codex 的行为边界。

## 必读顺序

Agent 开始工作前必须读取：

1. `README.md`
2. `ENVIRONMENT.md`
3. `GOAL.md`
4. `AGENTS.md`
5. `ARCHITECTURE.md`
6. `ROADMAP.md`
7. `docs/product/product-surface-map.md`
8. `docs/contracts/`
9. `docs/validation/validation-plan.md`
10. `docs/validation/latest-verification-summary.md`

## 核心硬规则

- 所有正式文档写入必须使用中文。
- `ROADMAP.md` 不授权执行。
- Linear Draft Plan 不授权执行。
- 只有 Linear 中唯一 configured executable issue 才能授权正式开发执行。
- 当前唯一 configured executable issue 不写死在仓库文档中；执行前必须从 Linear / Parent Codex queue preview 读取，并确认 WIP=1。
- Linear issue 中已填写的 Scope / Non-goals / Codex Instructions / Validation / Boundary / PR Requirements 是 Codex Execution Agent 的执行合同；子 Codex 按模板字段执行，不二次确认 issue scope，不重新定义边界。
- Project Planning Facilitator 只负责阶段规划、Linear Project / Issue 草案、Human review 后的 Linear 写入准备；不得执行 issue，不得启动 symphony-issue，不得操作 `Backlog` -> `Todo`。
- Parent Codex Automation Supervision 负责 Project 级 queue preview、eligible issue 自动调度、child Codex 监控、代码审查、host-side fallback 和流程迭代建议。
- 父 Codex 必须在第一个 `Todo` 前核对 Linear Project / Issue 执行合同格式。
- Human 确认 Project / Issue plan 并写入 Linear 后，第一个 issue 和后续 issue 的 `Backlog` -> `Todo` 操作都只能由父 Codex 自动执行。
- 父 Codex 自动调度前必须确认 WIP=1、previous issue Done、依赖满足、执行合同格式完整，并且当前 Project 没有 `Todo` / `In Progress` / `In Review` active conflict。
- Project 全部 Done 后，Parent Codex 必须把 Project 级 Stage Code Audit Report 落到 `docs/audit/<linear-project-slug>-stage-code-audit.md`，才能进入 Next Human Project Planning。
- Stage Code Audit Report 必须覆盖完整 Linear Project，不得只覆盖单个 issue。
- Stage Code Audit Report 必须包含 Root Docs Delta，检查 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md`、`ROADMAP.md` 是否与已完成 Project 的事实一致。
- Root Docs Refresh Gate 只允许 `@002 / PAR` 同步已发生事实；方向、目标、架构路线和下一阶段优先级必须交给 Human + `@001 / PLN` 决定。
- 父 Codex 负责 Project 切换时更新 `symphony-issue` active Project pointer；workflow 本体不得为每个 Project 复制一套。
- 父 Codex 更新 active Project pointer 后必须先做 queue preview，不得直接启动 `symphony-issue`，不得直接操作 `Backlog` -> `Todo`。
- symphony-issue 负责唯一 `Todo` issue 的执行调度、`Todo` -> `In Progress` 和 `In Progress` -> `In Review` 状态推进。
- GitHub PR Automation 负责 required checks、auto-merge、squash merge、branch cleanup 和 Linear bot auto Done。
- `.codex/*` 不进入 PR。
- `graphify-out/*` 不进入 PR。
- symphony-issue 调度 Codex 时使用 `dangerFullAccess` issue automation profile，允许 Codex 在当前 issue workspace 内更新当前 issue scope、完成 git commit / push、ready-for-review PR、GitHub auto-merge handoff 和本地 handoff marker；GitHub token、网络或 MCP elicitation 阻塞时由 host-side handoff fallback 接管。
- 新增或修改 production code 必须添加详细中文注释，说明业务目的、输入输出、领域不变量、外部系统边界和禁止触碰的交易能力；禁止用空泛注释逐行复述代码。
- Codex use-cases 对齐规则见 `docs/automation/codex-use-cases-alignment.md`；verified operations 记录格式见 `docs/automation/verified-operations.md`。
- Agent 默认读取 `docs/validation/latest-verification-summary.md`；完整 `verification.md` 只在审计、追溯或 debug 时读取。

## Role Alias Rule

MTPRO 采用 AEP 三位数字编号和三字母角色代号。数字编号与三字母代号等价，例如 `@001 = PLN`。

角色编号只用于沟通压缩，不改变职责边界，不授权执行，不替代 Linear issue、Project planning、GitHub required checks 或 Human decision。

| 编号 | 代号 | 角色 | MTPRO 职责摘要 |
| --- | --- | --- | --- |
| `001` | `PLN` | Project Planning Lead | 新阶段规划、Next Human Project Planning、Project / Issue 草案 |
| `002` | `PAR` | Parent Codex Automation Supervision | Project queue、eligible issue 调度、child Codex 监督、Stage Code Audit |
| `003` | `SYM` | symphony-issue | 唯一 issue 调度、`Todo` -> `In Progress`、`In Progress` -> `In Review` |
| `004` | `COD` | Codex Execution Agent | 当前 issue scope 内实现、验证、Pre-PR Code Review、PR handoff |
| `005` | `GHA` | GitHub PR Automation | required checks、auto-merge、squash merge、branch cleanup、Linear bot auto Done |
| `006` | `QAV` | QA / Validation | 验证、失败归因、验收证据、交易验证和回归边界 |
| `007` | `OPS` | Operations | 本地环境、运行、部署、Graphify / Symphony / GitHub 自动化可用性 |

Agent 收到 `给 @001 下 Codex 指令` 或 `@001：<任务>` 时，必须按 `PLN` 职责解析。其他编号同理。

## @002 Startup Runbook

当 Human 指令要求 `@002 / PAR` 接管一个已写入 Linear 的 Project 时，父 Codex 必须把启动、执行前检查、active Project pointer 更新、二次 queue preview 和首个 eligible issue 推进合并为一个连续动作。

标准顺序：

1. 读取 Project Planning Record 和 Linear Project / Issues。
2. 执行 Project / Issue 格式 Gate。
3. 执行 queue preview，确认 WIP=1、无 active conflict、依赖满足、first executable issue candidate 唯一。
4. 更新 `symphony-issue` active Project pointer，只更新 Project name、Project ID、Project slug、issue range 和 next eligible candidate。
5. pointer 更新后再次执行 queue preview。
6. gate 全部通过后，自动推进唯一 eligible `Backlog` -> `Todo`。
7. gate 任一失败时停止并报告。

`@002 Startup Runbook` 不创建 Linear Project / Issue，不修改 issue body，不启动 `symphony-issue`，不写代码，不创建 PR，不运行 Graphify update。

## 当前可做

- 执行当前唯一 configured executable issue 的明确 scope。
- 维护项目定义文档、contract-first 文档和 SwiftPM baseline。
- 维护 `docs/planning/project-role-map.md`，用于记录系统架构、前端设计、后端开发、数据 / 持久化、质量验证、部署与运营等能力角色覆盖情况。
- 维护 Product / Design / Engineering / Finance / Operations / QA 的 team role map，尤其是 Finance / Trading Domain、Product / Design 分工、Runtime Operations 和 Trading validation。
- 运行本地验证：`bash checks/run.sh`。
- Post-Issue Ledger / 施工后记账由 symphony-issue host-side `before_remove` 在 PR merge / Linear bot Done 后执行：同步持久本地仓库、刷新 Graphify resource relationship graph，并写入本地结构化摘要 `.codex/post-issue-ledger/latest.json`；如果环境不可用，必须记录原因且不提交 `graphify-out/*`。
- 下一步观察提示不单独授权执行，不得绕过 Parent Codex queue preflight，不得创建 Linear issue，不得修改 `ROADMAP.md`。
- 父 Codex 可读取 `.codex/post-issue-ledger/latest.json` 的下一步观察提示，用于 queue preview 和自动调度判断；提示本身不创建新 Project / Issue，不绕过依赖或 WIP=1。
- 执行 Pre-PR Codex Code Review。
- 创建 ready-for-review PR，并启用 GitHub auto-merge handoff。
- 在涉及跨系统动作时，按 verified operation 记录 actor、授权来源、输入、输出、validation 和 evidence location。

## 当前禁止

- 不执行非当前 Linear issue scope 的前端页面、Binance adapter、backtest engine、paper execution 或 database adapter。
- 不创建 Linear Project / Issue。
- 不修改 Linear status，除非父 Codex 在 Human-approved Project 内将 eligible `Backlog` issue 推进为唯一 `Todo`，或 symphony-issue 按规则推进当前 issue 执行状态。
- 不自行启动 Symphony；`symphony-issue` 只能由明确授权的本地自动化任务启动。
- 不运行 Graphify full rebuild。
- 不提交 `graphify-out/*`。
- 不实现 LiveExecutionAdapter。
- 不调用 Binance signed endpoint。
- 不绕过 Finance / Trading Domain 边界；策略、risk、fees、slippage、Backtest / Paper parity 相关变更必须保留交易语义验证。

## AEP v2 职责地图

| 阶段 | Agent 边界 |
| --- | --- |
| Project Planning Facilitator / Human Project Planning | 形成阶段目标、Linear Project / Issue 草案、顺序、依赖、验证和证据要求；Human 授权后可写入 Linear，但所有 issue 必须保持 `Backlog` |
| Parent Codex Automation Supervision | Project 级 queue preview、eligible issue 自动调度、child Codex 监控、代码审查、host-side fallback 和流程迭代建议；不替代 Human 阶段规划，不直接 merge PR |
| symphony-issue | 只调度唯一 `Todo` issue；负责 `Todo` -> `In Progress`、Codex 执行调度、校验 handoff marker 后 `In Progress` -> `In Review` |
| GitHub PR Automation | 创建 PR 后交给 GitHub checks / auto-merge；Codex 不直接 merge |
| Next Human Project Planning | 当前 Project 全部 Done、Stage Code Audit Report 已落仓且 Root Docs Refresh Gate 已完成前不得建议或创建下一 Project |

## 三角色职责边界

| 角色 | MTPRO 当前职责 | 禁止 |
| --- | --- | --- |
| Project Planning Facilitator | 基于 Stage Code Audit 和 Human 目标整理 `MTPRO Runtime Research Workbench v1` 的 Project / Issue 草案、顺序、依赖、validation、evidence 和 first executable candidate | 不执行 issue，不操作 `Backlog` -> `Todo`，不启动 symphony-issue，不创建 PR |
| Parent Codex Automation Supervision | 核对 `MTP-16` 至 `MTP-23` 的执行合同格式，做 queue preview，自动操作唯一 eligible `Backlog` -> `Todo`，监督 child Codex 和阶段审计 | 不默认写业务代码，不创建新 Project / Issue，不决定下一阶段目标，不直接 merge PR |
| Child Codex Execution Agent | 只执行当前唯一 Linear issue scope，运行 validation，执行 Pre-PR Codex Code Review，创建 ready-for-review PR 和 GitHub auto-merge handoff | 不修改 Linear status，不操作 `Backlog` -> `Todo`，不决定下一 issue，不合并自己 PR |

Parent Codex 监督边界详见 `docs/automation/parent-codex-supervision.md`。

MTPRO `symphony-issue` workflow 模板和当前 active Project pointer 见 `docs/automation/symphony-issue-workflow-template.md`。

项目能力角色地图见 `docs/planning/project-role-map.md`。该文件按 Product / Design / Engineering / Finance / Operations / QA 维护 MTPRO 角色覆盖，只服务 Human Project Planning 和阶段复盘，不授权执行，不替代 Linear Project / Issue。

## Codex Execution Agent 流程

被 symphony-issue 调度后，Codex Execution Agent 分三段执行：

1. 执行前：读取 root docs、当前 Linear issue、相关 contracts、validation 和 Graphify read context；将当前 Linear issue 已填写的 Scope / Non-goals / Codex Instructions / Validation / Boundary / PR Requirements 作为执行合同。
2. 执行中：只完成当前 issue scope 内的代码、文档、测试或验证任务。
3. 执行后：运行 validation，更新 evidence chain，执行 Pre-PR Codex Code Review，创建 commit，创建 ready-for-review PR，启用 GitHub auto-merge handoff，并写入本地 `.codex/symphony-issue-handoff.json`。PR merge / Linear bot Done 后，Post-Issue Ledger / 施工后记账由 symphony-issue `before_remove` 处理。

Codex Execution Agent 不修改 Linear status；`In Progress` -> `In Review` 由 symphony-issue 在 PR 和 handoff evidence 就绪后推进。

如果 child Codex 被 GitHub token、网络或 MCP elicitation 阻塞，symphony-issue host-side handoff fallback 只接管 commit / push / PR / auto-merge handoff / 本地 marker，并在 PR evidence 中记录原因。fallback 不得扩大 diff scope，不得修改 Linear status，不得提交 `.codex/*`。

如果 child Codex 暴露流程缺口，父 Codex 可以在当前 issue scope 内修复自动化文档、PR evidence 或 handoff 规则，并把可复用结论追加到 automation docs。父 Codex 不得借此扩大业务实现范围。

## 代码中文注释规则

新增或修改 production code 时，Codex 必须补充详细中文注释。

必须注释：

- public type / protocol / actor / service 的职责。
- 关键函数的输入、输出和错误边界。
- 领域不变量，例如 paper-only、read-only market data、append-only event log。
- 外部系统边界，例如 Binance、SQLite、DuckDB、Graphify、Linear、GitHub。
- 任何禁止 Live trading、signed endpoint 或真实 broker action 的原因。

测试代码中的注释必须说明测试场景和验证目的。

禁止：

- 用英文替代中文说明。
- 写“处理数据”“执行逻辑”这类无信息量注释。
- 逐行复述代码。

## 参考项目边界

`macos-trader` 只作为产品语义和测试经验参考。

`nautilus_trader` 只作为 Kernel / MessageBus / Cache / Engine / Adapter 架构思想参考。

Agent 不得复制两个参考项目的整仓代码。
