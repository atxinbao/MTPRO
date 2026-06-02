# MTPRO Workbench UI/UX Design Rules v1

日期：2026-05-22

执行者：Codex（`@000 / AIE`，基于 `@004 / DSG` Figma 输出和 `@005 / ARC` 审查结论落仓）

## 1. 文档定位

本文档是 `MTPRO Workbench UI/UX Design Rules v1` 的 UI/UX Design Rules Reference / 设计规则依据。

它承接：

- `docs/product/mtpro-workbench-user-flow-blueprint-v1.md`
- `docs/product/mtpro-product-interaction-model-v1.md`
- `docs/design/mtpro-workbench-screen-layout-v1.md`
- `docs/product/product-surface-map.md`

它用于记录 macOS native professional trading workstation 的 UI/UX 设计规则：视觉方向、布局密度、状态表达、evidence components、Paper 本地控制、Live Monitoring 只读证据面、Future Gated placeholder 和禁止动作视觉表达。

它不是高保真最终视觉稿，不是组件规范，不是 SwiftUI 实现稿，不创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 `@002 / PAR`，不启动 Symphony，不运行 Graphify update，不授权任何 Future Live trading execution scope。

Figma canonical：

- File URL：`https://www.figma.com/design/0MkTyZXHmfBaZ2K9fqddCm/MTPRO-Professional-Trading-Workbench-Blueprint?node-id=51-2`
- File key：`0MkTyZXHmfBaZ2K9fqddCm`
- 主节点：`51:2`
- 标题：`MTPRO Workbench UI/UX Design Rules v1`

## 2. Canonical Frame List

| Node ID | Frame |
| --- | --- |
| `51:2` | `MTPRO Workbench UI/UX Design Rules v1` |
| `51:3` | `UI/UX 规则总览（Rules Overview）` |
| `51:30` | `视觉方向与布局规则（Visual Direction / Layout）` |
| `51:65` | `Typography / Spacing / Density 规则` |
| `51:100` | `Evidence Components 规则` |
| `51:135` | `状态标签与错误表达规则（Status Labels）` |
| `51:170` | `三态分区视觉规则（Current / Completed / Future）` |
| `51:205` | `Paper 本地 Session 控制规则` |
| `51:240` | `Live Monitoring 只读证据面规则` |
| `51:275` | `Future Gated Placeholder 规则` |
| `51:310` | `禁止动作视觉表达规则` |
| `51:345` | `Screen Layout v1 映射与 @005 审查重点` |

## 3. macOS Native Workstation Design Direction

MTPRO Workbench 应保持 macOS native workstation 语义：克制、紧凑、可扫描、以 split-view、sidebar、inspector 和 timeline preview 组织信息。

设计方向：

- Evidence navigation 优先：row、card、table、source link、inspector 和 timeline 是主交互。
- 专业工具密度：页面应支持高频检查和反复追溯，不做营销式 hero、装饰卡片堆叠或大面积说明页。
- 中文优先：页面标题、状态、边界说明、空状态和错误状态默认中文；英文只作为技术别名。
- 状态可解释：任何 `stale`、`blocked`、`degraded`、`error` 都必须有原因、source anchor 和下一步 evidence route。
- 边界可见：read-model-only、Future Gated、planning / boundary placeholder 必须在视觉上清楚区分。
- 控制克制：Paper 本地 session control 必须弱于 evidence navigation；Future live capability 不得表现为可点击控制面。

## 4. Unified Layout Rules

| 区域 | UI/UX 规则 | 禁止边界 |
| --- | --- | --- |
| Sidebar / 主导航 | 承载 Overview、Market Replay、Research、Backtest、Report、Paper、Portfolio、Risk、Events / Audit、Live Readiness、Live Monitoring、Future Gated 等工作区入口 | 不放 trading button、broker connect、API key 输入或 live command |
| Top status / session summary | 展示当前状态、latest evidence、Paper session summary、monitoring summary 或 blocked gate summary | 不触发 runtime start、reconnect、stop live 或 broker action |
| Main evidence workspace | 使用 evidence row / card / table 承载主要判断内容 | 不展示 SQLite / DuckDB schema、adapter request、exchange payload 或 broker object |
| Detail inspector | 展示选中 evidence 的 source、reason、trace、status、related links | 不暴露底层 Runtime object、database table、ORM model 或 broker state |
| Events / Audit preview | 展示当前页面的 timeline preview、source evidence link 和 projection freshness | 不提供事件编辑、完整查询语言、命令执行或 incident command |
| Future placeholder area | 展示 future gate、blocked reason、planning / boundary placeholder 和 source docs | 不授权 execution，不创建 planning / construction 入口，不提供 live command |

## 5. Typography / Spacing / Density Rules

