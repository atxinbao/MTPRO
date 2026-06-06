# MTPRO Live Readiness Roadmap v1

日期：2026-05-28

执行者：Codex

## 1. 文档定位

本文是 `MTPRO Live Readiness Roadmap v1`，用于在 `L2+ Workbench Beta Readiness complete` 后，单独记录通向实盘只读准备和未来实盘生产能力的路线。

本文不是 Linear Project Draft，不是 SwiftUI 实现稿，不是 Live PRO Console 产品定义，不创建 Linear Project / Issue，不推进 Todo，不启动 `@002 / PAR`，不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma，不写业务代码。

本文不授权 signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。

## 2. 当前基线

当前 Engine Maturity Roadmap 已完成：

- `L1 Paper Runtime`：Done。
- `L1.5 Data Catalog / Scenario Replay`：Done。
- `L2 Simulated Exchange / Backtest Parity`：Done。
- `L2+ Workbench Beta Readiness`：Done。
- `L3.0 Live Read-only Readiness Boundary`：Done / not counted in old denominator。
- `L3.1 Account / Position / Balance Read-model-only`：Done / not counted in old denominator。
- `L3.2 Private Stream / Account Snapshot Simulation Gate`：Done / not counted in old denominator。
- `L3.3 Live Monitoring Read-only Console v2`：Done / not counted in old denominator。
- `L3.4 Strategy / Trader Instance Readiness v1`：Done / not counted in old denominator。
- `Engine Module Boundary Consolidation before L4`：Done / not counted in old denominator。
- `Target Module Physical Layout / Source Migration before L4`：Done / not counted in old denominator。
- `Trader-Owned Strategies Layout Correction before L4`：Done / not counted in old denominator。
- `Trader EMA Strategy Layout Consolidation before L4`：Done / not counted in old denominator。
- `Trader Accounts / Coordination Compatibility Consolidation before L4`：Done / not counted in old denominator。
- `SwiftPM Target Graph Module Split before L4`：Done / not counted in old denominator。
- `TargetGraph Anchor Retirement / Real Module Source Root Migration before L4`：Done / not counted in old denominator。
- `Real Target Source Ownership / Core Envelope Retirement before L4`：Done / not counted in old denominator。
- `Core Envelope Retirement / Real Module Ownership Completion before L4`：Done / not counted in old denominator。

当前旧路线进度保持：

```text
Engine Maturity Roadmap Progress: 4 / 4 (100%)
Current maturity statement: Core Envelope Retirement / Real Module Ownership Completion before L4 complete
```

该 `4 / 4` 路线已经闭合。L3.0、L3.1、L3.2、L3.3、L3.4、Engine Module Boundary Consolidation before L4、Target Module Physical Layout / Source Migration before L4、Trader-Owned Strategies Layout Correction before L4、Trader EMA Strategy Layout Consolidation before L4、Trader Accounts / Coordination Compatibility Consolidation before L4、SwiftPM Target Graph Module Split before L4、TargetGraph Anchor Retirement / Real Module Source Root Migration before L4、Real Target Source Ownership / Core Envelope Retirement before L4 和 Core Envelope Retirement / Real Module Ownership Completion before L4 作为 Live Readiness 路线的 boundary / read-model-only / simulation gate / monitoring evidence / strategy-trader readiness evidence / L4 planning input / physical source migration / Trader container compatibility / buildable target graph evidence / no-active-TargetGraph-path evidence / real target ownership evidence / real module ownership completion evidence 追加，不继续改旧分母，不把旧路线回滚成未完成状态。

## 3. 为什么需要新路线口径

L1 到 L2+ 解决的是 local-first、paper-only、deterministic replay、simulation parity 和 macOS Workbench beta readiness。

L3 / L4 进入的是完全不同的风险域：

- credential / secret policy。
- account endpoint boundary。
- listenKey / private stream boundary。
- account / position / balance read model。
- broker capability split。
- strategy / trader instance readiness。
- future live monitoring。
- future live execution / OMS / risk / operations gates。

因此 L3 / L4 必须作为新的 Live Readiness 路线记录，不从 L2+ completion 自动授权执行。

## 4. Live Readiness Route

