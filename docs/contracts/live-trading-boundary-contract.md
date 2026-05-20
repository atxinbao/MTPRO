# Live Trading Boundary Contract

日期：2026-05-21

执行者：Codex

本文档定义 `MTPRO Live Trading Boundary Definition v1` 的 Live trading foundation 边界合同。它只固定 taxonomy、gate 顺序、当前禁止能力和后续 issue 的验证入口，不实现任何 API key、secret 存储、signed endpoint、account endpoint、listenKey、broker adapter、真实订单、OMS 或 `LiveExecutionAdapter`。

本文档不授权创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 `symphony-issue`，不启动真实交易，不读取 secret。

## MTP-61 Live trading foundation capability taxonomy 和 gate

`MTP-61-LIVE-FOUNDATION-TAXONOMY`

Live trading foundation 在当前 Project 中不是可执行实盘交易能力，而是一组必须先被命名、隔离和验证的受门禁能力。MTP-61 只允许定义这些词汇和 gate，不允许把它们变成可调用接口。

| Taxonomy term | 中文定义 | 当前状态 | 当前允许输出 | 当前禁止输出 |
| --- | --- | --- | --- | --- |
| `live capability` | 未来实盘交易基础能力的候选名称，例如 secret policy、signed endpoint、account endpoint、broker / exchange adapter、real order lifecycle。 | Future / gated | 合同术语、gate 列表、blocked evidence 锚点 | 可执行 API、Swift live adapter、真实订单命令 |
| `blocked capability` | 当前已识别但明确被阻断的能力；它可以被展示为 blocked evidence，但不能被执行。 | Blocked / non-executable | docs anchor、validation matrix anchor、后续 read-model-only evidence 输入 | fallback 到 paper order、broker action、signed endpoint |
| `future gate` | 允许某项 live capability 进入后续 Project Definition 前必须满足的条件。 | Required before future scope | gate 名称、证据要求、non-goal 边界 | 自动解锁后续 issue、自动推进 Todo |
| `forbidden capability` | 当前 Project 明确禁止的能力；任何实现、测试夹具或文档不得把它表达成当前可用能力。 | Forbidden in current scope | 禁止项清单、mechanical validation anchor | API key、secret、signed endpoint、account endpoint、listenKey、broker、real order、OMS、LiveExecutionAdapter |

## MTP-61 gate sequence

`MTP-61-LIVE-GATE-SEQUENCE`

Live trading foundation 必须按门禁顺序推进。当前 issue 只完成 Gate 0 的命名和验证锚点；后续 gate 只有在对应 Linear issue 成为唯一 configured executable issue 后才能施工。

| Gate | 名称 | 目标 | 允许证据 | 禁止扩展 |
| --- | --- | --- | --- | --- |
| Gate 0 | Taxonomy / blocked boundary | 定义 live capability、blocked capability、future gate、forbidden capability。 | `docs/contracts/live-trading-boundary-contract.md`、`TVM-LIVE-TRADING-FOUNDATION`、automation readiness anchor | 任何 Live implementation |
| Gate 1 | API key / signed / account / listenKey boundary | 定义 secret、signed endpoint、account endpoint 和 listenKey 的禁止边界。 | 后续 MTP-62 contract / validation anchor | secret 存储、API key 读取、signed request |
| Gate 2 | Adapter capability isolation | 隔离 current public read-only adapter 与 future live adapter capability。 | 后续 MTP-63 adapter isolation contract | `LiveExecutionAdapter`、broker adapter、exchange execution adapter |
| Gate 3 | Real order lifecycle terms | 定义 real order lifecycle 术语、future gate 和 forbidden capability tests。 | 后续 MTP-64 terminology / tests anchor | submit / cancel / replace、real order state machine |
| Gate 4 | Live readiness blocked read model | 新增最小 `LiveReadiness` / `LiveBlockedEvidence` read-model-only 表达。 | 后续 MTP-65 read model / tests | command surface、execution authorization |
| Gate 5 | Workbench blocked evidence surface | 将 blocked evidence 接入 Dashboard / Report / Event Timeline read-model-only 展示。 | 后续 MTP-66 App / Dashboard evidence | live button、risk control command、position management command |
| Gate 6 | Stage validation closeout | 收口 validation matrix、automation readiness 和 stage audit input material。 | 后续 MTP-67 stage audit input | 最终 Stage Code Audit Report、Root Docs Refresh Gate |

