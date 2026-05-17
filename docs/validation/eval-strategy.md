# Eval Strategy / 验证策略

日期：2026-05-18

执行者：Codex

## 定位

本文档定义 MTPRO 当前是否引入独立 eval 框架的判断标准。

当前结论：

```text
当前不引入独立 eval 框架。
```

MTPRO 当前使用 XCTest + fixtures + `bash checks/run.sh` 作为可重复验证入口。

## 当前验证方式

当前阶段继续使用：

- XCTest。
- JSON / Swift fixtures。
- `git diff --check`。
- `bash checks/automation-readiness.sh`。
- `bash checks/run.sh`。

这些足以覆盖：

- Binance public market data decoding。
- Core event / command / state contract。
- Backtest / Paper parity 的早期 contract。
- Persistence projection rebuild。
- Dashboard ViewModel snapshot。
- 自动化就绪边界。

## 什么时候可以引入独立 eval 框架

只有满足以下任一条件，才允许提出引入 eval 框架的 Linear issue：

1. XCTest + fixtures 无法表达跨策略、跨数据窗口或跨报告的评价。
2. Backtest / Paper parity 需要批量数据集、阈值矩阵和趋势对比。
3. 策略研究需要比较多个输出解释、报告质量或异常归因。
4. 连续两个 issue 出现人工判断型 validation failure。
5. 需要长期保存 eval 历史、趋势、失败样本和回归定位。
6. 需要评估 Agent 生成报告、自然语言解释或交易假设总结的质量。

## 引入前置条件

引入 eval 框架前必须满足：

- 已有明确 Linear issue。
- 已定义 eval target。
- 已定义输入数据集。
- 已定义 pass / fail 标准。
- 已定义输出 artifact。
- 已定义如何进入 `bash checks/run.sh` 或独立 CI / local gate。
- 已确认不会接触真实 broker action。

## 当前禁止

- 不因为偏好引入 eval 框架。
- 不为了替代 XCTest 引入 eval 框架。
- 不把 eval 框架作为业务实现前置依赖。
- 不把 eval 结果当作 Linear 执行授权。

