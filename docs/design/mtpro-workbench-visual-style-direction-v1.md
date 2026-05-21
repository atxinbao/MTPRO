# MTPRO Workbench Visual Style Direction v1

日期：2026-05-22

执行者：Codex（`@000 / AIE`，基于 `@004 / DSG` Figma 输出和 `@005 / ARC` 复审结论落仓）

## 1. 文档定位

本文档是 `MTPRO Workbench Visual Style Direction v1` 的 Visual Style Direction Reference / 视觉方向设计依据。

它承接：

- `docs/product/mtpro-workbench-user-flow-blueprint-v1.md`
- `docs/product/mtpro-product-interaction-model-v1.md`
- `docs/design/mtpro-workbench-screen-layout-v1.md`
- `docs/design/mtpro-workbench-ui-ux-design-rules-v1.md`
- `docs/design/mtpro-workbench-component-layout-specification-v1.md`
- `docs/product/product-surface-map.md`

它用于记录 macOS native 专业交易工作台的视觉方向、色彩语义、typography hierarchy、density、核心组件视觉样例和关键页面视觉样例。

它不是最终高保真 UI，不是组件库，不是 SwiftUI 实现稿，不创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 `@002 / PAR`，不启动 Symphony，不运行 Graphify update，不授权 Future Live trading execution scope，不授权业务代码开发。

Figma canonical：

- File URL：`https://www.figma.com/design/0MkTyZXHmfBaZ2K9fqddCm/MTPRO-Professional-Trading-Workbench-Blueprint?node-id=64-2`
- File key：`0MkTyZXHmfBaZ2K9fqddCm`
- 主节点：`64:2`
- 标题：`MTPRO Workbench Visual Style Direction v1`

## 2. Key Node List

| Node ID | 内容 |
| --- | --- |
| `64:2` | `MTPRO Workbench Visual Style Direction v1` |
| `64:4` | Visual Direction 总览 |
| `64:47` | 视觉定位 / macOS native professional workstation |
| `64:95` | 色彩语义 |
| `64:398` | Paper 视觉样例 |
| `64:460` | Live Monitoring 视觉样例 |
| `64:523` | Future Gated 视觉样例 |
| `64:567` | `@005 ARC Review Checklist` |

## 3. Visual Direction Summary

MTPRO Workbench 的视觉方向是 macOS native professional workstation。

核心原则：

- evidence-first：视觉重心是证据、状态、source、trace 和 timeline route，不是交易按钮。
- compact / dense but readable：界面可以紧凑，但必须保持中文状态、metadata、trace id 和 evidence row 可读。
- restrained visual language：克制、专业、低装饰，不做营销式 hero、装饰插画或 Web SaaS dashboard 风格。
- macOS native：保留 split view、sidebar、inspector、timeline preview 和工具型密度语义。
- 中文优先：页面标题、状态标签、原因说明和禁止动作默认中文；英文作为技术别名。
- boundary visible：read-model-only、Future Gated、blocked、degraded、error 和 no authorization 必须在视觉上可见。

## 4. Color Semantics

色彩只表达状态语义，不单独承担判断。所有状态必须同时配合中文标签、原因和 source。

| 色彩语义 | 用途 | 约束 |
| --- | --- | --- |
| neutral surface | macOS 工作台底色、主区、inspector、table surface | 不做大面积单色主题，不掩盖 evidence density |
| evidence emphasis | source link、trace route、active evidence、selected row | 只强调证据导航，不暗示执行授权 |
| healthy | evidence chain 可用 | healthy 不等于 live trading 可执行 |
| stale | freshness / projection / report / monitoring evidence 过期 | 必须显示 stale reason 和 source |
| blocked | gate、risk blocker、forbidden capability | 必须显示 blocked reason，不提供绕过动作 |
| degraded | 局部异常、延迟或一致性风险 | 必须显示 degraded scope，不表达已恢复 |
| error | evidence 生成或读取失败 | 必须进入 Events / Audit 或 source route，不提供 retry live |
| Future Gated | 未来门禁区、planning / boundary placeholder | 必须写明不是执行授权 |
| read-model-only | 已完成但只读的证据面，例如 Live Monitoring | 必须明确不代表 runtime control、broker stream 或 command surface |

## 5. Typography Hierarchy

| 层级 | 用途 | 规则 |
| --- | --- | --- |
| page title | 页面标题和工作区身份 | 清楚但克制，不使用 hero-scale type |
| section title | evidence 区、inspector 区、timeline 区 | 支持快速扫描，避免长段说明 |
| evidence row title | batch、signal、run、artifact、session、gate、monitoring evidence | 与 status、source、reason 同屏可读 |
| metadata / trace id | id、sequence、source、updatedAt、validation anchor | 等宽或紧凑风格，不能抢占主判断 |
| status label | empty / healthy / stale / blocked / degraded / error | 短标签，稳定尺寸，配合原因和 source |
| warning / blocked copy | 禁区、blocked reason、Future Gated 说明 | 中文优先，表达边界，不写成行动号召 |