## MTP-61 slice separation

`MTP-61-LIVE-SLICE-SEPARATION`

MTP-61 只定义 Live trading foundation 的 taxonomy 和 gate，不施工后续实盘产品切片。以下切片必须继续保持 Future / gated：

| Slice | 本 Project 内的位置 | MTP-61 边界 |
| --- | --- | --- |
| 实盘交易基础边界 / Live trading foundation | 当前 Project 的唯一范围 | 只定义 capability taxonomy、gate、blocked boundary 和 validation anchor。 |
| 实盘监控台 / Live monitoring console | Future slice | 不定义 live runtime health 实现，不接连接状态、行情流、订单流、错误、延迟监控。 |
| 实盘执行控制 / Live execution control | Future slice | 不定义 submit / cancel / replace 控制，不处理 execution report、reconciliation 或 incident fallback。 |
| 实盘风险控制 / Live risk control | Future slice | 不实现真实 pre-trade risk、仓位限制、订单金额限制、频率限制、熔断或禁交易状态。 |
| 实盘审计 / 事故回放 / 停机控制 | Future slice | 不实现 live audit trail、incident replay、emergency stop、shutdown / restore policy。 |

## MTP-62 API key / signed endpoint / account endpoint / listenKey 禁止边界

`MTP-62-CREDENTIAL-ENDPOINT-BOUNDARY`

MTP-62 固定 Gate 1 的 credential / signed / account / listenKey 边界。该 gate 只允许把这些能力表达为 forbidden terminology、future gate、validation anchor 和 deterministic forbidden capability test，不允许新增任何 secret handling、签名请求、账户 endpoint 调用或 listenKey user data stream。

| Capability | 当前状态 | 当前允许证据 | 当前禁止输出 |
| --- | --- | --- | --- |
| `API key` | Forbidden / future gate | 合同术语、`LiveTradingCredentialEndpointBoundary` forbidden capability、PR boundary evidence | 环境变量、配置项、Keychain 读取、secret 文件读取、HTTP header、query item |
| `secret storage` | Forbidden / future gate | future gate 条件、validation matrix anchor | secret store、credential provider、加密落盘、测试 fixture secret |
| `request signature` | Forbidden / future gate | signed endpoint capability contract 的 future gate | HMAC / signature 计算、timestamp / recvWindow signing、signed request helper |
| `signed endpoint` | Forbidden / future gate | contract docs、Core deterministic forbidden test、Adapters rejection test | SAPI / FAPI / DAPI / signed REST request、order 或 account signed path |
| `account endpoint` | Forbidden / future gate | account endpoint capability contract 的 future gate | `/api/v3/account`、account payload、balance / position sync |
| `listenKey user data stream` | Forbidden / future gate | listenKey contract 的 future gate | listenKey 创建、keepalive、user data stream、private WebSocket |
| `real account payload` | Forbidden / future gate | audit / operations evidence 要求 | 真实余额、真实持仓、broker position、account update event |

## MTP-62 future gates

`MTP-62-LIVE-CREDENTIAL-FUTURE-GATES`

以下 gate 只是后续 Project Definition 前的必要条件，不是当前实现任务：

- Human independent Live decision。
- API key / secret policy。
- signed endpoint capability contract。
- account endpoint capability contract。
- listenKey user data stream contract。
- public read-only adapter separation。
- audit and operations evidence。

MTP-62 当前新增的 Core fixture 是 `LiveTradingCredentialEndpointBoundary`，只用于 deterministic contract validation。它的 `readsAPIKey`、`storesSecret`、`signsRequests`、`callsSignedEndpoint`、`callsAccountEndpoint`、`createsListenKey`、`consumesRealAccountPayload`、`upgradesPublicReadOnlyAdapter` 和 `requiredValidationDependsOnNetwork` 必须全部为 `false`。

