# GOAL.md

## 项目目标

MTPRO 的目标是构建一个新的 macOS 原生交易研究工作台，用于替代和重构 `macos-trader` 中已经验证过的产品语义。

目标不是包装 NautilusTrader，也不是复制 `macos-trader` 整仓代码。

## 核心结果

MTPRO 应提供一个从策略研究到 Paper 执行一致的本地工作台：

- 读取 Binance public market data。
- 使用统一 Core 驱动 backtest 和 paper。
- 让策略、风险、组合、事件和验证证据可观察。
- 让 paper-only execution workflow、session-level local controls 和 Paper workflow evidence 在本地可回放、可验证、可展示。
- 保留未来 Live 执行边界，但第一版完全禁止真实 broker action。

## 成功标准

当前阶段成功标准：

- 项目目标、架构、产品面、契约和验证计划保持清楚，并能从 Linear / PR / Stage Code Audit evidence 追溯。
- SwiftPM baseline、Dashboard smoke 和统一验证入口可以构建和测试。
- Linear Project / Issue 已按 Human Project Planning 写入并成为执行事实源。
- 正式开发只从 Linear 中唯一 configured executable issue 进入。
- 每个 PR 通过 GitHub PR Automation 和本地验证。
- Project closure 后由 Parent Codex 输出 canonical Stage Code Audit Report，并完成 Root Docs Refresh Gate closure。

## 当前完成事实

截至 2026-05-20，当前已批准并 closure 的建设阶段已完成：

- Research / Backtest / Report / Paper readiness。
- Paper-only execution evidence。
- Paper workflow 可观察性和本地 session-level control shell。
- Live trading、signed endpoint、account endpoint、broker action 和真实订单能力仍保持禁止边界。

当前 Goal / Roadmap Target Progress 为 4 / 5（80%）。该进度按目标切片计算，不按 Project 数量直接计算，也不统计 `docs/design/mtpro-complete-blueprint.md` 中的 Future Construction Zones。

## 非目标

- 不实现真实 Live trading。
- 不接 signed endpoint。
- 不提交订单。
- 不迁移 `macos-trader` 整仓代码。
- 不引入 NautilusTrader 作为运行依赖。
- 不在 Project Definition 阶段实现业务功能。
