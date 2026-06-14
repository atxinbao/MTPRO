# MTPRO Workbench User Dashboard Content Model v1

日期：2026-05-20

执行者：Codex

## 1. 文档定位

本文定义 Workbench Dashboard 面向用户的内容模型。它只决定主屏展示什么、如何排序、哪些内容进入 inspector / timeline，不授权 Figma 修改、SwiftUI 实现、Live PRO Console 或交易命令。

## 2. 用户面板原则

- 首屏回答“系统现在能不能被信任”。
- 先展示 release / readiness / blocked boundary，再展示细节。
- Report / Events / Validation evidence 是用户判断的主线。
- Paper / guarded runtime evidence 不能被解释成 production trading authorization。

## 3. Overview Content Model

| 内容层 | 展示 |
| --- | --- |
| 首屏主判断 | release status、production disabled、latest validation、blocked gates |
| 主状态 | ready / running / stale / degraded / failed / blocked |
| 默认卡片 | data health、strategy evidence、risk state、execution state、portfolio projection、event integrity |
| 次级信息 | run id、source anchor、freshness、checksum、latest PR / release evidence |
| Drill-down | Report artifact、Event Timeline、validation output、operator runbook |
| 移出主屏 | raw payload、schema、adapter request、runtime object、broker/account state |

## 4. 页面内容模型

| Page | 主要内容 |
| --- | --- |
| Overview | current evidence health and blocked production boundary |
| Research | strategy input and data coverage |
| Backtest | deterministic run and result summary |
| Paper | paper-only session and simulated evidence |
| Report | artifact center and causal chain |
| Portfolio | projection and exposure |
| Risk | allow / reject evidence and limit context |
| Events | timeline, replay integrity and projection freshness |

## 5. Figma / High-Fidelity Input

保留工作台密度、清晰分区和 evidence-first 信息层级；降级装饰性图表、raw technical details 和未来能力 CTA；将用户可读 summary、blocked boundary、latest validation 和 report artifact 放到更高优先级。

## 6. 非授权边界

本文不授权 trading button、live command、order form、secret input、broker connect、production endpoint、real order、Live PRO Console 或 SwiftUI implementation。
