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

## MTP-21 Runtime Market Data Ingest Replay Projection

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 按 Linear issue `MTP-21` 串联 Binance public read-only market data ingest -> Core event log -> replay -> SQLite / DuckDB projection snapshots。
- 新增薄 `Runtime` target，依赖 `Adapters`、`Core` 和 `Persistence` 做跨模块编排，避免 `App` 直接调用 Binance adapter。
- required validation 使用 mock transport / fixture parity，不依赖真实 Binance 网络。
- 验证 market event sequence 单调、replay deterministic、DuckDB analytical snapshot 来自 replay，SQLite runtime snapshot 在 market-only ingest 下保持稳定空 snapshot。

文件范围：

- Added：
  - `Sources/Runtime/Runtime.swift`
  - `Tests/RuntimeTests/RuntimeTests.swift`
- Updated：
  - `Package.swift`
  - `README.md`
  - `ARCHITECTURE.md`
  - `docs/architecture/module-boundary.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/contracts/persistence-boundary.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- Runtime 只消费 Binance public read-only client 输出。
- 自动验证只使用 mock transport 和 fixture payload。
- request 不携带 API key、signature、listenKey、account、order、SAPI、FAPI 或 DAPI 片段。
- Event Log / replay envelope 仍是事实源。
- Projection snapshots 来自 replay，不暴露 SQLite / DuckDB schema。
- Market-only ingest 不伪造 Paper / Risk / Portfolio runtime facts。
- 未新增 UI。
- 未新增完整报表路径。
- 未把真实 Binance 网络 smoke test 作为 required validation。
- 未触碰 Live trading、signed endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 55 个 XCTest 通过；新增 3 个 RuntimeTests 覆盖端到端 ingest / event log / replay / projection snapshot、非空 file event log 拒绝和 SQLite adapter replay query。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh` 和 `swift test` 通过；55 个 XCTest 通过，输出 `MTPRO checks passed.` |

## MTP-22 macOS Dashboard Shell

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 按 Linear issue `MTP-22` 新增绑定 `DashboardViewModel` snapshot 的 macOS 只读看板 shell。
- 新增 `MTPRODashboard` SwiftPM executable，提供可构建、可 smoke-run 的 macOS app shell 入口。
- 展示 Market / Strategy / Backtest / Paper / Risk / Portfolio / Events 七个只读区域。
- 验证 shell 只消费 App 层 ViewModel / Read Model，不导入 Runtime / Adapters，不直连 database schema 或行情 adapter。

文件范围：

- Added：
  - `Sources/App/DashboardShell.swift`
  - `Sources/MTPRODashboard/MTPRODashboardApplication.swift`
- Updated：
  - `Package.swift`
  - `Sources/App/App.swift`
  - `Tests/AppTests/AppTests.swift`
  - `checks/run.sh`
  - `README.md`
  - `ARCHITECTURE.md`
  - `ENVIRONMENT.md`
  - `docs/product/product-surface-map.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/macos-build-run-loop.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- SwiftUI shell 唯一输入是 `DashboardViewModel` / `DashboardShellSnapshot`。
- 默认 app launch snapshot 是空 read model projection，不伪造 market、paper、risk、portfolio 或 event facts。
- `MTPRODashboard` executable 只依赖 `App` target。
- `Sources/App/DashboardShell.swift` 和 `Sources/MTPRODashboard/MTPRODashboardApplication.swift` 不导入 Runtime / Adapters。
- shell source 不直接引用 database implementation 名或 public market data client 类型。
- 未提供 live order button。
- 未连接真实 broker / exchange。
- 未读取 secret。
- 未触碰 signed endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift build --product MTPRODashboard` | pass | macOS dashboard executable 构建通过。 |
| `MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` | pass | 输出 `MTPRO Dashboard smoke: sections=7; readModelOnly=true; sections=Market,Strategy,Backtest,Paper,Risk,Portfolio,Events`。 |
| `swift test` | pass | 58 个 XCTest 通过；新增 AppTests 覆盖 shell snapshot binding、空 read model 初始快照和 forbidden integration source boundary。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、`swift build --product MTPRODashboard`、`MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` 和 `swift test` 通过；58 个 XCTest 通过，输出 `MTPRO checks passed.` |

CI 修复记录：

- GitHub Actions 初次运行失败：Linux runner 编译 `App` target 时不提供 SwiftUI，错误为 `no such module 'SwiftUI'`。
- 修复方式：`DashboardShell.swift` 保留跨平台 shell snapshot contract；真实 SwiftUI view 只在 `canImport(SwiftUI) && os(macOS)` 分支构建，非 macOS 使用 snapshot-only fallback 供 XCTest 和 CI 验证。
- 二次修复：SwiftPM Linux `swift test` 仍会编译 executable target，因此 `MTPRODashboardApplication` 也新增非 macOS command-line fallback，避免 unconditional `Darwin` / `SwiftUI` import。
- `checks/run.sh` 修复为只在 Darwin runner 执行 `swift build --product MTPRODashboard` 和 dashboard smoke run；Linux CI 跳过 macOS-only shell build / smoke 后继续运行 `swift test`。

## MTP-23 Research -> Backtest -> Report 最小路径

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 按 Linear issue `MTP-23` 新增 Research -> Backtest -> Report 最小路径。
- 新增 `ReportReadModel`、`ResearchBacktestReportArtifact`、`ReportViewModel` 和 Dashboard Report 快照。
- 复用既有 strategy / backtest / paper parity / projection snapshots，不新增 Runtime / Adapter 依赖。
- 准备阶段证据材料 `docs/validation/mtp-23-stage-evidence.md`。
- 明确 Stage Code Audit Report 不属于本 issue，必须在 Project 全部 Done 后由父 Codex 单独输出。

文件范围：

- Updated：
  - `Sources/App/App.swift`
  - `Sources/App/DashboardShell.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/product/product-surface-map.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`
- Added：
  - `docs/validation/mtp-23-stage-evidence.md`

边界确认：

- Report 输入只来自 `DuckDBAnalyticalProjectionSnapshot`、`SQLiteRuntimeProjectionSnapshot` 和 append-only event timeline 派生的 read model。
- Report 只表达 projection-level Backtest / Paper evidence，不替代 Core 层完整 signal timeline parity。
- Dashboard shell 只展示 Report ViewModel 快照，不导入 Runtime / Adapters，不调用行情 adapter。
- Report artifact 的 execution authorization 固定为 research output only。
- 未输出 Stage Code Audit Report。
- 未做完整报表系统。
- 未扩展完整 Paper execution 工作流。
- 未连接真实 broker / exchange。
- 未读取 secret。
- 未触碰 Live trading、signed endpoint、account endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 59 个 XCTest 通过；新增 AppTests 覆盖 Report read model、Dashboard Report 快照、projection-level parity evidence 和 missing Paper projection 禁区断言。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、`swift build --product MTPRODashboard`、`MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` 和 `swift test` 通过；smoke 输出 `sections=8`；59 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Runtime Research Workbench Stage Code Audit 落仓

日期：2026-05-18

执行者：Parent Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将本会话已输出的 `MTPRO Runtime Research Workbench v1` Stage Code Audit Report 固化为 canonical 仓库文档。
- 新增 `docs/audit/mtpro-runtime-research-workbench-v1-stage-code-audit.md`，作为后续 Next Human Project Planning 的固定读取入口。
- 更新 `docs/validation/latest-verification-summary.md`，指向新的 Stage Code Audit Report。
- 补充 Known CI Boundary，记录 `MTP-18` / `MTP-19` / `MTP-22` 的临时 CI 平台边界、修复方式和最终通过 run。

边界确认：

- 未修改 Linear Project / Issue。
- 未修改 Linear status。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未修改业务代码。
- 未创建下一阶段 Project / Issue。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 文档变更无空白错误。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、`swift build --product MTPRODashboard`、`MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` 和 `swift test` 通过；59 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Stage Code Audit Report Repository Gate

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 固化 MTPRO Stage Code Audit Report 落仓规则。
- 明确命名规则为 `docs/audit/<linear-project-slug>-stage-code-audit.md`。
- 明确 Stage Code Audit Report 必须覆盖完整 Linear Project，不得只覆盖单个 issue。
- 明确 Next Human Project Planning 必须读取落仓的 Project 级审计报告。

文件范围：

- Updated：
  - `README.md`
  - `AGENTS.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/audit/mtpro-runtime-research-workbench-v1-stage-code-audit.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未修改 Linear Project / Issue。
- 未修改 Linear status。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未修改业务代码。
- 未创建下一阶段 Project / Issue。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Stage Code Audit Report 落仓规则文档变更无空白错误。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build / smoke 和 `swift test` 通过；59 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Role Alias Number Rule

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 固化 MTPRO 三位数字编号和三字母角色代号规则。
- 明确 `@001 = PLN`，并固定 `001` 到 `007` 的核心角色映射。
- 明确角色编号只用于沟通压缩，不改变职责边界，不授权执行。

文件范围：

- Updated：
  - `AGENTS.md`
  - `docs/planning/project-role-map.md`
  - `docs/automation/parent-codex-supervision.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未修改 Linear Project / Issue。
- 未修改 Linear status。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未修改业务代码。
- 未创建下一阶段 Project / Issue。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Role Alias Rule 文档变更无空白错误。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build / smoke 和 `swift test` 通过；59 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Trading Validation Project Planning Record

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 新增 `MTPRO Trading Validation and Parity Hardening` 写入 Linear 前的 Project Planning Record。
- 在 `docs/planning/linear-draft-plan.md` 中链接当前 planning record。
- 明确仓库只保存 Project 级计划摘要和格式门槛。
- 明确完整 issue execution contract 以 Linear issue body 为准。

文件范围：

- Created：
  - `docs/planning/mtpro-trading-validation-and-parity-hardening-plan.md`
- Updated：
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 Todo。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未写业务代码。
- 未复制 7 个 issue 的完整正文到仓库。
- 未把 planning record 当作执行授权。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Trading Validation planning record 文档变更无空白错误。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build / smoke 和 `swift test` 通过；输出 `MTPRO checks passed.` |

## Project Planning Record Structure Normalization

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 将历史 Project planning 内容迁移到 `docs/planning/projects/`。
- 固化 Project Planning Record 的 canonical 命名规则和内容规则。
- 将 `docs/planning/linear-draft-plan.md` 收敛为入口索引和边界规则文档。
- 明确完整 issue execution contract 归属 Linear issue body。

文件范围：

- Created：
  - `docs/planning/projects/mtpro-guidance-plan.md`
  - `docs/planning/projects/mtpro-runtime-research-workbench-v1-plan.md`
  - `docs/planning/projects/mtpro-trading-validation-and-parity-hardening-plan.md`
- Deleted：
  - `docs/planning/mtpro-trading-validation-and-parity-hardening-plan.md`
- Updated：
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 Todo。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未写业务代码。
- 未复制完整 issue body 到仓库。
- 未把 planning record 当作执行授权。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Project Planning Record 结构迁移文档变更无空白错误。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build / smoke 和 `swift test` 通过；输出 `MTPRO checks passed.` |

## Parent Codex Startup Runbook

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 固化 `@002 / PAR` 接管已写入 Linear Project 时的启动 runbook。
- 明确执行前检查、active Project pointer 更新、pointer 后二次 queue preview 和唯一 eligible issue 推进必须作为连续动作处理。

文件范围：

- Updated：
  - `AGENTS.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/automation/symphony-issue-workflow-template.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 Todo。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Parent Codex startup runbook 文档变更无空白错误。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build / smoke 和 `swift test` 通过；输出 `MTPRO checks passed.` |

## MTP-24 Trading Validation Matrix

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 新增 `docs/validation/trading-validation-matrix.md`，作为 Trading Validation Matrix 和验收证据边界入口。
- 记录 EMA parity、order book imbalance parity、fees / slippage、risk blocker、portfolio exposure 和 report evidence 的现有 coverage、证据边界和后续回填责任。
- 在 `checks/automation-readiness.sh` 中检查 matrix 文件和 required `TVM-*` anchors，防止矩阵入口丢失。
- 在 `docs/validation/validation-plan.md` 中链接 matrix，并记录 MTP-24 的 required validation。
- 更新最近验证摘要，保留 MTP-24 本轮验证结果和当前 Project 边界。

文件范围：

- Created：
  - `docs/validation/trading-validation-matrix.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 production Swift code。
- 未实现策略逻辑。
- 未实现 fees / slippage 计算。
- 未实现 risk engine。
- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未接 Live trading、signed endpoint、account endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；已检查 `docs/validation/trading-validation-matrix.md` 和 `TVM-EMA-PARITY`、`TVM-ORDER-BOOK-IMBALANCE-PARITY`、`TVM-FEES-SLIPPAGE`、`TVM-RISK-BLOCKER`、`TVM-PORTFOLIO-EXPOSURE`、`TVM-REPORT-EVIDENCE`、`TVM-FUTURE-ISSUE-BACKFILL`。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 通过；59 个 XCTest 通过；输出 `MTPRO checks passed.` |

## 2026-05-18 — MTP-25 EMA Backtest / Paper parity hardening

执行者：Codex

关联 Linear issue：`MTP-25` — 加固 EMA Backtest / Paper signal timeline parity。

本轮变更：

- `BacktestEventFlow` / `PaperSessionEventFlow` 在 EMA 计算前校验 bars 是否被 `MarketDataQuery.range` 完整覆盖。
- 新增 deterministic Core tests，覆盖 strategy config、symbol、timeframe、warm-up、signal direction、timestamp、完整 signal timeline 和 query range too narrow 错误边界。
- 回填 `docs/validation/trading-validation-matrix.md` 的 `TVM-EMA-PARITY`。
- 更新 `docs/contracts/backend-use-case-contract.md`、`docs/contracts/api-contract.md` 和 `docs/validation/validation-plan.md` 的 MTP-25 契约 / 验证说明。

验证命令：

```bash
swift test --filter CoreTests/testEMA
bash checks/run.sh
```

验证结果：

- `swift test --filter CoreTests/testEMA` 通过：4 个 EMA XCTest，0 failure。
- 更新 latest summary 后的两次中间验证失败均来自 automation readiness 固定锚点缺失：先缺少 `临时 CI 平台边界`，再缺少 `覆盖完整 Linear Project`；两个锚点已恢复。
- `bash checks/run.sh` 通过：`git diff --check`、`bash checks/automation-readiness.sh`、`swift build --product MTPRODashboard`、`MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard`、`swift test` 均通过。
- `swift test` 全量结果：61 个 XCTest，0 failure。
- Dashboard smoke 输出：`MTPRO Dashboard smoke: sections=8; readModelOnly=true; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。
- 最终输出：`MTPRO checks passed.`。

边界确认：

- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint、account endpoint、broker action 或真实订单行为。
- 未修改 Linear status。
- 未运行 Graphify full rebuild。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

## Root Docs Refresh Gate

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 固化 Project Done 后的 Root Docs Refresh Gate。
- 明确 Stage Code Audit Report 必须包含 Root Docs Delta。
- 明确 `@002 / PAR` 只同步 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md`、`ROADMAP.md` 中已发生的事实；方向性变化交给 Human + `@001 / PLN`。

文件范围：

- Updated：
  - `AGENTS.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 Todo。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Root Docs Refresh Gate 文档变更无空白错误。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build / smoke 和 `swift test` 通过；61 个 XCTest 通过；输出 `MTPRO checks passed.` |

## MTP-26 Order Book Imbalance parity / bias evidence

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 为 `OrderBookImbalanceSignalSample` 增加 `inputSource`，让订单簿失衡信号 evidence 可追溯到原始 snapshot 或 delta 应用后的本地读模型。
- 新增 `OrderBookImbalanceResearchParity` 与 `OrderBookImbalanceResearchParityResult`，比较直接策略 contract 和 research event flow 的 signal samples。
- 明确 ask dominance 只作为 research bias，signal direction 仍为 `.flat`，不映射为 short、margin、futures leverage 或真实订单动作。
- 在 DuckDB analytical signal timeline projection 中保留 `orderBookInputSource`，供 read model / report evidence 使用，不暴露数据库 schema。
- 回填 `TVM-ORDER-BOOK-IMBALANCE-PARITY`，并在 validation plan / contract docs 记录 MTP-26 验收边界。

文件范围：

- Updated：
  - `Sources/Core/OrderBookImbalance.swift`
  - `Sources/Core/ResearchEventFlows.swift`
  - `Sources/Persistence/Persistence.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未运行 Graphify full rebuild。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未实现 futures leverage / margin action。
- 未实现 Paper 或 Live execution 推进。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests/testOrderBookImbalance` | pass | 4 个 CoreTests 通过；覆盖订单簿失衡 invalid input、research stream、parity / bias evidence 和 deterministic fixture。 |
| `swift test --filter PersistenceTests/testTemporaryDuckDBProjectionRebuildsAnalyticalState` | pass | 1 个 PersistenceTests 通过；验证 DuckDB analytical signal timeline 保存 order book input source。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 通过；62 个 XCTest 通过；输出 `MTPRO checks passed.` |

## MTP-27 Fees / slippage assumptions and minimum cost evidence

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 新增 Core-only `ExecutionCostAssumptions`，定义 deterministic fixture：maker fee `2 bps`、taker fee `5 bps`、fixed slippage `1.5 bps` 和 `8` 位小数 rounding scale。
- 新增 `ExecutionCostEstimateRequest` / `ExecutionCostEstimate` / `ExecutionCostCalculator`，输出 gross notional、fee amount、slippage amount 和 total cost amount。
- 新增 `ExecutionCostParity` / `ExecutionCostParityResult`，比较 Backtest 与 Paper 使用同一固定假设和同一输入时的 cost evidence 是否一致。
- 回填 `TVM-FEES-SLIPPAGE`，并在 validation plan / contract docs 记录 MTP-27 验收边界。

文件范围：

- Added：
  - `Sources/Core/ExecutionCosts.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未运行 Graphify full rebuild。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未实现 exchange fee table。
