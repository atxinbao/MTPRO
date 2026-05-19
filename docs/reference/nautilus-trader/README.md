# NautilusTrader Reference Study

日期：2026-05-19

执行者：@000 / AIE 汇总，基于 @003 / PRD、@004 / DSG、@005 / ARC 三个 Linear 外 reference 角色输出。

## 定位

本文档集是 MTPRO 的 NautilusTrader 参考研究记录。它只服务 Product / Design / Architecture 后续规划，不写 Linear，不创建 Project / Issue，不推进 `Todo`，不启动 Symphony，不写业务代码，不直接修改 root docs。

NautilusTrader 只作为参考项目：

- 学习其产品工作流、信息架构和系统结构。
- 不复制 NautilusTrader 代码。
- 不引入 NautilusTrader 作为运行依赖。
- 不把 NautilusTrader 的 Live trading 能力映射为 MTPRO 当前路线。

## 阅读顺序

| 文件 | 角色 | 用途 |
| --- | --- | --- |
| `product-reference.md` | `@003 / PRD` | 产品流程、用户路径、Research / Backtest / Paper / Report / Dashboard 能力参考 |
| `design-reference.md` | `@004 / DSG` | Workbench 信息架构、页面拆分、ViewModel / Read Model 映射和状态语言参考 |
| `architecture-reference.md` | `@005 / ARC` | Kernel / Engine / MessageBus / Cache / Adapter / Risk / Portfolio / Execution / Replay 架构映射 |
| `root-docs-delta-proposal.md` | `@000 / AIE` | 汇总候选 root docs delta，只作为 Human + `@001 / PLN` 的规划输入 |

## 共识结论

NautilusTrader 的核心参考价值不是 UI，也不是可直接复用的代码，而是：

- 统一交易语义。
- event-driven runtime。
- adapter 归一化。
- backtest / paper / live 的环境分层。
- risk / execution / portfolio 的因果链。
- report / visualization 作为研究和回测证据出口。

MTPRO 当前应该学习：

- Research -> Backtest -> Report -> Paper 的证据链组织方式。
- Data / Event Log / Replay / Projection / ViewModel 的分层边界。
- Strategy signal -> proposal -> risk -> paper execution decision -> simulated fill -> portfolio projection -> report 的可追溯链路。
- Workbench 以 evidence 和状态解释组织，而不是以交易按钮组织。

MTPRO 当前不应该学习：

- Live trading / signed endpoint / broker action。
- 多 venue / 多资产 / 全 OMS 的复杂度。
- Redis / external message broker / production event sourcing 平台。
- 直接复制 NautilusTrader Rust / Python 代码或 API shape。
- 把 Paper workflow 做成可切换 Live 的隐藏开关。

## 后续使用规则

- 本目录只提供 reference study，不授权执行。
- 候选 delta 必须先进入 Human + `@001 / PLN` 的下一阶段规划判断。
- 只有被 Human 确认并写入 Linear Project / Issue 后，才可能进入 `@002 / PAR` queue preflight 和 symphony-issue 执行链路。
- 如果后续 root docs 采纳某个 delta，应在对应 PR 中引用本目录文件和具体 proposal。

## 来源

- GitHub source: https://github.com/nautechsystems/nautilus_trader
- Official docs: https://nautilustrader.io/docs/latest/
- Rust API: https://nautechsystems.github.io/nautilus_docs/rust-api-latest/
- Python API: https://nautechsystems.github.io/nautilus_docs/python-api-latest/