## MTP-62 public read-only adapter separation

`MTP-62-PUBLIC-READ-ONLY-SEPARATION`

当前 Binance adapter 仍只能使用 public read-only market data boundary。`BinanceReadOnlyAdapterBoundary` 和 `BinancePublicMarketDataClient` 不得升级为 signed / account capability：

- `BinanceForbiddenCapability` 必须继续包含 `API key`、`signed endpoint`、`account endpoint` 和 `listenKey user data stream`。
- `BinancePublicMarketDataClient` 必须在 transport 前拒绝 `requiresAPIKey`、`signature`、`/api/v3/account`、`listenKey`、SAPI、FAPI 和 DAPI surface。
- Required validation 继续使用本地 deterministic tests，不依赖真实 Binance 网络、真实 API key 或真实账户。
- 任何 future signed / account / listenKey capability 必须进入独立 Project Definition，不能复用当前 public market data adapter 偷渡。

## MTP-63 public read-only adapter / future live adapter capability 隔离合同

`MTP-63-ADAPTER-CAPABILITY-ISOLATION`

MTP-63 固定 Gate 2 的 adapter capability isolation。该 gate 只允许把当前 `Binance public market data` adapter 表达为 public read-only market data boundary，并把 future live adapter、broker / exchange execution adapter、execution venue connection 和 real order adapter capability 表达为 forbidden terminology、future gate、validation anchor 和 deterministic forbidden test。

当前 `LiveAdapterCapabilityIsolationBoundary` fixture 必须满足：

- `issueID == MTP-63`。
- `gate == adapterCapabilityIsolation`。
- `currentAdapterName == Binance public market data`。
- `readOnlyAllowedCapabilities == exchangeInfo / klines / recent trades / best bid / ask / depth snapshot / depth delta`。
- `currentAdapterIsReadOnly == true`。
- `currentAdapterRequiresAPIKey == false`。
- `currentAdapterUsesSignedEndpoint == false`。
- `currentAdapterCallsAccountEndpoint == false`。
- `currentAdapterCreatesListenKey == false`。
- `implementsLiveExecutionAdapter == false`。
- `instantiatesBrokerExecutionAdapter == false`。
- `instantiatesExchangeExecutionAdapter == false`。
- `exposesExecutionVenueConnection == false`。
- `submitsRealOrder == false`。
- `cancelsRealOrder == false`。
- `replacesRealOrder == false`。
- `requiredValidationDependsOnNetwork == false`。

`MTP-63-LIVE-ADAPTER-FUTURE-GATES`

Future live adapter 只有在后续独立 Project Definition 中补齐以下 gate 后才能进入实现规划：

- Human independent Live decision。
- credential endpoint boundary satisfied。
- adapter capability contract。
- broker / exchange adapter contract。
- real order lifecycle contract。
- risk and operations readiness。
- audit evidence。

这些 gate 不授权当前实现 `LiveExecutionAdapter`，不创建 broker / exchange adapter，不连接 execution venue，不提交 / 撤销 / 替换真实订单。

`MTP-63-BROKER-EXCHANGE-FUTURE-ONLY`

Broker / exchange execution adapter 在当前 Project 中只能作为 future-only 边界出现：

- `LiveExecutionAdapter` 必须继续是 forbidden capability，不得新增 Swift protocol / struct / class / actor / enum 实现。
- `broker execution adapter` 必须继续是 forbidden capability，不得连接 broker SDK、交易所私有 endpoint 或 execution venue。
- `exchange execution adapter` 必须继续是 forbidden capability，不得实现订单 submit / cancel / replace transport。
- `BinanceReadOnlyAdapterBoundary` 必须继续只暴露 public market data allowed capabilities，并在 forbidden capabilities 中包含 `LiveExecutionAdapter`、broker / exchange execution adapter、execution venue connection、real order lifecycle 和 OMS。
- `BinancePublicMarketDataClient` 必须在 transport 前拒绝 broker、LiveExecutionAdapter、submit、cancel、replace 等执行语义片段。

