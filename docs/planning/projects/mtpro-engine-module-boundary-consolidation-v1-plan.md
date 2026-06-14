# MTPRO Engine Module Boundary Consolidation v1

日期：2026-05-30

执行者：Codex

类型：Project Planning Record / non-executable

## 文档定位

本文档只保存 `MTPRO Engine Module Boundary Consolidation v1` 的 Project 级计划摘要。它不创建 Linear Project / Issue，不修改 Linear status，不推进 Todo，不启动 `@002 / PAR`，不写业务代码。

## Project Summary

| 字段 | 内容 |
| --- | --- |
| Project name | `MTPRO Engine Module Boundary Consolidation v1` |
| Target maturity | `Architecture Boundary Consolidation before L4` |
| Goal | Define architecture-graph-aligned module boundary terminology，并把 Engine / Layer 边界、依赖方向、future gates 和 L4 handoff 输入固定到文档与验证 |
| Target engines | DomainModel、MessageBus、Cache、Database、DataClient、DataEngine、Trader、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Dashboard / Workbench surface |

## Scope / Non-goals

| Scope | Non-goals |
| --- | --- |
| 固定 module boundary terminology、allowed source、forbidden dependency、future gate 和 validation anchors | 不修改 `Package.swift` target graph，不移动 `Sources` |
| 明确 MessageBus / Cache / Database spine、DataClient / DataEngine、Trader / Portfolio / Risk / Execution / Dashboard 边界 | 不实现 Strategy runtime、Trader runtime、Live runtime |
| 输出 L4 planning input material | 不实现 ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint、private stream、real order、Live PRO Console 或 trading command |

## Acceptance Criteria

Project-level acceptance criteria：

- `architecture.md`、`docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/latest-verification-summary.md` 对齐。
- 每个 module boundary 有明确 owner、allowed input、forbidden dependency 和 future gate。
- L4 readiness 只作为 planning input，不授权 execution。

Milestone acceptance criteria：

- M1 Architecture Boundary Contract。
- M2 MessageBus / Cache / Database Spine。
- M3 DataClient / DataEngine Boundary。
- M4 Strategies / Trader / Account / Portfolio Context。
- M5 RiskEngine / ExecutionEngine / ExecutionClient Future Gate。
- M6 Workbench Surface / L4 Handoff。

Issue acceptance criteria：

- 每个 issue body 必须包含 Goal / Scope / Non-goals / Codex Instructions / Validation / Boundary / PR Requirements / Dependencies / Acceptance Criteria。
- 每个 issue 必须保留 forbidden capability audit。
- 每个 issue 完成后必须有 PR / checks / merge / Linear Done / post-issue ledger evidence。

## Suggested Issue Order

1. Define architecture-graph-aligned module boundary terminology。
2. Define MessageBus / Cache / Database spine boundaries。
3. Define DataClient / DataEngine boundaries。
4. Define Strategy / Trader / Account / Portfolio context boundaries。
5. Define RiskEngine / ExecutionEngine / ExecutionClient future gates。
6. Close Workbench surface / L4 handoff evidence。

## Validation Requirements

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- targeted architecture / module-boundary tests required by issue contract

## Queue Boundary

- WIP=1。
- First executable issue candidate 只能由 Parent Codex queue preflight 确认。
- Planning record 不授权执行。
- ExecutionClient implementation、OMS implementation、Live runtime、broker gateway、trading command 仍禁止。
