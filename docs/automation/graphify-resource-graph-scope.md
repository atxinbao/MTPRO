# MTPRO Graphify 资源关系图范围

日期：2026-05-18

执行者：Codex

## 目的

Graphify resource relationship graph 用于帮助 Agent 理解 MTPRO 的资源关系、合同边界、验证入口和自动化边界。

它不授权执行，不替代 Linear issue，不替代 PR evidence，不替代 `verification.md`。

## 图类型

```text
resource relationship graph
```

默认不是 source code graph。

## 默认纳入路径

- `README.md`
- `docs/environment.md`
- `GOAL.md`
- `AGENTS.md`
- `docs/architecture.md`
- `docs/roadmap.md`
- `.github/pull_request_template.md`
- `.github/workflows/checks.yml`
- `checks/`
- `docs/`
- `docs/validation/latest-verification-summary.md`

## 默认排除路径

- `Sources/`
- `Tests/`
- `.build/`
- `.swiftpm/`
- `.git/`
- `.codex/`
- `graphify-out/`
- 完整 `verification.md`

## 使用位置

- 执行前：作为 read context。
- PR merge / Linear bot Done 后：由 Post-Issue Ledger 做 scoped resource relationship graph refresh。

## 边界

- 不纳入完整源码目录。
- 不纳入测试目录。
- 不运行 full rebuild。
- 不提交 `graphify-out/*`。
- 不把 Graphify 输出作为执行授权。
- 完整 `verification.md` 默认不进入 Graphify context；只有审计、追溯或 debug 时才读取。
- 如果 Graphify 不可用，必须记录原因，不阻塞已经完成的 PR / Linear Done。
