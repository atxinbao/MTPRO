# MTPRO Domain Context

日期：2026-05-20

执行者：Codex

## 定位

本文档是 MTPRO 的 shared language / 领域上下文入口。

它只定义稳定词汇和禁止混用的说法，不是 spec，不是 implementation plan，不授权创建 Linear Project / Issue，不授权推进 `Todo`，不启动 Symphony，不写业务代码。

来源：`mattpocock/skills` 的 shared language / `CONTEXT.md` 思路。参考 `https://github.com/mattpocock/skills`、`https://github.com/mattpocock/skills/blob/main/CONTEXT.md`、`https://github.com/mattpocock/skills/tree/main/skills/engineering/grill-with-docs`。

## Project / Execution Terms

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Project Charter` | `GOAL.md`，说明为什么建、服务谁、硬边界和成功标准 | 不叫完整蓝图 |
| `Root Blueprint` | `BLUEPRINT.md`，项目总览、默认读取顺序和完整蓝图入口 | 不授权执行 |
| `Complete Blueprint` | `BLUEPRINT.md`，最终产品 / 系统 / 设计蓝图 | 不叫当前 sprint，不叫 issue plan |
| `Engineering Module Map / 工程模块地图` | `docs/architecture.md`，承接 `BLUEPRINT.md` 的工程模块、模块边界、数据流、接口关系和架构不变量 | 不等于完整未来蓝图，不推翻蓝图 |
| `Construction Plan` | `docs/roadmap.md`，根据蓝图和工程模块定义施工顺序、当前施工阶段、完成进度和非授权边界 | 不等于 Linear queue |
| `Current Construction Scope` | Human 当前允许进入规划的施工范围 | 不包含 Future Construction Zones / 未来建设区 |
| `Future Construction Zones / 未来建设区` | 完整蓝图中的长期能力区，例如 Live、signed endpoint、broker、OMS；可以设计，但当前不施工 | 不得自动变成 Linear issue |
| `Project Planning Record` | 仓库中的 Project 级计划摘要，位于 `docs/planning/projects/` | 不复制完整 Linear issue body |
| `Linear execution contract` | Linear issue body 中的 Scope / Non-goals / Codex Instructions / Validation / Boundary / PR Requirements | 不由仓库文档替代 |
| `configured executable issue` | Linear live-read 中通过 Parent Codex queue preflight 后唯一可执行 issue | 不等于 Backlog issue |
| `Parent Codex queue preflight` | `@002 / PAR` 在 Project 内确认 WIP=1、依赖、contract 和 active conflict 的检查 | 不等于 symphony-issue 执行 |
| `symphony-issue` | 调度唯一 `Todo` issue 的执行层 actor | 不创建 Project，不做 planning |
| `Stage Code Audit Report` | Project 全部 Done 后由 Parent Codex 单独输出并落仓的 Project 级审计报告 | 不由 child issue 输出 |
| `Root Docs Refresh Gate` | Project closure 后把已发生代码事实同步回 root docs 的 gate | 不决定下一阶段方向 |
| `Current Phase Progress Bar` | `@002 / PAR` 按 `GOAL.md` / `docs/roadmap.md` 目标切片输出的阶段完成进度 | 不按 Project 数量直接计算 |

## Runtime / App Terms

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Market Data` | Binance public read-only 行情数据 | 不包含 account、listenKey、signed endpoint |
| `Event Log` | append-only facts source | 不叫 UI model，不保存 runtime object |
| `Replay` | 从 facts source 重建 projection / evidence 的确定性路径 | 不叫生产恢复系统 |
| `Projection` | SQLite / DuckDB 或内存读模型中的派生视图 | 不作为 UI contract |
| `Read Model` | App / Dashboard 可以消费的稳定只读数据结构 | 不暴露 database schema |
| `ViewModel` | Dashboard / Workbench 绑定的 UI 输入 | 不直接读取 adapter、runtime object 或 persistence schema |
| `Command Model` | 本地 paper-only session-level 控制意图模型 | 不表示真实交易命令 |
| `Report Artifact` | 汇总 research / backtest / paper / risk / event evidence 的研究输出 | 不授权真实交易 |
| `Event Timeline` | read-model-only 的 evidence 浏览视图 | 不做完整查询语言，不暴露 persistence |

## Live Boundary Terms