`MTP-63-LIVEEXECUTIONADAPTER-NON-IMPLEMENTATION`

MTP-63 的 non-implementation evidence 必须来自三层本地证据：

- Core deterministic test 证明 `LiveAdapterCapabilityIsolationBoundary` 的 `implementsLiveExecutionAdapter`、broker / exchange instantiation 和 real order flags 全部为 `false`，并且 Codable 解码无法把它们恢复为 `true`。
- Adapters deterministic test 证明 `BinanceReadOnlyAdapterBoundary` 不暴露 `LiveExecutionAdapter`、broker / exchange execution adapter 或 execution venue capability，且 transport 前拒绝执行语义片段。
- `checks/automation-readiness.sh` 必须机械检查 MTP-63 anchors，并拒绝 `Sources/` 或 `Tests/` 中出现 `LiveExecutionAdapter` public type / protocol / actor / class / enum declaration。

## MTP-64 real order lifecycle 术语、future gate 和 forbidden capability tests

`MTP-64-REAL-ORDER-LIFECYCLE-TERMINOLOGY`

MTP-64 固定 Gate 3 的 real order lifecycle terminology。该 gate 只允许把真实订单生命周期表达为术语、future gate、validation anchor 和 deterministic forbidden test，不允许实现真实订单状态机、submit / cancel / replace、execution report、broker fill、reconciliation、OMS、真实账户状态或 broker position sync。

| Term | 中文定义 | 当前状态 | 当前允许证据 | 当前禁止输出 |
| --- | --- | --- | --- | --- |
| `real order intent` | 后续 Live / OMS 可能需要的真实订单意图。 | Future / gated | 术语、future gate、forbidden test | 当前 Swift command、paper order intent 升级 |
| `real order state machine` | 后续跟踪真实订单状态迁移的状态机。 | Future / gated | 合同名称、gate 条件 | 当前 enum / reducer / engine 实现 |
| `real order submit` | 后续向 broker / exchange 提交真实订单。 | Forbidden now | future submit contract | HTTP / SDK / adapter submit |
| `real order cancel` | 后续撤销真实订单。 | Forbidden now | future cancel contract | cancel command / transport |
| `real order replace` | 后续替换真实订单参数。 | Forbidden now | future replace contract | replace command / transport |
| `execution report` | 后续 broker / exchange 返回的真实订单执行回报。 | Future / gated | future execution report contract | 当前 ingestion、event 或 read model 授权 |
| `broker fill` | 后续真实 broker / exchange fill。 | Future / gated | future broker fill contract | simulated fill 升级为 broker fill |
| `order reconciliation` | 后续本地状态与 broker / exchange 状态核对。 | Future / gated | future reconciliation contract | 当前 reconciliation service |
| `OMS` | 后续完整订单管理系统。 | Future / gated | OMS blueprint gate | 当前 OMS 类型、服务或 workflow |
| `real account state` | 后续真实账户余额、持仓和 account update。 | Future / gated | account state future gate | 当前 account state / broker position sync |

`MTP-64-REAL-ORDER-LIFECYCLE-FUTURE-GATES`

Future real order lifecycle 只有在后续独立 Project Definition 中补齐以下 gate 后才能进入实现规划：

- Human independent Live decision。
- credential endpoint boundary satisfied。
- adapter capability isolation satisfied。
- real order state machine contract。
- submit contract。
- cancel contract。
- replace contract。
- execution report contract。
- broker fill contract。
- reconciliation contract。
- OMS blueprint。
- live risk / operations / audit evidence。

这些 gate 不授权当前实现真实订单状态机，不创建 submit / cancel / replace command，不消费 execution report，不记录 broker fill，不执行 reconciliation，也不实现 OMS。

`MTP-64-PAPER-REAL-LIFECYCLE-ISOLATION`

Paper order lifecycle 与 real order lifecycle 必须保持隔离：

