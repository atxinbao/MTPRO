# GOAL.md

## 项目目标

MTPRO 的目标是构建一个新的 macOS 原生交易研究工作台，用于替代和重构 `macos-trader` 中已经验证过的产品语义。

目标不是包装 NautilusTrader，也不是复制 `macos-trader` 整仓代码。

## 核心结果

MTPRO 应提供一个从策略研究到 Paper 执行一致的本地工作台：

- 读取 Binance public market data。
- 使用统一 Core 驱动 backtest 和 paper。
- 让策略、风险、组合、事件和验证证据可观察。
- 保留未来 Live 执行边界，但第一版完全禁止真实 broker action。

## 成功标准

第一阶段成功标准：

- 项目目标、架构、产品面、契约和验证计划清楚。
- SwiftPM skeleton 可以构建和测试。
- Linear Draft Plan 可以从 ROADMAP 转换，但当前不写入 Linear。
- Human Review 完成前不进入业务实现。

## 非目标

- 不实现真实 Live trading。
- 不接 signed endpoint。
- 不提交订单。
- 不迁移 `macos-trader` 整仓代码。
- 不引入 NautilusTrader 作为运行依赖。
- 不在 Project Definition 阶段实现业务功能。
