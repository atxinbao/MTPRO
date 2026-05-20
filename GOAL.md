# GOAL.md

本文档是 MTPRO 的 Project Charter，不是完整蓝图，不是架构地图，不是施工计划。

它只回答四个问题：

- 为什么建。
- 服务谁。
- 永久硬边界是什么。
- 怎样判断当前阶段仍然在正确方向上。

完整产品 / 系统 / 设计蓝图见 canonical `BLUEPRINT.md`；当前施工阶段、目标切片和进度条见 `ROADMAP.md`。

## 项目使命

MTPRO 的目标是构建一个新的 macOS 原生交易研究工作台，用于替代和重构 `macos-trader` 中已经验证过的产品语义。

MTPRO 不是 NautilusTrader 的 Swift 包装，也不是 `macos-trader` 的整仓迁移。它要把参考项目和既有产品经验收敛成自己的 SwiftPM-first、macOS-native、evidence-first 工作台。

## 服务对象

MTPRO 首先服务本地交易研究和 Paper readiness 用户：

- 需要用 Binance public market data 做研究、回测和报告的人。
- 需要确认 Backtest / Paper / Risk / Portfolio evidence 是否一致的人。
- 需要在不触碰真实交易的前提下观察 paper workflow 的人。
- 未来可能评估 Live trading readiness，但当前不能直接进入真实交易的人。

## 核心承诺

MTPRO 必须长期保持这些结果：

- Research -> Backtest -> Report -> Paper 的本地工作流可追溯、可回放、可验证。
- Core 领域语义、event log、projection、read model 和 ViewModel 边界清楚。
- 交易语义以 deterministic evidence 表达，而不是靠 UI 状态或人工说明兜底。
- Paper 能力全部保持 paper-only，不能被解释为真实订单、真实成交或 broker action。
- Future Live 可以在蓝图中描述，但必须经过独立 Human decision、独立 Project Definition 和新的 safety / risk / operations gates。

## 当前阶段成功标准

当前阶段只判断 paper-only foundation 是否继续健康：

- `BLUEPRINT.md` 保持最终产品 / 系统 / 设计蓝图清楚。
- `ARCHITECTURE.md` 保持当前架构地图和设计基线清楚。
- `ROADMAP.md` 保持已批准阶段、目标切片和进度条清楚。
- Linear / PR / Stage Code Audit evidence 能追溯每个已完成建设阶段。
- SwiftPM baseline、Dashboard smoke 和统一验证入口 `bash checks/run.sh` 持续可运行。
- 正式开发只从 Linear 中唯一 configured executable issue 进入。
- Project closure 后必须完成 Stage Code Audit Report 和 Root Docs Refresh Gate closure。

## 当前目标进度

截至 2026-05-20，当前已批准并 closure 的建设阶段已完成：

- Research / Backtest / Report / Paper readiness。
- Paper-only execution evidence。
- Paper workflow 可观察性和本地 session-level control shell。
- 更长周期 market data replay / operations 本地 evidence baseline。
- Live trading、signed endpoint、account endpoint、broker action 和真实订单能力仍保持禁止边界。

当前 Goal / Roadmap Target Progress 为 5 / 5（100%）。该进度只覆盖当前已批准、已执行并完成 closure 的 paper-only foundation 目标切片，不按 Project 数量直接计算，也不统计 `BLUEPRINT.md` 中的 Future Construction Zones。

## 永久硬边界

- 当前阶段不实现真实 Live trading。
- 当前阶段不接 signed endpoint、account endpoint 或 listenKey。
- 当前阶段不连接 broker。
- 当前阶段不提交、撤销、替换真实订单。
- 当前阶段不实现真实账户余额、broker position sync 或 OMS。
- 不迁移 `macos-trader` 整仓代码。
- 不引入 NautilusTrader 作为运行依赖。
- 不把 `BLUEPRINT.md` 中的 Future Construction Zones 自动转成当前 execution scope。

## 非授权边界

- `GOAL.md` 不创建 Linear Project / Issue。
- `GOAL.md` 不修改 Linear status。
- `GOAL.md` 不推进 `Todo`。
- `GOAL.md` 不启动 Symphony。
- `GOAL.md` 不授权 future capability 进入当前执行 scope。
