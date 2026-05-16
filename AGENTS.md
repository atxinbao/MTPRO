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

## 核心硬规则

- 所有正式文档写入必须使用中文。
- `ROADMAP.md` 不授权执行。
- Linear Draft Plan 不授权执行。
- 只有 Linear 中唯一 configured executable issue 才能授权正式开发执行。
- 当前唯一 configured executable issue 不写死在仓库文档中；执行前必须从 Linear / Parent Codex queue preview 读取，并确认 WIP=1、scope、validation 和 evidence。
- Parent Codex Automation Supervision 负责 Project 级 queue preview、child Codex 监控、代码审查、host-side fallback 和流程迭代建议。
- 父 Codex 只有在 Human 明确授权后，才可将 eligible `Backlog` issue 推进为唯一 `Todo`。
- symphony-issue 负责唯一 `Todo` issue 的执行调度、`Todo` -> `In Progress` 和 `In Progress` -> `In Review` 状态推进。
- GitHub PR Automation 负责 required checks、auto-merge、squash merge、branch cleanup 和 Linear bot auto Done。
- `.codex/*` 不进入 PR。
- `graphify-out/*` 不进入 PR。
- symphony-issue 调度 Codex 时使用 `dangerFullAccess` issue automation profile，允许 Codex 在当前 issue workspace 内更新当前 issue scope、完成 git commit / push、ready-for-review PR、GitHub auto-merge handoff 和本地 handoff marker；GitHub token、网络或 MCP elicitation 阻塞时由 host-side handoff fallback 接管。

## 当前可做

- 执行当前唯一 configured executable issue 的明确 scope。
- 维护项目定义文档、contract-first 文档和 SwiftPM skeleton。
- 运行本地验证：`bash checks/run.sh`。
- Post-Issue Ledger / 施工后记账由 symphony-issue host-side `before_remove` 在 PR merge / Linear bot Done 后执行：同步持久本地仓库、刷新 Graphify resource relationship graph，并写入本地结构化摘要 `.codex/post-issue-ledger/latest.json`；如果环境不可用，必须记录原因且不提交 `graphify-out/*`。
- 下一步观察提示不授权执行，不得自动推进下一个 issue，不得创建 Linear issue，不得修改 `ROADMAP.md`。
- 父 Codex 可读取 `.codex/post-issue-ledger/latest.json` 的只读下一步观察提示并向 Human 汇报，但不得把它当作执行授权。
- 执行 Pre-PR Codex Code Review。
- 创建 ready-for-review PR，并启用 GitHub auto-merge handoff。

## 当前禁止

- 不执行非当前 Linear issue scope 的前端页面、Binance adapter、backtest engine、paper execution 或 database adapter。
- 不创建 Linear Project / Issue。
- 不修改 Linear status，除非 Human 明确授权父 Codex 将 eligible `Backlog` issue 推进为唯一 `Todo`。
- 不自行启动 Symphony；`symphony-issue` 只能由明确授权的本地自动化任务启动。
- 不运行 Graphify full rebuild。
- 不提交 `graphify-out/*`。
- 不实现 LiveExecutionAdapter。
- 不调用 Binance signed endpoint。

## AEP v2 职责地图

| 阶段 | Agent 边界 |
| --- | --- |
| Human Project Planning | 只读项目目标、Roadmap 和 Linear 规划结果，不替代 Human 决策 |
| Parent Codex Automation Supervision | Project 级 queue preview、child Codex 监控、代码审查、host-side fallback 和流程迭代建议；不替代 Human 决策，不直接 merge PR |
| symphony-issue | 只调度唯一 `Todo` issue；负责 `Todo` -> `In Progress`、Codex 执行调度、校验 handoff marker 后 `In Progress` -> `In Review` |
| GitHub PR Automation | 创建 PR 后交给 GitHub checks / auto-merge；Codex 不直接 merge |
| Next Human Project Planning | 当前 Project 全部 Done 前不得建议或创建下一 Project |

Parent Codex 监督边界详见 `docs/automation/parent-codex-supervision.md`。

## Codex Execution Agent 流程

被 symphony-issue 调度后，Codex Execution Agent 分三段执行：

1. 执行前：读取 root docs、当前 Linear issue、相关 contracts、validation 和 Graphify read context，锁定 scope / non-goals / allowed files / forbidden files。
2. 执行中：只完成当前 issue scope 内的代码、文档、测试或验证任务。
3. 执行后：运行 validation，更新 evidence chain，执行 Pre-PR Codex Code Review，创建 commit，创建 ready-for-review PR，启用 GitHub auto-merge handoff，并写入本地 `.codex/symphony-issue-handoff.json`。PR merge / Linear bot Done 后，Post-Issue Ledger / 施工后记账由 symphony-issue `before_remove` 处理。

Codex Execution Agent 不修改 Linear status；`In Progress` -> `In Review` 由 symphony-issue 在 PR 和 handoff evidence 就绪后推进。

如果 child Codex 被 GitHub token、网络或 MCP elicitation 阻塞，symphony-issue host-side handoff fallback 只接管 commit / push / PR / auto-merge handoff / 本地 marker，并在 PR evidence 中记录原因。fallback 不得扩大 diff scope，不得修改 Linear status，不得提交 `.codex/*`。

如果 child Codex 暴露流程缺口，父 Codex 可以在当前 issue scope 内修复自动化文档、PR evidence 或 handoff 规则，并把可复用结论追加到 automation docs。父 Codex 不得借此扩大业务实现范围。

## 参考项目边界

`macos-trader` 只作为产品语义和测试经验参考。

`nautilus_trader` 只作为 Kernel / MessageBus / Cache / Engine / Adapter 架构思想参考。

Agent 不得复制两个参考项目的整仓代码。
