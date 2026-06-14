# Live Trading Boundary Contract

日期：2026-05-21

执行者：Codex

本文档定义 `MTPRO Live Trading Boundary Definition v1` 的 Live trading foundation 边界合同。它只固定 taxonomy、gate 顺序、当前禁止能力和验证入口，不实现 API key、secret 存储、signed endpoint、account endpoint、listenKey、broker adapter、真实订单、OMS 或 `LiveExecutionAdapter`。

本文档不授权创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 `symphony-issue`，不启动真实交易，不读取 secret。

## Shared Boundary

| Term | 当前含义 |
| --- | --- |
| live capability | 未来实盘能力候选名，只能被描述为 gated / future |
| blocked capability | 当前识别但被阻断的能力，只能产出 blocked evidence |
| future gate | 后续 Project Definition 前必须满足的 gate，不自动解锁执行 |
| forbidden capability | 当前明确禁止的能力，任何实现或测试不得表达为可用 |

## Gate Sequence

| Gate | 主题 | 当前输出 |
| --- | --- | --- |
| Gate 0 | MTP-61 taxonomy / slice separation | live capability、blocked capability、future gate、forbidden capability |
| Gate 1 | MTP-62 credential / endpoint boundary | `LiveTradingCredentialEndpointBoundary`，不读 API key / secret |
| Gate 2 | MTP-63 adapter isolation | public read-only adapter 与 future live adapter 隔离 |
| Gate 3 | MTP-64 real order lifecycle | real order lifecycle 只作为术语 / future gate / forbidden tests |
| Gate 4 | MTP-65 blocked read model | `LiveReadiness` / `LiveBlockedEvidence` read-model-only |
| Gate 5 | MTP-66 blocked evidence surface | Dashboard / Report / Event Timeline read-model-only 展示 |
| Gate 6 | MTP-67 stage closeout | validation matrix、automation readiness、stage audit input material |

## Slice Separation

MTP-61 只定义实盘交易基础边界；实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制 都是 Future slice，不能从本文档自动进入执行。

## Anchor Ledger

| Anchor | 压缩说明 |
| --- | --- |
| MTP-61 Live trading foundation capability taxonomy 和 gate | live trading foundation 只命名 capability taxonomy 和 gates |
| MTP-61-LIVE-FOUNDATION-TAXONOMY | `live capability` / `blocked capability` / `future gate` / `forbidden capability` taxonomy |
| MTP-61-LIVE-GATE-SEQUENCE | Gate 0 -> Gate 6 顺序，不跳过 dependencies |
| MTP-61-LIVE-SLICE-SEPARATION | Live foundation、monitoring、execution、risk、audit/stop 分片隔离 |
| MTP-62 API key / signed endpoint / account endpoint / listenKey 禁止边界 | credential / endpoint 只能作为 forbidden / future gate |
| MTP-62-CREDENTIAL-ENDPOINT-BOUNDARY | `LiveTradingCredentialEndpointBoundary` 不读取 key、不存 secret、不签名请求 |
| MTP-62-LIVE-CREDENTIAL-FUTURE-GATES | Human decision、secret policy、signed/account/listenKey contracts、audit / ops evidence |
| MTP-62-PUBLIC-READ-ONLY-SEPARATION | `BinancePublicMarketDataClient` 保持 public read-only |
| MTP-63 public read-only adapter / future live adapter capability 隔离合同 | 当前 adapter 与 future live adapter 隔离 |
| MTP-63-ADAPTER-CAPABILITY-ISOLATION | `LiveAdapterCapabilityIsolationBoundary` |
| MTP-63-LIVE-ADAPTER-FUTURE-GATES | future live adapter 需要独立 Project Definition |
| MTP-63-BROKER-EXCHANGE-FUTURE-ONLY | broker / exchange execution adapter 属于 future-only |
| MTP-63-LIVEEXECUTIONADAPTER-NON-IMPLEMENTATION | 当前不实现 `LiveExecutionAdapter` |
| MTP-64 real order lifecycle 术语、future gate 和 forbidden capability tests | real order lifecycle 只做术语、gate、forbidden tests |
| MTP-64-REAL-ORDER-LIFECYCLE-TERMINOLOGY | real submit / cancel / replace / fill / reconciliation 均非当前能力 |
| MTP-64-REAL-ORDER-LIFECYCLE-FUTURE-GATES | real order 需要 broker、OMS、risk、ops gates |
| MTP-64-PAPER-REAL-LIFECYCLE-ISOLATION | paper lifecycle 不能升级为 real lifecycle |
| MTP-64-FORBIDDEN-CAPABILITY-TESTS | forbidden capability tests 必须覆盖 real order shortcut |
| MTP-65 LiveReadiness / LiveBlockedEvidence read model | 只产出 blocked read model |
| MTP-65-LIVE-READINESS-BLOCKED-READ-MODEL | Live readiness 是 read-model-only |
| MTP-65-LIVE-BLOCKED-EVIDENCE-GATES | blocked evidence 记录 missing gates |
| MTP-65-READ-MODEL-ONLY-NON-COMMAND | 不产生 command surface |
| MTP-65-SCHEMA-ADAPTER-RUNTIME-NON-EXPOSURE | 不暴露 schema、adapter、runtime object |
| MTP-66-LIVE-BLOCKED-EVIDENCE-SURFACE | blocked evidence 可展示 |
| MTP-66-DASHBOARD-REPORT-EVENT-TIMELINE-READ-MODEL | Dashboard / Report / Event Timeline 只消费 read model |
| MTP-66-NO-LIVE-COMMAND-OR-BUTTON | 无 live command 或交易按钮 |
| MTP-66-SCHEMA-ADAPTER-RUNTIME-NON-EXPOSURE | 不暴露 schema、adapter、runtime object |
| MTP-67-LIVE-BOUNDARY-STAGE-CLOSEOUT | stage closeout 只收 validation input |
| MTP-67-STAGE-AUDIT-INPUT-MATERIAL | stage audit input material，不是最终审计 |
| MTP-67-NO-FINAL-STAGE-CODE-AUDIT | 当前不创建 final Stage Code Audit |

## Type Anchors

- LiveExecutionAdapter
- LiveTradingCredentialEndpointBoundary
- LiveAdapterCapabilityIsolationBoundary
- RealOrderLifecycleBoundary
- BinancePublicMarketDataClient

## Validation Contract

- live capability、blocked capability、future gate、forbidden capability 必须能被本地 deterministic validation 命中。
- 当前不读取 secret，不连接 signed/account endpoint，不创建 listenKey。
- 当前不实例化 broker / exchange execution adapter，不提交 / 取消 / 替换真实订单。
- 实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制 必须继续作为 future gated slices。
