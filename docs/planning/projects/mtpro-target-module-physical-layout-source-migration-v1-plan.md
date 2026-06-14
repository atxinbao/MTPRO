# MTPRO Target Module Physical Layout / Source Migration v1

日期：2026-05-31

执行者：Codex

类型：Project Planning Record / non-executable

## 文档定位

本文档只保存 `MTPRO Target Module Physical Layout / Source Migration v1` 的 planning 摘要。它不授权移动 `Sources` 文件，不授权修改 `Package.swift` target graph，不创建 Linear Project / Issue，不推进 Todo。

## Project Summary

| 字段 | 内容 |
| --- | --- |
| Project name | `MTPRO Target Module Physical Layout / Source Migration v1` |
| Target maturity | `Target Module Physical Layout / Source Migration before L4` |
| Goal | 规划 target module physical layout、source migration order、SwiftPM target strategy、compatibility shell、import boundary 和 validation evidence |

## Target Layout Contract

| Module family | Target path |
| --- | --- |
| Domain Model | `Sources/DomainModel/` |
| Message Bus | `Sources/MessageBus/` |
| Cache | `Sources/Cache/` |
| Database | `Sources/Database/` |
| Data Client | `Sources/DataClient/<venue>/` |
| Data Engine | `Sources/DataEngine/` |
| Strategies | `Sources/Strategies/<strategy>/` as historical planning wording; later corrected to Trader-owned layout |
| Trader | `Sources/Trader/` |
| Portfolio | `Sources/Portfolio/` |
| Risk Engine | `Sources/RiskEngine/` |
| Execution Engine | `Sources/ExecutionEngine/` |
| Execution Client | `Sources/ExecutionClient/` |
| Dashboard | `Sources/Dashboard/` |

## Milestones

| Milestone | 摘要 |
| --- | --- |
| M1 Migration Contract / Package Target Strategy | 固定 physical layout、source migration guard、compatibility envelope strategy |
| M2 Domain / Message / Cache / Database | 规划基础模块 source root |
| M3 DataClient / DataEngine | 规划 venue-scoped data client 与 data engine source root |
| M4 Strategy / Trader / Portfolio | 规划策略、账户、组合上下文；后续已修正为 Trader-owned strategies |
| M5 Risk / Execution / ExecutionClient | 规划 future-gated execution / risk source roots |
| M6 Dashboard / Workbench | 规划 read-model-only UI source root |
| M7 Compatibility Envelope | 规划 retained compatibility shell |
| M8 Validation Matrix / Stage Audit Input | 收口 validation 和 stage audit input |

## Validation Requirements

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- source path / target graph checks required by issue contract

## Final Boundary

本文档是 planning evidence。它不授权 source move、`Package.swift` target graph change、business code、L4 implementation、ExecutionClient implementation、OMS implementation、Live PRO Console、trading command 或 production trading。
