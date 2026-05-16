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
- 当前唯一 configured executable issue 是 Linear 中的 `MTP-8`；执行前仍必须确认 WIP=1、scope、validation 和 evidence。
- symphony-project 负责 Project 队列和 `Backlog` -> `Todo`；Codex 不修改 Linear status。
- symphony-issue 尚未启动；未获明确授权前，Agent 不得启动 symphony-issue。
- GitHub PR Automation 负责 required checks、auto-merge、squash merge、branch cleanup 和 Linear bot auto Done。
- `.codex/*` 不进入 PR。
- `graphify-out/*` 不进入 PR。

## 当前可做

- 执行当前唯一 configured executable issue 的明确 scope。
- 维护项目定义文档、contract-first 文档和 SwiftPM skeleton。
- 运行本地验证：`bash checks/run.sh`。
- 创建 ready-for-review PR，并交给 GitHub PR Automation。

## 当前禁止

- 不执行非当前 Linear issue scope 的前端页面、Binance adapter、backtest engine、paper execution 或 database adapter。
- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不启动 Symphony。
- 不运行 Graphify update。
- 不实现 LiveExecutionAdapter。
- 不调用 Binance signed endpoint。

## AEP v2 职责地图

| 阶段 | Agent 边界 |
| --- | --- |
| Human Project Planning | 只读项目目标、Roadmap 和 Linear 规划结果，不替代 Human 决策 |
| symphony-project | 只读取当前 Project 队列；不执行 issue，不调度 Codex，不处理 PR |
| symphony-issue | 未启动前不得自行运行；启动后只执行唯一 `Todo` issue |
| GitHub PR Automation | 创建 PR 后交给 GitHub checks / auto-merge；Codex 不直接 merge |
| Next Human Project Planning | 当前 Project 全部 Done 前不得建议或创建下一 Project |

## 参考项目边界

`macos-trader` 只作为产品语义和测试经验参考。

`nautilus_trader` 只作为 Kernel / MessageBus / Cache / Engine / Adapter 架构思想参考。

Agent 不得复制两个参考项目的整仓代码。