| 阶段 | 目标 | 状态 | 允许的当前处理 | 明确禁止 |
| --- | --- | --- | --- | --- |
| `L2+ Workbench Beta Readiness` | 本地 macOS Workbench 可安装、可启动、可演示、可验收 | Done | 作为进入 Live Readiness 讨论的基线 | 不代表 production release 或 live readiness |
| `L3.0 Live Read-only Readiness Boundary` | 定义只读接近真实账户前的术语、凭证策略、endpoint 分类、adapter capability matrix、forbidden write capability baseline 和验证门槛 | Done | Stage Code Audit Report、contract、forbidden tests、readiness anchors 已闭环 | 不实现任何真实 endpoint、secret storage、listenKey、broker connection 或账户读取 |
| `L3.1 Account / Position / Balance Read-model-only` | 定义 account / position / balance 的 read-model-only 语义和 evidence surface | Done | Stage Code Audit Report、contract、deterministic fixture、forbidden tests、Workbench / Report / Events read-model-only surface 已闭环 | 不读取真实账户，不同步 broker position，不实现 margin / leverage / real PnL |
| `L3.2 Private Stream / Account Snapshot Simulation Gate` | 通过 simulation / fixture gate 证明 private stream 与 account snapshot 只能在受控边界内被表达 | Done | Stage Code Audit Report、contract、deterministic fixture、forbidden endpoint/runtime tests、Workbench / Report / Events read-model-only simulation gate surface 已闭环 | 不创建 listenKey，不连接 private WebSocket，不运行 production stream |
| `L3.3 Live Monitoring Read-only Console v2` | 在 L3.0-L3.2 gate 通过后，升级 Live Monitoring 的只读证据面 | Done | Stage Code Audit Report、Core deterministic evidence、Workbench / Report / Events read-model-only surface、forbidden tests 和 automation readiness 已闭环 | 不提供交易控制，不提供 Live PRO Console，不提供 order-level command UI |
| `L3.4 Strategy / Trader Instance Readiness v1` | 定义 Strategy Instance / Trader Instance 的只读上下文、生命周期、quoter / hedger role、account / portfolio / risk read-model 输入和 paper/live-neutral proposal contract | Done | Stage Code Audit Report、contract、forbidden tests、Workbench / Report / Events read-model-only strategy readiness surface 和 automation readiness 已闭环 | 不让 strategy 直接调用 Execution Client，不输出 broker command，不实现 OMS、trading button、Live PRO Console 或 live command |
| `Engine Module Boundary Consolidation before L4` | 固定 architecture-graph-aligned target module boundary、source layout、dependency direction、forbidden path taxonomy 和 L4 planning input material | Done | Stage Code Audit Report、module boundary docs、validation matrix、automation readiness 和 L4 planning input material 已闭环 | 不移动 production source，不修改 `Package.swift` target graph，不实现 L4 runtime、ExecutionClient、OMS、broker adapter、Live PRO Console 或 live command |
| `Target Module Physical Layout / Source Migration before L4` | 把 target module boundary 落为 physical source directories 和 compatibility envelope | Done | Stage Code Audit Report、source migration evidence、remaining compatibility shell audit、validation matrix 和 automation readiness 已闭环 | 不新增 SwiftPM target，不做 target graph split，不实现 L4 runtime、ExecutionClient、OMS、broker adapter、Live PRO Console 或 live command |
| `Trader-Owned Strategies Layout Correction before L4` | 把 concrete strategy 归入 Trader-owned source layout，修正旧 peer-level strategy 口径 | Done | Stage Code Audit Report、EMA active placement、OrderBookImbalance historical / compatibility placement、StrategyBindings boundary 和 forbidden direct execution audit 已闭环 | 不新增 active non-EMA strategy，不实现 Strategy runtime、Trader runtime、ExecutionClient、OMS、broker adapter、Live PRO Console 或 live command |
| `Trader EMA Strategy Layout Consolidation before L4` | 收口 current active concrete strategy only `EMA`，canonical active path only `Sources/Trader/Strategies/EMA/` | Done | Stage Code Audit Report、EMA-only path validation、RiskBinding boundary、compatibility envelope 和 forbidden direct execution audit 已闭环 | 不让非 EMA strategy 进入 active source，不实现 broker command、OMS、trading button、live command 或 L4 capability |
| `Trader Accounts / Coordination Compatibility Consolidation before L4` | 补齐 `Trader = Accounts + Strategies/EMA + Coordination` 的 Trader container compatibility relationship | Done | Stage Code Audit Report、`Sources/Trader/Accounts` account context boundary、StrategyBindings wording retirement、stale Package excludes cleanup、Trader container completeness validation 已闭环 | 不实现 Trader runtime、Strategy runtime、real account read、ExecutionClient implementation、OMS、broker gateway 或 L4 capability |
| `SwiftPM Target Graph Module Split before L4` | 把 architecture-graph-aligned source layout 落为 buildable SwiftPM target graph | Done | Stage Code Audit Report、DomainModel / MessageBus / Database / DataClient / DataEngine / Cache / TraderStrategies / Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient / Dashboard target evidence、compatibility envelope audit 和 forbidden implementation audit 已闭环；Workbench / App / AppCompatibility 已退休为 historical wording | 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed/account endpoint、private stream runtime、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability |
| `TargetGraph Anchor Retirement / Real Module Source Root Migration before L4` | 退休 active `Sources/TargetGraph` compile anchor，并把 target boundary source roots 固定到真实 module roots | Done | Stage Code Audit Report、no active `Sources/TargetGraph` directory、no active `Package.swift` `Sources/TargetGraph` target path、real module source root snapshot、compatibility envelope audit 和 forbidden implementation audit 已闭环 | 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed/account endpoint、private stream runtime、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability |
| `Real Target Source Ownership / Core Envelope Retirement before L4` | 验证 real target source ownership，移除 direct Trader -> ExecutionEngine dependency，并把 retained compatibility envelopes 显式纳入 retirement matrix | Done | Stage Code Audit Report、real target ownership contract、real target smoke tests、foundation / data / trader / risk / execution ownership migration、Dashboard naming cleanup、unsafe construct allowed-path validation、Core envelope retirement matrix 已闭环 | 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed/account endpoint、private stream runtime、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability |
| `Core Envelope Retirement / Real Module Ownership Completion before L4` | 完成第二轮 real module ownership completion，并显式保留 retained compatibility envelope / L4 blocker matrix | Done | Stage Code Audit Report、MessageBus / DataEngine / Portfolio / RiskEngine / ExecutionEngine ownership completion、Database / Persistence / Runtime matrix、Dashboard active naming cleanup、all architecture targets real API smoke coverage 和 retained compatibility envelope matrix 已闭环 | 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed/account endpoint、private stream runtime、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability |
| `L4 Live Production / Trading Commands` | 真实 execution、OMS、broker fill、reconciliation、live risk、ops / incident / stop 和独立 Live PRO Console | Future Gated | 只能作为 future gated map | 当前不进入 planning / Linear / implementation |

