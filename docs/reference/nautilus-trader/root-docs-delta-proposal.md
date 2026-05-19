# NautilusTrader Root Docs Delta Proposal

日期：2026-05-19

执行者：@000 / AIE 汇总。

## 定位

本文档汇总 `@003 / PRD`、`@004 / DSG`、`@005 / ARC` 对 NautilusTrader 的参考研究，形成 MTPRO root docs 的候选 delta proposal。

本文档不直接修改 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md`、`ROADMAP.md` 或 `docs/product/*` / `docs/contracts/*`。它先作为 Human + `@000 / AIE` 的 Complete Blueprint Design 输入，再作为 Human + `@001 / PLN` 后续规划输入。不写 Linear、不创建 Project / Issue、不推进 `Todo`、不启动 Symphony、不写业务代码。

## 采纳原则

候选 delta 进入 root docs 前必须满足：

- 能强化 MTPRO 当前目标：Research -> Backtest -> Report -> Paper readiness / paper-only execution evidence。
- 不引入 Live trading、signed endpoint、account endpoint、listenKey、broker action 或真实订单。
- 不把 NautilusTrader 作为运行依赖。
- 不复制 NautilusTrader 代码。
- 不把 reference study 直接转成 Linear issue。
- 不破坏 ViewModel / Read Model-only UI 边界。

## GOAL.md 候选 delta

### G1：明确目标用户

候选表述：

```text
MTPRO 面向需要在本地 macOS 上完成策略研究、回测、报告审计和 Paper readiness 验证的交易研究用户。第一版不面向实盘交易执行用户。
```

理由：

- NautilusTrader 偏专业量化开发者和 API-first 工作流。
- MTPRO 的差异化应是本地 macOS workbench，把 evidence chain 做成更易观察的产品路径。

### G2：强化 Report 是核心结果

候选表述：

```text
Report 是 Research / Backtest / Paper 的证据中心，用于保存 run id、event range、parity、cost、risk、portfolio、replay 和 paper-only boundary evidence。
```

理由：

- NautilusTrader 的 reports / visualization 是回测和研究分析的重要出口。
- MTPRO 已经形成 Report read model，应继续把 Report 作为阶段成果和审计入口。

### G3：明确“不做 NautilusTrader 替代品”

候选表述：

```text
MTPRO 不复制 NautilusTrader，不引入 NautilusTrader 作为运行依赖，也不尝试覆盖其多 venue / live trading / full OMS 能力。
```

理由：

- 防止后续规划把 reference study 误解为功能复制清单。

## ARCHITECTURE.md 候选 delta

### A1：补充共同核心 / 环境特化边界

候选表述：

```text
MTPRO 采用共同核心 + 环境特化的架构原则：Core 保存稳定领域模型、事件、策略、risk、paper-only execution 和 portfolio projection 语义；Runtime 负责编排 ingest / event log / replay / projection；App 只消费 ViewModel / Read Model。Backtest / Paper 共享策略和事件语义，但 Paper 不升级为 Live。
```

理由：

- NautilusTrader 的 Kernel / Engine / MessageBus / Cache 说明统一核心能减少 backtest / paper 语义漂移。
- MTPRO 应学习组织原则，不学习完整 live execution stack。

### A2：明确 paper execution 因果链

候选表述：

```text
Paper execution evidence 必须遵循 strategy signal -> paper action proposal -> risk decision -> paper order intent -> simulated fill evidence -> paper-only portfolio projection -> report read model 的因果链。
```

理由：

- NautilusTrader 的 execution / risk / portfolio 路径强调命令、事件、cache 和 portfolio 的顺序。
- MTPRO 当前正在建立 paper-only execution workflow，需要把因果链写成架构不变量。

### A3：补充 Event Log / Replay / Projection 观察面

候选表述：

```text
Event Log 是 append-only facts source；Replay 是跨 Research / Backtest / Paper 的可审计能力；SQLite / DuckDB / Dashboard 都只能消费 projection 或 read model，不反向成为事实源。
```

理由：

- NautilusTrader 的 event-driven / replay 思想适合作为 MTPRO evidence chain 的长期结构。

## ENVIRONMENT.md 候选 delta

### E1：补充 reference study 边界

候选表述：

```text
Reference study 是 Linear 外研究活动，只能输出 reference docs 和 root docs delta proposal。它不创建 Linear Project / Issue，不推进 Todo，不启动 Symphony，不写业务代码。
```

理由：

- 当前 Product / Design / Architecture reference 角色都在 Linear 外工作。
- 需要防止 reference 结论被自动执行。

### E2：补充 Live 禁区说明

候选表述：

```text
任何 Live trading、signed endpoint、account endpoint、broker action、真实订单、真实成交或账户状态相关能力，都必须作为独立未来规划处理，不能从 Paper workflow 或 reference study 自然滑入。
```

理由：

- NautilusTrader 的产品路径天然包含 live trading。
- MTPRO 当前路线必须显式阻断该迁移。

## ROADMAP.md 候选 delta

### R1：新增 Reference Synthesis Gate

候选流程：

```text
External reference study
-> Product / Design / Architecture reference docs
-> root docs delta proposal
-> Human + @000 / AIE Complete Blueprint Design
-> Human + @001 / PLN planning decision
-> optional Linear Project / Issues
```

理由：

- 当前三角色研究已经形成参考资料，但不应直接进入执行队列。

### R2：未来阶段候选方向

候选方向只作为规划输入，不授权执行：

- Workbench Information Architecture v1：把 Research / Backtest / Paper / Report / Portfolio / Risk / Events 的页面和状态语言收敛为产品工作台。
- Event Timeline and Evidence Explorer v1：强化 event log、replay、projection freshness 和 evidence chain 的可观察性。
- Paper Execution Evidence Hardening v2：继续加固 paper order lifecycle、simulated fill、portfolio projection 和 report evidence 的一致性。

### R3：Live 仍非默认路线

候选表述：

```text
Live trading 不是默认 Roadmap 分支。任何 Live 相关讨论必须先经过 Human decision、新 Project Definition、安全边界和独立 planning，不得由 Paper workflow 自动推进。
```

## docs/product/* 候选 delta

### P1：新增用户路径文档

候选文件：

```text
docs/product/user-workflows.md
```

建议覆盖：

- Research workflow。
- Backtest workflow。
- Report review workflow。
- Paper evidence workflow。
- Dashboard monitoring workflow。
- Blocked Live workflow。

### P2：新增 report artifact taxonomy

候选文件：

```text
docs/product/report-artifact-taxonomy.md
```

建议覆盖：

- Backtest report artifact。
- Paper session report artifact。
- Risk blocker artifact。
- Portfolio exposure artifact。
- Replay / Event Log artifact。
- Stage Audit artifact。

### P3：补充 Workbench 状态语言

候选状态：

- empty。
- ready。
- running。
- degraded。
- failed。
- blocked。
- stale。
- paper-only。
- read-model-only。

## docs/contracts/* 候选 delta

### C1：Frontend ViewModel Contract

候选补充：

- 每个 Dashboard / Workbench 页面必须声明主 ViewModel 和辅助 ViewModel。
- UI 不得直接读取 SQLite / DuckDB schema、adapter request、runtime object 或 broker state。
- Report / Paper / Risk / Portfolio 页面必须展示 paper-only boundary。

### C2：Backend Use Case Contract

候选补充：

- use case 必须声明输入 event stream、输出 event / read model、replay behavior 和 forbidden live capability。
- Paper execution use case 必须声明 paper-only decision、simulated fill 和 projection 因果链。

### C3：Persistence Boundary

候选补充：

- Event Log 是 facts source。
- SQLite / DuckDB 是 projection。
- replay 必须从 event log envelope 出发。
- projection 不得反向授权执行或成为 UI schema contract。

## 暂不采纳项

以下 NautilusTrader 能力暂不进入 MTPRO root docs：

- 多 venue execution adapter。
- full OMS。
- real-time live node。
- account reconciliation。
- Redis-backed runtime persistence。
- margin / leverage / broker position sync。
- strategy IDE / strategy marketplace。
- Plotly / Jupyter 作为核心 UI 依赖。

## 下一步

建议下一轮由 Human + `@001 / PLN` 读取本文件，决定是否把某些 delta 进入新的 Project Planning。

本文件本身不授权执行。
