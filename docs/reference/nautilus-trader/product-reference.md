# NautilusTrader Product Reference Study

日期：2026-05-19

执行者：@003 / PRD Product Reference Lead

## 角色边界

本文档只保存 MTPRO NautilusTrader Reference Study 的 Product Reference 结论。不创建 Linear Project / Issue，不推进 `Todo`，不启动 Symphony，不写业务代码，不直接修改 `GOAL.md` 或 `docs/roadmap.md`。

MTPRO 不包装 NautilusTrader，不引入 NautilusTrader 作为运行依赖，不复制 NautilusTrader 代码。NautilusTrader 只作为产品能力、工作流组织和用户路径参考。

## 产品参考结论

| 主题 | NautilusTrader 表达 | MTPRO 采用方式 |
| --- | --- | --- |
| 统一交易语义 | Trading Node、Data Engine、Risk Engine、Execution Engine、Portfolio、Message Bus 贯穿生命周期 | 学习“统一语义 + 可重放 workflow”，不复制整套平台 |
| Research -> Backtest | Python / Rust API、Backtest Engine、Backtest Node、catalog、reports / visualization | 转成 macOS Workbench 的 Research、Backtest、Report 证据链 |
| Backtest -> Live 一致性 | 同一策略代码可用于 backtest 和 live trading | 只作为长期产品参考；MTPRO 当前必须截断在 paper / guarded runtime evidence |
| 多 venue / adapter | 支持 crypto、FX、equities、data provider 和 execution venue adapter | 只学习 adapter 边界；当前 release 固定 Binance-only |
| 数据能力 | order book、quote tick、trade tick、bar、instrument metadata、catalog、Parquet | 学习数据形态分层、catalog、replay 和 freshness evidence |
| 报告和可视化 | account、fills、positions、PnL、stats、tearsheet | Report 是 Research -> Backtest -> Paper 的证据中心，不是交易授权入口 |

## 用户路径摘要

```text
阅读文档
-> 安装 / 准备数据 catalog
-> 配置 venue / data / strategy
-> 运行 backtest
-> 查看 reports / visualization
-> 选择是否进入 live trading
```

MTPRO 的对应路径应更产品化：

```text
Research Context
-> Data Coverage / Freshness
-> Strategy Signal Preview
-> Backtest Run Evidence
-> Report Artifact
-> Paper / guarded runtime evidence
-> blocked production boundary
```

## 对 MTPRO 产品面的压缩建议

| 产品面 | 应学习 | 不应学习 |
| --- | --- | --- |
| Research | symbol、timeframe、strategy、data range、signal health、data coverage | 完整策略 IDE 或直接交易入口 |
| Backtest | run lifecycle、input snapshot、cost assumptions、event range、deterministic replay evidence | NautilusTrader 式复杂 config tree |
| Paper | paper session、risk blocker、simulated fill、portfolio exposure、event log | 真实 broker、signed endpoint、LiveExecutionAdapter |
| Report | artifact、run id、event range、parity evidence、risk / portfolio evidence | 只显示汇总数字、隐藏 causal chain |
| Dashboard | 当前状态、阻塞原因、evidence navigation、read-model-only | 直接读取 adapter、database schema 或 runtime object |
| Live | 展示 blocked boundary 和 future gates | 默认引导连接账户、读取 secret 或发送真实订单 |

## 候选 Delta Proposal

| Proposal | 目标文档 | 建议 |
| --- | --- | --- |
| G1 | `GOAL.md` | 明确目标用户是专业交易者 / 研究者，不是通用散户终端 |
| G2 | `GOAL.md` | 强化 Report 是核心结果：每次 research / backtest / paper run 都必须留下可复核 evidence |
| G3 | `GOAL.md` | 明确 MTPRO 不是 NautilusTrader 替代品，只借鉴 workflow 和架构语义 |
| R1 | `docs/roadmap.md` | 增加 Product Reference Synthesis Gate 作为规划输入，不授权执行 |
| R2 | `docs/roadmap.md` | 把 Report 作为 Research -> Backtest -> Paper 的中心节点 |
| R3 | `docs/roadmap.md` | 明确未来 Live 仍非默认方向，必须保持 gated / blocked |
| P1 | `docs/product/*` | 新增用户路径页：Overview、Research、Backtest、Paper、Report、Portfolio、Risk、Events |
| P2 | `docs/product/*` | 定义 report artifact taxonomy：backtest、paper session、risk blocker、portfolio exposure、replay / event log、stage audit |
| P3 | `docs/product/*` | 补充状态语言：ready、running、degraded、failed、blocked、paper-only、read-model-only |

## 来源 URL

- GitHub source: https://github.com/nautechsystems/nautilus_trader
- Official docs: https://nautilustrader.io/docs/latest/
- Concepts: https://nautilustrader.io/docs/latest/concepts/
- Architecture: https://nautilustrader.io/docs/latest/concepts/architecture/
- Backtesting: https://nautilustrader.io/docs/latest/concepts/backtesting/
- Live trading: https://nautilustrader.io/docs/latest/concepts/live/
- Reports: https://nautilustrader.io/docs/latest/concepts/reports/
- Visualization: https://nautilustrader.io/docs/latest/concepts/visualization/
- Data: https://nautilustrader.io/docs/latest/concepts/data/
- Adapters: https://nautilustrader.io/docs/latest/concepts/adapters/
- Binance integration: https://nautilustrader.io/docs/latest/integrations/binance/
- Rust API: https://nautechsystems.github.io/nautilus_docs/rust-api-latest/
- Python API: https://nautechsystems.github.io/nautilus_docs/python-api-latest/