## 5. L3.0 / L3.1 / L3.2 / L3.3 / L3.4 / Engine Boundary 完成事实与下一候选

已完成的 L3.0 / L3.1 / L3.2 / L3.3 / L3.4 / Engine Boundary Project：

```text
MTPRO Live Read-only Readiness Boundary v1
MTPRO Account / Position / Balance Read-model-only v1
MTPRO Private Stream / Account Snapshot Simulation Gate v1
MTPRO Live Monitoring Read-only Console v2
MTPRO Strategy / Trader Instance Readiness v1
MTPRO Engine Module Boundary Consolidation v1
MTPRO Target Module Physical Layout / Source Migration v1
MTPRO Trader-Owned Strategies Layout Correction v1
MTPRO Trader EMA Strategy Layout Consolidation v1
MTPRO Trader Accounts / Coordination Compatibility Consolidation v1
MTPRO SwiftPM Target Graph Module Split v1
MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration v1
MTPRO Real Target Source Ownership Validation / Core Envelope Retirement v1
MTPRO Core Envelope Retirement / Real Module Ownership Completion v1
```

这些 Project 已完成 Live read-only readiness 的边界定义、APB read-model-only evidence surface、private stream / account snapshot simulation gate evidence boundary、Live Monitoring v2 read-model-only evidence surface、Strategy / Trader structural readiness evidence boundary、L4 前的 target module boundary / planning input material、L4 前的 target module physical directories / compatibility envelope / source migration evidence、Trader-owned strategy layout correction、EMA-only active strategy consolidation、`Trader = Accounts + Strategies/EMA + Coordination` compatibility consolidation、buildable SwiftPM target graph evidence chain、no-active-TargetGraph-path / real module source root migration evidence、real target ownership / Core envelope retirement matrix evidence，以及第二轮 real module ownership completion / retained envelope matrix evidence，而不是实现 read-only account runtime、private stream runtime、account snapshot runtime、Live Monitoring runtime、Strategy runtime、Trader runtime、ExecutionClient implementation、OMS implementation、broker command、Live PRO Console 或 L4 execution。

