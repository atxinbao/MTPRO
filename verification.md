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

## MTPRO symphony-issue Handoff Alignment

日期：2026-05-16
执行者：Codex
PR：本轮 PR
Commit：本轮提交

目的：
- 将 MTPRO PR 模板补齐 `symphony-issue` handoff evidence。
- 将 Linear `MTP-8` 至 `MTP-15` 描述统一对齐为 AEP v2 `symphony-issue` / GitHub PR Automation / Graphify scoped update 语义。
- 移除 future issues 中的旧 Authorized Merge / Graphify no-update 表述，并保留 Backlog 执行锁定。

文件范围：
- Created：无
- Updated：
  - `.github/pull_request_template.md`
  - `verification.md`
- Deleted：无

边界确认：
- 未修改业务代码。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未创建 Linear Project / Issue。
- 仅更新 Linear `MTP-8` 至 `MTP-15` 描述，不修改 Linear status。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | `swift test` 通过 |
| Linear issue description consistency check | 通过 | `MTP-8` 至 `MTP-15` 无旧 Authorized Merge / Graphify no-update 语义，并包含 handoff marker、Graphify scoped update 和 GitHub auto-merge handoff 要求 |

## MTPRO Agent Boundary Alignment for symphony-issue

日期：2026-05-16
执行者：Codex
PR：本轮 PR
Commit：本轮提交

目的：
- 修正 `AGENTS.md` 中仍保留的旧边界，明确 symphony-issue 已作为授权本地自动化负责唯一 `Todo` issue 调度。
- 明确 Codex Execution Agent 执行后需要运行 Graphify scoped resource relationship graph update，或记录环境不可用 / issue 禁止原因。

文件范围：
- Created：无
- Updated：
  - `AGENTS.md`
  - `verification.md`
- Deleted：无

