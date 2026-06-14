# Product Surface Map

日期：2026-06-14

执行者：Codex

本文档定义 MTPRO 产品面入口。它只说明用户能看到什么、哪些 surface 已完成、哪些命令或实盘能力仍禁止；详细设计、验证和 Stage Audit evidence 分别进入 `docs/design/`、`docs/validation/` 和 `docs/audit/`。

## 产品定位

MTPRO 第一版是 local-first macOS Trader Workstation Dashboard，用于观察 Research -> Backtest -> Report -> Paper -> Risk -> Portfolio -> Events 的 evidence chain。

UI 以 evidence navigation 为中心，不以交易按钮为中心。当前 release v0.5.0 只允许 Binance、Spot + USDⓈ-M Perpetual、EMA + RSI、dry-run / testnet-guarded / production-blocked boundary；production trading 默认关闭。

## 当前信息架构

| 区域 | 用户问题 | 当前边界 |
| --- | --- | --- |
| Market | 当前 market / replay evidence 是否可用 | 只读 DataClient / DataEngine evidence |
| Strategy | EMA / RSI signal 和 proposal 从哪里来 | Trader-owned strategy read model |
| Backtest | 回测、成本、parity 是否可追溯 | deterministic evidence |
| Report | 当前 evidence chain 是否闭合 | report artifact / summary |
| Paper | paper session / simulated lifecycle 是否一致 | paper-only / dry-run |
| Risk | 为什么允许、拒绝或阻断 | RiskEngine evidence |
| Portfolio | projection 和 exposure 是否一致 | read-model / projection |
| Events | 事实链和 replay 是否可审计 | append-only evidence |
| Live / Commands | 为什么不能实盘 | blocked / gated evidence |

## 禁止项

- 不提供默认可用的 live order button、trading button、order form 或 production command。
- 不连接真实 broker，不读取 production secret，不连接 production endpoint。
- 不提交、撤销或替换真实订单。
- 不让 UI 直接消费 database schema、ORM model、runtime object、adapter request 或 raw broker payload。

## 已完成产品面锚点

| 阶段 | 当前结论 |
| --- | --- |
| MTP-22..MTP-29 | macOS Dashboard shell、Report、Risk / Portfolio、trading validation evidence 已完成。 |
| MTP-36 / MTP-44 | Paper Session runtime evidence 和 Paper execution workflow evidence 已进入 Report / Dashboard read model。 |
| MTP-47..MTP-52 | Paper workflow Workbench 信息架构、session-level local controls、Event Boundary、observability、Event Timeline / Evidence Explorer 子集、Dashboard / Workbench shell 增量扩展已完成。 |
| MTP-54..MTP-59 | Market Data Replay Operations、metadata / batch replay、retention / freshness、fixture parity、event log / projection consistency、Report / Dashboard / Event Timeline evidence 已完成。 |
| MTP-66 / MTP-68 / MTP-72 / MTP-73 / MTP-80 | Live blocked / monitoring / execution-control evidence surface 已完成；只表达 read-model-only 或 blocked evidence。 |
| MTP-78 | Paper / real command isolation 已完成；paper session controls 不能升级为 order-level command。 |

Machine guard anchors:

- MTP-47 Paper workflow Workbench 信息架构和控制壳边界
- MTP-48 Paper session 本地控制 Command Model
- MTP-49 Paper session 本地控制 Event Boundary
- MTP-52 Dashboard / Workbench shell 增量扩展
- MTP-55 Market Data Replay Metadata / Batch Replay Contract
- MTP-56 Market Data Replay Retention / Freshness Evidence
- MTP-57 Market Data Replay Fixture Parity / Replay Consistency
- MTP-58 Market Data Replay Event Log / Projection Consistency
- MTP-59 Market Data Replay Report / Dashboard / Event Timeline Evidence
- MTP-66 Live blocked evidence Dashboard / Report / Event Timeline 展示面
- MTP-72 Dashboard / Report live monitoring evidence 区块
- MTP-73 Event Timeline live monitoring evidence preview

## 设计和产品文档索引

| 文档 | 作用 |
| --- | --- |
| `docs/product/mtpro-workbench-user-flow-blueprint-v1.md` | Workbench 用户动线 |
| `docs/product/mtpro-product-interaction-model-v1.md` | 页面能看、能判断、能点、不能点什么 |
| `docs/product/mtpro-workbench-user-dashboard-content-model-v1.md` | Dashboard 内容优先级 |
| `docs/product/mtpro-product-surface-split-v1.md` | Workbench 与 Future Live PRO Console 分界 |
| `docs/design/mtpro-workbench-screen-layout-v1.md` | 页面区域和布局 |
| `docs/design/mtpro-workbench-ui-ux-design-rules-v1.md` | UI/UX 规则 |
| `docs/design/mtpro-workbench-component-layout-specification-v1.md` | 组件和布局规格 |
| `docs/design/mtpro-workbench-visual-style-direction-v1.md` | 视觉方向 |
| `docs/design/mtpro-workbench-user-facing-dashboard-high-fidelity-v2.md` | Figma `85:2` Dashboard v2 evidence |
| `docs/design/mtpro-workbench-user-facing-dashboard-high-fidelity-v3.md` | Figma `91:2` Dashboard v3 evidence |

## Surface 分界

Workbench 当前只展示 read-model / ViewModel / evidence surface。Future Live PRO Console 是独立 future product surface，必须经 Human + `@001 / PLN` planning、live queue 写入、Parent Codex queue preflight 和 issue contract 后才能进入 execution。

当前文档不创建 Linear Project / Issue，不推进 Todo，不授权 Live PRO Console、production command、broker gateway、signed endpoint、account endpoint / listenKey、real order lifecycle、OMS、real broker 或 production trading。
