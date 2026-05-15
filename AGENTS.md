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
- MTPRO 不创建单独的 test-mode onboarding Project / Issues。
- 当前唯一 configured executable issue 是 Linear 中的 `MTP-8`；执行前仍必须确认 WIP=1、scope、validation 和 evidence。
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

## 参考项目边界

`macos-trader` 只作为产品语义和测试经验参考。

`nautilus_trader` 只作为 Kernel / MessageBus / Cache / Engine / Adapter 架构思想参考。

Agent 不得复制两个参考项目的整仓代码。
