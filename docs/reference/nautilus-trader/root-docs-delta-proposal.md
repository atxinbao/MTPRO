# NautilusTrader Root Docs Delta Proposal

日期：2026-05-19

执行者：Codex

## 定位

本文保存 NautilusTrader reference study 之后对 MTPRO root docs 的候选 delta。它只作为蓝图输入，不直接修改 root docs，不创建 Project / Issue，不授权 execution。

## 采纳原则

- 只采纳 workflow、evidence chain、module boundary 和 product language。
- 不引入 NautilusTrader 作为运行依赖。
- 不复制 NautilusTrader 代码。
- 不把 Live trading reference 自动转为 current scope。

## Root Docs Delta Summary

| 目标文档 | 候选 delta | 当前处理 |
| --- | --- | --- |
| `GOAL.md` | 明确目标用户、强化 Report 是核心结果、说明 MTPRO 不是 NautilusTrader 替代品 | 已吸收到 root docs 的产品定位和硬边界 |
| `architecture.md` | 补充共同核心 / 环境特化边界、paper execution 因果链、Event Log / Replay / Projection 观察面 | 已在 Engineering Module Map 和 module-boundary 中承接 |
| `environment.md` | 补充 reference study 边界和 Live 禁区说明 | 已保留 no-secret / no-production / no-broker boundary |
| `docs/roadmap.md` | 引入 Reference Synthesis Gate、future candidate route、Live 非默认路线 | 已由 roadmap / planning handoff 承接 |
| `docs/product/*` | 新增用户路径、report artifact taxonomy、Workbench 状态语言 | 已拆入 product surface / dashboard / design docs |
| `docs/contracts/*` | 强化 Frontend ViewModel、Backend Use Case、Persistence Boundary | 已在 contract docs 中压缩保留 |

## 暂不采纳项

- 不采纳 NautilusTrader 的完整 live node / adapter runtime。
- 不采纳多 venue / 多 broker 作为当前 release 默认能力。
- 不采纳 UI 直连 cache、database schema、runtime object 或 adapter request。
- 不采纳 secret read、signed endpoint、production endpoint、real order lifecycle。

## 下一步

Root docs delta 只能由 Human + `@000 / AIE` 或 Human + `@001 / PLN` 在明确规划阶段吸收；不能从本文档自动生成 Linear / GitHub issue。