- 未实现 dynamic slippage model。
- 未实现 execution cost optimizer。
- 未实现 Paper 或 Live execution 推进。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests/testExecutionCost` | pass | 3 个 CoreTests 通过；覆盖 maker / taker fee、fixed slippage、gross notional、total cost、rounding scale、Backtest / Paper cost parity 和 invalid assumptions。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 通过；65 个 XCTest 通过；输出 `MTPRO checks passed.` |

## MTP-28 Risk blocker evidence and portfolio exposure read model

日期：2026-05-18

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 新增 `RiskBlockerEvidence` / `RiskBlockerReason`，记录 proposed Paper action context、risk profile、blocker reason 和 generatedAt。
- 新增 `PortfolioExposureSnapshot` / `PortfolioExposureSource`，记录 paper-only portfolio exposure、reference price、gross exposure notional 和 source。
- 扩展 SQLite runtime projection，保存 risk blocker evidence、portfolio exposure、source sequence 和 projected timestamp。
- 扩展 App / Dashboard Risk / Portfolio 只读 ViewModel，展示 blocker reason、exposure count 和 gross exposure notional。
- 回填 `TVM-RISK-BLOCKER`、`TVM-PORTFOLIO-EXPOSURE`，并在 validation plan / contract docs 记录 MTP-28 验收边界。

文件范围：

- Updated：
  - `Sources/Core/CoreError.swift`
  - `Sources/Core/CommandsAndQueries.swift`
  - `Sources/Core/DomainEvents.swift`
  - `Sources/Persistence/Persistence.swift`
  - `Sources/App/App.swift`
  - `Sources/App/DashboardShell.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/persistence-boundary.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未运行 Graphify full rebuild。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未实现完整风险引擎。
- 未实现实时风控。
- 未实现仓位管理、保证金、杠杆。
- 未实现真实账户余额、broker balance 或 Live execution。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests/testRiskBlockerEvidenceAndPortfolioExposureRemainPaperOnlyReadModels` | pass | 1 个 CoreTests 通过；覆盖 proposed Paper action context、risk profile、blocker reason、paper-only execution mode、portfolio exposure source 和 gross exposure notional。 |
| `swift test --filter <MTP-28 targeted Persistence/App tests>` | pass | 4 个 targeted XCTest 通过；覆盖 SQLite runtime projection、Risk / Portfolio ViewModel 和 Dashboard shell snapshot。 |
| `swift test` | pass | 66 个 XCTest 通过；新增 MTP-28 risk blocker / portfolio exposure evidence coverage。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 通过；66 个 XCTest 通过；输出 `MTPRO checks passed.` |

## MTP-29 Report / Dashboard trading validation evidence summary

日期：2026-05-19

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 新增 `ReportExecutionCostEvidence`，把 MTP-27 deterministic fees / slippage fixture 和 paper-only portfolio exposure projection 映射为 Report 层只读成本证据。
- 新增 `TradingValidationEvidenceSummary`，聚合 projection-level parity、Backtest / Paper cost parity、risk blocker evidence 和 portfolio exposure evidence。
- 扩展 `ResearchBacktestReportArtifact`、`ReportArtifactViewModel` 和 `ReportViewModel`，展示 cost assumption IDs、cost evidence count、cost parity consistency、risk blocker evidence IDs、portfolio exposure symbols 和 gross exposure notional。
- 扩展 Dashboard Report shell snapshot，展示 cost evidence、risk blockers、exposure evidence、cost parity、risk blocker evidence、exposure symbols 和 gross exposure。
- 回填 `TVM-REPORT-EVIDENCE`、validation plan、read model / frontend contract 和 product surface map。

文件范围：

- Updated：
  - `Sources/App/App.swift`
  - `Sources/App/DashboardShell.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未运行 Graphify full rebuild。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未实现完整报表系统。
- 未实现交易所费率表、动态滑点模型或执行成本优化。
- 未实现完整风险引擎、实时风控、仓位管理、保证金、杠杆或真实账户余额。
- 未实现 Paper 或 Live execution 推进。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 8 个 AppTests 通过；覆盖 Report / Dashboard trading validation evidence summary、Codable deterministic snapshot、schema leakage 禁区和 research-only execution authorization。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 通过；66 个 XCTest 通过；输出 `MTPRO checks passed.` |

## MTP-30 Validation summary, automation evidence, and Stage Code Audit input

日期：2026-05-19

执行者：Codex

PR：本轮 PR

Commit：本轮提交

目的：

- 更新最近验证摘要，记录 `MTPRO Trading Validation and Parity Hardening` 中 `MTP-24` 至 `MTP-29` 的 Done evidence 和 MTP-30 当前收口目标。
- 回填 `docs/validation/trading-validation-matrix.md` 的 MTP-30 阶段收口说明。
- 新增 `docs/validation/mtp-30-stage-audit-input.md`，汇总 Issue / PR evidence、merge commit、required check、matrix evidence chain、known boundaries、automation readiness evidence、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- 更新 `docs/validation/validation-plan.md` 和 `checks/automation-readiness.sh`，使 MTP-30 输入材料和关键锚点进入本地机械检查。

文件范围：

- Added：
  - `docs/validation/mtp-30-stage-audit-input.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未输出最终 Stage Code Audit Report。
- 未修改 active Project pointer。
- 未运行 Graphify full rebuild。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未实现完整报表系统。
- 未实现交易所费率表、动态滑点模型或执行成本优化。
- 未实现完整风险引擎、实时风控、仓位管理、保证金、杠杆或真实账户余额。
- 未实现 Paper 或 Live execution 推进。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；MTP-30 Stage Code Audit input、Trading Validation Matrix 和 automation anchors 完整。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 通过；66 个 XCTest 通过；输出 `MTPRO checks passed.` |

## MTPRO Trading Validation and Parity Hardening Stage Code Audit Report

日期：2026-05-19

执行者：Parent Codex Automation Supervision（@002 / PAR）

目的：

- 将 `MTPRO Trading Validation and Parity Hardening` 的 Project 级 Stage Code Audit Report 落仓到 canonical audit path。
- 同步最新验证摘要，记录 `MTP-24` 到 `MTP-30` 全部 Done、PR evidence、final validation、Known CI Boundary、Boundary Audit 和 Next Human Project Planning handoff。
- 通过 Root Docs Refresh Gate 更新 `README.md` 与 `ROADMAP.md` 中已发生的 Project 完成事实。

文件范围：

- Added：
  - `docs/audit/mtpro-trading-validation-and-parity-hardening-stage-code-audit.md`
- Updated：
  - `README.md`
  - `ROADMAP.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未推进任何 issue 到 `Todo`。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未写业务代码。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未实现 Live execution。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 本轮 Stage Code Audit Report 和文档更新无空白问题。 |
| `bash checks/run.sh` | failed first attempt | 首次本地增量构建在 `swift test` 链接阶段引用旧的 `SQLiteRuntimeProjectionSnapshot` 符号并失败；本轮仅改文档，判断为 SwiftPM 本地缓存边界。 |
| `swift package clean && bash checks/run.sh` | pass | 清理 SwiftPM build cache 后，同一验证入口通过；`git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 通过；66 个 XCTest 通过；输出 `MTPRO checks passed.` |

## MTPRO Paper Session Runtime v1 Project Planning Record

日期：2026-05-19

执行者：Codex（@001 / PLN）

目的：

- 将 Human 确认的 `MTPRO Paper Session Runtime v1` 修正版 Project / Issue 草案落仓为 Project-level planning record。
- 新增 `docs/planning/projects/mtpro-paper-session-runtime-v1-plan.md`，只保存 Project 级计划摘要和格式门槛。
- 更新 `docs/planning/linear-draft-plan.md` 索引，指向当前下一阶段 planning record。
- 更新 `docs/validation/latest-verification-summary.md`，记录该 planning record 已落仓但尚未写入 Linear。
- 更新 `checks/automation-readiness.sh`，将新 planning record 的命名、边界、不授权执行、Parent Codex queue preflight 规则纳入机械检查。

文件范围：

- Added：
  - `docs/planning/projects/mtpro-paper-session-runtime-v1-plan.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进 Todo。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未复制完整 Linear issue body 到仓库。
- 未把 planning record 当作执行授权。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Paper Session Runtime planning record 和文档更新无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 通过；输出 `MTPRO checks passed.` |

## MTP-31 Paper Session Lifecycle and Event Boundary

日期：2026-05-19

执行者：Codex

目的：

- 定义 Paper Session lifecycle 状态和 started / updated / closed paper-only events。
- 明确 Paper lifecycle facts 的 append-only event log 写入边界。
- 增加 deterministic lifecycle fixture / tests，并回填 validation docs / trading validation matrix。

文件范围：

- Added：
  - `Sources/Core/PaperSessionLifecycle.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Sources/Core/DomainEvents.swift`
  - `Sources/Core/ResearchEventFlows.swift`
  - `Sources/Persistence/Persistence.swift`
  - `Sources/App/App.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未解锁下一 issue。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未实现 action proposal。
- 未实现 portfolio projection update。
- 未实现完整 Paper execution engine。
- 未实现 Live execution。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 68 个 XCTest 通过；新增 Paper lifecycle deterministic facts、`.paper` stream event log boundary 和 decode validation coverage。 |
| `bash checks/run.sh` | failed first attempt after rebase | rebase 到 PR #61 后，automation readiness 仍机械要求最近验证摘要包含 `尚未写入 Linear`；已在 latest summary 中保留该历史 planning 状态说明，并明确当前 MTP-31 执行授权来自 Linear live-read issue contract。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build、dashboard smoke 和 `swift test` 全部通过；输出 `MTPRO checks passed.` |

## MTP-32 Paper Action Proposal Minimal Model and Fixture

日期：2026-05-19

执行者：Codex

目的：

- 定义 Paper action proposal 最小模型，把 strategy signal 转换为 paper-only action intent。
- 映射 strategy signal、symbol、timeframe、side、quantity / notional assumption。
- 复用 MTP-27 deterministic execution cost evidence。
- 增加 deterministic long / flat proposal fixture 和 validation tests。
- 回填 contracts、validation plan、Trading Validation Matrix 和 latest verification summary。

文件范围：

- Added：
  - `Sources/Core/PaperActionProposal.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未解锁下一 issue。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未新增 order command。
- 未新增 Paper action event log 写入。
- 未串联 risk blocker。
- 未实现 portfolio projection update。
- 未实现完整 Paper execution engine。
- 未实现 Live execution。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 70 个 XCTest 通过；新增 `testPaperActionProposalMapsStrategySignalToPaperOnlyIntentDeterministically` 和 `testPaperActionProposalDecodingRejectsNonPaperOrMismatchedIntent`，覆盖 long / flat 映射、notional、MTP-27 fixed cost evidence、paper-only authorization 和 Codable 不变量。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build、dashboard smoke 和 `swift test` 全部通过；70 个 XCTest 0 failures，输出 `MTPRO checks passed.` |

## MTP-33 Paper Action Proposal -> Risk Blocker Link

日期：2026-05-19

执行者：Codex

目的：

- 串联 strategy signal -> paper action proposal -> risk blocker 的本地 Core evidence 链路。
- 将 MTP-32 proposal 转换为 `RiskEvaluationQuery`。
- 在 deterministic policy 阻断时复用 `RiskBlockerEvidence`，记录 blocker reason、source sequence 和 paper-only context。
- 覆盖 allowed / blocked proposal evidence。
- 回填 contracts、validation plan、Trading Validation Matrix 和 latest verification summary。

文件范围：

- Added：
  - `Sources/Core/PaperActionRiskLink.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未解锁下一 issue。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未新增 order command。
- 未新增 Paper action event log 写入。
- 未实现 broker rejection fallback。
- 未实现完整风险引擎。
- 未实现 portfolio projection update。
- 未实现完整 Paper execution workflow。
- 未实现 Live execution。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 73 个 XCTest 通过；新增 `testPaperActionRiskLinkAllowsPaperProposalWithTraceableContext`、`testPaperActionRiskLinkBlocksOversizedPaperProposalWithEvidence`、`testPaperActionRiskDecisionDecodingRejectsMismatchedEvidence`，覆盖 allowed / blocked deterministic evidence、source sequence、paper-only context、无 broker / Live fallback 和 Codable 不变量。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build、dashboard smoke 和 `swift test` 全部通过；73 个 XCTest 0 failures，输出 `MTPRO checks passed.` |

## MTP-34 Paper-only Portfolio Projection Update Path

日期：2026-05-19

执行者：Codex

目的：

- 基于 MTP-33 allowed paper risk decision 更新 paper-only portfolio exposure projection。
- 定义 `PaperPortfolioProjectionUpdate` 和 `PortfolioEvent.paperProjectionUpdated`。
- 通过 replay / SQLite runtime projection 更新 `SQLitePortfolioProjection.exposures`。
- 保持 Portfolio ViewModel 只消费 read model projection，不直连 database schema、runtime object、adapter、broker 或交易动作。
- 回填 contracts、validation plan、Trading Validation Matrix 和 latest verification summary。

文件范围：

- Added：
  - `Sources/Core/PaperPortfolioProjectionUpdate.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Sources/Core/DomainEvents.swift`
  - `Sources/Persistence/Persistence.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/persistence-boundary.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未解锁下一 issue。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未新增 order command。
- 未新增 Paper action event log 写入。
- 未读取真实账户余额。
- 未做 margin / leverage。
- 未做 broker position sync。
- 未实现完整 portfolio management。
- 未实现完整 Paper execution workflow。
- 未实现 Live execution。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 77 个 XCTest 通过；新增 `testPaperPortfolioProjectionUpdateEmitsPaperOnlyPortfolioEventFromAllowedDecision`、`testPaperPortfolioProjectionUpdateRejectsBlockedDecisionAndCapabilityBypass`、`testSQLiteRuntimeProjectionAppliesPaperPortfolioProjectionUpdateFromReplay`、`testPortfolioViewModelConsumesPaperPortfolioUpdateProjectionReadOnly`，覆盖 allowed risk decision -> portfolio update、blocked decision 拒绝、Codable 禁区、SQLite replay projection 和 ViewModel read-model-only 边界。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build、dashboard smoke 和 `swift test` 全部通过；77 个 XCTest 0 failures，输出 `MTPRO checks passed.` |

## MTP-35 Paper Session Replay and Deterministic Evidence

日期：2026-05-19

执行者：Codex

目的：

- 建立 Paper Session replay path。
- 用 `PaperEvent.actionProposed` 将 proposal 纳入 `.paper` stream replay fact。
- 从 append-only event log replay 汇总 session lifecycle、proposal、risk blocker 和 portfolio projection event。
- 输出 `PaperSessionReplayEvidenceSummary` deterministic evidence。
- 证明 `FileEventLogStore` append-only facts source 经 replay 后可生成同一 summary，并驱动 SQLite runtime projection。
- 回填 contracts、validation plan、Trading Validation Matrix 和 latest verification summary。

文件范围：

- Added：
  - `Sources/Core/PaperSessionReplay.swift`
- Updated：
  - `Sources/Core/DomainEvents.swift`
  - `Sources/Persistence/Persistence.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/persistence-boundary.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未解锁下一 issue。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未新增生产级 event sourcing 平台。
- 未新增 schema migration framework。
- 未新增真实 broker event replay。
- 未接外部 execution venue。
- 未暴露 SQLite / DuckDB schema 给 UI。
- 未实现完整 Paper execution workflow。
- 未实现 Live execution。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 80 个 XCTest 通过；新增 `testPaperSessionReplayEvidenceSummarizesRuntimeEventsDeterministically`、`testPaperSessionReplayEvidenceRejectsOutOfOrderReplayResult`、`testPaperSessionReplayEvidenceUsesFileAppendOnlyFactsSource`，覆盖 replay summary、乱序 replay 拒绝、append-only facts source、SQLite runtime projection replay 和 paper-only boundary flags。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build、dashboard smoke 和 `swift test` 全部通过；80 个 XCTest 0 failures，输出 `MTPRO checks passed.` |

## Stage Code Audit Report - MTPRO Paper Session Runtime v1

日期：2026-05-19

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 将 `MTPRO Paper Session Runtime v1` 的 Project 级 Stage Code Audit Report 落仓为 canonical 文档。
- 固化 `MTP-31` 至 `MTP-37` 全部 Linear `Done`、PR #62 至 #68、merge commit、GitHub required check、Post-Issue Ledger 和边界审计证据。
- 更新 latest verification summary，指向 `docs/audit/mtpro-paper-session-runtime-v1-stage-code-audit.md`。

文件范围：

- Added：
  - `docs/audit/mtpro-paper-session-runtime-v1-stage-code-audit.md`
- Updated：
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未推进任何 issue 到 `Todo`。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未写业务代码。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 本轮审计落仓后执行通过。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 全部通过；80 个 XCTest 0 failures，输出 `MTPRO checks passed.` |

## MTP-36 Paper Session Runtime Evidence Report / Dashboard Read Model

日期：2026-05-19

执行者：Codex

目的：

- 将 Paper Session lifecycle、proposal、risk blocker、portfolio exposure 和 replay evidence 汇总到 Report / Dashboard read model。
- 新增 `PaperSessionRuntimeEvidenceSummary`，只消费 append-only event timeline replay summary 和 runtime projection read model。
- 扩展 `ResearchBacktestReportArtifact.paperRuntimeEvidence`、`ReportArtifactViewModel.paperRuntimeEvidence` 和 `ReportViewModel` runtime evidence 汇总字段。
- 扩展 Dashboard Report section，展示 runtime evidence、replay facts、runtime sessions、proposal IDs、runtime blocker IDs、portfolio update IDs、replay streams、deterministic replay 和 paper-only boundary。
- 回填 contracts、product surface、validation plan、Trading Validation Matrix 和 latest verification summary。

文件范围：

- Updated：
  - `Sources/App/App.swift`
  - `Sources/App/DashboardShell.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未解锁下一 issue。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未新增 UI 大改版。
- 未新增完整报告系统。
- 未新增 Paper execution workflow 扩展。
- 未新增 risk control command 或 position management command。
- 未暴露 SQLite / DuckDB schema、SQL、ORM model、runtime object 或 adapter request 给 UI。
- 未实现 Live execution。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 9 个 AppTests 通过；覆盖 Report / Dashboard runtime evidence read model、Codable deterministic snapshot、Dashboard shell runtime evidence 展示和 read-model-only 边界。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build、dashboard smoke 和 `swift test` 全部通过；80 个 XCTest 0 failures，输出 `MTPRO checks passed.` |

## MTP-37 Validation Docs, Automation Evidence, and Stage Audit Input

日期：2026-05-19

执行者：Codex

目的：

- 收口 `MTPRO Paper Session Runtime v1` 的 validation docs、automation evidence、known boundaries 和 Stage Code Audit input。
- 新增 `docs/validation/mtp-37-stage-audit-input.md`，汇总 MTP-31 至 MTP-36 的 PR evidence、merge commit、required check、paper runtime validation evidence chain、known boundaries、automation readiness evidence、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- 更新 `docs/validation/latest-verification-summary.md`，记录 MTP-37 live-read issue 状态、当前 Project PR evidence 和 MTP-37 本地验证摘要。
- 更新 `docs/validation/trading-validation-matrix.md` 和 `docs/validation/validation-plan.md`，补充 MTP-37 Paper Session Runtime 阶段收口和 required validation。
- 更新 `checks/automation-readiness.sh`，把 MTP-37 stage audit input、latest summary、matrix 和 validation plan anchors 纳入机械检查。

文件范围：

