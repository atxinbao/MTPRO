# MTPRO Live Readiness Roadmap v1

日期：2026-05-27

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

当前旧路线进度保持：

```text
Engine Maturity Roadmap Progress: 4 / 4 (100%)
Current maturity statement: L2+ Workbench Beta Readiness complete
```

该 `4 / 4` 路线已经闭合。L3 / L4 不继续改旧分母，不把旧路线回滚成未完成状态。

## 3. 为什么需要新路线口径

L1 到 L2+ 解决的是 local-first、paper-only、deterministic replay、simulation parity 和 macOS Workbench beta readiness。

L3 / L4 进入的是完全不同的风险域：

- credential / secret policy。
- account endpoint boundary。
- listenKey / private stream boundary。
- account / position / balance read model。
- broker capability split。
- future live monitoring。
- future live execution / OMS / risk / operations gates。

因此 L3 / L4 必须作为新的 Live Readiness 路线记录，不从 L2+ completion 自动授权执行。

## 4. Live Readiness Route

| 阶段 | 目标 | 状态 | 允许的当前处理 | 明确禁止 |
| --- | --- | --- | --- | --- |
| `L2+ Workbench Beta Readiness` | 本地 macOS Workbench 可安装、可启动、可演示、可验收 | Done | 作为进入 Live Readiness 讨论的基线 | 不代表 production release 或 live readiness |
| `L3.0 Live Read-only Readiness Boundary` | 定义只读接近真实账户前的术语、凭证策略、endpoint 分类、adapter capability matrix、forbidden write capability baseline 和验证门槛 | 下一阶段首选 planning candidate | 可做 docs-only planning record、contract、forbidden tests、readiness anchors | 不实现任何真实 endpoint、secret storage、listenKey、broker connection 或账户读取 |
| `L3.1 Account / Position / Balance Read-model-only` | 定义 account / position / balance 的 read-model-only 语义和 evidence surface | 后续 | 只读模型、fixture / blocked evidence、ViewModel boundary | 不读取真实账户，不同步 broker position，不实现 margin / leverage / real PnL |
| `L3.2 Private Stream / Account Snapshot Simulation Gate` | 通过 simulation / fixture gate 证明 private stream 与 account snapshot 只能在受控边界内被表达 | 后续 | 模拟输入、forbidden live stream tests、snapshot contract | 不创建 listenKey，不连接 private WebSocket，不运行 production stream |
| `L3.3 Live Monitoring Read-only Console v2` | 在 L3.0-L3.2 gate 通过后，升级 Live Monitoring 的只读证据面 | 后续 | read-model-only health、account snapshot evidence、connection gate explanation | 不提供交易控制，不提供 Live PRO Console，不提供 order-level command UI |
| `L4 Live Production / Trading Commands` | 真实 execution、OMS、broker fill、reconciliation、live risk、ops / incident / stop 和独立 Live PRO Console | Future Gated | 只能作为 future gated map | 当前不进入 planning / Linear / implementation |

## 5. L3.0 推荐切片

推荐下一阶段候选 Project：

```text
MTPRO Live Read-only Readiness Boundary v1
```

目标是先定义 Live read-only readiness 的边界，而不是实现 read-only account runtime。

L3.0 应回答：

- 哪些 live capability 仍然 forbidden。
- 哪些只读 capability 可以被定义为 future gate。
- credential / secret / endpoint / adapter capability 如何分类。
- account endpoint、listenKey、private stream 和 broker action 为什么仍不能进入当前 implementation。
- 后续 L3.1 / L3.2 / L3.3 需要哪些 validation anchors。

L3.0 不做：

- secret storage。
- signed request。
- account endpoint call。
- listenKey。
- private stream。
- broker adapter。
- account / position / balance runtime。
- Live Monitoring v2 implementation。
- Live PRO Console。
- trading button / live command。

## 6. 与 Workbench 的关系

Workbench 在 L3 路线中仍然只消费 Read Model / ViewModel：

- L3.0 只会定义 Live read-only readiness boundary，不改变 Workbench 行为。
- L3.1 才可能定义 account / position / balance 的 read-model-only evidence surface。
- L3.2 才可能定义 private stream / account snapshot 的 simulation gate。
- L3.3 才可能规划 Live Monitoring read-only Console v2。

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
- no emergency stop / shutdown / restore executable action。
- Workbench / Dashboard 只消费 Read Model / ViewModel。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

## 8. 后续推进规则

L3.0 继续推进时，必须先落仓 Project Planning Record，再由 Human 确认是否写入 Linear。

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
