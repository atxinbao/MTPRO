# GOAL.md

本文档是 MTPRO 的 Project Charter，不是完整蓝图，不是架构地图，不是施工计划。

它只回答四个问题：

- 为什么建。
- 服务谁。
- 永久硬边界是什么。
- 怎样判断当前阶段仍然在正确方向上。

完整产品 / 系统 / 设计蓝图见 canonical `BLUEPRINT.md`；当前施工阶段、目标切片和进度条见 `ROADMAP.md`。

## 项目使命

MTPRO 的目标是构建一个 local-first 的 macOS 原生专业交易工作台。

它先以 Research -> Backtest -> Report -> Paper 建立可追溯、可回放、可验证的交易证据链，再逐步演进为支持 Live trading、实盘监控、实盘执行控制、实盘风险控制和实盘审计 / 事故回放 / 停机控制的专业版本产品。

MTPRO 不是 NautilusTrader 的 Swift 包装，也不是 `macos-trader` 的整仓迁移。它要把参考项目和既有产品经验收敛成自己的 SwiftPM-first、macOS-native、evidence-first、local-first 工作台。

## 服务对象

MTPRO 首先服务个人专业交易者 / 独立策略研究者：

- 需要在本机 Mac 上研究策略、回测策略、生成报告的人。
- 需要用 Binance public market data 做可追溯研究的人。
- 需要确认 Backtest / Paper / Risk / Portfolio evidence 是否一致的人。
- 需要在不触碰真实交易的前提下观察 paper workflow 的人。
- 未来需要把成熟 evidence chain 推进到 Live trading 专业版本产品的人。

## 核心承诺

MTPRO 必须长期保持这些结果：

- Local-first：核心研究、回测、Paper、报告和审计能力优先在本地工作台闭环完成。
- Evidence chain first：工作台导航以 Research -> Backtest -> Report -> Paper -> Events 的证据链为主，而不是以交易按钮为中心。
- 少量可解释策略优先：当前策略能力聚焦 EMA、order book imbalance 等可解释 signal evidence，不做策略市场或复杂黑盒策略平台。
- Binance public read-only market data 是当前行情边界；signed endpoint、account endpoint、listenKey 和 broker action 不能混入当前阶段。
- Core 领域语义、event log、projection、read model、ViewModel 和 Command Model 边界清楚。
- Paper 能力全部保持 paper-only，不能被解释为真实订单、真实成交或 broker action。
- Live trading 是最终产品目标的一部分，但只能在独立 Human decision、独立 Project Definition、signed endpoint / broker / risk / operations gates 之后进入当前执行范围。

## 当前阶段成功标准

当前阶段只判断 paper-only foundation 是否继续健康：

- `BLUEPRINT.md` 保持最终产品 / 系统 / 设计蓝图清楚。
- `ARCHITECTURE.md` 保持当前架构地图和设计基线清楚。
- `ROADMAP.md` 保持已批准阶段、目标切片和两层进度条清楚。
- Linear / PR / Stage Code Audit evidence 能追溯每个已完成建设阶段。
- SwiftPM baseline、Dashboard smoke 和统一验证入口 `bash checks/run.sh` 持续可运行。
- 正式开发只从 Linear 中唯一 configured executable issue 进入。
- Project closure 后必须完成 Stage Code Audit Report 和 Root Docs Refresh Gate closure。

## 当前目标进度

MTPRO 采用两层进度口径：

1. Current Foundation Progress：当前已批准 paper-only foundation 的完成度。
2. Final Product Goal Progress：最终专业交易工作台产品目标的完成度。

截至 2026-05-20，Current Foundation Progress 已完成，Final Product Goal Progress 仍未完成。

### Current Foundation Progress

Current Foundation Progress：4 / 4（100%）

Progress：`[##########] 100%`

当前 foundation 已完成四类结果：

1. Research / Backtest / Report / Paper readiness。
2. Paper-only execution evidence。
3. Paper workflow 可观察性和本地 session-level control shell。
4. 更长周期 market data replay / operations 本地 evidence baseline。

该进度只覆盖当前已批准、已执行并完成 closure 的 paper-only foundation。详细 Project、PR、Stage Audit 和目标切片状态见 `ROADMAP.md` 和 `docs/audit/`。

### Final Product Goal Progress

Final Product Goal Progress：4 / 9（44%）

Progress：`[####------] 44%`

已完成的最终产品目标：研究 / 回测 / 报告基础能力、Paper 模拟执行基础能力、工作台证据导航与本地控制壳、行情数据回放运营能力。

Pending / gated 的最终产品目标：实盘交易基础边界、实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制。

完整 9 项目标切片、状态和证据口径见 `ROADMAP.md`。`GOAL.md` 不复制维护详细进度表。

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