- `PaperOrderIntent` 只表达本地 paper order intent / lifecycle evidence，`representsRealOrder`、`authorizesLiveTrading` 和 `isExecutableAsRealOrder` 必须保持 `false`。
- `PaperSimulatedFillEvidence` 只表达 deterministic simulated fill evidence，`representsRealFill`、`representsBrokerFill` 和 `updatesRealAccountBalance` 必须保持 `false`。
- `PaperPortfolioProjectionUpdate` 只表达 paper portfolio projection，`readsRealAccountBalance` 和 `syncsBrokerPosition` 必须保持 `false`。
- `RealOrderLifecycleBoundary` 的 `upgradesPaperOrderLifecycle`、`upgradesPaperOrderIntent`、`upgradesSimulatedFillToBrokerFill`、`upgradesPaperPortfolioToAccountState` 和 `readModelRepresentsRealOrderLifecycle` 必须保持 `false`。

`MTP-64-FORBIDDEN-CAPABILITY-TESTS`

MTP-64 的 non-implementation evidence 必须来自三层本地证据：

- Core deterministic test 证明 `RealOrderLifecycleBoundary` 只定义术语、future gate 和 allowed evidence，且所有 real order lifecycle / OMS / account / broker position / paper upgrade flags 全部为 `false`。
- Core deterministic test 证明 `PaperOrderIntent`、`PaperSimulatedFillEvidence` 和 `PaperPortfolioProjectionUpdate` 不能升级为 real order、broker fill 或 real account state。
- Adapters deterministic test 证明 `BinanceReadOnlyAdapterBoundary` 不暴露 execution report、broker fill、order reconciliation、real account state 或 broker position sync，且 `BinancePublicMarketDataClient` 在 transport 前拒绝 execution report、broker fill、reconciliation 和 OMS 语义片段。
- `checks/automation-readiness.sh` 必须机械检查 MTP-64 anchors，并拒绝 `Sources/` 或 `Tests/` 中出现 `RealOrderStateMachine` public type / protocol / actor / class / enum declaration。

## MTP-65 LiveReadiness / LiveBlockedEvidence read model

`MTP-65-LIVE-READINESS-BLOCKED-READ-MODEL`

MTP-65 固定 Gate 4 的最小 Live readiness blocked read model。该 gate 只允许新增 `LiveReadiness` 和 `LiveBlockedEvidence` 这类 read-model-only evidence，用来解释当前 Live trading foundation 为什么仍然被阻断；它不允许新增 command surface、execution authorization、UI button、adapter surface、Runtime object、SQLite / DuckDB schema、API key、signed endpoint、account endpoint、listenKey、broker adapter 或真实订单生命周期实现。

当前 `LiveReadiness` fixture 必须满足：

- `issueID == MTP-65`。
- `gate == liveReadinessBlockedReadModel`。
- `status == blocked`。
- `blockedEvidence == API key / signed endpoint / account endpoint / listenKey user data stream / broker adapter / real order lifecycle`。
- `isReadModelOnly == true`。
- `providesCommandSurface == false`。
- `authorizesLiveTrading == false`。
- `exposesAdapterSurface == false`。
- `exposesRuntimeObject == false`。
- `exposesSQLiteSchema == false`。
- `exposesDuckDBSchema == false`。
- `readsAPIKey == false`。
- `usesSignedEndpoint == false`。
- `callsAccountEndpoint == false`。
- `createsListenKey == false`。
- `instantiatesBrokerAdapter == false`。
- `representsRealOrderLifecycle == false`。
- `requiredValidationDependsOnNetwork == false`。

`MTP-65-LIVE-BLOCKED-EVIDENCE-GATES`

`LiveBlockedEvidence` 必须把每个 blocked capability 映射回已完成的 gate / contract anchor：

