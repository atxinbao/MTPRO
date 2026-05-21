# MTPRO Workbench Component / Layout Specification v1

日期：2026-05-22

执行者：Codex（`@000 / AIE`，基于 `@004 / DSG` Figma 输出和 `@005 / ARC` 审查结论落仓）

## 1. 文档定位

本文档是 `MTPRO Workbench Component / Layout Specification v1` 的 Component / Layout Specification Reference / 组件与布局规格依据。

它承接：

- `docs/product/mtpro-workbench-user-flow-blueprint-v1.md`
- `docs/product/mtpro-product-interaction-model-v1.md`
- `docs/design/mtpro-workbench-screen-layout-v1.md`
- `docs/design/mtpro-workbench-ui-ux-design-rules-v1.md`
- `docs/product/product-surface-map.md`

它用于记录 macOS native 工作台的 layout primitives、evidence components、state components、partition components、Paper 本地 session controls、Live Monitoring read-only evidence components、Future Gated placeholder 和 sizing / spacing / density tokens。

它不是高保真最终视觉稿，不是 SwiftUI 实现稿，不创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 `@002 / PAR`，不启动 Symphony，不运行 Graphify update，不授权 Future Live trading execution scope，不授权业务代码开发。

Figma canonical：

- File URL：`https://www.figma.com/design/0MkTyZXHmfBaZ2K9fqddCm/MTPRO-Professional-Trading-Workbench-Blueprint?node-id=57-2`
- File key：`0MkTyZXHmfBaZ2K9fqddCm`
- 主节点：`57:2`
- 标题：`MTPRO Workbench Component / Layout Specification v1`

## 2. Canonical Frame List

| Node ID | Frame |
| --- | --- |
| `57:2` | `MTPRO Workbench Component / Layout Specification v1` |
| `57:3` | `规格总览（Specification Overview）` |
| `57:41` | `Layout Primitives 规格` |
| `57:80` | `Evidence Components 规格` |
| `57:129` | `State Components 规格` |
| `57:169` | `Partition Components 规格` |
| `57:197` | `Paper Local Session Controls 规格` |
| `57:221` | `Live Monitoring Read-only Evidence 规格` |
| `57:261` | `Future Gated Placeholder 规格` |
| `57:281` | `Sizing / Spacing / Density Tokens` |
| `57:313` | `@005 ARC Review Checklist` |
| `60:2` | 补充可见标签：`evidence table` |

## 3. Specification Summary

### 3.1 Layout Primitives

| Primitive | 用途 | 边界 |
| --- | --- | --- |
| Sidebar | 承载工作区导航和三态分区入口 | 不放 trading button、broker connect、API key 输入或 live command |
| Top status | 展示当前状态、session summary、latest evidence、blocked / degraded / error 摘要 | 不触发 runtime start、reconnect、stop live 或 broker action |
| Main evidence workspace | 承载主要 evidence rows、cards、tables 和页面判断内容 | 只展示 ViewModel / Read Model 内容，不暴露 schema 或底层对象 |
| Detail inspector | 展示选中 evidence 的 source、reason、trace、status、related links | 不读取 Runtime、Adapter、SQLite / DuckDB schema、exchange payload 或 broker object |
| Events / Audit preview | 展示页面相关 timeline preview、source sequence 和 evidence route | 不提供事件编辑、完整查询语言、replay command 或 incident command |
| Future placeholder area | 展示 future gate、blocked reason、planning / boundary placeholder 和 source docs | 不授权 execution，不创建规划或施工入口，不提供 live command |

### 3.2 Evidence Components

| Component | 用途 | 必须包含 |
| --- | --- | --- |
| evidence row | 列表中呈现 batch、signal、run、artifact、session、gate、monitoring evidence | status、source、reason 或 trace route |
| evidence card | 首屏 summary、状态概览、blocked reason 和 next route | 判断目标、状态、source anchor |
| evidence table | 可比较的 evidence 集合，例如 replay、portfolio、risk、timeline preview | 稳定列、状态、trace id 或 source link |
| source link | 跳转相关页面、timeline 或文档 anchor | 只读导航，不触发外部写能力 |
| blocked reason panel | 解释 gate、boundary、blocked capability 和下一步可查看证据 | blocked reason、source doc、禁止动作说明 |
| inspector section | detail inspector 内的分组信息 | source / reason / trace / validation anchor |
| timeline preview row | 当前页面关联的事件预览 | stream、sequence、source evidence route |

### 3.3 State Components

