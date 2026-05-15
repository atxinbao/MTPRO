# 验证日志

本文件是只追加证据流水账。

它只记录每轮变更的目的、文件范围、边界确认和验证结果。

它不是协议事实源，不替代 `README.md`、`ROADMAP.md`、PR 正文或 Linear 证据。

## MTPRO 引导骨架

日期：2026-05-14

执行者：Codex

PR：未创建

提交：未创建

目的：

- 从 0 创建 MTPRO 项目定义和 SwiftPM 骨架。
- 固化当前用户确认的项目定义、契约优先边界和本地验证入口。

文件范围：

- 新增：
  - `README.md`
  - `GOAL.md`
  - `ENVIRONMENT.md`
  - `AGENTS.md`
  - `ARCHITECTURE.md`
  - `ROADMAP.md`
  - `Package.swift`
  - `Sources/`
  - `Tests/`
  - `docs/product/product-surface-map.md`
  - `docs/architecture/module-boundary.md`
  - `docs/contracts/`
  - `docs/validation/validation-plan.md`
  - `examples/README.md`
- 更新：
  - 无
- 删除：
  - 无

边界确认：

- 未实现业务功能。
- 未实现前端页面。
- 未实现 Binance 适配器。
- 未实现回测引擎。
- 未实现 Paper 执行。
- 未实现数据库适配器。
- 未创建 Linear 项目或事项。
- 未修改 Linear 状态。
- 未运行 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 已通过 |
| `swift test` | 通过 | 4 个 XCTest 通过 |

## MTPRO Linear 草案

日期：2026-05-14

执行者：Codex

PR：未创建

提交：未创建

目的：

- 按 AI Engineering Protocol 将 MTPRO `ROADMAP.md` 转换为只供审查的 Linear 草案。
- 保留 9 个里程碑：引导基线、核心模型与事件日志、Binance 只读行情、内核与缓存、EMA 回测与 Paper 一致性、订单簿策略、SQLite / DuckDB 投影、工作台看板、验证与自动化就绪。
- 明确第一个未来可执行事项草案为“核心领域模型与事件日志契约”。

文件范围：

- 新增：
  - `docs/planning/linear-draft-plan.md`
- 更新：
  - `verification.md`
- 删除：
  - 无

边界确认：

- 未调用 Linear API。
- 未创建 Linear 项目、里程碑或事项。
- 未修改 Linear 状态。
- 未启动 Symphony。
- 未运行 Graphify 更新、范围更新或全量重建。
- 未提交 `graphify-out/*`。
- 未实现 Binance 适配器。
- 未实现回测引擎。
- 未实现 Paper 执行。
- 未实现 UI。
- 未实现数据库适配器。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 已通过 |
| `swift test` | 通过 | 4 个 XCTest 通过 |

## MTPRO Linear 草案人工确认

日期：2026-05-14

执行者：Codex

PR：未创建

提交：未创建

目的：

- 记录用户对 MTPRO Linear 草案的人工确认。
- 将草案状态从等待审查更新为已确认。
- 标记 Linear 写入授权为“是”；当时仍需补齐 Linear 团队名称、团队标识、团队 ID，后续已由“Linear 团队信息修正”记录补齐。

文件范围：

- 新增：
  - 无
- 更新：
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- 删除：
  - 无

边界确认：

- 未调用 Linear API。
- 未创建 Linear 项目、里程碑或事项。
- 未修改 Linear 状态。
- 未启动 Symphony。
- 未运行 Graphify 更新、范围更新或全量重建。
- 未提交 `graphify-out/*`。
- 未进入开发执行。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 已通过 |
| `swift test` | 通过 | 4 个 XCTest 通过 |

## MTPRO Linear 团队信息修正

日期：2026-05-14

执行者：Codex

PR：未创建

提交：未创建

目的：

- 按用户最新确认修正 Linear 团队信息。
- 以团队名称 `NautilusTrade Pro`、团队 ID `MTP` 为准。
- 将 Linear 草案中的团队名称、团队标识、团队 ID 更新为 `NautilusTrade Pro / MTP`。

文件范围：

- 新增：
  - 无
- 更新：
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- 删除：
  - 无

边界确认：

- 未调用 Linear API。
- 未创建 Linear 项目、里程碑或事项。
- 未修改 Linear 状态。
- 未启动 Symphony。
- 未运行 Graphify 更新、范围更新或全量重建。
- 未进入开发执行。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 已通过 |
| `swift test` | 通过 | 4 个 XCTest 通过 |

## MTPRO Linear Setup

日期：2026-05-14

执行者：Codex

PR：未创建

提交：未创建

目的：

- 按已确认 Linear 草案执行 Linear Setup。
- 在团队 `MTP` 下创建 Project `MTPRO 引导`。
- 创建 9 个里程碑。
- 创建 `MTP-7` 到 `MTP-15`。
- 保持 `MTP-8` 为唯一 `Todo`，其余开发事项为 `Backlog`。

Linear 结果：