以下术语只用于 Future / gated 实盘边界设计和当前 blocked evidence，不授权当前 scope 实现真实交易能力。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `live capability` | 未来实盘交易基础能力的候选名称，例如 secret policy、signed endpoint、account endpoint、broker / exchange adapter、real order lifecycle | 不等于当前已有可执行能力 |
| `blocked capability` | 当前已识别但被 gate 阻断的能力；可以进入 read-model-only blocked evidence | 不等于 fallback、mock broker 或 paper order 升级 |
| `future gate` | 某项 live capability 进入后续 Project Definition 前必须满足的条件和证据 | 不自动解锁 Linear issue，不推进 Todo |
| `forbidden capability` | 当前 Project 明确禁止的能力；任何代码、测试或文档都不得把它表达成当前可用能力 | 不写成 allowed capability，不写成 partially supported |
| `credential endpoint boundary` | MTP-62 Gate 1 中 API key、secret storage、request signature、signed endpoint、account endpoint 和 listenKey 只能作为 forbidden / future gate 出现的边界 | 不读取本地 secret，不新增 env/config/keychain，不实现签名请求或 account payload |
| `adapter capability isolation` | MTP-63 Gate 2 中 current public read-only adapter 与 future live adapter / broker / exchange execution adapter 的隔离合同 | 不实现 `LiveExecutionAdapter`，不连接 execution venue，不把 public market data adapter 升级为执行 adapter |
| `real order lifecycle boundary` | MTP-64 Gate 3 中 real order intent、state machine、submit / cancel / replace、execution report、broker fill、reconciliation、OMS 和 real account state 只能作为 terminology、future gate 和 forbidden tests 出现的边界 | 不实现真实订单状态机，不把 paper order intent、simulated fill 或 paper portfolio projection 升级为 real order、broker fill 或 account state |

## Paper-only Terms

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Paper Session` | 本地 paper-only session lifecycle | 不等于真实账户 session |
| `Paper Action Proposal` | 策略信号转出的本地 paper-only action intent | 不等于 order |
| `Risk Blocker` | 本地 paper readiness 的 blocker / evidence | 不等于完整实盘风控引擎 |
| `Paper Order Intent` | 本地 paper-only order intent value model | 不等于真实订单请求 |
| `Paper Order Lifecycle` | 本地 paper order 状态证据 | 不等于交易所订单生命周期 |
| `Simulated Fill Evidence` | deterministic simulated fill 研究证据 | 不等于 broker fill 或 execution report |
| `Portfolio Projection` | 从 paper-only evidence 派生的组合观察面 | 不等于真实账户余额或 broker position |
| `Paper Workflow Control Shell` | session-level `start` / `pause` / `close` / `reset` 本地控制壳 | 不允许 submit / cancel / replace |

## Market Replay Terms

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Market Data Batch` | 本地 public read-only fixture / batch replay 输入集合 | 不绑定真实历史下载规模 |
| `Replay Run` | 一次本地 deterministic replay 的 metadata 和 evidence | 不等于生产调度任务 |
| `Retention Policy` | 本地 batch 是否保留 / 过期 / stale 的最小证据规则 | 不等于云端 archive 或 storage tiering |
| `Freshness Evidence` | Report / Dashboard / Event Timeline 可消费的 freshness read model | 不暴露 adapter 或 schema |
| `Fixture Parity` | mock transport / fixture 与 decoder / replay contract 的一致性验证 | 不依赖真实 Binance 网络 |

## Forbidden Terms / 当前禁用或必须带门禁语义的词

以下词在当前 construction scope 中必须带上 `Future`、`gated` 或 `forbidden` 语义。中文写法也必须表达“未来建设区 / 受门禁保护 / 当前禁止”，不能写成当前已具备能力：

- Live trading
- API key
- secret storage
- signed endpoint
- account endpoint
- listenKey
- broker integration
- broker execution adapter
- exchange execution adapter
- execution venue connection
- real order submit / cancel / replace
- real order lifecycle
- execution report
- broker fill
- order reconciliation
- OMS
- real account balance
- broker position sync
- production deployment / runtime operations

## 维护规则

- 新 Linear Project 规划前，`@001 / PLN` 必须读取本文档，避免 issue title / body 使用漂移术语。
- `@002 / PAR` 做 Stage Code Audit 和 Root Docs Refresh Gate 时，如发现 root docs、PR 或 validation evidence 中出现术语漂移，应记录为 Root Docs Delta。
- Codex Execution Agent 新增 public type / protocol / actor / service 时，应优先复用本文档中的领域词命名，并在中文注释中保持同一语义。
- 临时 planning note、implementation detail 和代码文件清单不得写入本文档。