L3.0 已回答：

- 哪些 live capability 仍然 forbidden。
- 哪些只读 capability 可以被定义为 future gate。
- credential / secret / endpoint / adapter capability 如何分类。
- account endpoint、listenKey、private stream 和 broker action 为什么仍不能进入当前 implementation。
- 后续 L4 需要哪些 signed/account/broker/risk/ops validation anchors。

L3.1 已回答：

- account / position / balance read-model-only terminology 如何落到 snapshot identity。
- source / freshness evidence、position exposure evidence 和 balance paper-vs-real boundary 如何表达。
- deterministic local fixture 如何作为 APB evidence source。
- Workbench / Report / Events 如何展示 APB read-model-only evidence。
- real account tests、account endpoint payload、broker state、schema、Runtime object 和 adapter request 为什么仍必须被隔离。

L3.2 已回答：

- simulated private account event source identity 如何固定 fixture / simulated / future-gated source labels。
- simulated account snapshot input、account snapshot update fixture 和 freshness evidence 如何通过 checksum、fixture version、observedAt、source watermark 串联。
- fresh / stale / blocked / missing evidence 如何只作为 local fixture evidence，不表示真实 account endpoint、private stream runtime 或 broker connectivity。
- Workbench / Report / Events 如何展示 private stream / account snapshot simulation gate read-model-only evidence。
- signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、broker adapter、Runtime object、schema、account payload 和 broker state 为什么仍必须被隔离。

L3.0 / L3.1 / L3.2 未做且仍不授权：

- secret storage。
- signed request。
- account endpoint call。
- listenKey。
- private stream runtime。
- broker adapter。
- account / position / balance runtime。
- real account read。
- broker position sync。
- real balance / margin / leverage / real PnL。
- Live Monitoring v2 implementation。
- Live PRO Console。
- trading button / live command。

## 6. 与 Workbench 的关系

Workbench 在 L3 路线中仍然只消费 Read Model / ViewModel：

- L3.0 已定义 Live read-only readiness boundary，并以 read-model-only evidence 接入 Dashboard / Report / Event Timeline boundary；不改变 Workbench 为真实 broker / account runtime。
- L3.1 已定义 account / position / balance 的 read-model-only evidence surface，并以 deterministic fixture / ViewModel / Dashboard smoke 保持本地只读证据链。
- L3.2 已定义 private stream / account snapshot 的 simulation gate，并以 deterministic fixture / ViewModel / Dashboard smoke 保持本地只读证据链。
- L3.3 已完成 Live Monitoring read-only Console v2。
- L3.4 已完成 Strategy Instance / Trader Instance readiness、quoter / hedger role 和 paper/live-neutral proposal contract 的 read-model-only evidence boundary。

Workbench 不展示 API key 输入、secret storage、broker connect、account connect、trading button、live command、order form、real order state、real account balance 或 broker position，除非后续独立 Project 通过 Human decision、Linear 写入和 Parent Codex queue preflight 明确授权。

## 7. 验证要求

后续 L3 路线的任一 Project 都必须验证：

- no signed endpoint。
- no account endpoint / listenKey implementation。
- no broker / exchange execution adapter。
- no `LiveExecutionAdapter`。
- no OMS / real order lifecycle。
- no real submit / cancel / replace。
- no execution report / broker fill / reconciliation。
- no real account / broker position / margin / leverage implementation。
- no Live PRO Console / trading button / live command。
- no direct Strategy Instance -> Execution Client / broker command path。
- no emergency stop / shutdown / restore executable action。
- Workbench / Dashboard 只消费 Read Model / ViewModel。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

## 8. 后续推进规则

L3.3 或任何后续 L3 / L4 slice 继续推进时，必须先落仓 Project Planning Record，再由 Human 确认是否写入 Linear。

执行链路仍然是：

```text
Human confirms Project direction
-> Project Planning Record
-> Linear Project / Issues written as Backlog / non-executable
-> Parent Codex queue preflight
-> unique Todo issue
-> symphony-issue
-> PR / checks / merge / Linear Done
```

本文不授权跳过 planning record，不授权直接创建 Linear，不授权直接推进 Todo。