- Typography：工作台内使用紧凑层级，页面标题清楚但不使用 hero-scale type；状态、source anchor、evidence id 和 detail labels 应可扫描。
- Spacing：采用稳定网格和固定区域，避免 hover、状态标签、长中文标题或 evidence id 改变布局尺寸。
- Density：主工作区允许更高信息密度，但必须通过分组标题、状态标签、表格列和 detail inspector 保持可读。
- Labels：状态标签短句优先，解释文本放到 inspector 或 detail row，避免把长说明塞进按钮或 pill。
- Language：中文为主，英文别名保留在括号或技术字段中，例如 `实盘监控台 / Live Monitoring`。

## 6. Evidence Components Rules

| Component | 设计规则 | 禁止边界 |
| --- | --- | --- |
| Evidence row | 用于 batch、signal、run、artifact、session、gate、monitoring evidence 等可追溯项 | 不作为 command row，不触发交易动作 |
| Evidence card | 用于首屏 summary、状态概览、blocked reason 和 next route | 不做营销卡片或可执行按钮容器 |
| Evidence table | 用于可比较的 evidence 列表，例如 replay、portfolio、risk、timeline preview | 不暴露 raw schema、SQL、ORM 或 exchange payload |
| Detail inspector | 承载 source、reason、trace id、validation anchor、related evidence | 不读取或展示 Runtime、Adapter、broker object |
| Source link | 跳转相关页面、timeline 或文档 anchor | 不启动外部系统写操作，不创建 issue，不推进 Todo |
| Timeline preview | 展示 append-only events 和 source sequence 的只读摘要 | 不编辑事件，不运行 replay command，不实现 incident replay |

## 7. Status Label Rules

| Status | 视觉 / 文案规则 | 允许交互 | 禁止交互 |
| --- | --- | --- | --- |
| `empty` | 显示暂无 evidence、上游来源和生成条件 | 跳转上游页面或 source doc | 伪造默认数据、触发 runtime |
| `healthy` | 显示 evidence chain 可用、最新状态和 source id | 查看详情、进入下游页面、进入 Events / Audit | 表达交易授权 |
| `stale` | 显示过期原因、updatedAt、freshness source | 查看 stale reason、跳转 Market Replay / Events | 一键绕过 freshness gate |
| `blocked` | 显示 blocked reason、gate、source anchor | 查看 boundary、相关 docs、timeline | 绕过 gate、启用 live capability |
| `degraded` | 显示 degraded scope、影响范围和下一步 evidence route | 查看局部异常和 source evidence | 表达系统已恢复或允许执行 |
| `error` | 显示 error evidence、source、可追溯路径 | 进入 Events / Audit 或相关 source page | 提供 retry live、reconnect、stop live 或交易动作 |

## 8. Three-state Visual Rules

| 分区 | 视觉含义 | 规则 |
| --- | --- | --- |
| Current completed | 已完成基础工作台能力 | 可展示 evidence、状态、详情、source link 和页面间导航；不得暗示真实交易授权 |
| Completed read-model-only evidence surface | 已完成但只能只读展示的证据面，例如 Live Monitoring | 必须标注 read-model-only；不得出现 reconnect、start live、stop live、broker stream control 或 live command |
| Future Gated | 未来门禁区 | 只能作为 planning / boundary placeholder；必须清楚写明不是执行授权，不创建规划或施工入口 |

## 9. Paper Session-level Controls Rules

Paper 页面只允许本地 session-level controls：

- `start`
- `pause`
- `close`
- `reset`

视觉约束：

- 这些控制必须弱于 evidence navigation，不能成为页面主视觉中心。
- 控制文案必须表达本地 Paper session 语义，不得写成订单动作。
- 控制区必须靠近 Paper session summary 和 paper-only boundary 说明。
- 点击路径必须保留 paper-only evidence trail，不得连接 broker、signed endpoint、account endpoint 或 live runtime。

禁止：

- `submit`
- `cancel`
- `replace`
- order form
- broker action
- real order lifecycle
- live command

## 10. Live Monitoring Visual Rules

`Live Monitoring` 已完成，但只是 Complete / read-model-only evidence surface。

允许展示：

- health evidence
- connection evidence
- market stream evidence
- order stream / order event evidence
- latency evidence
- error evidence
- degraded evidence

视觉约束：

- 必须标注 `Complete / read-model-only evidence surface`。
- stream 只能表达 read-model evidence，不画真实外部连接流、账户流或 broker order stream 控制图。
- order stream / order event 只能表达 blocked / simulated / future evidence，不代表真实 order stream runtime。
- 所有异常、延迟和降级都应连接 Events / Audit 或 Live Readiness source anchor。

禁止：

- reconnect
- start live / stop live
- broker stream 操作
- private WebSocket / listenKey 操作
- signed endpoint / account endpoint
- live command
- trading button

## 11. Future Gated Placeholder Rules

Future Live Execution、Future Live Risk、Future Incident Replay / Stop Controls 只能作为 planning / boundary placeholder。

