# MTPRO Workbench UI/UX Design Rules v1

日期：2026-05-20

执行者：Codex

## 1. 文档定位

本文定义 MTPRO Workbench 的 UI / UX 规则。它只约束信息架构、状态语言、布局密度、evidence component 和 forbidden UI surface，不修改 Figma，不授权 SwiftUI 实现、Live PRO Console、trading button、live command 或 order form。

## 2. Canonical Frame List

| Frame | 角色 |
| --- | --- |
| Overview | evidence health、release / readiness status、blocked boundary |
| Research | strategy input、data coverage、signal preview |
| Backtest | run lifecycle、input snapshot、result summary |
| Paper | paper-only session、risk blocker、simulated fill evidence |
| Report | artifact index、causal chain、validation evidence |
| Portfolio | projection、position、exposure |
| Risk | allow / reject evidence、limits context |
| Events | event timeline、replay integrity、projection freshness |

## 3. UI / UX Rules

| Rule | 要求 |
| --- | --- |
| macOS Native Workstation | 安静、密集、可扫描，不做 marketing hero 或装饰化大卡片 |
| Unified Layout | sidebar / toolbar / split detail / inspector / timeline 结构保持稳定 |
| Typography / Density | 表格、状态、证据链优先；避免大标题占据工作区 |
| Evidence Components | 每个关键状态必须能追溯 source anchor、sequence、freshness、validation |
| Status Label | 使用 ready、running、stale、degraded、failed、blocked、paper-only、read-model-only |
| Three-state Visual | normal / warning / blocked 必须可区分，blocked 不可伪装成 disabled CTA |
| Paper Controls | paper local control 只展示本地 session / evidence，不变成 live order |
| Live Monitoring | 只读 monitoring evidence，不显示 production control |
| Future Gated Placeholder | future capability 必须显示 gate 和缺失证据，不显示可点击执行按钮 |

## 4. Forbidden UI Surface Checklist

- 不显示 production trading button。
- 不显示 live command。
- 不显示 order form。
- 不显示 secret input as default onboarding path。
- 不显示 broker connect CTA 作为当前能力。
- 不显示 signed/account endpoint 操作。
- 不把 read-model-only blocked evidence 做成可执行 control。

## 5. Maintenance Boundary

本文是设计规则摘要；具体屏幕结构和 component spec 由对应 design docs 承接。任何 UI 实现仍必须由当前 issue scope 明确授权。
