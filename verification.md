# 验证日志

本文件是只追加证据流水账。

它只记录每轮变更的目的、文件范围、边界确认和验证结果。

它不是协议事实源，不替代 `README.md`、`ROADMAP.md`、PR 正文或 Linear 证据。

Agent / Graphify 默认读取 `docs/validation/latest-verification-summary.md`。

完整历史只在审计、追溯或 debug 时读取。

历史记录不压缩、不拆分、不重写。

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

## MTP-10 交易内核、数据引擎与缓存边界

日期：2026-05-16

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 建立 `MTPROCore` 的最小 `MTPROTradingKernel` actor 边界。
- 建立 `MTPROMessageBus`、`MTPRODataEngine` 和 `MTPROMarketDataCache` 的可测试契约。
- 将只读 `MTPROMarketEvent` 同步写入 cache 和 append-only event stream。
- 通过 replay envelope 确认 cache projection 可确定性重建。

文件范围：

- Created：
  - 无
- Updated：
  - `Sources/MTPROCore/MTPROCore.swift`
  - `Tests/MTPROCoreTests/MTPROCoreTests.swift`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`
- Deleted：
  - 无

Linear / scope 确认：

- Linear 查询显示 `MTP-10` 为当前唯一 active issue，状态为 `In Progress`。
- Linear 查询显示 `MTP-9` 已 `Done`。
- Linear 查询显示 `MTP-11` 至 `MTP-15` 仍为 `Backlog`。
- 本轮只执行 MTP-10 scope，不解锁后续 issue。

边界确认：

- 未实现 Live 执行。
- 未提交订单。
- 未实现数据库适配器。
- 未实现 SwiftUI 页面。
- 未实现 Binance 网络客户端。
- 未调用 Binance signed endpoint。
- 未调用 Binance account endpoint。
- 未实现策略、backtest engine 或 paper execution engine。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

Graphify 状态：

- 当前 issue workspace 未发现 `graphify-out/*` 可读取上下文。
- 已读取 `docs/automation/graphify-resource-graph-scope.md` 和 `docs/automation/automation-readiness.md`。
- 按本轮 workflow，Graphify post-merge resource graph refresh 由 symphony-issue host-side `before_remove` 在持久仓库 `/Users/mac/Documents/MTPRO` 执行；child Codex 本轮未运行 Graphify full rebuild。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | 通过 | 24 个 XCTest 通过，`MTPROCoreTests` 14 个测试通过 |
| `bash checks/run.sh` | 通过 | `git diff --check` 和 `swift test` 通过，输出 `MTPRO checks passed.` |

新增测试：

- MessageBus monotonic sequence 和 stream replay 测试。
- DataEngine read-only market event ingest 测试。
- Cache deterministic replay projection 测试。
- TradingKernel actor 并发 ingest 隔离测试。
- TradingKernel replay cache rebuild 测试。

Pre-PR Codex Code Review：

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| Diff scope | 通过 | 变更集中在 `MTPROCore`、核心测试、backend contract、validation plan 和验证日志 |
| Issue scope | 通过 | 覆盖 MTP-10 要求的 actor kernel、MessageBus、DataEngine、Cache 和 deterministic replay |
| Forbidden paths | 通过 | 未修改 `MTPROAdapters`、`MTPROPersistence`、`MTPROApp`、`Package.swift` 或非当前 issue 业务模块 |
| Live / signed endpoint boundary | 通过 | 未新增 API key、signature、account endpoint、listenKey、真实订单动作或 Live adapter |
| Validation credibility | 通过 | 默认项目级 `bash checks/run.sh` 已通过 |
| Graphify boundary | 通过 | 未运行 full rebuild，未提交 `graphify-out/*`，post-merge refresh 交由 host-side workflow |

## Post-Issue Ledger / 施工后记账流程收口

日期：2026-05-16

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将 MTP-10 真实自动化跑通后暴露出的 `before_remove` 语义收口为 Post-Issue Ledger / 施工后记账。
- 明确施工后记账只同步最新 `main`、刷新 Graphify resource relationship graph、承接只读下一步观察提示。
- 明确下一步观察提示不授权下一个 issue、不创建 Linear issue、不修改 `ROADMAP.md`。

文件范围：

- Created：
  - `docs/automation/post-issue-ledger.md`
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `.github/pull_request_template.md`
  - `docs/automation/automation-readiness.md`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未修改业务代码。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未把下一步观察提示写成执行授权。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，24 个 XCTest 通过 |

## Structured Post-Issue Ledger Summary

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将 Post-Issue Ledger / 施工后记账从纯 hook 命令说明升级为结构化本地摘要。
- 明确摘要路径为 `.codex/post-issue-ledger/latest.json`，只供父 Codex / Human 读取。
- 明确摘要不授权下一 issue，不进入 PR。

文件范围：

- Created：
  - 无
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `.github/pull_request_template.md`
  - `docs/automation/automation-readiness.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/automation/post-issue-ledger.md`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未修改业务代码。
- 未创建 Linear Project / Issue。
- 未自动推进 Linear issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未把 ledger summary 写成执行授权。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，24 个 XCTest 通过 |

## Parent Codex Automation Supervision Flow

日期：2026-05-16

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将父 Codex 明确为当前 Project 级自动化监督角色，替代未接入的独立 `symphony-project` continuation。
- 明确父 Codex 负责 queue preview、child Codex 监控、代码审查、host-side fallback 和流程迭代建议。
- 明确父 Codex 只有在 Human 明确授权后，才可将 eligible `Backlog` 推进为唯一 `Todo`。

文件范围：

- Created：
  - `docs/automation/parent-codex-supervision.md`
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `.github/pull_request_template.md`
  - `docs/automation/automation-readiness.md`
  - `docs/automation/post-issue-ledger.md`
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未修改业务代码。
- 未创建 Linear Project / Issue。
- 未自动推进 Linear issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未把父 Codex 写成业务实现 Agent 或 PR merge Agent。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无 whitespace 问题 |
| `bash checks/run.sh` | 通过 | `swift test` 通过，24 个 XCTest 通过 |

## MTP-11 EMA 回测与 Paper 一致性契约

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 实现 EMA cross 策略配置、EMA 信号样本和确定性 signal timeline。
- 实现 Backtest requested / signalGenerated / completed 事件流。
- 实现 Paper sessionRequested / signalGenerated / sessionCompleted 事件流。
- 建立 Backtest / Paper signal timeline parity 验证。

文件范围：

- Created：
  - 无
- Updated：
  - `Sources/MTPROCore/MTPROCore.swift`
  - `Tests/MTPROCoreTests/MTPROCoreTests.swift`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未实现 Live trading。
- 未连接 broker。
- 未提交真实订单。
- 未调用 Binance signed endpoint。
- 未实现订单簿失衡策略。
- 未实现完整 Dashboard 页面。
- 未实现数据库 adapter。
- 未修改 Linear status。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/run.sh` | 执行前通过 | 基线 24 个 XCTest 通过 |
| `swift package clean` | 通过 | 清理 SwiftPM 增量缓存 |
| `swift test` | 通过 | 28 个 XCTest 通过，新增 EMA fixture、回测事件流、Paper 事件流和 parity 测试 |
| `bash checks/run.sh` | 通过 | `git diff --check` 通过；`swift test` 28 个 XCTest 通过；输出 `MTPRO checks passed.` |

## MTP-12 订单簿失衡策略研究链路

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 定义订单簿读模型输入，复用只读 snapshot / delta market events。
- 实现订单簿 top depth notional imbalance 信号契约。
- 新增订单簿失衡研究 command / result / event flow，并可发布到 strategy stream。
- 用测试夹具验证 delta 应用、信号稳定性、边界拒绝和研究链路事件流。

文件范围：

- Created：
  - 无
- Updated：
  - `Sources/MTPROCore/MTPROCore.swift`
  - `Tests/MTPROCoreTests/MTPROCoreTests.swift`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`
- Deleted：
  - 无

Linear / scope 确认：

- Linear 查询显示 `MTP-12` 为当前唯一 active issue，状态为 `In Progress`。
- Linear 查询显示 `MTP-11` 已 `Done`。
- Linear 查询显示 `MTP-13` 至 `MTP-15` 仍为 `Backlog`。
- 本轮只执行 MTP-12 scope，不解锁后续 issue。

边界确认：

- 未接 signed endpoint。
- 未接 account endpoint。
- 未做 futures leverage / margin action。
- 未提交、取消或替换真实订单。
- 未实现 `LiveExecutionAdapter`。
- 未扩展 configured symbol universe。
- 未实现 persistence adapter。
- 未实现 SwiftUI 页面。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

Graphify 状态：

- 当前 issue workspace 未发现 `graphify-out/*` 可读取上下文。
- 已读取 `docs/automation/graphify-resource-graph-scope.md` 和 `docs/automation/post-issue-ledger.md`。
- 按本轮 workflow，Graphify post-merge resource graph refresh 由 symphony-issue host-side `before_remove` 在持久仓库 `/Users/mac/Documents/MTPRO` 执行；child Codex 本轮未运行 Graphify full rebuild。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | 通过 | 32 个 XCTest 通过，新增订单簿读模型、失衡信号和研究事件流测试 |
| `bash checks/run.sh` | 通过 | `git diff --check` 和 `swift test` 通过，32 个 XCTest 通过，输出 `MTPRO checks passed.` |

新增测试：

- Order book read model snapshot / delta deterministic application 测试。
- Order book imbalance stable signal fixture 测试。
- Order book imbalance invalid configuration / input rejection 测试。
- Order book imbalance research event flow strategy stream 测试。

Pre-PR Codex Code Review：

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| Diff scope | 通过 | 变更集中在 `MTPROCore`、核心测试、contract 文档、validation plan 和验证日志 |
| Issue scope | 通过 | 覆盖 MTP-12 要求的订单簿读模型输入、失衡信号、研究链路和测试夹具 |
| Forbidden paths | 通过 | 未修改 `MTPROAdapters`、`MTPROPersistence`、`MTPROApp`、`Package.swift` 或非当前 issue 业务模块 |
| Live / signed endpoint boundary | 通过 | 未新增 API key、signature、account endpoint、listenKey、真实订单动作、futures / margin action 或 Live adapter |
| Validation credibility | 通过 | 默认项目级 `bash checks/run.sh` 已通过 |
| Graphify boundary | 通过 | 未运行 full rebuild，未提交 `graphify-out/*`，post-merge refresh 交由 host-side workflow |

## MTP-13 SQLite / DuckDB 投影与重放边界

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 实现 persistence replay boundary，复用 `AppendOnlyEventLog` 与 `EventReplayCommand`。
- 建立 SQLite runtime projection contract，投影 paper session、risk rejection 和 portfolio runtime read model。
- 建立 DuckDB analytical projection contract，投影 market data、backtest、订单簿研究和 analytical signal timeline。
- 确认 database table、ORM model 和 runtime object 不作为 UI contract。

文件范围：

- Created：
  - 无
- Updated：
  - `Sources/MTPROPersistence/MTPROPersistence.swift`
  - `Tests/MTPROPersistenceTests/MTPROPersistenceTests.swift`
  - `docs/contracts/persistence-boundary.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`
- Deleted：
  - 无

Linear / scope 确认：

- Linear 查询显示 `MTP-13` 为当前唯一 active issue，状态为 `In Progress`。
- Linear 查询显示 `MTP-12` 已 `Done`。
- Linear 查询显示 `MTP-14` 和 `MTP-15` 仍为 `Backlog`。
- 本轮只执行 MTP-13 scope，不解锁后续 issue。

边界确认：

- 未让 UI 直接读取数据库表。
- 未暴露 ORM model。
- 未把 runtime object 持久化为 UI contract。
- 未做破坏性数据库迁移。
- 未引入真实 SQLite / DuckDB driver。
- 未实现 Live execution persistence。
- 未连接 broker。
- 未调用 Binance signed endpoint。
- 未提交、取消或替换真实订单。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

Graphify 状态：

- 当前 issue workspace 未发现 `graphify-out/*` 可读取上下文。
- 已读取 `docs/automation/graphify-resource-graph-scope.md`。
- 按本轮 workflow，Graphify post-merge resource graph refresh 由 symphony-issue host-side `before_remove` 在持久仓库 `/Users/mac/Documents/MTPRO` 执行；child Codex 本轮未运行 Graphify full rebuild。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/run.sh` | 执行前通过 | 基线 `git diff --check` 和 `swift test` 通过，32 个 XCTest 通过 |
| `swift test` | 通过 | 36 个 XCTest 通过，新增 replay、临时 SQLite、临时 DuckDB 和投影隔离测试 |
| `bash checks/run.sh` | 通过 | `git diff --check` 和 `swift test` 通过，36 个 XCTest 通过，输出 `MTPRO checks passed.` |

新增测试：

- Persistence replay boundary selected event range rebuild 测试。
- Temporary SQLite runtime projection rebuild 测试。
- Temporary DuckDB analytical projection rebuild 测试。
- Runtime / analytical projection isolation 测试。

Pre-PR Codex Code Review：

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| Diff scope | 通过 | 变更集中在 `MTPROPersistence`、持久化测试、contract 文档、validation plan 和验证日志 |
| Issue scope | 通过 | 覆盖 MTP-13 要求的事件日志重放、SQLite 运行投影、DuckDB 分析投影和隔离验证 |
| Forbidden paths | 通过 | 未修改 `MTPROApp`、`MTPROCore`、`MTPROAdapters`、`Package.swift` 或后续 issue scope |
| Live / signed endpoint boundary | 通过 | 未新增 API key、signature、account endpoint、listenKey、真实订单动作或 Live adapter |
| Validation credibility | 通过 | 默认项目级 `bash checks/run.sh` 已通过 |
| Graphify boundary | 通过 | 未运行 full rebuild，未提交 `graphify-out/*`，post-merge refresh 交由 host-side workflow |
| Handoff marker | 待 PR 后完成 | ready-for-review PR 和 auto-merge handoff 后写入 `.codex/symphony-issue-handoff.json` |

## MTP-14 Trader Workstation 看板 ViewModel 契约

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 实现 Market / Strategy / Backtest / Paper / Risk / Portfolio / Events 的 App 层 ViewModel contract。
- 建立 Dashboard read model 聚合，输入只来自 SQLite runtime projection、DuckDB analytical projection 和 append-only event timeline。
- 移除 `MTPROApp` target 对 `MTPROAdapters` 的直接依赖，强化 UI 不直接调用 Binance adapter 的边界。
- 新增 ViewModel source contract、读模型映射测试和状态快照测试。

文件范围：

- Created：
  - 无
- Updated：
  - `Package.swift`
  - `Sources/MTPROApp/MTPROApp.swift`
  - `Tests/MTPROAppTests/MTPROAppTests.swift`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`
- Deleted：
  - 无

Linear / scope 确认：

- Linear 查询显示 `MTP-14` 为当前唯一 active issue，状态为 `In Progress`。
- Linear 查询显示 `MTP-13` 已 `Done`。
- Linear 查询显示 `MTP-15` 仍为 `Backlog`。
- 本轮只执行 MTP-14 scope，不解锁后续 issue。

边界确认：

- 未实现 SwiftUI 页面。
- 未让 UI 直接读取数据库表。
- 未暴露 ORM model。
- 未暴露 runtime object。
- 未调用 Binance adapter。
- 未提供 live order button。
- 未连接 broker。
- 未调用 Binance signed endpoint。
- 未提交、取消或替换真实订单。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

Graphify 状态：

- 当前 issue workspace 未发现 `graphify-out/*` 可读取上下文。
- 已读取 `docs/automation/graphify-resource-graph-scope.md`。
- 按本轮 workflow，Graphify post-merge resource graph refresh 由 symphony-issue host-side `before_remove` 在持久仓库 `/Users/mac/Documents/MTPRO` 执行；child Codex 本轮未运行 Graphify full rebuild。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | 通过 | 39 个 XCTest 通过，新增 Dashboard ViewModel source contract、读模型映射和状态快照测试 |
| `bash checks/run.sh` | 通过 | `git diff --check` 和 `swift test` 通过，39 个 XCTest 通过，输出 `MTPRO checks passed.` |

新增测试：

- Dashboard ViewModel stable read model source contract 测试。
- Read model projection maps all dashboard sections 测试。
- Dashboard ViewModel Codable deterministic state snapshot 测试。

Pre-PR Codex Code Review：

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| Diff scope | 通过 | 变更集中在 `MTPROApp`、App tests、contract 文档、validation plan 和验证日志；`Package.swift` 仅移除 App 对 adapter 直接依赖并补测试依赖 |
| Issue scope | 通过 | 覆盖 MTP-14 要求的 ViewModel 契约、读模型映射和状态契约测试 |
| Forbidden paths | 通过 | `.codex/*` 被 `.gitignore` 忽略，`graphify-out/*` 不存在且未进入 PR |
| Live / signed endpoint boundary | 通过 | 未新增 API key、signature、account endpoint、listenKey、真实订单动作或 Live adapter |
| Validation credibility | 通过 | 默认项目级 `bash checks/run.sh` 已通过 |
| Graphify boundary | 通过 | 未运行 full rebuild，未提交 `graphify-out/*`，post-merge refresh 交由 host-side workflow |
| Handoff marker | 待 PR 后完成 | ready-for-review PR 和 auto-merge handoff 后写入 `.codex/symphony-issue-handoff.json` |

## MTP-15 验证加固与自动化就绪

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 完成 MTP-15 验证矩阵。
- 将 PR evidence template、GitHub PR Automation Gate、WIP=1、symphony-issue handoff marker 和 Graphify / Post-Issue Ledger 边界固化为本地可重复检查。
- 更新自动化就绪文档，记录 MTP-15 当前 Linear queue snapshot。

文件范围：

- Created：
  - `checks/automation-readiness.sh`
- Updated：
  - `.github/pull_request_template.md`
  - `checks/run.sh`
  - `docs/automation/automation-readiness.md`
  - `docs/automation/graphify-resource-graph-scope.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`
- Deleted：
  - 无

Linear / scope 确认：

- Linear 查询显示 `MTP-15` 为当前唯一 active issue，状态为 `In Progress`。
- Linear 查询显示 `MTP-14` 已 `Done`。
- 本轮只执行 MTP-15 scope，不解锁后续 issue。

边界确认：

- 未实现新的业务功能。
- 未修改 `Sources/` 或 `Tests/`。
- 未修改 `ROADMAP.md`。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未实现 `LiveExecutionAdapter`。
- 未调用 Binance signed endpoint。

Graphify 状态：

- 当前 issue workspace 未发现 `graphify-out/*` 可读取上下文。
- 已读取并更新 `docs/automation/graphify-resource-graph-scope.md` 的 MTP-15 child Codex 执行边界。
- 按本轮 workflow，Graphify post-merge resource graph refresh 由 symphony-issue host-side `before_remove` 在持久仓库 `/Users/mac/Documents/MTPRO` 执行；child Codex 本轮未运行 Graphify full rebuild。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | 通过 | 检查 workflow、PR 模板、WIP=1、handoff marker、Graphify 边界、ignore 边界和验证文档，输出 `MTPRO automation readiness checks passed.` |
| `bash -n checks/automation-readiness.sh checks/run.sh` | 通过 | shell 脚本语法检查通过 |
| `git diff --check` | 通过 | 无空白或补丁格式问题 |
| `bash checks/run.sh` | 通过 | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

新增验证：

- Automation readiness shell gate。
- PR template evidence gate。
- GitHub workflow required check gate。
- WIP=1 evidence gate。
- symphony-issue handoff marker gate。
- Graphify / Post-Issue Ledger boundary gate。
- `.codex/*` 与 `graphify-out/*` local output isolation gate。

Pre-PR Codex Code Review：

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| Diff scope | 通过 | 变更集中在验证脚本、PR 模板、automation docs、validation plan 和验证日志 |
| Issue scope | 通过 | 覆盖 MTP-15 要求的验证矩阵、PR 证据、WIP=1、handoff marker、GitHub PR Automation 和 Graphify 边界 |
| Forbidden paths | 通过 | 未修改业务源码、测试源码或 `ROADMAP.md`；`.codex/*` 被 `.gitignore` 忽略，`graphify-out/*` 不存在且未进入 PR |
| Live / signed endpoint boundary | 通过 | 未新增 API key、signature、account endpoint、listenKey、真实订单动作或 Live adapter |
| Validation credibility | 通过 | 默认项目级 `bash checks/run.sh` 已通过，并包含新增 automation readiness gate |
| Graphify boundary | 通过 | 未运行 full rebuild，未提交 `graphify-out/*`，post-merge refresh 交由 host-side workflow |
| Handoff marker | 待 PR 后完成 | ready-for-review PR 和 auto-merge handoff 后写入 `.codex/symphony-issue-handoff.json` |

## MTPRO Linear Issue Execution Contract Alignment

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将 MTPRO 的 Codex Execution Agent 执行前语义对齐为“Linear issue 内容就是执行合同”。
- 移除“执行前二次确认 issue scope / boundary / validation”的流程含义。
- 明确子 Codex 读取 Linear issue 中已填写的 Scope / Non-goals / Codex Instructions / Validation / Boundary / PR Requirements 后直接执行。

文件范围：

- Created：
  - 无
- Updated：
  - `AGENTS.md`
  - `checks/automation-readiness.sh`
  - `docs/automation/automation-readiness.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未修改业务源码。
- 未修改测试源码。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未实现 `LiveExecutionAdapter`。
- 未调用 Binance signed endpoint。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无空白或补丁格式问题。 |
| `bash checks/run.sh` | 通过 | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## MTPRO Project Role Map

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 补充 MTPRO 项目能力角色地图，明确系统架构、前端设计、后端开发、数据 / 持久化、质量验证、部署与运营等职责覆盖。
- 将角色地图定位为 Human Project Planning 和阶段复盘辅助文档，不授权执行，不替代 Linear Project / Issue。

文件范围：

- Created：
  - `docs/planning/project-role-map.md`
- Updated：
  - `AGENTS.md`
  - `checks/automation-readiness.sh`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未修改业务源码。
- 未修改测试源码。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未实现 `LiveExecutionAdapter`。
- 未调用 Binance signed endpoint。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | Project Role Map 文档和检查脚本更新无空白问题。 |
| `bash checks/run.sh` | 通过 | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Linear Team Name Correction

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 修正 `docs/planning/linear-draft-plan.md` 中的目标 Linear 团队名称。
- 将团队名称统一为 `Macostrader Pro`，团队标识和团队 ID 仍为 `MTP`。

文件范围：

- Created：
  - 无
- Updated：
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未修改业务源码。
- 未修改测试源码。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | Linear team name 修正文档无空白问题。 |
| `bash checks/run.sh` | 通过 | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Swift Module MTPRO Prefix Removal

日期：2026-05-17

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 移除 `Sources/`、`Tests/`、SwiftPM target / product 和 Swift 类型命名中的 `MTPRO` 前缀。
- 保留项目名 `MTPRO`，但代码模块使用通用名称 `Core`、`Adapters`、`Persistence`、`App`。
- 同步更新当前合同文档和 README 中的代码模块引用。

文件范围：

- Created / Renamed：
  - `Sources/Core/Core.swift`
  - `Sources/Adapters/Adapters.swift`
  - `Sources/Persistence/Persistence.swift`
  - `Sources/App/App.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/AdaptersTests/AdaptersTests.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `Tests/AppTests/AppTests.swift`
- Updated：
  - `Package.swift`
  - `README.md`
  - `ARCHITECTURE.md`
  - `ROADMAP.md`
  - `AGENTS.md`
  - `checks/automation-readiness.sh`
  - `docs/architecture/module-boundary.md`
  - `docs/audit/mtpro-guidance-stage-code-audit.md`
  - `docs/contracts/*.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`
- Deleted / Renamed from：
  - `Sources/MTPROCore/MTPROCore.swift`
  - `Sources/MTPROAdapters/MTPROAdapters.swift`
  - `Sources/MTPROPersistence/MTPROPersistence.swift`
  - `Sources/MTPROApp/MTPROApp.swift`
  - `Tests/MTPROCoreTests/MTPROCoreTests.swift`
  - `Tests/MTPROAdaptersTests/MTPROAdaptersTests.swift`
  - `Tests/MTPROPersistenceTests/MTPROPersistenceTests.swift`
  - `Tests/MTPROAppTests/MTPROAppTests.swift`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未实现 `LiveExecutionAdapter`。
- 未调用 Binance signed endpoint。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Swift module rename 无空白问题。 |
| `swift test` | pass | 39 个 XCTest 通过；module 名称已变为 `Core`、`Adapters`、`Persistence`、`App`。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；输出 `MTPRO checks passed.` |

## Project Supervision And Examples Cleanup

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 删除 MTPRO 项目中的 `examples/` 目录。
- 移除 active docs 中把独立 Project 级自动 continuation 程序作为未完成项的表述。
- 明确 MTPRO 当前 Project 级监督由 Parent Codex Automation Supervision 承接。

文件范围：

- Updated：
  - `README.md`
  - `ROADMAP.md`
  - `docs/automation/automation-readiness.md`
  - `docs/automation/graphify-resource-graph-scope.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`
- Deleted：
  - `examples/README.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未修改业务代码。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Project supervision / examples cleanup 无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Codex Use Cases Alignment

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将 OpenAI Codex use cases 映射到 MTPRO 当前工程流程。
- 补齐 codebase onboarding、Codex code review、verified operations、macOS build / run loop、eval strategy 和 docs sync 的本地规则。
- 明确当前不引入独立 eval 框架，并记录未来允许引入的条件。
- 新增代码详细中文注释规则。

文件范围：

- Created：
  - `docs/automation/codex-use-cases-alignment.md`
  - `docs/automation/verified-operations.md`
  - `docs/validation/eval-strategy.md`
  - `docs/validation/macos-build-run-loop.md`
- Updated：
  - `AGENTS.md`
  - `README.md`
  - `.github/pull_request_template.md`
  - `checks/automation-readiness.sh`
  - `docs/automation/automation-readiness.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未修改业务代码。
- 未引入独立 eval 框架。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Codex use-cases alignment 文档和检查更新无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Team Role Map Alignment

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 按 Codex use cases 的 Team 视角完善 MTPRO 项目角色图。
- 补齐 Product / Design / Engineering / Finance / Operations / QA 的职责映射。
- 新增 Finance / Trading Domain Analyst、Product Designer、Frontend / App Designer 和 Automation / Runtime Operations Engineer 边界。
- 将交易语义验证、fees / slippage、Backtest / Paper parity 和 runtime readiness 纳入角色和验证规则。

文件范围：

- Updated：
  - `README.md`
  - `AGENTS.md`
  - `docs/planning/project-role-map.md`
  - `docs/validation/validation-plan.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未修改业务代码。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Team role map alignment 无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Active Documentation Closeout

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 从 `README.md` 开始梳理 MTPRO active documentation。
- 移除 active docs 中写死 current issue / stale Linear 状态的表述。
- 压缩 README、ROADMAP、ENVIRONMENT、ARCHITECTURE、automation readiness、Graphify scope、validation plan 和 Linear draft plan。
- 明确 `MTPRO 引导` Project 已完成，当前下一步是 Human 基于阶段审计报告规划新的 Linear Project。

文件范围：

- Updated：
  - `README.md`
  - `ENVIRONMENT.md`
  - `GOAL.md`
  - `AGENTS.md`
  - `ARCHITECTURE.md`
  - `ROADMAP.md`
  - `checks/automation-readiness.sh`
  - `docs/automation/automation-readiness.md`
  - `docs/automation/graphify-resource-graph-scope.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改业务代码。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未压缩历史 verification 记录。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Active docs closeout 无空白问题。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.` |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## 最近验证摘要

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 新增最近验证摘要，降低 Agent / Graphify 日常读取完整 `verification.md` 的上下文成本。
- 保持 `verification.md` 为 append-only 完整证据流水账。

文件范围：

- Created：
  - `docs/validation/latest-verification-summary.md`
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `docs/automation/graphify-resource-graph-scope.md`
  - `checks/automation-readiness.sh`
  - `verification.md`
- Deleted：
  - 无

边界确认：

- 未修改业务代码。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未压缩、拆分或重写历史 verification 记录。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 最近验证摘要无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Runtime Research Workbench Linear Planning

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将 Human 确认的 `MTPRO Runtime Research Workbench v1` 写入 Linear。
- 创建 `MTP-16` 到 `MTP-23`，全部保持 `Backlog` / non-executable。
- 统一 Linear Project / Issue 正文为 Codex Execution Agent 执行合同格式。
- 在仓库中只记录摘要、issue 顺序、依赖和格式规则，不复制 8 个 issue 全文。

Linear 写入摘要：

- Project：`MTPRO Runtime Research Workbench v1`
- Project status：`Planned`
- Issue range：`MTP-16` 到 `MTP-23`
- Current Todo：none
- First executable candidate：`MTP-16`
- WIP=1：当前满足，未推进任何 issue 到 `Todo`

Linear issue 顺序：

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

Linear blocker 依赖：

- `MTP-17` blocked by `MTP-16`。
- `MTP-18` blocked by `MTP-17`。
- `MTP-19` blocked by `MTP-17`。
- `MTP-20` blocked by `MTP-16`。
- `MTP-21` blocked by `MTP-17`, `MTP-18`, `MTP-19`, `MTP-20`。
- `MTP-22` blocked by `MTP-18`, `MTP-19`, `MTP-21`。
- `MTP-23` blocked by `MTP-21`, `MTP-22`。

仓库文件范围：

- Updated：
  - `AGENTS.md`
  - `ROADMAP.md`
  - `checks/automation-readiness.sh`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未写业务代码。
- 未推进任何 Linear issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 仓库文档只记录摘要和格式规则，不复制 8 个 issue 全文。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Project Planning / Parent / Child Role Boundaries

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 固化 MTPRO 当前流程中的 Project Planning Facilitator、Parent Codex Automation Supervision 和 Child Codex Execution Agent 三角色职责边界。
- 明确 Project Planning Facilitator 只负责阶段规划、Linear Project / Issue 草案和写入准备，不操作 `Backlog` -> `Todo`。
- 明确第一个 issue 和后续 issue 的 `Backlog` -> `Todo` 都只能由 Parent Codex 在 Human 明确授权后执行。

文件范围：

- Updated：
  - `AGENTS.md`
  - `docs/automation/automation-readiness.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/planning/project-role-map.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未写业务代码。
- 未创建 Linear Project / Issue。
- 未推进任何 Linear issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 三角色职责边界文档变更通过 whitespace 检查。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## symphony-issue Active Project Pointer

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将 MTPRO 本地 `symphony-issue` workflow 定位为稳定执行规则 + active Project pointer。
- 将当前 active Project pointer 切到 `MTPRO Runtime Research Workbench v1`。
- 明确 Parent Codex 负责 Project 切换时更新 pointer，并在更新后先做 queue preview。

文件范围：

- Created：
  - `docs/automation/symphony-issue-workflow-template.md`
- Updated：
  - `AGENTS.md`
  - `docs/automation/automation-readiness.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`
- Local-only runtime updated：
  - `/Users/mac/code/symphony-workflows/mtpro-aep-v2.md`
  - `/Users/mac/code/symphony-workflows/runtime/mtpro-aep-v2-local-seed.md`
  - `/Users/mac/code/symphony-workflows/README.md`

边界确认：

- 未写业务代码。
- 未创建 Linear Project / Issue。
- 未推进任何 Linear issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 本地 workflow pointer 更新不授权执行。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | `symphony-issue` active Project pointer 文档变更通过 whitespace 检查。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## MTP-16 Core Domain File Split

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 按 Linear issue `MTP-16` 将 `Sources/Core/Core.swift` 按领域边界拆分为多个文件。
- 保持 `Core` module public API、行为和现有测试语义不变。
- 补齐触达 production code 的中文边界注释，明确 read-only market data、append-only event log、Paper-only 和禁止 Live trading / signed endpoint / broker action。

文件范围：

- Deleted：
  - `Sources/Core/Core.swift`
- Created：
  - `Sources/Core/CoreError.swift`
  - `Sources/Core/MarketPrimitives.swift`
  - `Sources/Core/MarketDataModels.swift`
  - `Sources/Core/OrderBookReadModel.swift`
  - `Sources/Core/StrategySignals.swift`
  - `Sources/Core/OrderBookImbalance.swift`
  - `Sources/Core/EMACross.swift`
  - `Sources/Core/CommandsAndQueries.swift`
  - `Sources/Core/ResearchResults.swift`
  - `Sources/Core/DomainEvents.swift`
  - `Sources/Core/ResearchEventFlows.swift`
  - `Sources/Core/EventLog.swift`
  - `Sources/Core/MarketDataCache.swift`
  - `Sources/Core/TradingKernel.swift`
  - `Sources/Core/CoreBaseline.swift`

边界确认：

- 未新增业务功能。
- 未修改策略逻辑。
- 未修改 persistence、adapter、App 行为。
- 未引入数据库、网络或 UI。
- 未触碰 Live trading、signed endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

行为保持检查：

- public 顶层类型数量：拆分前 66，拆分后 66。
- public 顶层类型缺失：无。
- public 顶层类型新增：无。
- `StrategyMarketDataValidation` 仍为 `ResearchEventFlows.swift` 文件内 private helper。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 修复一次机械切分遗漏括号后，39 个 XCTest 通过。 |
| `git diff --check` | pass | Core 文件拆分无 whitespace error。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Parent Codex Auto Project Scheduling

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将 MTPRO 中 Parent Codex Automation Supervision 调整为 Project 级自动调度角色。
- 明确 Human 授权停留在 Project / Issue plan review 和 Linear 写入层；`MTPRO Runtime Research Workbench v1` 内后续 eligible issue 由父 Codex 按 queue preflight 自动推进。

文件范围：

- Updated：
  - `README.md`
  - `AGENTS.md`
  - `.github/pull_request_template.md`
  - `docs/automation/automation-readiness.md`
  - `docs/automation/codex-use-cases-alignment.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/automation/post-issue-ledger.md`
  - `docs/automation/symphony-issue-workflow-template.md`
  - `docs/automation/verified-operations.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/planning/project-role-map.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未写业务代码。
- 未创建 Linear Project / Issue。
- 未推进任何 Linear issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update / full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 父 Codex 自动调度仍必须通过 WIP=1、依赖、previous issue Done 和 execution contract Gate。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Parent Codex 自动 Project 调度文档变更通过 whitespace 检查。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；39 个 XCTest 通过，输出 `MTPRO checks passed.` |

## MTP-17 File-backed Append-only Event Log

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 按 Linear issue `MTP-17` 新增追加式事件日志文件持久化边界。
- 支持写入 Core `EventEnvelope`，并按 `EventReplayCommand` 从文件事实源 replay。
- 验证 append-only sequence 不变量和 replay smoke path，为后续 SQLite / DuckDB adapter 提供稳定事实源。
- 保持文件格式对 UI、数据库 schema 和外部 API 不可见。

文件范围：

- Updated：
  - `Sources/Persistence/Persistence.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/persistence-boundary.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未实现 SQLite adapter。
- 未实现 DuckDB adapter。
- 未做 schema migration。
- 未接 Binance 网络。
- 未做 UI。
- 未触碰 Live trading、signed endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 42 个 XCTest 通过；新增文件事件日志 append、append-only 拒绝跳号、file replay projection smoke 测试。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；42 个 XCTest 通过，输出 `MTPRO checks passed.` |

## MTP-18 SQLite Runtime Projection Adapter

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 按 Linear issue `MTP-18` 新增 SQLite runtime projection adapter 最小闭环。
- 基于 MTP-17 event log / replay envelope 重建 paper session、risk rejection、portfolio projection。
- 提供 query snapshot，把 SQLite 私有投影存储重新读回稳定 `SQLiteRuntimeProjectionSnapshot`。
- 保持 SQLite schema、SQL statement 和 payload 编码不暴露给 UI、API 或 ViewModel contract。

文件范围：

- Updated：
  - `Package.swift`
  - `Sources/Persistence/Persistence.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/persistence-boundary.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- Event Log / replay envelope 仍是事实源。
- SQLite 只作为运行时投影 adapter，不保存真实 broker 状态。
- 未做完整 schema 设计。
- 未做 migration framework。
- 未引入 ORM。
- 未实现 DuckDB adapter。
- 未接 Binance 网络。
- 未做 UI。
- 未触碰 Live trading、signed endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 45 个 XCTest 通过；新增 SQLite runtime projection adapter rebuild / query snapshot / replacement / empty snapshot 测试。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；45 个 XCTest 通过，输出 `MTPRO checks passed.` |

## MTP-19 DuckDB Analytical Projection Adapter

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 按 Linear issue `MTP-19` 新增 DuckDB analytical projection adapter 最小闭环。
- 基于 MTP-17 event log / replay envelope 重建 market data、backtest run、order book research run 和 signal timeline。
- 在 macOS runtime target 使用官方 SwiftPM 包 `duckdb/duckdb-swift`，提供 query snapshot，把 DuckDB 私有分析投影存储重新读回稳定 `DuckDBAnalyticalProjectionSnapshot`。
- 保持 DuckDB schema、SQL statement 和 payload 编码不暴露给 UI、API 或 ViewModel contract。

文件范围：

- Added：
  - `Package.resolved`
  - `Sources/Persistence/DuckDBAnalyticalProjectionAdapter.swift`
- Updated：
  - `Package.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/persistence-boundary.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- Event Log / replay envelope 仍是事实源。
- DuckDB 只作为分析投影 adapter，不保存 runtime object 或真实 broker 状态。
- 未做完整 schema 设计。
- 未做 migration framework。
- 未引入 ORM。
- 未扩展 SQLite runtime adapter。
- 未接 Binance 网络。
- 未做 UI。
- 未触碰 Live trading、signed endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- GitHub Ubuntu runner 不构建官方 DuckDB Swift wrapper；真实 DuckDB adapter 由 macOS 本地验证覆盖，Linux CI 只编译公共 API。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter PersistenceTests/testDuckDBAnalyticalProjectionAdapter` | pass | 3 个 DuckDB adapter focused tests 通过；覆盖 rebuild / query snapshot、重复 rebuild 替换旧投影、空 snapshot。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；48 个 XCTest 通过，输出 `MTPRO checks passed.` |

## MTP-20 Binance Public Read-only Client Boundary

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 按 Linear issue `MTP-20` 新增 Binance public read-only market data client boundary。
- 在现有 endpoint contract 和 fixture decoder 基础上增加 client configuration、transport request、transport protocol、URLSession transport 和 client facade。
- 通过 mock transport required validation 覆盖 REST public endpoint、public depth stream path、fixture parity 和 forbidden capability 断言。
- 保持 required validation 不依赖真实 Binance 网络；真实网络 smoke test 仍仅可作为可选人工证据。

文件范围：

- Updated：
  - `Sources/Adapters/Adapters.swift`
  - `Tests/AdaptersTests/AdaptersTests.swift`
  - `docs/architecture/module-boundary.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- Binance client 只读取 public market data。
- request 发给 transport 前校验 `isReadOnly == true` 和 `requiresAPIKey == false`。
- request 发给 transport 前校验 path 属于 Binance public market data allowlist。
- transport request 不携带 API key、signature、listenKey、account、order、SAPI、FAPI 或 DAPI 片段。
- 未做 MTP-21 ingest 串联。
- 未写 Event Log。
- 未接 DataEngine / TradingKernel。
- 未做 SwiftUI 页面。
- 未把真实 Binance 网络 smoke test 作为 required validation。
- 未触碰 Live trading、signed endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AdaptersTests` | pass | 12 个 AdaptersTests 通过；新增 mock transport、REST fixture parity、public depth stream path 和 mutable/API-key contract transport 前拒绝测试。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；52 个 XCTest 通过，输出 `MTPRO checks passed.` |