| Blocked capability | Required gate | Required source anchors |
| --- | --- | --- |
| `API key` | Gate 1 credential endpoint boundary | `MTP-62-CREDENTIAL-ENDPOINT-BOUNDARY`、`LiveTradingCredentialEndpointBoundary` |
| `signed endpoint` | Gate 1 credential endpoint boundary | `MTP-62-LIVE-CREDENTIAL-FUTURE-GATES`、`LiveTradingCredentialEndpointBoundary` |
| `account endpoint` | Gate 1 credential endpoint boundary | `MTP-62-CREDENTIAL-ENDPOINT-BOUNDARY`、`LiveTradingCredentialEndpointBoundary` |
| `listenKey user data stream` | Gate 1 credential endpoint boundary | `MTP-62-LIVE-CREDENTIAL-FUTURE-GATES`、`LiveTradingCredentialEndpointBoundary` |
| `broker adapter` | Gate 2 adapter capability isolation | `MTP-63-ADAPTER-CAPABILITY-ISOLATION`、`LiveAdapterCapabilityIsolationBoundary` |
| `real order lifecycle` | Gate 3 real order lifecycle terms | `MTP-64-REAL-ORDER-LIFECYCLE-TERMINOLOGY`、`RealOrderLifecycleBoundary` |

`MTP-65-READ-MODEL-ONLY-NON-COMMAND`

MTP-65 的 read model 不得提供任何 command surface：

- 不新增 live command、order command、risk control command、position management command 或 trading entry point。
- 不把 `LiveReadinessStatus.blocked` 扩展为 ready / enabled / partial readiness。
- `LiveReadiness.allLiveGatesBlocked` 必须只在所有 blocked evidence 仍为 blocked 时为 `true`。
- Codable 解码必须拒绝把 `providesCommandSurface`、`authorizesLiveTrading`、API key、signed endpoint、account endpoint、listenKey、broker adapter 或 real order lifecycle flag 恢复为 `true`。

`MTP-65-SCHEMA-ADAPTER-RUNTIME-NON-EXPOSURE`

MTP-65 的 read model 不得暴露内部实现面：

- 不暴露 adapter request、adapter instance 或 broker adapter。
- 不暴露 Runtime object、workflow object 或 actor。
- 不暴露 SQLite schema、DuckDB schema、SQL、ORM 或 persistence implementation。
- 不依赖真实 Binance 网络、真实 API key、真实账户、broker state 或 production runtime operations。

## Current allowed evidence

MTP-61 至 MTP-65 当前只允许产生以下 evidence：

- Live trading foundation taxonomy。
- Gate sequence。
- 当前禁止能力清单。
- Gate 1 credential / signed / account / listenKey boundary。
- Gate 2 adapter capability isolation。
- Gate 3 real order lifecycle terminology / future gates / forbidden tests。
- Gate 4 Live readiness blocked read model / LiveBlockedEvidence deterministic snapshot。
- Validation matrix anchor。
- Automation readiness anchor。
- PR evidence 和 `bash checks/run.sh` 摘要。

这些 evidence 是 non-executable blocked evidence，不代表实盘 readiness 已满足，不代表后续 issue 可自动进入 `Todo`。

## Forbidden capabilities

以下能力在 MTP-61 中必须保持禁止：

- API key。
- secret storage。
- signed endpoint。
- account endpoint。
- listenKey user data stream。
- broker / exchange execution adapter。
- real order submit / cancel / replace。
- execution report。
- broker fill。
- order reconciliation。
- real order lifecycle implementation。
- real account state。
- broker position sync。
- OMS。
- `LiveExecutionAdapter`。
- live monitoring console。
- live execution control。
- live risk control。
- live audit / incident replay / stop controls。
- live order button、risk control command、position management command。

## Validation contract

MTP-61 必须满足：

- `bash checks/run.sh` 通过。
- `checks/automation-readiness.sh` 必须检查本文档和 `TVM-LIVE-TRADING-FOUNDATION` 锚点。
- `docs/validation/trading-validation-matrix.md` 必须能定位 Live trading foundation taxonomy 和 gate。
- `docs/validation/validation-plan.md` 必须说明 MTP-61 只做 taxonomy / gate / contract / blocked evidence。
- PR evidence 必须确认没有 API key、secret storage、signed endpoint、account endpoint、listenKey、broker、real order、OMS 或 `LiveExecutionAdapter` 实现。

MTP-62 必须满足：