- Added：
  - `docs/validation/mtp-37-stage-audit-input.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 symphony-issue。
- 未解锁下一 issue。
- 未运行 Graphify full rebuild。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未接真实 Binance 网络。
- 未读取 secret。
- 未接 signed endpoint / account endpoint。
- 未连接 broker。
- 未提交、取消或替换真实订单。
- 未输出最终 Stage Code Audit Report。
- 未推进下一 Project / Issue。
- 未修改 production code。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；确认 MTP-37 Stage Code Audit input、Trading Validation Matrix、latest summary 和 automation readiness anchors 完整。 |
| `bash checks/run.sh` | pass | `git diff --check`、`bash checks/automation-readiness.sh`、dashboard build、dashboard smoke 和 `swift test` 全部通过；80 个 XCTest 0 failures，输出 `MTPRO checks passed.` |

## MTPRO Paper Session Runtime v1 Root Docs Refresh Gate closure

日期：2026-05-19

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 基于 `docs/audit/mtpro-paper-session-runtime-v1-stage-code-audit.md` 逐项核查 root docs 是否需要事实刷新。
- 确认 `GOAL.md`、`ENVIRONMENT.md` 和 `ARCHITECTURE.md` 与已完成事实一致，无需更新。
- 更新 `ROADMAP.md`，记录最近完成 Project 为 `MTPRO Paper Session Runtime v1`，并指向 canonical Stage Code Audit Report。
- 更新 Stage Code Audit Report 的 Root Docs Delta pending note，记录本轮 closure 已执行。
- 更新 `docs/validation/latest-verification-summary.md`，记录 Root Docs Refresh Gate closure 已执行。

文件范围：

- Updated：
  - `docs/audit/mtpro-paper-session-runtime-v1-stage-code-audit.md`
  - `ROADMAP.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未推进任何 issue 到 `Todo`。
- 未启动 symphony-issue。
- 未运行 Graphify update。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未写业务代码。
- 未决定下一阶段方向。

Root Docs Refresh Gate 逐项结论：

| 文档 | 结果 | 原因 |
| --- | --- | --- |
| `GOAL.md` | no update needed | 目标仍是 Research -> Backtest -> Paper 一致性工作台，Live trading 禁区未变化。 |
| `ENVIRONMENT.md` | no update needed | Stage Code Audit Report 确认未新增本地运行依赖，统一验证入口仍是 `bash checks/run.sh`。 |
| `ARCHITECTURE.md` | no update needed | Core / Persistence / App / Dashboard 边界继续成立；paper-only event log、runtime projection 和 read-model-only Dashboard 仍落在既有架构边界内。 |
| `ROADMAP.md` | updated | 原文仍指向上一完成 Project，已同步为 `MTPRO Paper Session Runtime v1` 和对应 audit report 路径。 |

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 本轮 docs-only Root Docs Refresh Gate closure 变更无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 全部通过；80 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## MTPRO Paper Execution Workflow v1 Project Planning Record

日期：2026-05-19

执行者：Codex（`@001 / PLN`）

目的：

- 基于 Human 确认的 `MTPRO Paper Execution Workflow v1` Linear Project Draft 和 Candidate Linear Issue Drafts，落仓下一阶段 Project-level planning record。
- 新增 `docs/planning/projects/mtpro-paper-execution-workflow-v1-plan.md`，只保存 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable issue candidate、WIP=1 和边界。
- 更新 `docs/planning/linear-draft-plan.md`，将当前 Project planning record 指向 `MTPRO Paper Execution Workflow v1`。
- 更新 `docs/validation/latest-verification-summary.md`，记录 planning record 已落仓但尚未写入 Linear。
- 更新 `checks/automation-readiness.sh`，把新 planning record 的命名、边界和不授权执行规则纳入机械检查。

文件范围：

- Added：
  - `docs/planning/projects/mtpro-paper-execution-workflow-v1-plan.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未复制完整 Linear issue body 到仓库。
- Planning record 不授权执行。
- 完整 issue execution contract 以后以 Linear issue body 为准。
- Project 写入 Linear 后，所有 issue 初始必须保持 `Backlog / non-executable`。
- 后续由 Parent Codex queue preflight 自动判断唯一 eligible issue，并在 WIP=1、依赖满足、无 active conflict、execution contract 格式完整时推进 Todo。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 本轮 docs-only planning record 变更无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 全部通过；80 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## Stage Audit Input Location Normalization

日期：2026-05-19

执行者：Codex

目的：

- 将 Project 级阶段证据和 Stage Code Audit 输入材料从 `docs/validation/` 迁移到 `docs/audit/inputs/`。
- 使用 Project slug 命名输入材料，避免继续用单个 Linear issue 编号污染验证目录。
- 保留 `docs/validation/` 作为长期验证入口目录。

文件范围：

- Renamed：
  - `docs/validation/mtp-23-stage-evidence.md` -> `docs/audit/inputs/mtpro-runtime-research-workbench-v1-stage-evidence.md`
  - `docs/validation/mtp-30-stage-audit-input.md` -> `docs/audit/inputs/mtpro-trading-validation-and-parity-hardening-stage-audit-input.md`
  - `docs/validation/mtp-37-stage-audit-input.md` -> `docs/audit/inputs/mtpro-paper-session-runtime-v1-stage-audit-input.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/audit/mtpro-trading-validation-and-parity-hardening-stage-code-audit.md`
  - `docs/audit/mtpro-paper-session-runtime-v1-stage-code-audit.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未重写 `verification.md` 历史记录；旧路径只保留为历史流水账。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 本轮迁移和规则变更无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 全部通过；80 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## Project Completed State Gate

日期：2026-05-19

执行者：Codex

目的：

- 将 MTPRO Project closure 规则收口为 Linear Project status `Completed`。
- 明确全部有效 issues `Done` 只是 Project closure 前置条件，不等于 Project 已关闭。
- 明确 Parent Codex 必须确认 `type=completed`、`completedAt` 非空后，才能进入 Stage Code Audit Report 和 Root Docs Refresh Gate。
- 记录已完成历史 Project 的 Linear status 修正结果，并保留当前 `MTPRO Paper Execution Workflow v1` 为 `Planned`。

Linear 状态修正：

- `MTPRO Runtime Research Workbench v1`：已从 `Planned` 修正为 `Completed`，Linear 返回 `type=completed`、`completedAt` 非空。
- `MTPRO Trading Validation and Parity Hardening`：已从 `Planned` 修正为 `Completed`，Linear 返回 `type=completed`、`completedAt` 非空。
- `MTPRO Paper Session Runtime v1`：已从 `Planned` 修正为 `Completed`，Linear 返回 `type=completed`、`completedAt` 非空。
- `MTPRO Paper Execution Workflow v1`：保持 `Planned`，不作为已完成 Project 处理。

文件范围：

- Updated：
  - `AGENTS.md`
  - `README.md`
  - `ROADMAP.md`
  - `checks/automation-readiness.sh`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 当前 `MTPRO Paper Execution Workflow v1` 仍为 `Planned`，不授权执行。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Project Completed State Gate 文档变更无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 全部通过；80 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## Dashboard Source Naming Cleanup

日期：2026-05-19

执行者：Codex

目的：

- 移除 `Sources/MTPRODashboard` 目录中的项目名前缀。
- 移除 `MTPRODashboardApplication.swift` 文件名和入口类型中的项目名前缀。
- 将 SwiftPM executable product / target 收口为 `Dashboard`。
- 同步 macOS dashboard build / smoke 命令和当前文档引用。

文件范围：

- Renamed：
  - `Sources/MTPRODashboard/MTPRODashboardApplication.swift` -> `Sources/Dashboard/DashboardApplication.swift`
- Updated：
  - `Package.swift`
  - `Sources/App/DashboardShell.swift`
  - `Sources/Dashboard/DashboardApplication.swift`
  - `Tests/AppTests/AppTests.swift`
  - `checks/run.sh`
  - `README.md`
  - `ARCHITECTURE.md`
  - `ENVIRONMENT.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/macos-build-run-loop.md`
  - `docs/validation/validation-plan.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未修改业务交易逻辑。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Dashboard source naming cleanup 无空白问题。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、`swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `swift test` 全部通过；80 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## MTP-38 Paper-only Execution Workflow Contract

日期：2026-05-19

执行者：Codex

目的：

- 定义 paper-only execution workflow 的阶段顺序和事件边界。
- 明确 proposal、risk decision、paper execution decision、paper order、simulated fill 和 portfolio projection 的关系。
- 用 deterministic Core fixture / tests 固定 paper-only capability 禁区。
- 回填 Trading Validation Matrix、contract docs、validation plan 和最近验证摘要。

文件范围：

- Added：
  - `Sources/Core/PaperExecutionWorkflowContract.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `checks/automation-readiness.sh`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未实现 paper order lifecycle。
- 未实现 simulated fill。
- 未实现完整 OMS。
- 未接 Live trading、signed endpoint、account endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test` | pass | 82 个 XCTest 通过；新增 `testPaperExecutionWorkflowContractDefinesPaperOnlyStageAndEventBoundaries` 和 `testPaperExecutionWorkflowContractRejectsRealTradingCapabilityAndOrderBypass`。 |
| `swift test --filter CoreTests/testPaperExecutionWorkflowContract` | pass | 2 个 focused CoreTests 通过，覆盖 MTP-38 workflow contract stage order、event boundary、future issue 占位和 capability 禁区。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；确认新增 `TVM-PAPER-EXECUTION-WORKFLOW` anchor 可被机械检查定位。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、`swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `swift test` 全部通过；82 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## Role Alias Reference Roles

日期：2026-05-19

执行者：Codex

目的：

- 固定 MTPRO 的三位数字编号和三字母角色代号。
- 将 `@003 / PRD`、`@004 / DSG`、`@005 / ARC` 明确为 Linear 外 reference / root docs 角色。
- 明确 symphony-issue、Codex Execution Agent 和 GitHub PR Automation 是流程工具 / 执行层 actor，按名称调用，不占用 `@003`、`@004`、`@005` 编号。

文件范围：

- `AGENTS.md`
- `docs/automation/parent-codex-supervision.md`
- `docs/planning/project-role-map.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Role Alias Reference Roles 文档变更通过 whitespace 检查。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 `swift test` 全部通过；82 个 XCTest 0 failures，输出 `MTPRO checks passed.`。首次两次 `swift test` 在 `PersistenceTests/testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant` 附近触发 `xctest` signal 11，执行 `swift package clean` 后完整入口通过；未修改业务代码。 |

## MTP-39 Paper Order Intent / Lifecycle

日期：2026-05-19

执行者：Codex

目的：

- 定义 paper-only order intent 和 paper order lifecycle 的最小 Core value model。
- 映射 allowed / blocked risk result 到 `intentCreated` / `rejectedByRisk`。
- 用 deterministic fixture / tests 固定 paper-only capability 禁区。
- 回填 Trading Validation Matrix、contract docs、validation plan 和最近验证摘要。

文件范围：

- Added：
  - `Sources/Core/PaperOrderIntent.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Sources/Core/PaperExecutionWorkflowContract.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `checks/automation-readiness.sh`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未实现 paper execution decision。
- 未实现 simulated fill。
- 未实现完整 OMS。
- 未实现 cancel / replace 工作流。
- 未接 Live trading、signed endpoint、account endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests` | pass | 45 个 CoreTests 通过；新增 `testPaperOrderIntentCreatesPaperOnlyLifecycleFromAllowedRiskDecision`、`testPaperOrderIntentMapsBlockedRiskDecisionToRejectedLifecycle` 和 `testPaperOrderIntentDecodingRejectsCapabilityAndLifecycleBypass`。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；确认新增 `TVM-PAPER-ORDER-LIFECYCLE` anchor 可被机械检查定位。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、`swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `swift test` 全部通过；85 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## AI Engineer Role Alias

日期：2026-05-19

执行者：Codex

目的：

- 将 `000 / AIE` 固定为 MTPRO 的 AI Engineer 角色。
- 明确 `@000 / AIE` 是当前 Codex 协作入口，负责任务理解、仓库 / 流程选择、代码 / 文档执行、验证、PR handoff、角色路由和边界守护。
- 明确 `@000 / AIE` 不替代 Human decision，不绕过 Linear configured executable issue，不替代 `@001 / PLN`、`@002 / PAR` 或 Linear 外 reference 角色。

文件范围：

- `AGENTS.md`
- `docs/automation/parent-codex-supervision.md`
- `docs/planning/project-role-map.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | AI Engineer Role Alias 文档变更通过 whitespace 检查。 |
| `bash checks/run.sh` | pass | rebase 到最新 `main` 后，先遇到一次 SwiftPM 增量缓存导致的错误文案污染；执行 `swift package clean` 后完整入口通过，automation readiness、Dashboard build / smoke 和 `swift test` 全部通过；85 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## Documentation Entry Point Compression

日期：2026-05-19

执行者：Codex

目的：

- 从 `README.md` 开始压缩 MTPRO 项目入口文档，减少多轮迭代后残留的历史叙事、旧 Project pointer 和重复规则。
- 保留必要流程边界：Linear live-read、父 Codex queue gate、`symphony-issue` 执行边界、GitHub PR Automation、Post-Issue Ledger、Stage Code Audit Report 和 Root Docs Refresh Gate。
- 继续保持 `verification.md` append-only；默认验证入口仍是 `docs/validation/latest-verification-summary.md`。

文件范围：