| State | 规格含义 | 交互边界 |
| --- | --- | --- |
| `empty` | 暂无 evidence 或 artifact | 可跳转上游页面，不伪造数据，不触发 runtime |
| `healthy` | evidence chain 可用 | 可查看详情和下游 evidence；healthy 不等于执行授权 |
| `stale` | freshness、projection、report 或 monitoring evidence 已过期 | 可查看 stale reason 和 source route，不提供绕过动作 |
| `blocked` | capability、gate 或 risk blocker 阻断 | 可查看 blocked reason、source anchor 和 docs，不启用 future capability |
| `degraded` | 仍可观察但存在局部异常或一致性风险 | 可查看 degraded scope 和 evidence route，不表达已恢复或可执行 |
| `error` | evidence 生成或读取失败 | 可进入 Events / Audit，不提供 retry live、reconnect 或交易动作 |

### 3.4 Partition Components

| Partition | 规格含义 | 视觉 / 交互规则 |
| --- | --- | --- |
| Current completed | 已完成基础工作台能力 | 可以展示 evidence、状态、详情和页面导航；不表示真实交易授权 |
| Completed read-model-only evidence surface | 已完成但只读的证据面，例如 Live Monitoring | 必须标注 read-model-only，不提供 runtime control、broker stream 或 live command |
| Future Gated | 未来门禁区 | 只表达 planning / boundary placeholder、blocked reason 和 source doc；不是执行授权 |

### 3.5 Paper Local Session Controls

Paper 本地 session controls 只允许：

- `start`
- `pause`
- `close`
- `reset`

规格约束：

- 视觉权重必须弱于 evidence navigation。
- 控制文案必须是本地 Paper session 语义。
- 控制区必须靠近 Paper session summary 和 paper-only boundary。
- 控制不能升级为 order-level command、broker action 或 real order lifecycle。

### 3.6 Live Monitoring Read-only Evidence Components

Live Monitoring 只表达 Complete / read-model-only evidence surface。

允许组件：

- health evidence
- connection evidence
- stream evidence
- latency evidence
- error evidence
- degraded evidence

规格约束：

- 不表达外部运行时控制。
- 不画真实 broker stream、private WebSocket、account stream 或 real order stream runtime。
- stream / order event 只能表达 blocked / simulated / future evidence。
- 所有 evidence 必须能跳转 Events / Audit 或 Live Readiness source anchor。

### 3.7 Future Gated Placeholder

Future Gated placeholder 只表达：

- planning / boundary placeholder。
- 不是执行授权。
- 不创建规划或施工入口。
- blocked reason。
- source doc / architecture link。
- 当前禁止能力说明。

不得表达：

- start planning。
- create issue。
- begin build。
- connect broker。
- start live。
- submit / cancel / replace。
- emergency stop / restore live。

### 3.8 Sizing / Spacing / Density Tokens

`57:281` 固定 sizing / spacing / density 的设计意图：

- 工作台密度应服务高频扫描，不做营销式大留白。
- Sidebar、Top status、Main evidence workspace、Detail inspector 和 Events / Audit preview 需要稳定尺寸，避免状态标签或长中文标题导致布局跳动。
- Evidence row / table 需要支持 trace id、source、status 和 reason 的可扫描呈现。
- 状态标签应短且稳定，详细解释进入 inspector 或 blocked reason panel。
- Future placeholder area 必须有清楚边界，不与 Current completed 组件混淆。

## 4. Mapping to UI/UX Design Rules v1

本规格承接 `docs/design/mtpro-workbench-ui-ux-design-rules-v1.md`：

| UI/UX Rules v1 | Component / Layout Spec v1 |
| --- | --- |
| `51:30` 视觉方向与布局规则 | `57:41` Layout Primitives 规格 |
| `51:65` Typography / Spacing / Density 规则 | `57:281` Sizing / Spacing / Density Tokens |
| `51:100` Evidence Components 规则 | `57:80` Evidence Components 规格 |
| `51:135` 状态标签与错误表达规则 | `57:129` State Components 规格 |
| `51:170` 三态分区视觉规则 | `57:169` Partition Components 规格 |
| `51:205` Paper 本地 Session 控制规则 | `57:197` Paper Local Session Controls 规格 |
| `51:240` Live Monitoring 只读证据面规则 | `57:221` Live Monitoring Read-only Evidence 规格 |
| `51:275` Future Gated Placeholder 规则 | `57:261` Future Gated Placeholder 规格 |
| `51:310` 禁止动作视觉表达规则 | `57:313` `@005 ARC Review Checklist` 和禁止 UI surface 检查 |