- Project：`MTPRO 引导`
- Project ID：`3a8e07ff-0c15-47cf-b9d2-9a077dfa037e`
- Project URL：`https://linear.app/atxinbao/project/mtpro-引导-f3792087e333`
- 团队标识：`MTP`
- Linear 返回团队显示名称：Macostrader Pro

事项状态：

| Linear 事项 | 标题 | 状态 |
| --- | --- | --- |
| `MTP-7` | 记录引导基线 | `Done` |
| `MTP-8` | 核心领域模型与事件日志契约 | `Todo` |
| `MTP-9` | Binance 公开只读行情适配器契约 | `Backlog` |
| `MTP-10` | 交易内核、数据引擎与缓存边界 | `Backlog` |
| `MTP-11` | EMA 回测与 Paper 一致性契约 | `Backlog` |
| `MTP-12` | 订单簿失衡策略研究链路 | `Backlog` |
| `MTP-13` | SQLite / DuckDB 投影与重放边界 | `Backlog` |
| `MTP-14` | Trader Workstation 看板 ViewModel 契约 | `Backlog` |
| `MTP-15` | 验证加固与自动化就绪 | `Backlog` |

文件范围：

- 新增：
  - 无
- 更新：
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- 删除：
  - 无

边界确认：

- 已调用 Linear API 创建 Project、里程碑和事项。
- 已设置新建事项初始状态。
- 未修改既有 Linear 事项状态。
- 未启动 Symphony。
- 未运行 Graphify 更新、范围更新或全量重建。
- 未提交 `graphify-out/*`。
- 未进入开发执行。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| Linear Project 查询 | 通过 | `MTPRO 引导` 已创建 |
| Linear Todo 查询 | 通过 | 仅 `MTP-8` 为 `Todo` |
| Linear 里程碑查询 | 通过 | 9 个里程碑已创建 |
| `git diff --check` | 通过 | 已通过 |
| `swift test` | 通过 | 4 个 XCTest 通过 |

## MTPRO Automation Readiness

日期：2026-05-14

执行者：Codex

PR：未创建

提交：未创建

目的：

- 检查 GitHub + Linear 关联前提、PR 模板、WIP=1、Authorized Merge 分离和 Graphify 只读边界。
- 补齐本地中文 PR 模板。
- 记录自动化就绪状态和阻塞项。

文件范围：

- 新增：
  - `.github/pull_request_template.md`
  - `docs/automation/automation-readiness.md`
- 更新：
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- 删除：
  - 无

检查结果：

| 项目 | 结果 | 说明 |
| --- | --- | --- |
| Git remote | 阻塞 | `git remote -v` 无输出 |
| GitHub + Linear 关联 | 待验证 | 需要先配置 GitHub remote 并创建或关联 PR |
| PR 模板 | 通过 | 已新增 `.github/pull_request_template.md` |
| Linear Project | 通过 | Project ID：`3a8e07ff-0c15-47cf-b9d2-9a077dfa037e`；名称：`MTPRO 引导` |
| Linear WIP=1 | 通过 | 仅 `MTP-8` 为 `Todo` |
| Authorized Merge 分离 | 通过 | PR 模板已固化分离门槛 |
| Graphify 只读边界 | 通过 | 未运行 Graphify update、scoped update 或 full rebuild |

边界确认：

- 未创建 GitHub PR。
- 未推送远程分支。
- 未修改 Linear 状态。
- 未启动 Symphony。
- 未运行 Graphify 更新、范围更新或全量重建。
- 未提交 `graphify-out/*`。
- 未进入 `MTP-8` 开发执行。
- 未实现 Binance 适配器。
- 未实现回测引擎。
- 未实现 Paper 执行。
- 未实现 UI。
- 未实现数据库适配器。
- 未实现 `LiveExecutionAdapter`。
- 未调用 Binance signed endpoint。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git remote -v` | 阻塞项确认 | 当前无 Git remote |
| `gh repo view --json nameWithOwner,url` | 阻塞项确认 | 返回 `no git remotes found` |
| Linear Project ID 查询 | 通过 | Project `MTPRO 引导` 可查询 |
| Linear Todo 查询 | 通过 | 仅 `MTP-8` 为 `Todo` |
| `git diff --check` | 通过 | 已通过 |
| `swift test` | 通过 | 4 个 XCTest 通过 |

## MTPRO Bootstrap PR

日期：2026-05-14

执行者：Codex

PR：`https://github.com/atxinbao/MTPRO/pull/1`

提交：待合并

目的：

- 创建 GitHub private 仓库。
- 配置 `origin`。
- 发布 Bootstrap Draft PR。
- 验证 GitHub + Linear 关联。
- 保持正式开发未开始。

GitHub 结果：

- Repository：`https://github.com/atxinbao/MTPRO`
- Visibility：private
- Remote：`origin https://github.com/atxinbao/MTPRO.git`
- Base branch：`main`
- PR branch：`codex/bootstrap-readiness`
- Draft PR：`https://github.com/atxinbao/MTPRO/pull/1`

降级说明：