- `README.md`
- `ROADMAP.md`
- `AGENTS.md`
- `docs/automation/automation-readiness.md`
- `docs/automation/parent-codex-supervision.md`
- `docs/automation/symphony-issue-workflow-template.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

收口结果：

- `README.md` 压缩为项目目标、硬边界、当前执行源、代码结构、文档入口和验证入口。
- `ROADMAP.md` 压缩为阶段地图；当前 Project / active issue 必须从 Linear live-read，不固化到仓库。
- `AGENTS.md` 压缩为角色、执行链路、父 Codex、`symphony-issue`、Root Docs Refresh Gate 和代码 / 文档规则。
- `docs/automation/*` 移除旧 active Project slug，改为标准 workflow pointer / queue gate 规则。
- `latest-verification-summary.md` 保留轻量当前态和最近事实，避免日常读取完整 `verification.md`。

边界确认：

- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 文档压缩变更通过 whitespace 检查。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 `swift test` 全部通过；85 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## MTP-40 Simulated Fill Evidence

日期：2026-05-19

执行者：Codex

目的：

- 定义 paper-only simulated fill evidence 的最小 Core value model。
- 定义 deterministic fill assumption，并复用 MTP-27 fixed fee / slippage cost evidence。
- 将 simulated fill stage 标记为当前代码已实现，但不写 event log、不做 replay / projection 串联。
- 回填 Trading Validation Matrix、contract docs、validation plan 和最近验证摘要。

文件范围：

- Added：
  - `Sources/Core/PaperSimulatedFillEvidence.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Sources/Core/PaperExecutionWorkflowContract.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `checks/automation-readiness.sh`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未实现 paper execution decision。
- 未写 event log。
- 未新增 projection / ViewModel。
- 未实现真实撮合或真实成交回报。
- 未实现动态滑点模型、交易所费率表或执行成本优化。
- 未接 Live trading、signed endpoint、account endpoint、broker fill、account update、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests` | pass | 首次执行在 SwiftPM 拉取 `duckdb-swift` 时遇到 GitHub TLS transient fetch failure，重试后通过；48 个 CoreTests 0 failures，新增 `testPaperSimulatedFillEvidenceCreatesDeterministicPaperOnlyFillFromAllowedOrderIntent`、`testPaperSimulatedFillEvidenceRejectsRejectedIntentAndAssumptionMismatch` 和 `testPaperSimulatedFillEvidenceDecodingRejectsRealFillBrokerAndAccountBypass`。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；确认新增 `TVM-PAPER-SIMULATED-FILL` anchor 可被机械检查定位。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、`swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `swift test` 全部通过；88 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## MTP-41 Paper Execution Decision

日期：2026-05-19

执行者：Codex

目的：

- 定义 paper execution decision 本地链路。
- 串联 allowed risk decision -> paper order intent -> simulated fill evidence。
- 确认 blocked risk decision 只保留 blocker evidence，不生成 paper order、simulated fill assumption 或 simulated fill evidence。
- 回填 Trading Validation Matrix、contract docs、validation plan 和最近验证摘要。

文件范围：

- Added：
  - `Sources/Core/PaperExecutionDecision.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Sources/Core/PaperExecutionWorkflowContract.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `checks/automation-readiness.sh`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写 event log。
- 未新增 replay / projection / ViewModel。
- 未实现完整 execution engine。
- 未实现完整风险引擎。
- 未实现 broker rejection fallback。
- 未接 Live trading、signed endpoint、account endpoint、broker fill、account update、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests/testPaperExecutionDecision` | pass | 3 个 MTP-41 focused XCTest 0 failures，覆盖 allowed decision chain、blocked no-order 和 Codable bypass。 |
| `swift test --filter CoreTests` | pass | 51 个 CoreTests 0 failures。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、`swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `swift test` 全部通过；91 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## NautilusTrader Reference Study

日期：2026-05-19

执行者：Codex

目的：

- 记录 `@003 / PRD`、`@004 / DSG`、`@005 / ARC` 对 NautilusTrader 的 Linear 外 reference study。
- 汇总 NautilusTrader 对 MTPRO Product / Design / Architecture 的参考价值。
- 输出 root docs delta proposal，作为 Human + `@001 / PLN` 后续规划输入。

文件范围：

- Added：
  - `docs/reference/nautilus-trader/README.md`
  - `docs/reference/nautilus-trader/product-reference.md`
  - `docs/reference/nautilus-trader/design-reference.md`
  - `docs/reference/nautilus-trader/architecture-reference.md`
  - `docs/reference/nautilus-trader/root-docs-delta-proposal.md`
- Updated：
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未直接修改 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md` 或 `ROADMAP.md`。
- 未复制 NautilusTrader 代码。
- 未引入 NautilusTrader 作为运行依赖。
- 未接 Live trading、signed endpoint、account endpoint、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift package clean` | pass | 先清理 SwiftPM 增量缓存；此前本地曾因缓存污染导致 `testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant` 报旧错误。 |
| `swift test --filter PersistenceTests/testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant` | pass | 清理后 focused test 通过，确认不是 reference docs 引入的逻辑回归。 |
| `git diff --check` | pass | Reference study 文档通过 whitespace 检查。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、Dashboard build / smoke 和 `swift test` 全部通过；91 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## MTP-42 Paper Execution Event Log Replay Projection

日期：2026-05-19

执行者：Codex

目的：

- 串联 paper execution decision、paper order intent 和 simulated fill evidence 到 append-only event log。
- 通过 deterministic replay 提取 paper-only simulated fill evidence。
- 将 replay 后的 simulated fill evidence 作为 paper-only portfolio projection 的唯一来源。
- 回填 Trading Validation Matrix、contract docs、validation plan 和最近验证摘要。

文件范围：

- Added：
  - `Sources/Core/PaperExecutionEventLog.swift`
- Updated：
  - `Sources/App/App.swift`
  - `Sources/Core/DomainEvents.swift`
  - `Sources/Core/PaperPortfolioProjectionUpdate.swift`
  - `Sources/Core/PaperSessionReplay.swift`
  - `Sources/Persistence/Persistence.swift`
  - `Tests/AppTests/AppTests.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/PersistenceTests/PersistenceTests.swift`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/persistence-boundary.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未实现完整 execution engine。
- 未实现完整风险引擎。
- 未实现 broker rejection fallback。
- 未接 Live trading、signed endpoint、account endpoint、broker fill、account update、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests/testPaperExecution` | pass | 8 个 focused XCTest 0 failures，覆盖 MTP-41 decision 链路和 MTP-42 event append / replay / projection focused path。 |
| `swift test --filter CoreTests` | pass | 53 个 CoreTests 0 failures。 |
| `swift test` | pass | 93 个 XCTest 0 failures。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、`swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `swift test` 全部通过；93 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## MTP-44 Paper Execution Workflow Report / Dashboard Evidence

日期：2026-05-19

执行者：Codex

目的：

- 将 paper execution workflow evidence 汇总到 Report read model。
- 在 Dashboard Report snapshot 中展示 decision、paper order、simulated fill、workflow streams、portfolio projection 和 paper-only boundary。
- 保持 UI 只消费 ViewModel / Read Model，不新增交易入口。
- 回填 product surface、read model / ViewModel contract 和 Trading Validation Matrix。

文件范围：

- Updated：
  - `Sources/App/App.swift`
  - `Sources/App/DashboardShell.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/product/product-surface-map.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未实现完整报告系统。
- 未新增 UI command、order command、risk control command 或 position management command。
- 未暴露 SQLite / DuckDB schema、SQL、ORM model、runtime object 或 adapter request。
- 未接 Live trading、signed endpoint、account endpoint、broker fill、account update、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 9 个 AppTests 0 failures，覆盖 Report / Dashboard workflow evidence、Codable snapshot、read-model-only boundary 和无 UI execution surface。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、`swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `swift test` 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true`；93 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## MTP-45 Paper Execution Workflow Validation Docs / Stage Audit Input

日期：2026-05-19

执行者：Codex

目的：

- 收口 `MTPRO Paper Execution Workflow v1` 的 validation docs、automation evidence、known boundaries 和 Stage Code Audit 输入材料。
- 汇总 `MTP-38`、`MTP-39`、`MTP-40`、`MTP-41`、`MTP-42`、`MTP-44` 的 issue / PR evidence、merge commit 和 required check evidence。
- 为 Parent Codex 在 Project 全部 Done 且 Linear Project `Completed` 后输出最终 Stage Code Audit Report 提供输入。
- 保持本 issue 为 docs-only / evidence-only，不新增业务交易能力。

文件范围：

- Added：
  - `docs/audit/inputs/mtpro-paper-execution-workflow-v1-stage-audit-input.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/automation/automation-readiness.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未输出最终 Stage Code Audit Report。
- 未创建下一 Project / Issue。
- 未触碰 Live trading、signed endpoint、account endpoint、broker fill、account update、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；确认 MTP-45 audit input、matrix、latest summary 和 validation plan anchors 完整。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、`swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `swift test` 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true`；93 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## MTPRO Paper Execution Workflow v1 Stage Code Audit Report

日期：2026-05-19

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 将 `MTPRO Paper Execution Workflow v1` 的 canonical Stage Code Audit Report 落仓。
- 固化 `MTP-38`、`MTP-39`、`MTP-40`、`MTP-41`、`MTP-42`、`MTP-44`、`MTP-45` 的 issue / PR evidence、merge commit、required check、validation、boundary audit、Known CI Boundary、Root Docs Delta 和 Next Human Project Planning handoff。
- 记录 `MTP-43`、`MTP-46` 为 Duplicate 并排除 canonical queue。
- 记录 Linear Project status `Completed`，`completedAt=2026-05-19T14:48:42.973Z`。
- 更新最近验证摘要，指向 canonical Stage Code Audit Report。

文件范围：

- Added：
  - `docs/audit/mtpro-paper-execution-workflow-v1-stage-code-audit.md`
- Updated：
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未创建 Linear Project / Issue。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify full rebuild。
- 未写业务代码。
- 未进入下一阶段规划。
- 未触碰 Live trading、signed endpoint、account endpoint、broker fill、account update、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 无 whitespace error。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、Dashboard build、Dashboard smoke 和 `swift test` 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true`；93 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |
## MTPRO Complete Blueprint Design

日期：2026-05-19
执行者：Codex（`@000 / AIE`）
PR：
Commit：

目的：
- 将 MTPRO 的完整产品 / 系统 / 设计蓝图落仓。
- 明确 Human + `@000 / AIE` 共同负责 Complete Blueprint Design。
- 明确 `@001 / PLN` 只在蓝图确认后基于 Current Construction Scope 进入下一阶段 Project Planning。
- 明确 Live / signed endpoint / broker / OMS 等长期能力可以进入最终蓝图，但当前仍保持 future / gated，不授权执行。

文件范围：
- Created:
  - `docs/design/mtpro-complete-blueprint.md`
- Updated:
  - `README.md`
  - `AGENTS.md`
  - `docs/planning/project-role-map.md`
  - `docs/reference/nautilus-trader/README.md`
  - `docs/reference/nautilus-trader/root-docs-delta-proposal.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`
- Deleted:

收口结果：
- 新增 MTPRO Complete Blueprint Design，覆盖 Final Product Blueprint、System Architecture Blueprint、Workbench / UX Blueprint、Complete Capability Map、Current Construction Scope、Future Construction Zones、Root Docs Delta Proposal 和 Linear Planning Handoff。
- `@000 / AIE` 职责补充为 Human 的完整蓝图协作入口，负责把 reference study、Stage Code Audit、root docs 和现有代码能力综合成 MTPRO 自己的蓝图。
- NautilusTrader reference study 的后续路径调整为先进入 Human + `@000 / AIE` Complete Blueprint Design，再进入 Human + `@001 / PLN` Project Planning。
- automation readiness 增加蓝图文件和角色边界锚点。

边界确认：
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Backlog` -> `Todo`。
- 未启动 `@002 / PAR`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Complete Blueprint Design docs-only 变更通过 whitespace 检查。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 93 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |
## Blueprint Responsibility Cleanup and Phase Progress Rule

日期：2026-05-20
执行者：Codex（`@000 / AIE`）
PR：
Commit：

目的：
- 将 `@000 / AIE` 的详细职责清单从 `docs/design/mtpro-complete-blueprint.md` 移出，保持蓝图文档专注产品 / 系统 / 设计蓝图本体。
- 明确当前阶段完成进度条由 `@002 / PAR` 在 Project closure、Stage Code Audit Report 和 Root Docs Refresh Gate closure 后输出。
- 明确阶段进度条不写入蓝图文档，不授权下一阶段执行。

文件范围：
- Updated:
  - `AGENTS.md`
  - `checks/automation-readiness.sh`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/design/mtpro-complete-blueprint.md`
  - `docs/planning/project-role-map.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

收口结果：
- 蓝图文档删除 `@000 / AIE 蓝图职责` 大段职责清单，只保留蓝图本体和边界说明。
- `@000 / AIE` 职责继续由 `AGENTS.md` 和 `docs/planning/project-role-map.md` 维护。
- `@002 / PAR` closure 规则新增 `Current Phase Progress Bar / 当前阶段完成进度条`。
- 进度条必须基于当前 Human-approved phase 内 completed Project 数量计算，不能基于完整蓝图或 Future Construction Zones 计算。

边界确认：
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Backlog` -> `Todo`。
- 未启动 `@002 / PAR`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Blueprint responsibility cleanup 和 progress rule docs-only 变更通过 whitespace 检查。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 93 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## Current Phase Progress Baseline

日期：2026-05-20
执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：
- 补齐当前版本的 Current Phase Progress baseline。
- 明确当前阶段为 `MTPRO paper-only research / validation / execution foundation`。
- 明确 Completed Projects 为 5 / 5（100%），Progress 为 `[##########] 100%`。
- 明确进度条只统计当前已 Human-approved、已执行、已 closure 的建设阶段 Project。
- 明确进度条不统计 `docs/design/mtpro-complete-blueprint.md` 中的 Future Construction Zones，不授权下一阶段执行。

Completed Projects：
- `MTPRO 引导`
- `MTPRO Runtime Research Workbench v1`
- `MTPRO Trading Validation and Parity Hardening`
- `MTPRO Paper Session Runtime v1`
- `MTPRO Paper Execution Workflow v1`

Latest Completed Project：`MTPRO Paper Execution Workflow v1`

Next Handoff：Human + `@001 / PLN`

文件范围：
- Updated:
  - `docs/validation/latest-verification-summary.md`
  - `ROADMAP.md`
  - `docs/planning/linear-draft-plan.md`
  - `verification.md`

边界确认：
- docs-only。
- 未修改 `docs/design/mtpro-complete-blueprint.md`。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未把 future capability 计入 progress。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Current Phase Progress baseline docs-only 变更无 whitespace error。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 93 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## Goal / Roadmap Progress Baseline Correction

日期：2026-05-20
执行者：Codex（`@000 / AIE`）

目的：
- 修正 Current Phase Progress baseline 的计算口径。
- 明确 Project Closure Count 只说明已关闭 Project 数量，不代表 `GOAL.md` / `ROADMAP.md` 目标完成度。
- 将真正的进度条改为 Goal / Roadmap Target Progress。

修正结果：
- Project Closure Count：5 / 5（100%）。
- Goal / Roadmap Target Progress：3 / 5（60%）。
- Progress：`[######----] 60%`。

目标切片：
- Complete：Research / Backtest / Report / Paper readiness。
- Complete：Paper-only execution evidence。
- Complete / enforced：Live trading 禁区和 future boundary。
- Pending：Paper workflow 可观察性和本地控制壳。
- Pending：更长周期 market data replay / operations。

文件范围：
- Updated:
  - `AGENTS.md`
  - `ROADMAP.md`
  - `checks/automation-readiness.sh`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：
- docs-only。
- 未修改 `docs/design/mtpro-complete-blueprint.md`。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Goal / Roadmap progress baseline correction 无 whitespace error。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 93 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTPRO Paper Workflow Control Shell v1 Project Planning Record

日期：2026-05-20

执行者：Codex（`@001 / PLN`）

目的：

- 基于 Human 确认的 `MTPRO Paper Workflow Control Shell v1` Linear Project Draft 和 Candidate Linear Issue Drafts，落仓下一阶段 Project-level planning record。
- 新增 `docs/planning/projects/mtpro-paper-workflow-control-shell-v1-plan.md`，只保存 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable issue candidate、WIP=1 和边界。
- 更新 `docs/planning/linear-draft-plan.md`，将当前 Project planning record 指向 `MTPRO Paper Workflow Control Shell v1`。
- 更新 `docs/validation/latest-verification-summary.md`，记录 planning record 已落仓但尚未写入 Linear。
- 更新 `checks/automation-readiness.sh`，把新 planning record 的命名、边界和不授权执行规则纳入机械检查。

文件范围：

- Added：
  - `docs/planning/projects/mtpro-paper-workflow-control-shell-v1-plan.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 `@002 / PAR`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 未复制完整 Linear issue body 到仓库。
- Planning record 不授权执行。
- 完整 issue execution contract 以后以 Linear issue body 为准。
- Project 写入 Linear 后，所有 issue 初始必须保持 `Backlog / non-executable`。
- 后续由 Parent Codex queue preflight 自动判断唯一 eligible issue，并在 WIP=1、依赖满足、无 active conflict、execution contract 格式完整时推进 Todo。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 本轮 docs-only planning record 变更无 whitespace error。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 93 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-47 Paper workflow Workbench information architecture / control shell boundary

日期：2026-05-20

执行者：Codex（Codex Execution Agent）

目的：

- 按 Linear issue `MTP-47` 定义 Paper workflow Workbench information architecture 和控制壳边界。
- 新增 App 层 `PaperWorkflowWorkbenchInformationArchitecture` deterministic fixture，固定 session-level controls、observability sections 和 forbidden capability。
- 将 `TVM-PAPER-WORKFLOW-CONTROL-SHELL` 回填到 trading validation matrix，并更新 product / contract / validation docs。

文件范围：

- Added：
  - `Sources/App/PaperWorkflowWorkbenchArchitecture.swift`
- Updated：
  - `Tests/AppTests/AppTests.swift`
  - `checks/automation-readiness.sh`
  - `docs/product/product-surface-map.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 只定义 Workbench information architecture、session-level control shell 边界、validation anchor 和合同文档。
- session-level controls 只允许 `start` / `pause` / `close` / `reset`。
- 未实现 Command Model。
- 未实现 UI 控件。
- 未实现 Event Timeline。
- 未实现 order-level command、OMS、Live trading、signed endpoint、account endpoint、listenKey、broker action 或真实订单提交 / 撤销 / 替换。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 11 个 AppTests，0 failures；覆盖 MTP-47 Workbench IA fixture、session-level controls、observability sections、forbidden capability 和 no order-level command 合同拒绝。 |
| `bash checks/automation-readiness.sh` | pass | `TVM-PAPER-WORKFLOW-CONTROL-SHELL`、MTP-47 validation-plan、contract docs 和 product surface anchors 均可机械定位。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 95 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-48 Paper session local control Command Model

日期：2026-05-20

执行者：Codex（Codex Execution Agent）

目的：

- 按 Linear issue `MTP-48` 新增 session-level Paper local control Command Model。
- 支持 `start` / `pause` / `close` / `reset` 四个本地 Paper session control intent。
- 定义 command validation、rejected reason 和 Codable capability bypass 拒绝边界。
- 保持不实现 UI 控件、不写 event log、不触碰 order-level command、broker action、signed endpoint 或真实订单行为。

文件范围：

- Added：
  - `Sources/Core/PaperSessionLocalControlCommand.swift`
- Updated：
  - `Sources/Core/CommandsAndQueries.swift`
  - `Sources/Core/CoreError.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `checks/automation-readiness.sh`
  - `docs/product/product-surface-map.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- accepted command 只能作用于本地 Paper session。
- session-level controls 只允许 `start` / `pause` / `close` / `reset`。
- 非 session-level command、order-level command、`submit` / `cancel` / `replace`、broker action 和非 paper execution mode 均被 validation 拒绝。
- Codable 解码拒绝恢复 order-level command、真实交易授权、Live trading、signed endpoint、account endpoint、listenKey、broker action 或真实订单 submit / cancel / replace capability。
- 未实现 session-level control -> event boundary 串联。
- 未实现 UI 控件或 Event Timeline。
- 未连接 broker / exchange。
- 未接 signed endpoint、account endpoint、listenKey 或 Live execution。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests/testPaperSessionLocalControl` | pass | 3 个 CoreTests，0 failures；覆盖 Command Model 四个 session-level controls、raw request rejected reason、no submit / cancel / replace / broker action 和 Codable capability bypass 拒绝。 |
| `bash checks/automation-readiness.sh` | pass | `PaperSessionLocalControlCommand`、MTP-48 validation-plan、contract docs、product surface 和 matrix anchors 均可机械定位。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 98 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-49 Paper session local control event boundary

日期：2026-05-20

执行者：Codex（Codex Execution Agent）

目的：

- 按 Linear issue `MTP-49` 串联 session-level control -> paper-only event boundary。
- 将 valid `start` / `pause` / `close` / `reset` command 映射为 `.paper` stream 中的本地 session control fact。
- 将 invalid command rejection reason 写为可 replay 的本地 rejection evidence。
- 保持 append-only event boundary，不生成 order command、broker action、signed endpoint 或真实交易行为。

文件范围：

- Added：
  - `Sources/Core/PaperSessionLocalControlEventLog.swift`
- Updated：
  - `Sources/Core/DomainEvents.swift`
  - `Sources/Core/PaperSessionReplay.swift`
  - `Sources/Persistence/Persistence.swift`
  - `Sources/App/App.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `checks/automation-readiness.sh`
  - `docs/product/product-surface-map.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/backend-use-case-contract.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- accepted command 只能写入 `PaperEvent.sessionControlApplied`，并固定为 `.paper` stream。
- rejected command 只能写入 `PaperEvent.sessionControlRejected`，保留 `PaperSessionLocalControlRejectedReason`。
- event sequence 继续由 `AppendOnlyEventLog` 单调分配，不能重排或覆盖既有 facts。
- replay summary、SQLite projection 和 App matcher 已显式识别新增 paper event cases；当前不新增 projection schema、ViewModel、UI 控件或 Event Timeline。
- 未生成 paper order command、real order command、order intent、simulated fill、broker action、signed endpoint、account endpoint、listenKey 或 Live execution。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests/testPaperSessionLocalControl` | pass | 6 个 CoreTests，0 failures；覆盖 accepted command -> `sessionControlApplied`、invalid command -> `sessionControlRejected`、append-only `.paper` stream 和 no order / no broker event。 |
| `bash checks/automation-readiness.sh` | pass | `PaperSessionLocalControlEventLogBoundary`、MTP-49 validation-plan、contract docs、product surface 和 matrix anchors 均可机械定位。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 101 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-50 Paper workflow observability Read Model / ViewModel

日期：2026-05-20

执行者：Codex（Codex Execution Agent）

目的：

- 按 Linear issue `MTP-50` 扩展 Paper workflow observability Read Model / ViewModel。
- 展示 session status、proposal evidence、allowed paper execution chain、blocked risk evidence、portfolio projection evidence、replay freshness 和 report artifact status。
- 保持 UI-facing shape 只通过 ViewModel / Read Model，不暴露 SQLite / DuckDB schema、adapter request 或 runtime object。

文件范围：

- Added：
  - `Sources/App/PaperWorkflowObservability.swift`
- Updated：
  - `Sources/App/App.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/product/product-surface-map.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- `PaperWorkflowObservabilityReadModel` 只从既有 `ReportReadModel`、`PaperReadModel`、`RiskReadModel`、`PortfolioReadModel` 和 `EventTimelineReadModel` 聚合稳定输入。
- `PaperWorkflowObservabilityViewModel` 是 Codable deterministic snapshot，展示 blocked / allowed evidence、chain coverage、replay freshness 和 report artifact status。
- `DashboardReadModel` / `DashboardViewModel` 只新增 read-model-only 观察快照，不修改 Dashboard shell UI。
- 未新增 projection schema、Runtime wiring、adapter request、Event Timeline explorer、UI control 或 order-level command。
- 未接 Live trading、signed endpoint、account endpoint、listenKey、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 13 个 AppTests，0 failures；覆盖 Paper workflow observability snapshot、session status、blocked / allowed evidence、chain coverage、replay freshness、report artifact status、Codable deterministic equality 和 schema / runtime / adapter non-exposure。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 103 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-51 read-model-only Event Timeline / Evidence Explorer 子集

日期：2026-05-20

执行者：Codex（Codex Execution Agent）

目的：

- 按 Linear issue `MTP-51` 新增 Event Timeline / Evidence Explorer 的 read-model-only 子集。
- 让用户可以按 timeline snapshot 观察 market event、strategy signal、risk decision、paper order、simulated fill、portfolio projection 和 report artifact 的 evidence links。
- 保持 Explorer 只读，不提供 query language、command surface、Persistence adapter direct read、Runtime command、UI control 或交易操作。

文件范围：

- Added：
  - `Sources/App/PaperWorkflowEvidenceExplorer.swift`
- Updated：
  - `Sources/App/App.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/product/product-surface-map.md`
  - `docs/contracts/api-contract.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- `PaperWorkflowEvidenceExplorerReadModel` 只从既有 `MarketReadModel`、`StrategyReadModel`、`ReportReadModel`、`PaperWorkflowObservabilityReadModel` 和 `EventTimelineReadModel` 聚合稳定输入。
- `PaperWorkflowEvidenceExplorerViewModel` 是 Codable deterministic snapshot，展示 timeline items、evidence links、section snapshots、read-only filter snapshot 和 coverage flags。
- filter 只在已生成 ViewModel snapshot 内筛选 section，不下推为 query language，不读取 SQLite / DuckDB schema，不调用 Runtime 或 Persistence adapter。
- `DashboardReadModel` / `DashboardViewModel` 只新增 read-model-only Explorer 快照，不修改 Dashboard shell UI。
- 未新增 projection schema、Runtime wiring、adapter request、UI control、order-level command、risk control、position management、broker action、signed endpoint、account endpoint、listenKey、真实订单或 Live execution。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 15 个 AppTests，0 failures；覆盖 Event Timeline / Evidence Explorer deterministic snapshot、market / strategy / risk / order / fill / portfolio / report section coverage、evidence links、read-only filter、Codable deterministic equality 和 schema / runtime / adapter / command non-exposure。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 105 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-52 增量扩展 Dashboard / Workbench shell 并保持 read-model-only

日期：2026-05-20

执行者：Codex（Codex Execution Agent）

目的：

- 按 Linear issue `MTP-52` 在现有 Dashboard / Workbench shell 上增量呈现 Paper workflow control shell、observability read model 和 Event Timeline / Evidence Explorer 子集。
- 让 shell snapshot 展示 `start` / `pause` / `close` / `reset` 四个 session-level local controls，并证明它们只消费 Command Model，不形成按钮、表单或可执行交易入口。
- 保持 Dashboard smoke、read-model-only、paper-only、no schema / runtime / adapter direct access 和 forbidden command evidence。

文件范围：

- Updated：
  - `Sources/App/DashboardShell.swift`
  - `Tests/AppTests/AppTests.swift`
  - `checks/automation-readiness.sh`
  - `docs/product/product-surface-map.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- `DashboardShellControlSnapshot` 只把 `PaperWorkflowSessionControl` 映射到 `PaperSessionLocalControlAction`，scope 固定为 local paper session，control level 固定为 session，execution mode 固定为 paper。
- `DashboardShellWorkbenchSnapshot` 只组合现有 App 层 ViewModel / Read Model / Command Model，展示 observability metrics、Event Timeline / Evidence Explorer preview 和 workbench boundary flags。
- SwiftUI shell 只渲染文本、指标和 read-only preview，不包含按钮、文本输入、开关、order-level command、Runtime command、adapter request 或 schema direct access。
- Dashboard smoke 继续保持八个 Dashboard sections，并新增 `workbenchReadModelOnly=true`、controls 和 timeline item evidence。
- 未接 Live trading、signed endpoint、account endpoint、listenKey、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 16 个 AppTests，0 failures；覆盖 Dashboard / Workbench shell snapshot control / observability / explorer binding、Dashboard smoke workbench evidence、session-level local command presentation 和 no button / no command / schema / runtime / adapter boundary tests。 |
| `bash checks/automation-readiness.sh` | pass | 新增 MTP-52 contract / product / validation / matrix / source / test anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 106 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset`，最终输出 `MTPRO checks passed.`。 |

## MTP-53 加固 deterministic validation、Dashboard smoke 和 automation readiness evidence

日期：2026-05-20

执行者：Codex（Codex Execution Agent）

目的：

- 按 Linear issue `MTP-53` 收口 `MTPRO Paper Workflow Control Shell v1` 的 deterministic validation、Dashboard smoke、automation readiness anchor、known boundaries 和 Stage Code Audit input。
- 汇总 MTP-47 至 MTP-52 的 issue / PR evidence、merge commit、required check、Dashboard smoke 和 validation evidence chain。
- 明确最终 Stage Code Audit Report 仍由 Parent Codex 在 Project 全部 Done 且 Linear Project `Completed` 后单独输出。

文件范围：

- Added：
  - `docs/audit/inputs/mtpro-paper-workflow-control-shell-v1-stage-audit-input.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

边界确认：

- 本 issue 只准备阶段证据材料，不输出最终 Stage Code Audit Report。
- 未创建下一 Project / Issue，未推进下一 Project / Issue，未启动下一阶段 `symphony-issue`。
- 未写业务功能扩展，未修改 production code。
- Dashboard smoke evidence 覆盖 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`controls=start,pause,close,reset` 和 `timelineItems=0`。
- `timelineItems=0` 来自空启动 read model；fixture 级 Event Timeline / Evidence Explorer coverage 仍由 App deterministic tests 覆盖。
- 未接 Live trading、signed endpoint、account endpoint、listenKey、broker action 或真实订单行为。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `DASHBOARD_SMOKE=1 swift run Dashboard` | pass | 输出 `Dashboard smoke: sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 |
| `bash checks/automation-readiness.sh` | pass | MTP-53 stage audit input、validation plan、matrix、latest summary 和 Dashboard smoke anchors 均可机械定位，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 106 个 XCTest 全部通过，最终输出 `MTPRO checks passed.`。 |

## MTPRO Paper Workflow Control Shell v1 Stage Code Audit Report

日期：2026-05-20

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 将 `MTPRO Paper Workflow Control Shell v1` 的 canonical Stage Code Audit Report 落仓。
- 基于 Linear live-read、PR #91 至 #97、Post-Issue Ledger 和 `MTP-53` Stage Audit Input 固化 Project closure 证据。
- 更新最近验证摘要，指向 canonical Stage Code Audit Report。

文件范围：

- Added：
  - `docs/audit/mtpro-paper-workflow-control-shell-v1-stage-code-audit.md`
- Updated：
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

证据：

- Canonical issues `MTP-47`、`MTP-48`、`MTP-49`、`MTP-50`、`MTP-51`、`MTP-52`、`MTP-53` 全部 Linear `Done`。
- Linear Project status 已设置为 `Completed`，`completedAt=2026-05-19T21:37:34.706Z`。
- `MTP-53` PR #97 已 merge，merge commit 为 `f2efe3d23a092b9e938c7697a8002860abc1962a`。
- GitHub required check `checks` 已通过：`https://github.com/atxinbao/MTPRO/actions/runs/26126719584/job/76842160441`。
- Post-Issue Ledger 对 `MTP-53` 的 `git_pull_ff_only` 和 `graphify_update` 均为 `passed`；`graphify-out/*` 未提交。

边界确认：

- 本轮只落仓 Stage Code Audit Report，不创建 Linear Project / Issue。
- 未推进任何 issue 到 `Todo`。
- 未启动新的 Symphony。
- 未运行 Graphify manual update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- Root Docs Refresh Gate 尚未执行；Current Phase Progress Bar 需在该 gate closure 后单独刷新。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Stage Code Audit Report 落仓变更无 whitespace error。 |
| `bash checks/run.sh` | pass | 首次运行暴露 persistent repo `.build` 缓存污染导致的 `CoreError` enum layout 断言串扰；执行 `swift package clean` 后完整验证通过，Dashboard build / smoke 和 106 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTPRO Paper Workflow Control Shell v1 Root Docs Refresh Gate closure

日期：2026-05-20

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 基于 `docs/audit/mtpro-paper-workflow-control-shell-v1-stage-code-audit.md` 逐项核查 root docs 是否落后于已完成事实。
- 同步当前 Goal / Roadmap Target Progress，明确进度按目标切片计算，不按 Project 数量直接计算。
- 记录 Root Docs Refresh Gate closure，作为交给 Human + `@001 / PLN` 的事实输入。

Root docs 判断：

- `GOAL.md`：updated。同步 Paper workflow 可观察性、本地 session-level control shell 和当前 Goal / Roadmap Target Progress 4 / 5（80%）。
- `ENVIRONMENT.md`：no update needed。未新增本地运行依赖；统一验证入口仍是 `bash checks/run.sh`，并继续包含 Dashboard smoke。
- `ARCHITECTURE.md`：updated。同步 Core paper-only command / event boundary、App read model / ViewModel 和 Dashboard / Workbench read-only shell snapshot 的已完成事实。
- `ROADMAP.md`：updated。新增 `MTPRO Paper Workflow Control Shell v1` 为 Completed，Project Closure Count 更新为 6 / 6，Goal / Roadmap Target Progress 更新为 4 / 5（80%）。

边界确认：

- 本轮只同步已发生事实，不写下一阶段方向、目标、架构路线或优先级。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未修改 `docs/design/mtpro-complete-blueprint.md`。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Root Docs Refresh Gate closure docs-only 变更无 whitespace error。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 106 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTPRO Market Data Replay Operations v1 Project Planning Record

日期：2026-05-20

执行者：Codex（`@001 / PLN`）

目的：

- 将 Human 确认的 `MTPRO Market Data Replay Operations v1` 下一阶段 Project-level planning record 落仓。
- 只保存 Project 级计划摘要和格式门槛，不复制维护完整 Linear issue body。
- 更新 Project Planning Record 索引、最近验证摘要和 automation readiness anchor。

文件范围：

- Added：
  - `docs/planning/projects/mtpro-market-data-replay-operations-v1-plan.md`
- Updated：
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

规划摘要：

- Project name：`MTPRO Market Data Replay Operations v1`
- Project goal：建立本地、paper-only、public-read-only 的 market data batch / replay operations 基线。
- First executable issue candidate：定义 Binance public read-only market data batch / replay boundary。
- WIP=1：所有候选 issue 写入 Linear 后必须初始保持 `Backlog / non-executable`。
- 完整 issue execution contract 以后以 Linear issue body 为准。

边界确认：

- 本轮只落仓 Project Planning Record。
- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 `@002 / PAR`。
- 未启动 Symphony / `symphony-issue`。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 本 planning record 不授权执行。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Project Planning Record 落仓 docs-only 变更无 whitespace error。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 106 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-54 Binance public read-only market data batch / replay boundary

日期：2026-05-20

执行者：Codex Execution Agent

目的：

- 定义 `MTPRO Market Data Replay Operations v1` 第一项 issue 的 Binance public read-only market data batch / replay boundary。
- 固化本地 fixture / batch replay contract 的最小字段、required validation mode、optional manual network smoke 边界和 forbidden capability。
- 更新 contract、product surface、validation plan、trading validation matrix 和 automation readiness anchor。

Linear live-read：

- Linear Project：`MTPRO Market Data Replay Operations v1`。
- 当前 issue：`MTP-54` 为唯一 `In Progress` issue。
- `MTP-55`、`MTP-56`、`MTP-57`、`MTP-58`、`MTP-59` 和 `MTP-60` 均为 `Backlog`。
- WIP=1。

文件范围：

- Added：
  - `Sources/Adapters/BinanceMarketDataBatchReplayBoundary.swift`
- Updated：
  - `Tests/AdaptersTests/AdaptersTests.swift`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

证据：

- `BinanceMarketDataBatchReplayBoundary` 固定 public read-only、local fixture replay、required validation 离线可重复和 production operations 禁区。
- `BinanceMarketDataBatchReplayContractField` 覆盖 batch id、replay run id、symbol、interval、time window、fixture source、record count 和 checksum / parity hint。
- `BinanceMarketDataBatchReplayValidationMode` 区分 required mock transport / fixture parity / local batch replay 与 optional manual Binance public network smoke。
- `BinanceMarketDataBatchReplayForbiddenCapability` 显式禁止 API key、signed endpoint、account endpoint、listenKey、Live trading、broker action、真实订单、production runtime operations、large-scale historical downloader 和 data platform。
- Trading Validation Matrix 新增 `TVM-MARKET-DATA-REPLAY-OPERATIONS`，并由 `checks/automation-readiness.sh` 机械检查。

边界确认：

- 不实现真实长周期历史下载器。
- 不实现 production scheduler、多节点运行、云端数据湖或大规模数据平台。
- 不新增 Dashboard UI、Event Timeline evidence 或 read model 输出。
- 不暴露 SQLite / DuckDB schema、runtime object 或 adapter request。
- 不接 API key、signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AdaptersTests/testBatchReplay` | pass | 2 个 focused XCTest，0 failures；覆盖 boundary 最小字段、required / optional validation mode、forbidden capability 和 Codable deterministic snapshot。 |
| `bash checks/automation-readiness.sh` | pass | 新增 MTP-54 validation matrix、validation plan、contract docs、source/test anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 108 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-55 local replay operations metadata 和 batch replay contract

日期：2026-05-20

执行者：Codex Execution Agent

目的：

- 新增 `MTPRO Market Data Replay Operations v1` 第二项 issue 的本地 replay operations metadata 和 batch replay contract。
- 将 MTP-54 的 batch / replay 字段集合落实为 deterministic metadata value model，覆盖 batch id、replay run id、symbol、interval、time window、fixture source、record count 和 checksum / parity hint。
- 更新 contract、product surface、validation plan、trading validation matrix、latest verification summary 和 automation readiness anchor。

Linear live-read：

- Linear Project：`MTPRO Market Data Replay Operations v1`。
- 当前 issue：`MTP-55` 为唯一 `In Progress` issue。
- `MTP-54` 已 `Done`。
- `MTP-56`、`MTP-57`、`MTP-58`、`MTP-59` 和 `MTP-60` 均为 `Backlog`。
- WIP=1。

文件范围：

- Added：
  - `Sources/Adapters/BinanceMarketDataReplayOperationsMetadata.swift`
- Updated：
  - `Sources/Adapters/BinanceMarketDataBatchReplayBoundary.swift`
  - `Tests/AdaptersTests/AdaptersTests.swift`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

证据：

- `BinanceMarketDataReplayOperationsMetadata` 固定 local replay operations metadata 字段，且 Codable round-trip 后保持 deterministic equality。
- `BinanceMarketDataBatchReplayContract` 把 metadata 绑定到 `BinanceMarketDataBatchReplayBoundary`，并证明 required fields、required validation mode、optional validation mode 和 forbidden capability 未漂移。
- `BinanceMarketDataReplayOperationsFixture` 提供 BTCUSDT / 1m / 单条本地 fixture 的 deterministic metadata / contract evidence。
- Tests 覆盖 invalid metadata：负数 record count、空 checksum / parity hint 和不完整 boundary contract。
- Tests 验证 metadata field values 不包含 signed endpoint、account endpoint、listenKey、broker、real order 或 production runtime operations surface。
- Trading Validation Matrix 继续使用 `TVM-MARKET-DATA-REPLAY-OPERATIONS`，并由 `checks/automation-readiness.sh` 机械检查 MTP-55 source / tests / docs anchors。

边界确认：

- 不实现真实长周期历史下载器。
- 不实现 production scheduler、多节点运行、云端数据湖或大规模数据平台。
- 不实现 retention engine、freshness read model、fixture parity hardening、event log / projection consistency 或 UI evidence 接入。
- 不暴露 SQLite / DuckDB schema、runtime object 或 adapter request。
- 不接 API key、signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AdaptersTests/testBatchReplay` | pass | 5 个 focused XCTest，0 failures；覆盖 metadata Codable deterministic equality、batch replay contract completeness、required validation local-only、invalid metadata 和 forbidden field surface tests。 |
| `bash checks/automation-readiness.sh` | pass | 新增 MTP-55 validation matrix、validation plan、contract docs、product surface、source/test anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 111 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-56 最小 retention policy 和 freshness evidence read model

日期：2026-05-20

执行者：Codex Execution Agent

目的：

- 新增 `MTPRO Market Data Replay Operations v1` 第三项 issue 的最小 retention policy 和 freshness evidence read model。
- 让本地 replay operations 可以表达 batch 是否 retained、stale、expired 或 not retained。
- 更新 contract、product surface、validation plan、trading validation matrix、latest verification summary 和 automation readiness anchor。

Linear live-read：

- Linear Project：`MTPRO Market Data Replay Operations v1`。
- 当前 issue：`MTP-56` 为唯一 `In Progress` issue。
- `MTP-54` 和 `MTP-55` 已 `Done`。
- `MTP-57`、`MTP-58`、`MTP-59` 和 `MTP-60` 均为 `Backlog`。
- WIP=1。

文件范围：

- Added：
  - `Sources/Adapters/BinanceMarketDataReplayFreshness.swift`
- Updated：
  - `Tests/AdaptersTests/AdaptersTests.swift`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

证据：

- `BinanceMarketDataReplayRetentionPolicy` 固定最小本地 retention policy，并 deterministic 计算 fresh、stale、expired 和 not retained。
- `BinanceMarketDataReplayFreshnessEvidenceReadModel` 从 `BinanceMarketDataBatchReplayContract` 派生 batch / replay metadata、policy 摘要、batch age、freshness status 和 retention evidence。
- `BinanceMarketDataReplayBatchFreshnessSummary` 聚合 fresh / stale / expired / not retained / retained batch ids，并输出稳定 summary line。
- Tests 验证 freshness read model 不暴露 SQLite / DuckDB schema、adapter request、runtime object、storage tiering、cloud archive、production deletion job 或 command surface。
- Tests 验证 non-local replay contract 会被拒绝，required validation 继续只依赖 mock transport / fixture parity / local batch replay。
- Trading Validation Matrix 继续使用 `TVM-MARKET-DATA-REPLAY-OPERATIONS`，并由 `checks/automation-readiness.sh` 机械检查 MTP-56 source / tests / docs anchors。

边界确认：

- 不实现完整 retention engine。
- 不执行生产数据清理任务。
- 不做云端 archive、storage tiering、多节点运行或数据湖。
- 不串联 event log / projection consistency，不接 Dashboard UI 或 operations console。
- 不暴露 SQLite / DuckDB schema、runtime object、adapter request 或 persistence adapter direct read。
- 不接 API key、signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AdaptersTests/testBatchReplay` | pass | 8 个 focused XCTest，0 failures；覆盖 retention policy、freshness evidence read model、batch freshness summary、schema / adapter / runtime non-exposure 和 non-local replay contract rejection tests。 |
| `bash checks/automation-readiness.sh` | pass | 新增 MTP-56 validation matrix、validation plan、contract docs、product surface、source/test anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 114 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-57 deterministic fixture parity 和 replay consistency

日期：2026-05-20

执行者：Codex Execution Agent

目的：

- 新增 `MTPRO Market Data Replay Operations v1` 第四项 issue 的 deterministic fixture parity 和 replay consistency evidence。
- 验证本地 batch replay output、metadata record count、record ordering、checksum / parity hint 和 metadata consistency。
- 更新 contract、product surface、validation plan、trading validation matrix、latest verification summary 和 automation readiness anchor。

Linear live-read：

- Linear Project：`MTPRO Market Data Replay Operations v1`。
- 当前 issue：`MTP-57` 为唯一 `In Progress` issue。
- `MTP-54`、`MTP-55` 和 `MTP-56` 已 `Done`。
- `MTP-58`、`MTP-59` 和 `MTP-60` 均为 `Backlog`。
- WIP=1。

文件范围：

- Added：
  - `Sources/Adapters/BinanceMarketDataReplayParity.swift`
- Updated：
  - `Sources/Adapters/BinanceMarketDataReplayOperationsMetadata.swift`
  - `Tests/AdaptersTests/AdaptersTests.swift`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

证据：

- `BinanceMarketDataBatchReplayConsistencyEvidence` 从 `BinanceMarketDataBatchReplayContract` 和本地 replayed `MarketBar` records 派生，不读取真实 Binance 网络、不写 event log、不触发 projection。
- `BinanceMarketDataBatchReplayDeterministicParity` 生成 deterministic replay output summary 和稳定 FNV-1a parity hint。
- Tests 验证 metadata record count、symbol、interval、time window、record ordering 和 checksum / parity hint 与 replay output 一致。
- Tests 验证 record count drift、乱序 replay output、checksum drift、metadata drift 和 non-local replay contract 会被拒绝。
- Trading Validation Matrix 继续使用 `TVM-MARKET-DATA-REPLAY-OPERATIONS`，并由 `checks/automation-readiness.sh` 机械检查 MTP-57 source / tests / docs anchors。

边界确认：

- 不做真实 Binance 网络 required validation。
- 不实现真实长周期历史下载器。
- 不进入 production operations。
- 不串联 event log / projection consistency，不接 Dashboard UI 或 operations console。
- 不暴露 SQLite / DuckDB schema、runtime object、adapter request 或 persistence adapter direct read。
- 不接 API key、signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AdaptersTests/testBatchReplay` | pass | 11 个 focused XCTest，0 failures；覆盖 deterministic fixture parity、replay consistency、metadata count / ordering / checksum drift rejection 和 network boundary drift tests。 |
| `bash checks/automation-readiness.sh` | pass | 新增 MTP-57 validation matrix、validation plan、contract docs、product surface、source/test anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 117 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## MTP-58 event log / projection snapshot consistency evidence

日期：2026-05-20

执行者：Codex Execution Agent

目的：

- 新增 `MTPRO Market Data Replay Operations v1` 第五项 issue 的 event log / projection snapshot consistency evidence。
- 将 MTP-55 replay metadata、MTP-56 freshness evidence、MTP-57 deterministic replay consistency evidence 与 append-only `.market` event log、replay result、cache snapshot、SQLite runtime projection 空快照和 DuckDB analytical projection snapshot 串联。
- 更新 contract、read-model projection、persistence boundary、product surface、validation plan、trading validation matrix、latest verification summary 和 automation readiness anchor。

Linear live-read：

- Linear Project：`MTPRO Market Data Replay Operations v1`。
- 当前 issue：`MTP-58` 为唯一 `In Progress` issue。
- `MTP-54`、`MTP-55`、`MTP-56` 和 `MTP-57` 已 `Done`。
- `MTP-59` 和 `MTP-60` 均为 `Backlog`。
- WIP=1。

文件范围：

- Added：
  - `Sources/Runtime/MarketDataReplayProjectionConsistency.swift`
- Updated：
  - `Tests/RuntimeTests/RuntimeTests.swift`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/contracts/read-model-projection.md`
  - `docs/contracts/persistence-boundary.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

证据：

- `MarketDataReplayProjectionConsistency` 从本地 batch replay contract、freshness evidence、fixture parity evidence 和 append-only event log facts 生成 consistency summary。
- `MarketDataReplayEventLogConsistencyEvidence` 验证 `.market` stream sequence、replay result sequence、metadata record count 和 event log record count 一致。
- `MarketDataReplayProjectionSnapshotConsistencySummary` 验证 replay output summary、event log summary、cache snapshot summary 和 DuckDB analytical projection summary 一致。
- Tests 验证 market-only replay 不在 SQLite runtime projection 中产生 Paper / Risk / Portfolio 状态。
- Tests 验证 summary 可 Codable encode / decode，并保持 deterministic equality。
- Tests 验证 event log drift、projection snapshot drift、schema / runtime source drift 和 non-local replay contract drift 会被拒绝。
- Trading Validation Matrix 继续使用 `TVM-MARKET-DATA-REPLAY-OPERATIONS`，并由 `checks/automation-readiness.sh` 机械检查 MTP-58 source / tests / docs anchors。

边界确认：

- 不做完整数据库 schema 设计。
- 不做 migration framework。
- 不做 production data pipeline。
- 不接 Dashboard / Report / Event Timeline UI。
- 不暴露 SQLite / DuckDB schema、SQL、ORM、runtime object、adapter request 或 persistence adapter direct read。
- 不接 API key、signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter RuntimeTests` | pass | 7 个 RuntimeTests，0 failures；覆盖 event log / projection consistency、deterministic summary、schema non-exposure、event log drift、projection drift 和 source boundary drift tests。 |
| `bash checks/automation-readiness.sh` | pass | 新增 MTP-58 Runtime source / tests、validation-plan、matrix、contract docs、product surface anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过，输出 `MTPRO checks passed.`。 |

## 2026-05-20 — MTP-59 Report / Dashboard / Event Timeline replay operations evidence

执行者：Codex

上下文：

- Linear live-read 确认 `MTP-59` 为唯一 `In Progress` issue；`MTP-54`、`MTP-55`、`MTP-56`、`MTP-57` 和 `MTP-58` 已 `Done`；`MTP-60` 为 `Backlog`；WIP=1。
- 本轮 scope 限定为 Report / Dashboard / Event Timeline read-model-only evidence 接入，展示 batch id、replay run id、freshness status、retention status 和 projection consistency summary。

文件范围：

- Added：
  - `Sources/App/MarketDataReplayOperationsEvidence.swift`
- Updated：
  - `Package.swift`
  - `Sources/App/App.swift`
  - `Sources/App/PaperWorkflowEvidenceExplorer.swift`
  - `Sources/App/DashboardShell.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/product/product-surface-map.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

证据：

- `MarketDataReplayOperationsEvidenceReadModel` 和 `MarketDataReplayOperationsEvidenceViewModel` 将 MTP-58 summary 复制成 App 层 read-model-only evidence，不让 Dashboard shell 直接导入 Runtime / Adapters。
- `ReportViewModel` 展示 replay operations evidence count、batch ids、replay run ids、freshness / retention status、event log / replay record counts 和 projection consistency boundary。
- `PaperWorkflowEvidenceExplorerSection.marketDataReplayOperation` 新增 Event Timeline 专用分区，展示 replay operations evidence item。
- `DashboardShellSnapshot` Report section 新增 `Replay ops` 指标和 replay operation details；Dashboard smoke 保持 8 个主 sections。

边界确认：

- 不做完整 UI redesign。
- 不做 production operations console。
- 不新增 Runtime command、retention cleanup、projection rebuild、order-level command、按钮或表单。
- 不暴露 SQLite / DuckDB schema、SQL、ORM、Runtime object、adapter request 或 persistence implementation。
- 不接 API key、signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。
- 未修改 Linear status。
- 未创建 Linear Project / Issue。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 16 个 AppTests，0 failures；覆盖 Report / Dashboard / Event Timeline replay operations evidence、Codable snapshot、market data replay operation timeline item 和 no schema / no runtime / no adapter / no command boundary tests。 |
| `bash checks/automation-readiness.sh` | pass | 新增 MTP-59 App read model / ViewModel、Report / Dashboard / Event Timeline evidence、validation-plan、matrix、contract docs、product surface 和 source/test anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Professional Trading Workstation Goal Alignment

日期：2026-05-20

执行者：Codex

目的：

- 将 MTPRO 最终产品定位明确为 local-first 的 macOS 原生专业交易工作台。
- 将 `GOAL.md` 从旧的 paper-only 5/5 口径调整为两层进度：Current Foundation Progress 和 Final Product Goal Progress。
- 将最终产品目标拆成 9 个中文优先目标切片，覆盖 Research / Backtest / Report、Paper、Workbench、Market Data Replay，以及 future-gated 的实盘交易基础边界、实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制。
- 同步 `BLUEPRINT.md`、`ROADMAP.md`、Parent Codex 进度条规则和 automation readiness 锚点。

文件范围：

- Updated：
  - `README.md`
  - `AGENTS.md`
  - `GOAL.md`
  - `BLUEPRINT.md`
  - `ROADMAP.md`
  - `docs/automation/parent-codex-supervision.md`
  - `checks/automation-readiness.sh`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Professional Trading Workstation Goal Alignment 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | 两层进度、专业交易工作台定位、final product goal slices 和 future-gated 实盘切片锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Goal Charter Progress Scope Compression

日期：2026-05-20

执行者：Codex

目的：

- 将 `GOAL.md` 中的当前进度内容压回 Project Charter 级别。
- 保留 Current Foundation Progress 和 Final Product Goal Progress 两层总数。
- 保留已完成 foundation 摘要和 future-gated 实盘目标名称。
- 明确完整 9 项目标切片、状态和证据口径由 `ROADMAP.md` 维护，`GOAL.md` 不复制维护详细进度表。

文件范围：

- Updated：
  - `GOAL.md`
  - `checks/automation-readiness.sh`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Goal Charter Progress Scope Compression 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | `GOAL.md` 保留两层进度总数并指向 `ROADMAP.md` 维护详细目标切片。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Complete Blueprint Product / Architecture / Design Structure

日期：2026-05-20

执行者：Codex

目的：

- 将 `BLUEPRINT.md` 明确为产品、架构、设计三线合一的完整蓝图。
- 新增 Blueprint Design Lenses，说明 Product / Architecture / Design 三条线分别回答什么问题。
- 将蓝图结构调整为 Product Blueprint、Architecture Blueprint、Design Blueprint、Infrastructure Blueprint、Trading Capability Blueprint、Live Gate Blueprint、Current / Future Boundary、Blueprint -> Architecture -> Roadmap Handoff。
- 明确 `ARCHITECTURE.md` 承接 `BLUEPRINT.md`，把蓝图翻译为系统模块、边界、数据流、接口、约束和技术分层；`ROADMAP.md` 再承接施工顺序。

文件范围：

- Updated：
  - `BLUEPRINT.md`
  - `checks/automation-readiness.sh`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Complete Blueprint Product / Architecture / Design Structure 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | 蓝图三线结构、基础设施、交易能力、实盘准入和蓝图到架构 / 路线交接锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Remove Legacy Blueprint Compatibility Entry

日期：2026-05-20

执行者：Codex

目的：

- 删除 `docs/design/mtpro-complete-blueprint.md` 旧兼容入口。
- 明确蓝图本体只维护在根目录 `BLUEPRINT.md`。
- 清理当前入口文档、shared language、latest verification summary 和 automation readiness 中的旧兼容入口引用。
- 保留 `verification.md` 历史记录中的旧路径引用，保持 append-only 审计历史不重写。

文件范围：

- Deleted：
  - `docs/design/mtpro-complete-blueprint.md`
- Updated：
  - `BLUEPRINT.md`
  - `README.md`
  - `docs/domain/context.md`
  - `checks/automation-readiness.sh`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Remove Legacy Blueprint Compatibility Entry 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | readiness 确认旧兼容入口不存在，蓝图入口只保留 `BLUEPRINT.md`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## 2026-05-20 — MTP-60 automation readiness、validation evidence 和 stage audit input material 收口

执行者：Codex

上下文：

- Linear live-read 确认 `MTP-60` 为唯一 `In Progress` issue；`MTP-54`、`MTP-55`、`MTP-56`、`MTP-57`、`MTP-58` 和 `MTP-59` 已 `Done`；WIP=1。
- 本轮 scope 限定为 validation evidence、automation readiness anchor、Dashboard smoke evidence、known boundaries 和 Stage Code Audit input material。
- 本 issue 不输出最终 Stage Code Audit Report；最终报告仍由 Parent Codex 在 Project 全部 Done 且 Linear Project `Completed` 后单独输出。

文件范围：

- Added：
  - `docs/audit/inputs/mtpro-market-data-replay-operations-v1-stage-audit-input.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/automation/automation-readiness.md`
  - `docs/validation/latest-verification-summary.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `verification.md`

证据：

- MTP-60 Stage Audit Input 汇总 PR #101、#102、#103、#104、#105、#106 和当前 issue PR 的 evidence 输入。
- Market data replay operations validation evidence chain 覆盖 MTP-54 batch / replay boundary、MTP-55 metadata contract、MTP-56 retention / freshness evidence、MTP-57 fixture parity、MTP-58 event log / projection consistency 和 MTP-59 Report / Dashboard / Event Timeline read-model-only evidence。
- `checks/automation-readiness.sh` 新增 MTP-60 audit input、validation plan、matrix、latest summary 和 Dashboard smoke anchors。
- Trading Validation Matrix 新增 MTP-60 阶段收口说明，指向 `docs/audit/inputs/mtpro-market-data-replay-operations-v1-stage-audit-input.md`。

边界确认：

- 不输出最终 Stage Code Audit Report。
- 不创建下一 Project / Issue。
- 不推进下一 Project / Issue。
- 不启动下一阶段 `symphony-issue`。
- 不写业务功能扩展。
- 不接 API key、signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。
- 不实现 production data platform、production scheduler、retention cleanup job、projection rebuild command 或 operations console。
- 未修改 Linear status。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未提交 `.codex/*` 或 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 新增 MTP-60 stage audit input、validation plan、matrix、latest summary 和 Dashboard smoke anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## MTPRO Market Data Replay Operations v1 Stage Code Audit Report

日期：2026-05-20

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 完成 `MTPRO Market Data Replay Operations v1` 的 Project closure evidence。
- 确认 `MTP-54`、`MTP-55`、`MTP-56`、`MTP-57`、`MTP-58`、`MTP-59`、`MTP-60` 全部 Linear `Done/type=completed`。
- 将 Linear Project status 设置并确认为 `Completed/type=completed`，`completedAt=2026-05-20T08:23:20Z`。
- 将 Project 级 Stage Code Audit Report 落仓为 canonical 文档。
- 更新最近验证摘要，指向 canonical Stage Code Audit Report。

文件范围：

- Added：
  - `docs/audit/mtpro-market-data-replay-operations-v1-stage-code-audit.md`
- Updated：
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

证据：

- PR #101、#102、#103、#104、#105、#106、#107 全部已通过 GitHub required check `checks` 并 squash merge。
- 末端 merge commit 为 `640c7c096fc236f7037551edb7611cbe17f226a2`。
- Post-Issue Ledger 对 `MTP-60` 记录 `git_pull_ff_only` 和 `graphify_update` 均为 `passed`。
- Graphify resource relationship graph 由 Post-Issue Ledger 刷新为 1140 nodes、1092 edges、66 communities。
- Stage Code Audit Report 已记录 Known CI Boundary：本 Project 无当前 main 遗留 failing PR run；MTP-57 的 Linear 状态 race 属于临时 automation 现象，不是 GitHub checks 失败。

边界确认：

- 本轮只落仓 Stage Code Audit Report，不创建 Linear Project / Issue。
- 未推进任何 issue 到 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update；Graphify evidence 来自 Post-Issue Ledger 已完成记录。
- 未写业务代码。
- 未修改 root docs；Root Docs Refresh Gate 需在本 Stage Code Audit Report 合并后单独执行。
- 未提交 `.codex/*` 或 `graphify-out/*`。
- 不接 Live trading、signed endpoint、account endpoint、listenKey、broker action 或真实订单行为。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 本轮 Stage Code Audit Report 落仓变更无 whitespace error。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## MTPRO Market Data Replay Operations v1 Root Docs Refresh Gate closure

日期：2026-05-20

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 基于已合并的 `docs/audit/mtpro-market-data-replay-operations-v1-stage-code-audit.md` 执行 Root Docs Refresh Gate closure。
- 逐项核查 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md`、`ROADMAP.md` 是否落后于已完成事实。
- 更新当前 Goal / Roadmap Target Progress 和 Current Phase Progress Bar。

Root docs 判断：

- `GOAL.md`：updated。同步 “更长周期 market data replay / operations” 已形成本地 evidence baseline，并将当前目标进度更新为 5 / 5（100%）。
- `ENVIRONMENT.md`：no update needed。本 Project 未新增外部依赖或验证入口；统一验证入口仍是 `bash checks/run.sh`。
- `ARCHITECTURE.md`：updated。同步 Adapters / Runtime / App / Dashboard 的 market data replay operations evidence flow。
- `ROADMAP.md`：updated。新增 `MTPRO Market Data Replay Operations v1` 为 Completed，并将 Project Closure Count 更新为 7 / 7、Goal / Roadmap Target Progress 更新为 5 / 5（100%）。

文件范围：

- Updated：
  - `GOAL.md`
  - `ARCHITECTURE.md`
  - `ROADMAP.md`
  - `docs/audit/mtpro-market-data-replay-operations-v1-stage-code-audit.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- 本轮只同步已发生事实。
- 不决定下一阶段方向。
- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 `Todo`。
- 不启动 Symphony。
- 不运行 Graphify update。
- 不写业务代码。
- 不修改 `docs/design/mtpro-complete-blueprint.md`。
- 不把 future capability 计入 progress。

Current Phase Progress：

```text
Current Phase Progress
Phase: MTPRO paper-only research / validation / execution foundation
Project Closure Count: 7/7 (100%)
Goal / Roadmap Target Progress: 5/5 (100%)
Progress: [##########] 100%
Latest Completed Project: MTPRO Market Data Replay Operations v1
Next Handoff: Human + @001 / PLN
```

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Root Docs Refresh Gate closure docs-only 变更无 whitespace error。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## AEP Numbered Blueprint Flow Alignment

日期：2026-05-20

执行者：Codex

目的：

- 将调整后的 AEP Root Blueprint / Complete Blueprint / Construction Plan 分层应用到 MTPRO。
- 新增根目录 `BLUEPRINT.md` 作为 Root Blueprint 入口和默认读取顺序事实源。
- 将 MTPRO root docs 对齐到 AEP 编号方法论：`GOAL.md` 是 Project Charter，`BLUEPRINT.md` 是 Root Blueprint，`ARCHITECTURE.md` 是 Architecture Map，`ROADMAP.md` 是 Construction Plan。
- 将 `docs/validation/latest-verification-summary.md` 从长历史摘录压缩回轻量入口，同时保留 automation readiness 所需锚点。

文件范围：

- Added：
  - `BLUEPRINT.md`
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `GOAL.md`
  - `ARCHITECTURE.md`
  - `ROADMAP.md`
  - `checks/automation-readiness.sh`
  - `docs/design/mtpro-complete-blueprint.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | AEP alignment docs-only 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | Root Blueprint、默认读取顺序、Complete Blueprint 分层和 latest summary 锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；输出 `MTPRO checks passed.`。 |

## Skill-derived Agent Engineering Practices Integration

日期：2026-05-20

执行者：Codex

目的：

- 将 `mattpocock/skills` 中适合 MTPRO 的 shared language、Feedback Loop First、TDD / Tracer Bullet、Diagnose Loop、Architecture Deepening Review 和 Handoff Discipline 整合到 MTPRO 项目流程。
- 新增 MTPRO 领域上下文入口，让 Agent 在 Project Planning、Linear issue、PR、Stage Audit 和代码注释中使用统一术语。
- 用 automation readiness 将新增方法论文档和关键锚点变成机械检查项。

参考来源：

- `https://github.com/mattpocock/skills`
- `https://github.com/mattpocock/skills/blob/main/CONTEXT.md`
- `https://github.com/mattpocock/skills/tree/main/skills/engineering/grill-with-docs`
- `https://github.com/mattpocock/skills/tree/main/skills/engineering/tdd`
- `https://github.com/mattpocock/skills/tree/main/skills/engineering/diagnose`
- `https://github.com/mattpocock/skills/tree/main/skills/engineering/to-issues`
- `https://github.com/mattpocock/skills/tree/main/skills/engineering/improve-codebase-architecture`

文件范围：

- Added：
  - `docs/domain/context.md`
  - `docs/automation/agent-engineering-practices.md`
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `BLUEPRINT.md`
  - `checks/automation-readiness.sh`
  - `docs/design/mtpro-complete-blueprint.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | docs-only methodology 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | shared language、agent engineering practices、Root Blueprint 读序和关键锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Root Docs Compression Pass After Skills Integration

日期：2026-05-20

执行者：Codex

目的：

- 基于 `mattpocock/skills` 方法论整合后的版本，从 `README.md` 开始再压缩一轮默认读路径。
- 保持 `README.md` 为仓库入口，`BLUEPRINT.md` 为 Root Blueprint，`AGENTS.md` 为行为边界，`docs/domain/context.md` 为 shared language，`docs/automation/agent-engineering-practices.md` 为方法论入口，`docs/validation/latest-verification-summary.md` 为轻量验证入口。
- 删除重复解释，保留必要锚点和 automation readiness 机械检查。

文件范围：

- Updated：
  - `README.md`
  - `AGENTS.md`
  - `BLUEPRINT.md`
  - `checks/automation-readiness.sh`
  - `docs/domain/context.md`
  - `docs/automation/agent-engineering-practices.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

压缩结果：

- 默认入口相关文档从 1054 行压缩到约 965 行。
- `AGENTS.md` 将角色长解释收回 `docs/planning/project-role-map.md`。
- `docs/domain/context.md` 合并 Project / Execution 术语表。
- `docs/automation/agent-engineering-practices.md` 保留规则和锚点，减少解释性展开。
- `docs/validation/latest-verification-summary.md` 保持轻量入口，不复制完整 audit/input 路径清单。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | docs compression 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | root docs、shared language、skills practices、latest summary 和关键锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Canonical Blueprint Unification

日期：2026-05-20

执行者：Codex

目的：

- 将 Root Blueprint 与 Complete Blueprint 统一到根目录 `BLUEPRINT.md`。
- 保留 `docs/design/mtpro-complete-blueprint.md` 为旧链接兼容入口，避免蓝图正文双写漂移。
- 同步 README、AGENTS、GOAL、ROADMAP、shared language、role map、Parent Codex supervision、latest summary 和 automation readiness 锚点。

文件范围：

- Updated：
  - `README.md`
  - `AGENTS.md`
  - `GOAL.md`
  - `BLUEPRINT.md`
  - `ROADMAP.md`
  - `checks/automation-readiness.sh`
  - `docs/domain/context.md`
  - `docs/design/mtpro-complete-blueprint.md`
  - `docs/planning/project-role-map.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | blueprint unification docs/checks 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | canonical `BLUEPRINT.md`、兼容入口、root docs、shared language 和关键锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Goal / Blueprint Responsibility Optimization

日期：2026-05-20

执行者：Codex

目的：

- 将 `GOAL.md` 压回 Project Charter：为什么建、服务谁、永久硬边界、成功标准和当前目标进度入口。
- 将最终产品 / 系统 / 设计规划集中到 `BLUEPRINT.md`。
- 在 `BLUEPRINT.md` 中固化 `GOAL.md` / `BLUEPRINT.md` / `ARCHITECTURE.md` / `ROADMAP.md` 的职责分工。
- 将 Goal / Blueprint 分工加入 automation readiness 机械锚点。

文件范围：

- Updated：
  - `GOAL.md`
  - `BLUEPRINT.md`
  - `checks/automation-readiness.sh`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Goal / Blueprint 分工优化变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | Project Charter、Blueprint responsibility contract、Blueprint update rule 和 root docs 锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Blueprint Boundary Chinese Labels

日期：2026-05-20

执行者：Codex

目的：

- 为 `Future Construction Zones` 增加中文并列描述：`未来建设区`。
- 为 `Gated / Forbidden Capabilities` 增加中文并列描述：`受门禁保护或当前禁止的能力`。
- 为 `Forbidden Terms` 增加中文并列描述：`当前禁用或必须带门禁语义的词`。
- 将中英并列写法加入 automation readiness，避免蓝图边界退回全英文标签。

文件范围：

- Updated：
  - `BLUEPRINT.md`
  - `GOAL.md`
  - `ROADMAP.md`
  - `AGENTS.md`
  - `docs/domain/context.md`
  - `docs/planning/project-role-map.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Blueprint boundary Chinese labels 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | Future Construction Zones / 未来建设区、Gated / Forbidden Capabilities / 受门禁保护或当前禁止的能力等锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Secondary Weight Docs Rehome

日期：2026-05-20

执行者：Codex

目的：

- 将 `ARCHITECTURE.md`、`ENVIRONMENT.md`、`ROADMAP.md` 下沉为 `docs/` 下的二级权重文档。
- 固定 `docs/architecture.md` 的中文语义为 Engineering Module Map / 工程模块地图。
- 固定 `docs/roadmap.md` 的职责为“根据蓝图和工程模块定义施工顺序、进度和下一阶段 handoff”。
- 明确 `docs/architecture.md`、`docs/environment.md` 和 `docs/roadmap.md` 只能承接并细化 `BLUEPRINT.md`，不能推翻蓝图。

文件范围：

- Moved：
  - `ARCHITECTURE.md` -> `docs/architecture.md`
  - `ENVIRONMENT.md` -> `docs/environment.md`
  - `ROADMAP.md` -> `docs/roadmap.md`
- Updated：
  - `README.md`
  - `AGENTS.md`
  - `GOAL.md`
  - `BLUEPRINT.md`
  - `checks/automation-readiness.sh`
  - `docs/domain/context.md`
  - `docs/planning/project-role-map.md`
  - `docs/planning/linear-draft-plan.md`
  - `docs/automation/graphify-resource-graph-scope.md`
  - `docs/automation/parent-codex-supervision.md`
  - `docs/automation/codex-use-cases-alignment.md`
  - `docs/automation/post-issue-ledger.md`
  - `docs/reference/nautilus-trader/*`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Secondary Weight Docs Rehome 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | 二级权重文档位置、工程模块地图语义、roadmap 施工路线语义和旧根目录入口反向检查通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Environment / Architecture Docs Deepening

日期：2026-05-20

执行者：Codex

目的：

- 补强 `docs/environment.md`，使其成为运行 / 验证 / 外部系统边界的清晰合同，而不是简短摘要。
- 补强 `docs/architecture.md`，使其成为承接 `BLUEPRINT.md` 的工程模块地图，明确 SwiftPM 依赖方向、模块边界、能力流、架构不变量和 Future Live 隔离。
- 将关键章节写入 `checks/automation-readiness.sh` 锚点，降低后续文档漂移风险。

文件范围：

- `docs/environment.md`
- `docs/architecture.md`
- `checks/automation-readiness.sh`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Environment / Architecture Docs Deepening 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | environment / architecture 新章节锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Roadmap Docs Deepening

日期：2026-05-20

执行者：Codex

目的：

- 补强 `docs/roadmap.md`，使其成为承接 `BLUEPRINT.md` 和 `docs/architecture.md` 的施工路线、进度口径和下一轮 handoff 合同。
- 明确路线输入、已完成阶段地图、两层进度模型、施工切片选择规则、实盘路线门槛、Project 收口规则和下一轮交接合同。
- 将关键章节写入 `checks/automation-readiness.sh` 锚点，降低后续路线和进度口径漂移风险。

文件范围：

- `docs/roadmap.md`
- `checks/automation-readiness.sh`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project。
- 未创建 Linear issue。
- 未修改 Linear status。
- 未推进 `Todo`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Roadmap Docs Deepening 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | roadmap 新章节锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## Root Docs Stack Compression

日期：2026-05-20
执行者：Codex
PR：本 PR
Commit：

目的：
- 从 `README.md` 开始继续压缩 MTPRO 文档栈。
- 保持 `GOAL.md` / `BLUEPRINT.md` / `docs/environment.md` / `docs/architecture.md` / `docs/roadmap.md` 的权重分工。
- 压缩重复叙述，让 `README.md` 只做入口，`GOAL.md` 只做 Project Charter，`BLUEPRINT.md` 只做 canonical Root / Complete Blueprint。
- 保留 `docs/architecture.md` 作为 Engineering Module Map / 工程模块地图。
- 保留 `docs/roadmap.md` 作为 Construction Plan / 施工路线。

文件范围：
- Updated:
  - `README.md`
  - `AGENTS.md`
  - `GOAL.md`
  - `BLUEPRINT.md`
  - `docs/architecture.md`
  - `docs/roadmap.md`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

边界确认：
- docs-only。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未推进 Todo。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Root Docs Stack Compression 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | root docs / blueprint / roadmap / architecture 锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## MTPRO Live Trading Boundary Definition v1 Project Planning Record

日期：2026-05-20

执行者：Codex（`@000 / AIE`）

目的：

- 将 Human 确认的 `MTPRO Live Trading Boundary Definition v1` 下一阶段 Project-level planning record 落仓。
- 只保存 Project 级计划摘要和格式门槛，不复制维护完整 Linear issue body。
- 更新 Project Planning Record 索引、最近验证摘要和 automation readiness anchor。

文件范围：

- Added：
  - `docs/planning/projects/mtpro-live-trading-boundary-definition-v1-plan.md`
- Updated：
  - `docs/planning/linear-draft-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

规划摘要：

- Project name：`MTPRO Live Trading Boundary Definition v1`
- Project goal：定义 Live trading foundation 的 gate、contract、blocked evidence 和 forbidden capability tests。
- First executable issue candidate：定义 Live trading foundation capability taxonomy 和 gate。
- WIP=1：所有候选 issue 写入 Linear 后必须初始保持 `Backlog / non-executable`。
- 完整 issue execution contract 以后以 Linear issue body 为准。

边界确认：

- 本轮只落仓 Project Planning Record。
- 未创建 Linear Project。
- 未创建 Linear Issues。
- 未修改 Linear status。
- 未推进任何 issue 到 `Todo`。
- 未启动 `@002 / PAR`。
- 未启动 Symphony / `symphony-issue`。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。
- 本 planning record 不授权执行。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Live Trading Boundary planning record docs-only 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | Live Trading Boundary planning record 锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## MTP-61 Live Trading Foundation taxonomy / gate

日期：2026-05-21

执行者：Codex

目的：

- 定义 Live trading foundation capability taxonomy、gate 顺序和当前禁止边界。
- 为 `live capability`、`blocked capability`、`future gate` 和 `forbidden capability` 建立 shared language。
- 将 MTP-61 的验证入口固定到 `TVM-LIVE-TRADING-FOUNDATION` 和 automation readiness anchor。

文件范围：

- Added：
  - `docs/contracts/live-trading-boundary-contract.md`
- Updated：
  - `docs/domain/context.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未实现 API key。
- 未实现 secret storage。
- 未实现 signed endpoint。
- 未实现 account endpoint。
- 未实现 listenKey user data stream。
- 未连接 broker / exchange execution adapter。
- 未实现 real order submit / cancel / replace。
- 未实现 OMS。
- 未实现 `LiveExecutionAdapter`。
- 未做实盘监控台、执行控制、风险控制、审计 / 停机控制。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | MTP-61 docs / checks 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | `docs/contracts/live-trading-boundary-contract.md`、`TVM-LIVE-TRADING-FOUNDATION`、MTP-61 validation-plan 和 domain terms anchors 通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 121 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## MTP-62 API key / signed endpoint / account endpoint / listenKey boundary

日期：2026-05-21

执行者：Codex

目的：

- 定义 API key / secret / signed endpoint / account endpoint / listenKey 的禁止边界和 future gate。
- 证明 public read-only market data adapter 不能升级为 signed / account capability。
- 将 Gate 1 validation anchor 回填到 `TVM-LIVE-TRADING-FOUNDATION`、validation plan 和 automation readiness。

文件范围：

- Added：
  - `Sources/Core/LiveTradingBoundary.swift`
- Updated：
  - `Sources/Core/CoreError.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/AdaptersTests/AdaptersTests.swift`
  - `docs/contracts/live-trading-boundary-contract.md`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/domain/context.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未读取真实 API key。
- 未新增环境变量、配置项、Keychain 读取或 secret 文件读取。
- 未实现 secret storage。
- 未实现 request signature / signed request helper。
- 未调用 signed endpoint。
- 未调用 account endpoint。
- 未创建 listenKey 或 user data stream。
- 未连接 broker / exchange execution adapter。
- 未实现真实账户 payload、真实订单、OMS 或 `LiveExecutionAdapter`。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter LiveTradingCredentialEndpointBoundary` | pass | 2 tests, 0 failures；覆盖 MTP-62 Core Gate 1 fixture、Codable round trip 和 forbidden flag bypass rejection。 |
| `swift test --filter PublicReadOnlyAdapterCannotUpgradeIntoMTP62CredentialOrAccountCapability` | pass | 1 test, 0 failures；覆盖 public read-only adapter 对 keyed / signature / account / listenKey contract 的 transport 前拒绝。 |
| `bash checks/automation-readiness.sh` | pass | MTP-62 contract、matrix、validation-plan、domain terms 和 deterministic test anchors 通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 124 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## MTP-63 public read-only adapter / future live adapter capability isolation

日期：2026-05-21

执行者：Codex

目的：

- 定义 current Binance public read-only adapter 与 future live adapter capability 的隔离合同。
- 证明 future live adapter、`LiveExecutionAdapter`、broker / exchange execution adapter 和 execution venue 只能作为 future gate / forbidden capability 出现。
- 将 Gate 2 validation anchor 回填到 `TVM-LIVE-TRADING-FOUNDATION`、validation plan 和 automation readiness。

文件范围：

- Updated：
  - `Sources/Core/LiveTradingBoundary.swift`
  - `Sources/Adapters/Adapters.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/AdaptersTests/AdaptersTests.swift`
  - `docs/contracts/live-trading-boundary-contract.md`
  - `docs/domain/context.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未实现 future live adapter。
- 未实现 `LiveExecutionAdapter` public type / protocol / actor / class / enum。
- 未连接 broker / exchange execution adapter。
- 未连接 execution venue。
- 未调用 signed endpoint、account endpoint 或 listenKey。
- 未提交、撤销或替换真实订单。
- 未实现 real order lifecycle 或 OMS。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter LiveAdapterCapabilityIsolationBoundary` | pass | 2 tests, 0 failures；覆盖 MTP-63 Core Gate 2 fixture、Codable round trip、`LiveExecutionAdapter` non-implementation、broker / exchange adapter instantiation rejection 和 real order bypass rejection。 |
| `swift test --filter PublicReadOnlyAdapterCannotInstantiateMTP63LiveAdapterOrExecutionVenueCapability` | pass | 1 test, 0 failures；覆盖 public read-only adapter 对 broker、`LiveExecutionAdapter`、submit、cancel 和 replace contract 的 transport 前拒绝。 |
| `swift test --filter MTP63` | pass | 2 tests, 0 failures；覆盖 Core deterministic fixture 和 Adapters execution semantic rejection fast path。 |
| `bash checks/automation-readiness.sh` | pass | MTP-63 contract、matrix、validation-plan、domain terms、deterministic test anchors 和 `LiveExecutionAdapter` declaration guard 通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 127 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## MTP-64 real order lifecycle terminology / future gate / forbidden capability tests

日期：2026-05-21

执行者：Codex

目的：

- 定义 Gate 3 real order lifecycle terminology、future gate 和 forbidden capability tests。
- 证明 submit / cancel / replace、execution report、broker fill、reconciliation、OMS、真实账户状态和 broker position sync 仍是 future / forbidden capability。
- 证明 paper order lifecycle、simulated fill 和 paper portfolio projection 不能升级为 real order、broker fill 或 account state。

文件范围：

- Updated：
  - `Sources/Core/LiveTradingBoundary.swift`
  - `Sources/Adapters/Adapters.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `Tests/AdaptersTests/AdaptersTests.swift`
  - `docs/contracts/live-trading-boundary-contract.md`
  - `docs/contracts/binance-market-data-contract.md`
  - `docs/domain/context.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未实现 real order state machine。
- 未实现 submit / cancel / replace。
- 未实现 execution report ingestion。
- 未记录 broker fill 或 real fill。
- 未执行 reconciliation。
- 未实现 OMS。
- 未读取真实账户状态。
- 未同步 broker position。
- 未把 paper order intent、simulated fill 或 paper portfolio projection 升级为真实订单、broker fill 或 account state。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter RealOrderLifecycle` | pass | 4 tests, 0 failures；覆盖 Gate 3 Core fixture、paper / real lifecycle isolation 和 Adapters real order lifecycle rejection。 |
| `swift test --filter MTP64` | pass | 3 tests, 0 failures；覆盖 Core deterministic fixture、forbidden bypass rejection 和 Adapters transport-before-network rejection fast path。 |
| `bash checks/automation-readiness.sh` | pass | MTP-64 contract、matrix、validation-plan、domain terms、deterministic test anchors 和 `RealOrderStateMachine` declaration guard 通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 131 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## MTP-65 LiveReadiness / LiveBlockedEvidence read model

日期：2026-05-21

执行者：Codex

目的：

- 新增 Gate 4 `LiveReadiness` / `LiveBlockedEvidence` read-model-only blocked evidence。
- 表达 API key、signed endpoint、account endpoint、listenKey、broker adapter 和 real order lifecycle gates 当前全部 blocked。
- 证明 read model 不提供 live command、交易按钮、adapter / runtime / SQLite / DuckDB schema 暴露、真实订单生命周期或真实交易授权。

文件范围：

- Updated：
  - `Sources/Core/LiveTradingBoundary.swift`
  - `Tests/CoreTests/CoreTests.swift`
  - `docs/contracts/live-trading-boundary-contract.md`
  - `docs/domain/context.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未实现 live command。
- 未新增交易按钮。
- 未读取 API key。
- 未新增 secret storage。
- 未实现 signed endpoint、account endpoint 或 listenKey。
- 未实例化 broker adapter。
- 未暴露 Runtime object、adapter surface、SQLite schema 或 DuckDB schema。
- 未实现 real order lifecycle、real order state machine、submit / cancel / replace、execution report、broker fill、reconciliation、OMS、真实账户状态或 broker position sync。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP65` | pass | 3 tests, 0 failures；覆盖 `LiveReadiness` deterministic snapshot、`LiveBlockedEvidence` per-gate evidence、Codable round trip、blocked capability drift rejection、command / schema / adapter / runtime / Live bypass rejection。 |
| `bash checks/automation-readiness.sh` | pass | MTP-65 contract、matrix、validation-plan、domain terms、Core type anchors 和 deterministic test anchors 通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 134 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`；最终输出 `MTPRO checks passed.`。 |

## MTP-66 Dashboard / Report / Event Timeline Live blocked evidence

日期：2026-05-21

执行者：Codex

目的：

- 将 Gate 4 `LiveReadiness` / `LiveBlockedEvidence` 接入 Gate 5 Dashboard / Report / Event Timeline read-model-only 展示面。
- 展示 API key、signed endpoint、account endpoint、listenKey、broker adapter 和 real order lifecycle 六个 Live gates 仍为 blocked。
- 证明 Dashboard / Report / Event Timeline 不提供 live command、交易按钮、adapter / runtime / SQLite / DuckDB schema 暴露、真实订单生命周期或真实交易授权。

文件范围：

- Added：
  - `Sources/App/LiveTradingBlockedEvidence.swift`
- Updated：
  - `Sources/App/App.swift`
  - `Sources/App/PaperWorkflowEvidenceExplorer.swift`
  - `Sources/App/DashboardShell.swift`
  - `Tests/AppTests/AppTests.swift`
  - `docs/contracts/live-trading-boundary-contract.md`
  - `docs/contracts/frontend-view-model-contract.md`
  - `docs/product/product-surface-map.md`
  - `docs/domain/context.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未实现 live monitoring console。
- 未实现 live execution control。
- 未实现 live risk control。
- 未实现 live audit / incident replay / stop controls。
- 未新增 live command、order-level command、risk control command 或 position management command。
- 未新增交易按钮、表单或真实订单入口。
- 未读取 API key、secret 或真实账户数据。
- 未实现 signed endpoint、account endpoint 或 listenKey。
- 未实例化 broker adapter。
- 未暴露 Runtime object、adapter surface、SQLite schema 或 DuckDB schema。
- 未实现 real order lifecycle、real order state machine、submit / cancel / replace、execution report、broker fill、reconciliation、OMS、真实账户状态或 broker position sync。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 17 tests, 0 failures；覆盖 `LiveTradingBlockedEvidenceViewModel` deterministic Codable snapshot、Report / Dashboard / Event Timeline blocked evidence、read-model-only boundary、no command / no button / no adapter / no runtime / no schema assertions。 |
| `bash checks/automation-readiness.sh` | pass | MTP-66 contract、matrix、validation-plan、frontend contract、product surface、domain term、App source anchors、Dashboard smoke anchor 和 deterministic test anchors 通过。 |
| `DASHBOARD_SMOKE=1 swift run Dashboard` | pass | 输出 `Dashboard smoke: sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 135 个 XCTest 全部通过；最终输出 `MTPRO checks passed.`。 |

## MTP-67 validation matrix、automation readiness 和 stage audit input material 收口

日期：2026-05-21

执行者：Codex

目的：

- 收口 `MTPRO Live Trading Boundary Definition v1` 的 validation matrix、automation readiness anchor、known boundaries、Dashboard smoke evidence 和 Stage Code Audit input material。
- 汇总 `MTP-61` 至 `MTP-66` 的 PR evidence、merge commit 和 GitHub required check，为 Parent Codex 最终 Stage Code Audit Report 提供输入。
- 明确 MTP-67 不输出最终 Stage Code Audit Report，不创建或推进下一 Project / Issue，不启动下一阶段 `symphony-issue`，不实现任何 Live capability。

文件范围：

- Added：
  - `docs/audit/inputs/mtpro-live-trading-boundary-definition-v1-stage-audit-input.md`
- Updated：
  - `docs/contracts/live-trading-boundary-contract.md`
  - `docs/validation/trading-validation-matrix.md`
  - `docs/validation/validation-plan.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

边界确认：

- 未修改 production code。
- 未输出最终 Stage Code Audit Report。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未启动下一阶段 `symphony-issue`。
- 未实现 API key、secret storage、signed endpoint、account endpoint、listenKey、broker adapter、`LiveExecutionAdapter`、真实订单、OMS、live command 或交易按钮。
- 未暴露 adapter request、Runtime object、SQLite / DuckDB schema、SQL、ORM、真实账户或 broker state。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | MTP-67 stage audit input、Live boundary contract、latest summary、validation plan、matrix、Dashboard smoke evidence 和关键锚点均可机械定位；输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6`；135 个 XCTest 通过；最终输出 `MTPRO checks passed.`。 |

## MTPRO Live Trading Boundary Definition v1 Stage Code Audit Report

日期：2026-05-21

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 将 `MTPRO Live Trading Boundary Definition v1` 的 canonical Stage Code Audit Report 落仓。
- 固化 `MTP-61`、`MTP-62`、`MTP-63`、`MTP-64`、`MTP-65`、`MTP-66`、`MTP-67` 的 issue / PR evidence、merge commit、required check、validation、Boundary Audit、Known CI Boundary、Root Docs Delta pending 和 Next Human Project Planning handoff。
- 记录 Linear Project closure：status `Completed`，type `completed`，`completedAt=2026-05-20T18:40:57.214Z`。

文件范围：

- Added：
  - `docs/audit/mtpro-live-trading-boundary-definition-v1-stage-code-audit.md`
- Updated：
  - `checks/automation-readiness.sh`
  - `docs/validation/latest-verification-summary.md`
  - `verification.md`

证据：

- `MTP-61` 至 `MTP-67` 全部 Linear `Done`。
- PR #132 已 merge。
- Merge commit：`ad1e64c3d52b0e037cd72de59edf520ab403d81d`。
- GitHub required check：`checks` pass，run `https://github.com/atxinbao/MTPRO/actions/runs/26182443581/job/77028886608`。
- Final validation：`bash checks/run.sh` passed。
- XCTest：135 tests, 0 failures。
- Dashboard smoke：`sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6`。
- Post-Issue Ledger：`git_pull_ff_only` failed because `/Users/mac/Documents/MTPRO` had unrelated local Workbench 中文优先设计 changes; `graphify_update` skipped to avoid stale graph.

边界确认：

- 本轮只落仓 Stage Code Audit Report，不创建 Linear Project / Issue。
- 不推进 Todo。
- 不启动 Symphony。
- 不运行 Graphify update。
- 不写业务代码。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
- Root Docs Refresh Gate 仍需在本 Stage Code Audit Report 合并后单独执行。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Stage Code Audit Report 落仓变更无 whitespace error。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 135 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6`；最终输出 `MTPRO checks passed.`。 |

## MTPRO Live Monitoring Console v1 Planning Record

日期：2026-05-21

执行者：Codex（`@001 / PLN`）

目的：

- 将 Human 已确认的 `MTPRO Live Monitoring Console v1` Project-level planning record 落仓。
- 承接 Final Product Goal Slice #6：实盘监控台。
- 仓库只保存 Project 级计划摘要和格式门槛，不复制维护完整 Linear issue body。
- 明确本阶段保持 read-model-only，订单流 / 订单事件流仅表示 blocked / simulated / future evidence，不表示真实订单状态机。

文件范围：

- `docs/planning/projects/mtpro-live-monitoring-console-v1-plan.md`
- `docs/planning/linear-draft-plan.md`
- `docs/validation/latest-verification-summary.md`
- `checks/automation-readiness.sh`
- `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未推进 Todo。
- 未启动 `@002 / PAR`。
- 未启动 Symphony / symphony-issue。
- 未运行 Graphify update。
- 未写业务代码。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Live Monitoring Console planning record docs / checks 变更无 whitespace error。 |
| `bash checks/run.sh` | pass | 首轮 `swift test` 出现一次 `xctest` signal 11；执行 `swift package clean` 后重跑通过，automation readiness、Dashboard build / smoke 和 135 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6`；最终输出 `MTPRO checks passed.`。 |

## MTPRO Live Trading Boundary Definition v1 Root Docs Refresh Gate Closure

日期：2026-05-21

执行者：Parent Codex Automation Supervision（`@002 / PAR`）

目的：

- 基于已落仓的 `docs/audit/mtpro-live-trading-boundary-definition-v1-stage-code-audit.md` 执行 Root Docs Refresh Gate closure。
- 只同步已发生事实：`MTPRO Live Trading Boundary Definition v1` 已完成，Live trading foundation boundary 已从 Pending / gated 进入 Complete。
- 重新计算 Current Foundation Progress、Final Product Goal Progress 和 Project Closure Count。
- 保持下一阶段方向、目标、架构路线和优先级交给 Human + `@001 / PLN`。

文件范围：

- Updated：
  - `GOAL.md`
  - `docs/architecture.md`
  - `docs/roadmap.md`
  - `docs/audit/mtpro-live-trading-boundary-definition-v1-stage-code-audit.md`
  - `docs/validation/latest-verification-summary.md`
  - `checks/automation-readiness.sh`
  - `verification.md`

Root docs 判断：

| Root doc | 结果 | 原因 |
| --- | --- | --- |
| `GOAL.md` | updated | Final Product Goal Progress 从 `4 / 9 (44%)` 更新为 `5 / 9 (56%)`，并明确 Live trading foundation 只完成 boundary / blocked evidence / read-only surface。 |
| `docs/environment.md` | no update needed | 本 Project 未新增 required validation、secret、broker credential、signed endpoint、Graphify 或外部写能力；统一验证入口仍是 `bash checks/run.sh`。 |
| `docs/architecture.md` | updated | 同步 Core / Adapters / App / Dashboard 的 Live boundary evidence flow 和 public read-only / future execution adapter isolation。 |
| `docs/roadmap.md` | updated | 新增 completed Project，Project Closure Count 更新为 `8 / 8 (100%)`，Final Product Goal Progress 更新为 `5 / 9 (56%)`。 |

边界确认：

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 Symphony。
- 不运行 Graphify update。
- 不写业务代码。
- 不决定下一阶段方向。
- 不修改 `BLUEPRINT.md`。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | Root Docs Refresh Gate closure 变更无 whitespace error。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 135 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6`；最终输出 `MTPRO checks passed.`。 |

## MTPRO-native PR Evidence Fields

日期：2026-05-21

执行者：Codex（`@000 / AIE`）

目的：

- 将 `mattpocock/skills` 中已经吸收的方法论继续收敛为 MTPRO-native PR evidence fields。
- 不安装、不调用、不复制外部 skill runtime，避免新增执行入口和 AEP / Linear / Parent Codex 流程冲突。
- 通过 PR 模板和 automation readiness 机械化以下证据字段：
  - `Feedback Loop Evidence`
  - `Tracer Bullet / Fixture Evidence`
  - `Diagnose Evidence`
  - `Architecture Deepening Candidate`

文件范围：

- `.github/pull_request_template.md`
- `docs/automation/agent-engineering-practices.md`
- `checks/automation-readiness.sh`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

边界确认：

- docs / checks only。
- 未创建 Linear Project / Issue。
- 未修改 Linear status。
- 未推进 Todo。
- 未启动 `@002 / PAR`。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未写业务代码。
- 未安装外部 `mattpocock/skills` runtime。
- 未提交 `.codex/*`。
- 未提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | MTPRO-native PR evidence fields docs / checks 变更无 whitespace error。 |
| `bash checks/automation-readiness.sh` | pass | PR 模板和工程实践文档中的 `Feedback Loop Evidence`、`Tracer Bullet / Fixture Evidence`、`Diagnose Evidence`、`Architecture Deepening Candidate` 锚点通过。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 135 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6`；最终输出 `MTPRO checks passed.`。 |

## MTP-68 Live Monitoring Console IA / Read-model-only Boundary

日期：2026-05-21

执行者：Codex

目的：

- 定义 Live monitoring console information architecture、术语、状态分类和 read-model-only 边界。
- 为后续 runtime health、connection、market stream、order stream、latency、error、degraded state 和 operations evidence 提供统一合同。
- 只定义 validation anchor 名称 / 入口，不在本 issue 实际修改 `checks/automation-readiness.sh`。

文件范围：

- `docs/contracts/live-monitoring-console-contract.md`
- `docs/contracts/frontend-view-model-contract.md`
- `docs/product/product-surface-map.md`
- `docs/domain/context.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增 `MTP-68-LIVE-MONITORING-CONSOLE-IA`，覆盖 Overview、Runtime Health、Connection、Market Stream、Order Stream Evidence、Latency、Error / Degraded State 和 Operations Evidence。
- 新增 `MTP-68-LIVE-MONITORING-TERMS` 和 `MTP-68-LIVE-MONITORING-STATUS-TAXONOMY`，定义 live runtime health、connection status、market stream status、order stream evidence、latency evidence、error evidence、degraded state、operations evidence，以及 blocked / simulated / futureOnly / unknown / nominal / stale / degraded / error / recovered 状态分类。
- 新增 `MTP-68-LIVE-MONITORING-READ-MODEL-ONLY`，明确 Dashboard / Report / Event Timeline 只能展示 Read Model / ViewModel。
- 新增 `MTP-68-ORDER-STREAM-EVIDENCE-NOT-REAL-ORDER-STATE`，明确订单流 / 订单事件流只表示 blocked / simulated / future evidence，不表示真实订单状态机。
- 新增 `TVM-LIVE-MONITORING-CONSOLE` 候选矩阵入口和 `MTP-68-NO-AUTOMATION-READINESS-CLOSEOUT`，确认 automation readiness 实际收口保留给 MTP-74。

边界确认：

- 不实现 live runtime。
- 不接 signed endpoint、account endpoint 或 listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine、execution report、broker fill、order reconciliation、OMS、真实账户状态或 broker position sync。
- 不提供 live command、交易按钮、表单、order-level command、risk control command、position management command、submit / cancel / replace 或自动恢复动作。
- 不修改 `checks/automation-readiness.sh`。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 新增合同文件和 docs 变更无 whitespace error。 |
| docs anchor check | pass | `MTP-68-LIVE-MONITORING-CONSOLE-IA`、`MTP-68-LIVE-MONITORING-READ-MODEL-ONLY`、`MTP-68-ORDER-STREAM-EVIDENCE-NOT-REAL-ORDER-STATE`、`MTP-68-NO-AUTOMATION-READINESS-CLOSEOUT` 和 `TVM-LIVE-MONITORING-CONSOLE` 均可定位。 |
| automation readiness boundary check | pass | `checks/automation-readiness.sh` 中没有 MTP-68 / `TVM-LIVE-MONITORING-CONSOLE` 收口项。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 135 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6`；最终输出 `MTPRO checks passed.`。 |

## MTP-69 Live Runtime Health / Connection Status Read Model

日期：2026-05-21

执行者：Codex

目的：

- 新增 live runtime health / connection status 最小 read model。
- 用只读 evidence 表达 future live runtime health 和 connection 状态分类。
- 保持无真实 runtime、无真实连接、无 secret、无 account payload、无 broker、无 command surface。

文件范围：

- `Sources/Core/CoreError.swift`
- `Sources/Core/LiveMonitoringConsole.swift`
- `Tests/CoreTests/CoreTests.swift`
- `docs/contracts/live-monitoring-console-contract.md`
- `docs/validation/validation-plan.md`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- 新增 `LiveMonitoringStatus`，覆盖 `healthy`、`blocked`、`disconnected`、`degraded` 和 `unavailable`。
- 新增 `LiveConnectionKind`，覆盖 public market data、future private user data 和 future broker session 三类 connection evidence。
- 新增 `LiveConnectionStatusReadModel`，fixture 状态为 public market data `disconnected`、future private user data `blocked`、future broker session `unavailable`。
- 新增 `LiveRuntimeHealthReadModel`，fixture 状态为 `blocked`，并聚合三类 connection status evidence。
- 新增 constructor / Codable 解码校验，拒绝 command surface、runtime polling、真实网络连接、WebSocket、API key、secret、signed endpoint、account endpoint、listenKey、account payload、broker adapter、adapter surface、Runtime object、SQLite / DuckDB schema、Live trading authorization、trading execution authorization 和 network-dependent validation。

边界确认：

- 不实现 live runtime。
- 不建立真实网络连接。
- 不接 signed endpoint、account endpoint 或 listenKey。
- 不读取 API key、secret 或 account payload。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine。
- 不提供 reconnect、start / stop live command、交易按钮或真实交易授权。
- 不修改 `checks/automation-readiness.sh`；MTP-74 才做 MTP-68 至 MTP-73 的统一机械收口。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

验证：

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP69` | pass | 3 个 focused XCTest 通过；覆盖 deterministic fixture、Codable round trip、connection source anchors、no command、no network、no secret、no account payload、no broker、no schema。 |
| `bash checks/run.sh` | pass | automation readiness、Dashboard build / smoke 和 138 个 XCTest 全部通过；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=6; liveBlockedGates=6`；最终输出 `MTPRO checks passed.`。 |