## 6. Density Summary

| 密度区域 | 方向 |
| --- | --- |
| sidebar density | 支持高频工作区切换，分区清楚，避免营销导航样式 |
| top status density | 承载当前状态、latest evidence 和 summary，不放重型操作 |
| evidence table density | 支持多列扫描、source、trace、status、reason，不因长文本造成跳动 |
| inspector density | 放置详细原因、source anchor、related evidence 和 validation anchor |
| timeline preview density | 展示 stream、sequence、source evidence 和状态变化，保持只读预览 |

## 7. Core Component Visual Samples

Figma `64:*` 的 visual style direction 为以下组件提供视觉样例方向：

| Component | 视觉样例要求 |
| --- | --- |
| evidence row | 行内包含 title、status、source、reason / trace route，选中后进入 inspector |
| evidence card | 用于 Overview、blocked reason、monitoring summary 和 Future placeholder 的概览表达 |
| evidence table | 用于高密度 evidence 列表，必须支持状态标签、source 和 trace |
| status label | 使用状态色 + 中文标签 + 原因，不单靠颜色判断 |
| blocked reason panel | 展示 gate、blocked reason、source doc 和禁止动作说明 |
| detail inspector section | 展示 source / reason / trace / related evidence / validation anchor |
| timeline preview row | 展示 stream、sequence、event summary、source evidence route |
| Future Gated placeholder | 显示 planning / boundary placeholder、blocked 和不是执行授权 |

## 8. Key Page Visual Samples

| 页面样例 | 视觉方向 | 边界 |
| --- | --- | --- |
| Overview | 总览 latest evidence、状态、next route 和 timeline preview | 不出现交易按钮，不授权 live capability |
| Paper | Paper evidence table 优先，本地 session controls 弱于 evidence navigation | 只允许开始 / 暂停 / 关闭 / 重置，不出现订单级控制 |
| Live Monitoring | Complete / read-model-only evidence surface，展示 health / connection / stream / latency / error / degraded evidence | 不出现 reconnect、start live、stop live 或 broker stream control |
| Future Gated | planning / boundary placeholder、blocked、source doc、非授权说明 | 不出现可执行入口，不暗示 Future gate 已打开 |

`runtime health: blocked` 这类文案是 read-model evidence label，用于表达 `LiveMonitoring` read model 中的只读证据状态，不是底层 Runtime object，不代表当前有真实 runtime control，也不授权连接 broker、private stream 或 live command。

## 9. `@005 / ARC` Review Result

`@005 / ARC` 已只读复审 Figma canonical `64:2 / 64:4` 的 `MTPRO Workbench Visual Style Direction v1`。

审查结论：通过。

问题分级：

| 级别 | 结论 |
| --- | --- |
| P0 | 未发现 |
| P1 | 未发现 |
| P2 | 未发现阻断项 |

复审确认：

- `64:4` 明确标注 Visual Direction，不是最终 UI、不是 SwiftUI implementation、不授权 Linear execution、不新增真实交易入口。
- `64:47` 符合 macOS native professional workstation：split view、sidebar、inspector、timeline preview，且明确不是 Web SaaS dashboard。
- `64:95` 色彩语义围绕 evidence、状态、read-model-only、Future Gated；状态色必须配合中文标签、原因和 source。
- `64:398` Paper 样例只保留本地 session 控制：开始 / 暂停 / 关闭 / 重置，且视觉权重低于 evidence table。
- `64:460` Live Monitoring 保持 Complete / read-model-only evidence surface，只展示 health / connection / stream / latency / error / degraded evidence。
- `64:523` Future Gated 只表达 planning / boundary placeholder、blocked、source doc、非授权说明。
- `64:567` 复审清单覆盖设计阶段边界、数据消费边界、Paper、Live Monitoring、Future Gated 和禁用入口检查。

## 10. Forbidden UI Surface Review Result

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

## 11. Maintenance Boundary

本文档是设计层视觉方向依据，可作为后续最终高保真 UI、组件库、SwiftUI implementation planning 的输入。

它不替代：

- `BLUEPRINT.md` 的 Root / Complete Blueprint 地位。
- `docs/product/mtpro-workbench-user-flow-blueprint-v1.md` 的产品用户动线依据。
- `docs/product/mtpro-product-interaction-model-v1.md` 的产品交互模型。
- `docs/design/mtpro-workbench-screen-layout-v1.md` 的 screen layout 依据。
- `docs/design/mtpro-workbench-ui-ux-design-rules-v1.md` 的 UI/UX rules 依据。
- `docs/design/mtpro-workbench-component-layout-specification-v1.md` 的组件 / 布局规格依据。
- `docs/architecture.md` 的 Engineering Module Map。
- Linear issue body 的 execution contract。

后续如果要进入最终 UI、高保真实现、SwiftUI 实现、业务代码开发、Future Live trading 或 Linear execution，必须先通过 Human + `@001 / PLN` 形成 Project / Issue draft，并由 Linear live-read、Parent Codex queue preflight 和唯一 configured executable issue 授权。