- 本地 `git push` 连续两次因 GitHub 443 连接超时失败。
- 已改用 GitHub API 导入远端 Git objects。
- 远端 commit SHA 与本地 commit SHA 不同，但 GitHub compare 已确认文件范围。

证据链：

| 项目 | 值 |
| --- | --- |
| 本地 baseline commit | `a141648 Bootstrap MTPRO skeleton` |
| 远端 `main` import commit | `d4d172b7e51b43fc65cfbd2d5791d3b0aab0f4d0` |
| 本地证据 commit | `24abb12 Document Linear setup and automation readiness` |
| 远端 PR branch import commit | `58e488b928a9076bada4ca8854389a3e7b572e72` |

Linear 结果：

- `MTP-7` 已追加 Bootstrap PR attachment。
- `MTP-8` 仍是唯一 `Todo`。
- `MTP-9` 到 `MTP-15` 仍保持 `Backlog`。
- 未修改 Linear 状态。

文件范围：

- 新增：
  - 无
- 更新：
  - `docs/automation/automation-readiness.md`
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- 删除：
  - 无

边界确认：

- 已创建 GitHub private 仓库。
- 已创建 Bootstrap Draft PR。
- 已将 PR 关联到 Linear `MTP-7`。
- 未修改 Linear 状态。
- 未启动 Symphony。
- 未运行 Graphify 更新、范围更新或全量重建。
- 未提交 `graphify-out/*`。
- 未进入 `MTP-8` 开发执行。
- 未实现 Binance 适配器。
- 未实现回测引擎。
- 未实现 Paper 执行。
- 未实现 UI。
- 未实现数据库适配器。
- 未实现 `LiveExecutionAdapter`。
- 未调用 Binance signed endpoint。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `gh repo view atxinbao/MTPRO --json nameWithOwner,url,isPrivate,defaultBranchRef` | 通过 | private 仓库存在，默认分支为 `main` |
| GitHub compare `main...codex/bootstrap-readiness` | 通过 | ahead 1，变更文件为 PR 模板、自动化就绪、Linear 草案和验证日志 |
| Linear `MTP-7` attachment 查询 | 通过 | 已关联 Bootstrap Draft PR |
| Linear Todo 查询 | 通过 | 仅 `MTP-8` 为 `Todo` |
| `git diff --check` | 通过 | 已通过 |
| `swift test` | 通过 | 4 个 XCTest 通过 |

## MTPRO Onboarding Test Removal

日期：2026-05-16
执行者：Codex
PR：本轮 PR
Commit：本轮提交

目的：

- 将 MTPRO 项目路径调整为不创建单独的 test-mode onboarding Project / Issues。
- 明确第一个真实 `MTP-8` PR 同时验证 GitHub PR Automation 链路。
- 将旧 Authorized Merge / Bootstrap 阶段状态更新为 GitHub PR Automation 语义。

文件范围：

- Created：无
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `ROADMAP.md`
  - `docs/automation/automation-readiness.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/contracts/binance-market-data-contract.md`
  - `verification.md`
- Deleted：无

边界确认：

- 未创建单独 test Project。
- 未创建单独 test Issues。
- 未修改 Linear。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未实现业务功能。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，4 个 XCTest 通过 |

## MTPRO AEP v2 Flow Alignment

日期：2026-05-16
执行者：Codex
PR：本轮 PR
Commit：本轮提交

目的：

- 按 AEP v2 正式流程重新梳理 MTPRO 当前状态。
- 明确 `1. Human Project Planning` 到 `5. Next Human Project Planning` 的项目级映射。
- 明确当前唯一 configured executable issue 是 `MTP-8`。
- 明确 Symphony Issue Automation 尚未启动，GitHub PR Automation 已配置。

文件范围：

- Created：无
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `ROADMAP.md`
  - `docs/automation/automation-readiness.md`
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- Deleted：无

边界确认：

- 未修改 Linear。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未实现业务功能。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，4 个 XCTest 通过 |

## MTPRO Graphify Resource Graph Initialization

日期：2026-05-16
执行者：Codex
PR：本轮 PR
Commit：本轮提交

目的：
- 初始化 MTPRO 本地 Graphify resource relationship graph，让后续 Agent 可读取项目资源关系上下文。
- 明确 Graphify 默认不是 source code graph，源码目录、测试目录和 `graphify-out/*` 不进入 PR。

文件范围：
- Created：
  - `.graphifyignore`
  - `docs/automation/graphify-resource-graph-scope.md`
- Updated：
  - `docs/automation/automation-readiness.md`
  - `verification.md`
- Deleted：无

边界确认：
- 未修改 Linear。
- 未启动 Symphony。
- 未修改业务代码。
- 未纳入完整源码目录。
- 未纳入测试目录。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `graphify update .` | 通过 | 本地生成 176 nodes / 156 edges / 24 communities |
| Graphify source / test directory exclusion check | 通过 | 确认 `Sources/` 和 `Tests/` 未作为 graph source files |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，4 个 XCTest 通过 |