允许：

- 展示缺失 gate。
- 展示 blocked reason。
- 展示 source doc / architecture link。
- 展示当前禁止能力。
- 跳转 Live Readiness、Live Monitoring、Events / Audit 或相关文档。

禁止：

- 提供执行入口。
- 提供交易动作。
- 提供 live control。
- 提供 “start planning” / “create issue” / “begin build” 这类规划或施工入口。
- 暗示 Linear execution 已授权。
- 暗示 Future gate 已打开。

## 12. Forbidden UI Surface Checklist

UI / UX 规则明确禁止出现以下表面：

| 禁止项 | 说明 |
| --- | --- |
| API key / secret storage input | 不出现输入框、设置项、keychain 入口或 secret 文件选择 |
| signed endpoint | 不出现签名请求、签名状态、signed route 或 signed action |
| account endpoint / listenKey | 不出现账户 endpoint、private stream、listenKey 创建或 user data stream 控制 |
| broker adapter / broker action | 不出现 broker connect、venue connect、adapter action 或 execution venue 控制 |
| `LiveExecutionAdapter` | 不出现类名式能力入口、配置项或状态卡 |
| real order state machine / OMS | 不出现真实订单状态机、OMS 工作流、订单生命周期控制面 |
| submit / cancel / replace | 不出现按钮、菜单、快捷键、toolbar item、row action 或灰色诱导按钮 |
| broker fill / execution report / reconciliation | 不出现真实成交回报、broker fill、对账执行面或 reconciliation command |
| real account balance / broker position | 不出现真实账户余额、broker 仓位、margin、leverage 或 account state |
| trading button / live command / order-level command UI | 不出现交易按钮、live command、order-level command、order form 或 position command |

## 13. Screen Layout v1 Mapping

`MTPRO Workbench UI/UX Design Rules v1` 承接 `docs/design/mtpro-workbench-screen-layout-v1.md`：

- `51:3` 和 `51:345` 映射 `40:3` Layout IA Map。
- `51:30`、`51:65` 映射 `40:*` 的 macOS split-view layout、信息密度和页面区域。
- `51:100`、`51:135` 映射所有页面的 evidence row / card / table / inspector / timeline preview 和状态表达。
- `51:170` 映射 Current completed、Completed read-model-only evidence surface 和 Future Gated 的三态分区。
- `51:205` 映射 Paper 页面本地 session-level controls。
- `51:240` 映射 Live Monitoring 的 Complete / read-model-only evidence surface。
- `51:275`、`51:310` 映射 Future Gated placeholder 和禁止动作视觉表达。

后续如果进入高保真视觉稿或组件规范，应继续从 `40:*` screen layout 和 `51:*` UI/UX rules 读取，而不是直接从产品动线图推导实现。

## 14. `@005 / ARC` Review Result

`@005 / ARC` 已只读审查 Figma canonical `51:2` 的 `MTPRO Workbench UI/UX Design Rules v1`，并对照已落仓的 Product Interaction Model、Screen Layout v1、Product Surface Map、`BLUEPRINT.md`、`architecture.md` 和 `docs/validation/latest-verification-summary.md`。

审查结论：通过。

问题分级：

| 级别 | 结论 |
| --- | --- |
| P0 | 未发现 |
| P1 | 未发现 |
| P2 | 未发现 |

关键确认：

- UI 只消费 ViewModel / Read Model / Command Model。
- 不读取 Runtime、Adapter、SQLite / DuckDB schema、exchange payload 或 broker object。
- Paper 本地控制严格限定为 session-level `start` / `pause` / `close` / `reset`。
- Live Monitoring 保持 Complete / read-model-only evidence surface。
- Future Gated 只表达 planning / boundary placeholder，不形成当前执行范围或授权暗示。
- 禁止能力只能作为边界说明出现，不能以按钮、表单、toolbar、菜单或快捷操作呈现。

## 15. Maintenance Boundary

本文档是设计层 UI/UX rules 依据，可作为后续 macOS native component / layout specification、高保真视觉设计和 SwiftUI implementation planning 的输入。

它不替代：

- `BLUEPRINT.md` 的 Root / Complete Blueprint 地位。
- `docs/product/mtpro-workbench-user-flow-blueprint-v1.md` 的产品用户动线依据。
- `docs/product/mtpro-product-interaction-model-v1.md` 的产品交互模型。
- `docs/design/mtpro-workbench-screen-layout-v1.md` 的 screen layout 依据。
- `architecture.md` 的 Engineering Module Map。
- Linear issue body 的 execution contract。

后续如果要进入最终高保真 UI、组件规范或 SwiftUI 实现，必须先通过 Human + `@001 / PLN` 形成 Project / Issue draft，并由 Linear live-read、Parent Codex queue preflight 和唯一 configured executable issue 授权。
