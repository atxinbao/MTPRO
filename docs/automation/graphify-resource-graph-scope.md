# MTPRO Graphify 资源关系图范围

日期：2026-05-17

执行者：Codex

## 目的

初始化 MTPRO 的 Graphify resource relationship graph，让 Agent 能快速理解项目目标、架构、Roadmap、contract-first 文档、验证入口和自动化边界。

## 图类型

resource relationship graph

## 源码范围授权

no

## 默认纳入路径

- `README.md`
- `ENVIRONMENT.md`
- `GOAL.md`
- `AGENTS.md`
- `ARCHITECTURE.md`
- `ROADMAP.md`
- `.github/pull_request_template.md`
- `.github/workflows/checks.yml`
- `checks/run.sh`
- `docs/architecture/`
- `docs/automation/`
- `docs/contracts/`
- `docs/planning/`
- `docs/product/`
- `docs/validation/`
- `examples/README.md`
- `verification.md` latest records only for context

## 默认排除路径

- `Sources/`
- `Tests/`
- `.build/`
- `.swiftpm/`
- `.git/`
- `.codex/`
- `graphify-out/`

## 边界确认

- Graphify 默认是 resource relationship graph，不是 source code graph。
- 本轮不纳入完整源码目录。
- 本轮不纳入测试目录。
- 本轮不把 Graphify 输出作为执行授权。
- 本轮不修改 Linear。
- 本轮不启动 Symphony。
- `graphify-out/*` 默认不进入 PR。

## 使用方式

Graphify context 可用于执行前理解项目资源关系。

它不替代：

- `GOAL.md`
- `ARCHITECTURE.md`
- `ROADMAP.md`
- Linear configured executable issue
- PR evidence
- `verification.md`

## MTP-15 执行边界

日期：2026-05-17

执行者：Codex

MTP-15 只验证 Graphify 资源关系图的边界和证据链，不在 child Codex workspace 内强制刷新 Graphify。

当前执行约束：

- Graphify read context 如本地不可用，必须在 PR evidence 和 `verification.md` 记录原因。
- Child Codex 不运行 Graphify full rebuild。
- Child Codex 不提交 `graphify-out/*`。
- Child Codex 不把 scoped update 扩大为源码图，不纳入 `Sources/` 或 `Tests/`。
- PR merge / Linear bot Done 后，Graphify resource relationship graph refresh 由 symphony-issue host-side `before_remove` 触发 Post-Issue Ledger / 施工后记账处理。
- Post-Issue Ledger 输出 `.codex/post-issue-ledger/latest.json` 是本地只读摘要，不授权下一 issue。
