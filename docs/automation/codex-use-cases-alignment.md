# Codex Use Cases Alignment

日期：2026-05-18

执行者：Codex

## 定位

本文档把 OpenAI Codex 官方 use cases 映射到 MTPRO 当前工程流程。

它不授权执行，不替代 Linear issue，不替代 `AGENTS.md`，不创建新流程。

## 资料来源

- https://developers.openai.com/codex/use-cases
- https://developers.openai.com/codex/use-cases/codebase-onboarding
- https://developers.openai.com/codex/use-cases/github-code-reviews
- https://developers.openai.com/codex/use-cases/verified-operations-workflows
- https://developers.openai.com/codex/use-cases/native-macos-apps
- https://developers.openai.com/codex/use-cases/ai-app-evals
- https://developers.openai.com/codex/use-cases/update-documentation

## 1. Codebase Onboarding / 项目理解

MTPRO 使用 Codex 时，不能只从当前 Swift 文件开始改代码。

每个阶段开始前，父 Codex 必须先形成阶段级项目理解：

- 当前 Linear Project 和唯一 active issue。
- `GOAL.md`、`docs/architecture.md`、`docs/roadmap.md`。
- `docs/contracts/` 中与当前 issue 相关的 contract。
- `docs/architecture/module-boundary.md`。
- Linear queue context、latest verification summary 和相关 Stage Code Audit evidence。
- 当前阶段的 source / test / validation 入口。

输出形式：

- 当前 issue PR body 的来源、范围、非目标和验证。
- 必要时追加阶段代码审计或 flow map，但不为每个小 PR 生成长文。

## 2. Codex Code Review / 代码审查

MTPRO 必须保留 Pre-PR Codex Code Review。

代码审查重点：

- diff 是否只覆盖当前 Linear issue scope。
- 是否突破 Live trading 禁区。
- 是否调用 Binance signed / account endpoint。
- 是否绕过 contract-first 文档。
- 是否缺少测试或验证证据。
- 是否缺少必要中文代码注释。
- `.codex/*` 和无关 generated files 是否被排除。

GitHub PR 创建后，可以继续使用 GitHub 上的 Codex review 作为补充审查，但它不替代本地验证和 Parent Codex 监督。

## 3. Verified Operations / 可审计操作

MTPRO 中所有跨系统操作必须按 verified operations 方式记录。

适用操作：

- Human 确认 Project / Issue plan 并写入 Linear 后，父 Codex 将 eligible `Backlog` 自动推进为唯一 `Todo`。
- Codex Execution Agent 执行唯一 `Todo` issue。
- host-side fallback。
- GitHub auto-merge handoff。
- Post-Issue Ledger / 施工后记账。

权威记录格式见 `docs/automation/verified-operations.md`。

## 4. Native macOS App / macOS 构建运行闭环

MTPRO 是 macOS 交易研究工作台，后续不能长期只依赖 `swift test`。

进入 App / UI 阶段前，必须补齐 macOS build / run / telemetry 验证：

- SwiftPM build。
- macOS App shell 或可运行入口。
- 最小 Logger / telemetry 事件。
- UI smoke check 或运行日志证据。

在 UI 阶段前，`swift test` 和 `bash checks/run.sh` 仍是当前 baseline validation。

## 5. Evals / 交易行为验证矩阵

当前不引入独立 eval 框架。

当前阶段使用 XCTest + fixtures 表达可重复验证：

- Binance fixture decoding。
- Backtest / Paper parity。
- Strategy signal determinism。
- Persistence projection rebuild。
- Dashboard ViewModel snapshot。

只有满足以下任一条件时，才考虑引入独立 eval 框架：

- XCTest + fixture 无法表达跨策略、跨数据窗口或报告质量评分。
- 连续两个 Linear issue 出现人工判断型 validation failure。
- Backtest / Paper parity 需要批量数据集和指标阈值矩阵。
- 需要比较多个策略输出、报告解释或 Agent 生成分析质量。
- 验证结果需要独立 dashboard、历史趋势或多运行对比。

引入 eval 框架前必须先有明确 Linear issue，并更新 `docs/validation/eval-strategy.md`。

## 6. Keep Docs Up-to-date / 文档同步

每个 PR 必须只更新与当前 issue 相关的文档。

文档同步规则：

- API / contract 变化必须同步 `docs/contracts/`。
- 模块边界变化必须同步 `docs/architecture.md` 或 `docs/architecture/module-boundary.md`。
- 验证变化必须同步 `docs/validation/validation-plan.md`。
- 自动化流程变化必须同步 `docs/automation/`。
- `verification.md` 只追加验证流水账，不复刻 PR body。

## 代码中文注释规则

新增或修改 production code 时，必须添加详细中文注释。

注释必须说明：

- 类型或函数的业务目的。
- 输入、输出和关键约束。
- 领域不变量。
- 外部系统、持久化、Linear、GitHub 或交易边界。
- 为什么该实现不能执行 Live trading 或 signed endpoint。

禁止：

- 用英文替代中文说明。
- 写空泛注释，例如“处理数据”“执行逻辑”。
- 为了注释而逐行复述代码。
