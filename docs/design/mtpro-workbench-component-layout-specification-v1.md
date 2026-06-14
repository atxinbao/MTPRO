# MTPRO Workbench Component / Layout Specification v1

日期：2026-05-20

执行者：Codex

## 1. 文档定位

本文压缩保存 Workbench component / layout specification。它只定义布局原语、evidence components、state components、partition components 和 forbidden UI surface，不授权 Figma 修改、SwiftUI 实现、Live PRO Console、trading button 或 live command。

## 2. Component Specification

| Component family | 用途 | 边界 |
| --- | --- | --- |
| Layout Primitives | sidebar、toolbar、split view、detail pane、inspector、timeline | 不嵌套装饰 card，不挤压状态文本 |
| Evidence Components | source anchor、sequence、freshness、checksum、validation badge | 只展示 evidence，不触发 runtime |
| State Components | ready、running、stale、degraded、failed、blocked、paper-only、read-model-only | blocked 不能伪装成可执行 disabled button |
| Partition Components | Research、Backtest、Paper、Report、Portfolio、Risk、Events 分区 | 页面只消费 ViewModel / Read Model |
| Paper Local Session Controls | 本地 paper session 状态、run / stop / replay evidence | 不升级为 real submit / cancel / replace |
| Live Monitoring Read-only Evidence | health、connection、latency、error、blocked gate | 不连接 endpoint，不执行 command |
| Future Gated Placeholder | 显示 gate、缺失证据、required approval | 不显示 production CTA |

## 3. Sizing / Density Tokens

- 工作台优先使用紧凑密度、固定 toolbar 高度、可扫描表格和 timeline。
- 状态标签、证据 ID、时间戳和校验信息必须能在窄宽度下换行或截断。
- 控制按钮必须用明确 icon / label，不使用含糊营销式 CTA。

## 4. Mapping

本文承接 `mtpro-workbench-ui-ux-design-rules-v1.md` 与 screen layout v1。所有 component 都必须坚持 read-model-only / evidence-first：UI 不直接读取 adapter、runtime object、database schema、broker state 或 account payload。

## 5. Maintenance Boundary

本文是设计规格摘要，不是实现任务。实现必须由当前 issue contract 授权，并通过 validation / readiness guard。