## 5. Mapping to Screen Layout v1

本规格承接 `docs/design/mtpro-workbench-screen-layout-v1.md`：

- Layout primitives 对应 Screen Layout v1 的 Sidebar、Top status、Main evidence workspace、Detail inspector、Events / Audit preview 和 Future Gated placeholder area。
- Evidence components 对应 Screen Layout v1 各页面的 evidence row、card、table、source link、timeline preview 和 detail inspector。
- State components 对应所有页面的 `empty` / `healthy` / `stale` / `blocked` / `degraded` / `error` 状态表达。
- Partition components 对应 Current completed、Completed read-model-only evidence surface 和 Future Gated 的页面分区。
- Paper Local Session Controls 对应 Paper 页面本地 `start` / `pause` / `close` / `reset` 控制区。
- Live Monitoring Read-only Evidence 对应 Live Monitoring 页面和 Overview / Report / Events 中的只读监控证据摘要。
- Future Gated Placeholder 对应 Future Gated、Future Live Execution、Future Live Risk、Future Incident Replay / Stop Controls 页面。

## 6. `@005 / ARC` Review Result

`@005 / ARC` 已只读审查 Figma canonical `57:2` 的 `MTPRO Workbench Component / Layout Specification v1`，覆盖 `57:3`、`57:41`、`57:80`、`57:129`、`57:169`、`57:197`、`57:221`、`57:261`、`57:281`、`57:313` 和补充标签 `60:2`。

审查结论：通过。

问题分级：

| 级别 | 结论 |
| --- | --- |
| P0 | 未发现 |
| P1 | 未发现 |
| P2 | 未发现 |

关键确认：

- 该规格仍停留在 Workbench UI Layer。
- 该规格只消费 ViewModel / Read Model / Command Model。
- Layout primitives 只定义 UI 区域，没有 Runtime、Adapter、SQLite / DuckDB schema、exchange payload 或 broker object 直连暗示。
- Evidence components 包含 source link、blocked reason、detail inspector、timeline preview，并明确不触发外部写能力。
- State components 覆盖 `empty` / `healthy` / `stale` / `blocked` / `degraded` / `error`，且 `healthy` 明确不等于执行授权。
- Paper controls 严格限定为本地 session-level `start` / `pause` / `close` / `reset`，视觉弱于 evidence navigation。
- Live Monitoring 保持 Complete / read-model-only evidence surface。
- Future Gated placeholder 只表达 planning / boundary placeholder、blocked reason、source doc 和非授权状态，不创建规划或施工入口。
- `60:2` 只是 `evidence table` 可见标签，无越界语义。

## 7. Forbidden UI Surface Review Result

`@005 / ARC` 确认未发现以下能力被设计为入口、按钮、表单、toolbar、菜单、快捷操作或当前 scope：

| 禁止项 | 检查结果 |
| --- | --- |
| API key / secret storage input | 无 |
| signed endpoint | 无 |
| account endpoint / listenKey | 无 |
| broker adapter / broker action | 无 |
| `LiveExecutionAdapter` | 无 |
| real order state machine / OMS | 无 |
| submit / cancel / replace | 无 |
| broker fill / execution report / reconciliation | 无 |
| real account balance / broker position | 无 |
| trading button / live command / order-level command UI | 无 |
| reconnect / start live / stop live | 无 |

## 8. Maintenance Boundary

本文档是设计层组件 / 布局规格依据，可作为后续高保真视觉设计、macOS native component specification 和 SwiftUI implementation planning 的输入。

它不替代：

- `BLUEPRINT.md` 的 Root / Complete Blueprint 地位。
- `docs/product/mtpro-workbench-user-flow-blueprint-v1.md` 的产品用户动线依据。
- `docs/product/mtpro-product-interaction-model-v1.md` 的产品交互模型。
- `docs/design/mtpro-workbench-screen-layout-v1.md` 的 screen layout 依据。
- `docs/design/mtpro-workbench-ui-ux-design-rules-v1.md` 的 UI/UX rules 依据。
- `docs/architecture.md` 的 Engineering Module Map。
- Linear issue body 的 execution contract。

后续如果要进入 SwiftUI 实现、业务代码开发、Future Live trading 或 Linear execution，必须先通过 Human + `@001 / PLN` 形成 Project / Issue draft，并由 Linear live-read、Parent Codex queue preflight 和唯一 configured executable issue 授权。