边界确认：
- 未修改业务代码。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/run.sh` | 通过 | `swift test` 通过，4 个 XCTest 通过 |
| `git diff --check` | 通过 | 无 whitespace 问题 |

## MTP-8 核心领域模型与事件日志契约

日期：2026-05-16

执行者：Codex

PR：未创建（当前 sandbox / GitHub token 阻塞，需 host-side handoff fallback）

Commit：未创建（当前 sandbox 拒绝写入 `.git/index.lock`）

目的：

- 实现 `MTPROCore` 核心 symbol、timeframe、market event、domain event、command、query、event envelope 契约。
- 定义只追加事件日志契约和 replay 契约。
- 为后续 backtest / paper 一致性保留统一事件语义。
- 增加核心单元测试，覆盖正常路径、边界值、价格 / 数量约束、Codable 反序列化约束、只追加序列和拒绝 Live action 的约束。

文件范围：

- Created：无
- Updated：
  - `Sources/MTPROCore/MTPROCore.swift`
  - `Tests/MTPROCoreTests/MTPROCoreTests.swift`
  - `verification.md`
- Deleted：无

边界确认：

- 未修改 `MTPROAdapters`。
- 未修改 `MTPROPersistence`。
- 未修改 `MTPROApp`。
- 未接 Binance 网络。
- 未实现真实持久化 adapter。
- 未实现内核运行时。
- 未实现策略。
- 未实现 UI。
- 未实现 `LiveExecutionAdapter`。
- 未调用 signed endpoint。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

Graphify 状态：

- 执行前 `graphify-out/*` 在当前 worktree 中不存在，无法读取既有 Graphify 输出上下文。
- 已读取 `.graphifyignore` 和 `docs/automation/graphify-resource-graph-scope.md` 确认 Graphify 资源关系图边界。
- 执行后已尝试 `graphify update .`。
- Graphify update 未完成：当前 Graphify CLI 返回 `Re-extracting code files in . (no LLM needed)...` 后失败，错误为 `[Errno 1] Operation not permitted`。
- 本轮未生成或提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/run.sh` | 阻塞 | SwiftPM 在当前 sandbox 中尝试写入 `/Users/mac/.cache/clang/ModuleCache`，随后内部 `sandbox-exec` 返回 `Operation not permitted`，未进入源码编译 |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `CLANG_MODULE_CACHE_PATH="$PWD/.build/clang-module-cache" swift test --disable-sandbox --cache-path "$PWD/.build/swiftpm-cache" --config-path "$PWD/.build/swiftpm-config" --security-path "$PWD/.build/swiftpm-security" --scratch-path "$PWD/.build"` | 通过 | 12 个 XCTest 通过；其中 `MTPROCoreTests` 9 个测试通过 |
| `graphify update .` | 阻塞 | Graphify CLI 在当前 sandbox 中返回 `[Errno 1] Operation not permitted`，未生成可提交输出 |

Pre-PR Codex Code Review：

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| Diff scope | 通过 | 仅修改 `Sources/MTPROCore/MTPROCore.swift`、`Tests/MTPROCoreTests/MTPROCoreTests.swift`、`verification.md` |
| Issue scope | 通过 | 变更只覆盖核心领域模型、事件、命令 / 查询、事件信封、只追加日志和 replay 契约 |
| Forbidden paths | 通过 | 未修改 `MTPROAdapters`、`MTPROPersistence`、`MTPROApp` 或其他非当前 issue scope 文件 |
| Live / signed endpoint boundary | 通过 | 未新增 `LiveExecutionAdapter`、网络调用、signed endpoint、account endpoint 或真实订单动作 |
| Validation credibility | 需说明 | 默认 `bash checks/run.sh` 被本地 sandbox 阻塞；等价 `git diff --check` 与 sandbox-compatible `swift test --disable-sandbox` 已通过 |
| Graphify boundary | 需说明 | 已尝试 scoped update，但 Graphify CLI 在当前 sandbox 中失败；未提交 `graphify-out/*` |

## MTPRO symphony-issue Automation Write Profile

日期：2026-05-16
执行者：Codex
PR：本轮 PR
Commit：本轮提交

目的：
- 将 MTPRO 本地自动化边界对齐到 `symphony-issue` automation write profile。
- 明确 child Codex 可在当前 issue workspace 内完成 git commit / push、ready-for-review PR、GitHub auto-merge handoff 和本地 handoff marker。
- 明确 child Codex 被 sandbox、GitHub token、网络或 MCP elicitation 阻塞时，可由 host-side fallback 接管 handoff。

文件范围：
- Created：无
- Updated：
  - `.github/pull_request_template.md`
  - `AGENTS.md`
  - `docs/automation/automation-readiness.md`
  - `verification.md`
- Deleted：无

本地运行配置：
- `/Users/mac/code/symphony-workflows/mtpro-aep-v2.md`
- `/Users/mac/code/symphony-workflows/runtime/mtpro-aep-v2-local-seed.md`

边界确认：
- 未修改业务代码。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- host-side fallback 不扩大 issue scope，不替代 Linear 状态推进。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无 whitespace 问题。 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，4 个 XCTest 通过。 |

## MTPRO symphony-issue Host Handoff Fallback Alignment

日期：2026-05-16
执行者：Codex
PR：本轮 PR
Commit：本轮提交

目的：
- 将 MTPRO 本地自动化边界从默认 `dangerFullAccess` 收回到 `workspaceWrite` issue workspace 写入模型。
- 明确 child Codex 可处理 git / PR / marker，若被 sandbox、GitHub token、网络或 MCP elicitation 阻塞，则由 symphony-issue host-side handoff fallback 接管。
- 同步 workflow 运行配置，避免下一轮 MTP issue 自动化继续依赖 child Codex 直接写 `.git` 或 `.codex`。

文件范围：
- Created：无
- Updated：
  - `AGENTS.md`
  - `docs/automation/automation-readiness.md`
  - `verification.md`
- Deleted：无

本地运行配置：
- `/Users/mac/code/symphony-workflows/mtpro-aep-v2.md`
- `/Users/mac/code/symphony-workflows/runtime/mtpro-aep-v2-local-seed.md`

边界确认：
- 未修改业务代码。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无 whitespace 问题。 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，4 个 XCTest 通过。 |
| `mix test core + workspace/config` | 通过 | Symphony 相关 90 个测试通过。 |

## MTP-9 Binance 公开只读行情适配器契约

日期：2026-05-16

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 实现 `MTPROAdapters` 的 Binance public market data read-only endpoint contract。
- 固化 `exchangeInfo`、`klines`、recent trades、best bid / ask、有限深度快照和深度增量的 contract。
- 将 Binance public fixture payload 解码为 `MTPROCore` market event model。
- 用测试覆盖 configured universe、`1m` / `5m` timeframe、record limit、fixture decoding、unsupported symbol、invalid numeric payload 和 forbidden capability boundary。

文件范围：

- Created：
  - 无
- Updated：
  - `Sources/MTPROAdapters/MTPROAdapters.swift`
  - `Tests/MTPROAdaptersTests/MTPROAdaptersTests.swift`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`
- Deleted：
  - 无

Linear / scope 确认：

- Linear 查询显示 `MTP-9` 为当前唯一 `In Progress` issue。
- Linear 查询显示 `MTP-8` 已 `Done`。
- Linear 查询显示 `MTP-10` 至 `MTP-15` 仍为 `Backlog`。
- 根文档中仍有 `MTP-8` current issue 的历史文字；本轮执行授权以 Linear 当前状态和用户提供的 `symphony-issue` workflow 为准。

边界确认：

- 未接真实 Binance 网络。
- 未实现 URLSession client。
- 未实现 WebSocket 生命周期管理。
- 未使用 API key。
- 未调用 signed endpoint。
- 未调用 account endpoint。
- 未提交、取消或替换订单。
- 未实现 `LiveExecutionAdapter`。
- 未实现策略。
- 未实现 TradingKernel / DataEngine / Cache。
- 未实现 persistence adapter。
- 未实现 SwiftUI 页面。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

Graphify 状态：

- 执行前 `graphify-out/*` 在当前 worktree 中不存在，无法读取既有 Graphify 输出上下文。
- 已读取 `docs/automation/graphify-resource-graph-scope.md`，确认 Graphify 资源关系图边界和 `graphify-out/*` 不进入 PR。
- 执行后已尝试 `graphify update .`。
- Graphify update 未完成：当前 Graphify CLI 返回 `Re-extracting code files in . (no LLM needed)...` 后失败，错误为 `[Errno 1] Operation not permitted`。
- 本轮未生成或提交 `graphify-out/*`。

本地 `.codex` evidence 状态：

- 已创建仓库根目录 `.codex/`，但当前 sandbox 拒绝向 `.codex/*` 写入文件。
- `apply_patch` 写入 `.codex/*` 返回 `writing outside of the project`。
- `touch .codex/foo` 返回 `Operation not permitted`。
- 因此 `.codex/structured-request.json`、`.codex/context-scan.json`、`.codex/operations-log.md`、`.codex/testing.md` 和 `.codex/review-report.md` 未能写入。
- 后续 `.codex/symphony-issue-handoff.json` 很可能需要 host-side handoff fallback 接管写入。

Git / PR handoff 状态：

- 已尝试 `git add` 精确暂存本轮 5 个 tracked 文件。
- `git add` 被当前 sandbox 阻塞，错误为 `Unable to create '.git/index.lock': Operation not permitted`。
- 未产生半写入的 `.git/index.lock`。
- `git diff --cached --name-only` 为空，未产生 partial staging。
- `gh auth status` 显示当前 GitHub CLI token invalid。
- 因此 commit / push / ready-for-review PR / auto-merge handoff / `.codex/symphony-issue-handoff.json` 需要 host-side handoff fallback 接管。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | 通过 | 19 个 XCTest 通过，其中 `MTPROAdaptersTests` 8 个测试通过 |
| `bash checks/run.sh` | 阻塞 | SwiftPM 在当前 sandbox 中尝试写入 `/Users/mac/.cache/clang/ModuleCache`，随后返回 `Operation not permitted`，未进入源码编译 |
| `CLANG_MODULE_CACHE_PATH="$PWD/.build/clang-module-cache" swift test --disable-sandbox --cache-path "$PWD/.build/swiftpm-cache" --config-path "$PWD/.build/swiftpm-config" --security-path "$PWD/.build/swiftpm-security" --scratch-path "$PWD/.build"` | 通过 | 19 个 XCTest 通过，其中 `MTPROAdaptersTests` 8 个测试通过 |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `graphify update .` | 阻塞 | Graphify CLI 返回 `[Errno 1] Operation not permitted`，未生成可提交输出 |
| `git add ... && git commit ...` | 阻塞 | 当前 sandbox 拒绝创建 `.git/index.lock`，未完成 commit |
| `gh auth status` | 阻塞 | GitHub CLI token invalid，无法由 child Codex 创建 PR |

Pre-PR Codex Code Review：

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| Diff scope | 通过 | 变更集中在 adapter contract、adapter tests、Binance contract 文档、validation 文档和验证日志 |
| Issue scope | 通过 | 覆盖 MTP-9 要求的 public read-only market data adapter contract、fixture decoding 和 forbidden capability tests |
| Forbidden paths | 通过 | 未修改 `MTPROCore`、`MTPROPersistence`、`MTPROApp`、`Package.swift` 或非当前 issue 业务模块 |
| Live / signed endpoint boundary | 通过 | 未新增 API key、signature、account endpoint、listenKey、真实订单动作或 Live adapter |
| Validation credibility | 需说明 | 默认 `bash checks/run.sh` 被本地 sandbox 阻塞；等价 `git diff --check` 与 sandbox-compatible `swift test --disable-sandbox` 已通过 |
| Graphify boundary | 需说明 | 已尝试 update，但 sandbox 阻塞；未提交 `graphify-out/*` |
| Handoff marker | 需 fallback | 当前 sandbox 拒绝写入 `.codex/*`，本地 marker 预计需要 host-side fallback |
| GitHub handoff | 需 fallback | 当前 sandbox 拒绝写 `.git`，且 `gh` token invalid；commit / push / PR / auto-merge 预计需要 host-side fallback |

Host-side handoff fallback：

- child Codex 已完成当前 issue scope 的实现、测试、Graphify update 尝试和 Pre-PR Code Review。
- child Codex sandbox 拒绝写入 `.codex/*`，因此本地 handoff marker 由 host-side fallback 在 PR 创建后写入。
- child Codex sandbox 的 `bash checks/run.sh` 失败原因是 SwiftPM cache 写入权限，不是源码或测试失败。
- host-side fallback 在同一 issue workspace 中补跑 `git diff --check`，结果通过。
- host-side fallback 在同一 issue workspace 中补跑 `bash checks/run.sh`，结果通过，19 个 XCTest 全部通过。
- host-side fallback 只接管 commit / push / PR / auto-merge handoff / 本地 marker，不扩大 diff scope，不修改 Linear status。

Host-side validation：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | host 环境无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | host 环境 `swift test` 通过，19 个 XCTest 通过 |

## MTPRO current issue stale wording cleanup

日期：2026-05-16

执行者：Codex

目的：

- 清理 active docs 中把 `MTP-8` 写死为当前唯一 configured executable issue 的旧表述。
- 明确当前执行事项必须从 Linear / symphony-project 运行时状态读取。
- 明确 `MTP-8` 和 `MTP-9` 已完成，`MTP-10` 仍为 `Backlog`，本轮暂不接 symphony-project continuation。

文件范围：

- Created：
  - 无
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `ROADMAP.md`
  - `docs/automation/automation-readiness.md`
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未接入 symphony-project continuation。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 已在 host 环境运行 Graphify update，确认不经 child sandbox 可完成；输出仍位于忽略路径 `graphify-out/*`。
- 未提交 `graphify-out/*`。
- 未提交 `.codex/*`。
- 未修改业务代码。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `rg active stale MTP-8 current issue wording` | 通过 | active docs 未再把 `MTP-8` 写死为 current issue |
| `graphify update .` | 通过 | host 环境更新 `graphify-out/*`，未纳入 git |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，19 个 XCTest 通过 |

## MTPRO symphony-issue execution profile and Graphify refresh alignment

日期：2026-05-16

执行者：Codex

目的：

- 将 MTPRO 文档对齐到本地 symphony-issue 的 `dangerFullAccess` issue automation profile。
- 明确 child Codex 可在 issue workspace 内完成 git / PR / handoff marker；GitHub token、网络或 MCP elicitation 阻塞时再由 host-side handoff fallback 接管。
- 明确 Graphify update 不再依赖 child sandbox，PR merge / Linear bot Done 后由 symphony-issue host-side `before_remove` 刷新 `/Users/mac/Documents/MTPRO` 的 resource relationship graph。

文件范围：

- Created：
  - 无
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `docs/automation/automation-readiness.md`
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未接入 symphony-project continuation。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify full rebuild。
- 未提交 `graphify-out/*`。
- 未提交 `.codex/*`。
- 未修改业务代码。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，19 个 XCTest 通过 |