- `bash checks/run.sh` 通过。
- `checks/automation-readiness.sh` 必须检查 `MTP-62-CREDENTIAL-ENDPOINT-BOUNDARY`、`MTP-62-LIVE-CREDENTIAL-FUTURE-GATES` 和 `MTP-62-PUBLIC-READ-ONLY-SEPARATION`。
- `Tests/CoreTests/CoreTests.swift` 必须覆盖 `LiveTradingCredentialEndpointBoundary` deterministic fixture、Codable 禁区和 API key / secret / signed / account / listenKey bypass rejection。
- `Tests/AdaptersTests/AdaptersTests.swift` 必须覆盖 public read-only adapter 拒绝 API key、signature、account endpoint 和 listenKey contract。
- PR evidence 必须确认没有环境变量、配置项、Keychain 读取、secret 文件读取、签名 helper、account endpoint 调用或 listenKey user data stream。

MTP-63 必须满足：

- `bash checks/run.sh` 通过。
- `checks/automation-readiness.sh` 必须检查 `MTP-63-ADAPTER-CAPABILITY-ISOLATION`、`MTP-63-LIVE-ADAPTER-FUTURE-GATES`、`MTP-63-BROKER-EXCHANGE-FUTURE-ONLY` 和 `MTP-63-LIVEEXECUTIONADAPTER-NON-IMPLEMENTATION`。
- `Tests/CoreTests/CoreTests.swift` 必须覆盖 `LiveAdapterCapabilityIsolationBoundary` deterministic fixture、Codable 禁区、`LiveExecutionAdapter` non-implementation、broker / exchange adapter instantiation rejection 和 real order bypass rejection。
- `Tests/AdaptersTests/AdaptersTests.swift` 必须覆盖 public read-only adapter 拒绝 broker、LiveExecutionAdapter、submit、cancel 和 replace contract。
- PR evidence 必须确认没有 `LiveExecutionAdapter` 实现、broker / exchange execution adapter、execution venue connection、real order submit / cancel / replace、signed endpoint、account endpoint、listenKey 或真实订单行为。

MTP-64 必须满足：

- `bash checks/run.sh` 通过。
- `checks/automation-readiness.sh` 必须检查 `MTP-64-REAL-ORDER-LIFECYCLE-TERMINOLOGY`、`MTP-64-REAL-ORDER-LIFECYCLE-FUTURE-GATES`、`MTP-64-PAPER-REAL-LIFECYCLE-ISOLATION` 和 `MTP-64-FORBIDDEN-CAPABILITY-TESTS`。
- `Tests/CoreTests/CoreTests.swift` 必须覆盖 `RealOrderLifecycleBoundary` deterministic fixture、Codable 禁区、submit / cancel / replace / execution report / broker fill / reconciliation / OMS bypass rejection，以及 paper order / simulated fill / paper portfolio 不可升级为 real order / broker fill / account state。
- `Tests/AdaptersTests/AdaptersTests.swift` 必须覆盖 public read-only adapter 拒绝 execution report、broker fill、reconciliation、OMS、real account state 和 broker position sync contract。
- PR evidence 必须确认没有 real order state machine、submit / cancel / replace、execution report、broker fill、reconciliation、OMS、真实账户状态、broker position sync 或 paper-to-real lifecycle upgrade。

MTP-65 必须满足：

- `bash checks/run.sh` 通过。
- `checks/automation-readiness.sh` 必须检查 `MTP-65-LIVE-READINESS-BLOCKED-READ-MODEL`、`MTP-65-LIVE-BLOCKED-EVIDENCE-GATES`、`MTP-65-READ-MODEL-ONLY-NON-COMMAND` 和 `MTP-65-SCHEMA-ADAPTER-RUNTIME-NON-EXPOSURE`。
- `Tests/CoreTests/CoreTests.swift` 必须覆盖 `LiveReadiness` deterministic fixture、`LiveBlockedEvidence` deterministic evidence、Codable round trip、blocked capability list drift rejection、command surface rejection、schema / adapter / runtime non-exposure、API key / signed / account / listenKey / broker / real order lifecycle bypass rejection。
- PR evidence 必须确认没有 live command、交易按钮、API key、secret storage、signed endpoint、account endpoint、listenKey、broker adapter、Runtime object / persistence schema 暴露、真实订单生命周期或任何真实交易授权。
