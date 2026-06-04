# MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration v1 Stage Audit Input

日期：2026-06-04

执行者：Codex

本文档服务 `MTP-232 Close validation matrix / compatibility envelope / stage audit input`。它只准备 `MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration v1` 的 stage closeout input material，供后续 Parent Codex Project Closure / final Stage Code Audit Report 使用。

本文档不是最终 Stage Code Audit Report，不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进下一阶段 Todo，不启动 `@002 / PAR`、Symphony 或 `symphony-issue`，不运行 Graphify / code-index，不修改 Figma。

## MTP-232-TARGETGRAPH-STAGE-CLOSEOUT

本阶段覆盖 `MTP-224` 至 `MTP-232`。阶段目标是把 `Sources/TargetGraph` 从 active compile anchor 迁出并退休 active path references，同时把 active target roots 固定到真实 module roots。

当前 closeout state：

- `Sources/TargetGraph/` directory 不再存在。
- `Package.swift` 不再包含 active `path: "Sources/TargetGraph..."` target path。
- Active target roots 固定为 `Sources/DomainModel`、`Sources/MessageBus`、`Sources/Database`、`Sources/DataClient`、`Sources/Cache`、`Sources/DataEngine`、`Sources/Trader/Strategies/EMA`、`Sources/Trader`、`Sources/Portfolio`、`Sources/RiskEngine`、`Sources/ExecutionClient`、`Sources/ExecutionEngine`、`Sources/Workbench` 和 `Sources/Dashboard`。
- 历史 `Sources/TargetGraph/<Module>` 文字只能作为 before-state / retired evidence 保留，不得描述 current compiler owner、final module root、feature landing path、runtime owner 或 L4 capability source。

## MTP-232-ISSUE-PR-EVIDENCE-CHAIN

| Issue | PR | Required check | Merge commit | Linear Done evidence |
| --- | --- | --- | --- | --- |
| `MTP-224` | [PR #363](https://github.com/atxinbao/MTPRO/pull/363) | `checks` SUCCESS, completed at `2026-06-04T12:08:55Z` | `fdf65a5d057ac1b2d57df36d4ec45d5e0b3e0113` | Done / completed at `2026-06-04T12:09:26.294Z` |
| `MTP-225` | [PR #364](https://github.com/atxinbao/MTPRO/pull/364) | `checks` SUCCESS, completed at `2026-06-04T12:34:34Z` | `55614d2b111a584084b204de4c75e9b8c51a5bdb` | Done / completed at `2026-06-04T12:35:09.140Z` |
| `MTP-226` | [PR #365](https://github.com/atxinbao/MTPRO/pull/365) | `checks` SUCCESS, completed at `2026-06-04T13:02:07Z` | `9bdc146cd7a9d0c2d9e01a93dd6dc084a767d74a` | Done / completed at `2026-06-04T13:02:39.732Z` |
| `MTP-227` | [PR #366](https://github.com/atxinbao/MTPRO/pull/366) | `checks` SUCCESS, completed at `2026-06-04T13:23:40Z` | `24cba30035ed9e77b571833271af77c48062fb3a` | Done / completed at `2026-06-04T13:24:11.960Z` |
| `MTP-228` | [PR #367](https://github.com/atxinbao/MTPRO/pull/367) | `checks` SUCCESS, completed at `2026-06-04T13:47:18Z` | `9d42f1b6d68f097be9ca8baeb894d2605c17ddf9` | Done / completed at `2026-06-04T13:47:59.420Z` |
| `MTP-229` | [PR #368](https://github.com/atxinbao/MTPRO/pull/368) | `checks` SUCCESS, completed at `2026-06-04T14:08:49Z` | `9e1876f549d4eb043b6161dfe34f3e9a8c8a1f33` | Done / completed at `2026-06-04T14:09:34.897Z` |
| `MTP-230` | [PR #369](https://github.com/atxinbao/MTPRO/pull/369) | `checks` SUCCESS, completed at `2026-06-04T14:36:11Z` | `a05e9d0c189d13e71e0d9fd2bcbed0d4f0ef03f4` | Done / completed at `2026-06-04T14:36:37.406Z` |
| `MTP-231` | [PR #370](https://github.com/atxinbao/MTPRO/pull/370) | `checks` SUCCESS, completed at `2026-06-04T14:58:17Z` | `6932dd862ec5669d7ab48c654fedfa8ec9b594ee` | Done / completed at `2026-06-04T14:58:37.697Z` |

Post-issue ledger evidence exists under `.codex/post-issue-ledger/mtp-224.json` through `.codex/post-issue-ledger/mtp-231.json` and is intentionally not submitted in PR.

## MTP-232-VALIDATION-MATRIX-CLOSEOUT

`TVM-TARGETGRAPH-ANCHOR-RETIREMENT-REAL-MODULE-SOURCE-ROOT-MIGRATION` now covers:

- MTP-224 contract definition.
- MTP-225 TargetGraph / real root / Package / tests audit.
- MTP-226 foundation target real-root migration.
- MTP-227 data target real-root migration.
- MTP-228 Trader / Portfolio / Risk target real-root migration.
- MTP-229 execution future gate target real-root migration.
- MTP-230 Workbench / Dashboard target real-root migration.
- MTP-231 final active `Sources/TargetGraph` path reference retirement.
- MTP-232 stage audit input material and closeout readiness.

The matrix remains validation evidence only. It does not authorize runtime, live trading, broker gateway, OMS, signed endpoint, account endpoint, private WebSocket runtime, real order lifecycle, Live PRO Console, trading button, live command, order form or L4 capability.

## MTP-232-COMPATIBILITY-ENVELOPE-CLOSEOUT

Retained compatibility envelopes remain intentional:

- `Core` continues compiling retained implementation source for domain, message bus, cache, data replay / quality, Trader Accounts / EMA / Coordination, Portfolio, RiskEngine, ExecutionClient future gate and ExecutionEngine paper / simulated evidence.
- `Adapters` continues compiling Binance public read-only market data implementation.
- `Persistence` continues compiling projection implementation.
- `Runtime` continues compiling retained ingest / replay implementation.
- `App` remains a compatibility re-export of `Workbench`.

MTP-232 does not delete retained compatibility implementation and does not introduce new module layout.

## MTP-232-AUTOMATION-READINESS-CLOSEOUT

Automation readiness now mechanically checks:

- `Sources/TargetGraph` path is absent.
- `Package.swift` has no active `Sources/TargetGraph` path.
- MTP-226 through MTP-231 target migration tests and docs anchors are present.
- Stage closeout input exists and includes no final Stage Code Audit / no Project Completed mutation / no next Project / Issue / no next Todo boundaries.
- No Symphony, no Graphify, no code-index, no Figma.
- No `.codex/*`, `.build/*` or `graphify-out/*` PR submission.

## MTP-232-FORBIDDEN-IMPLEMENTATION-AUDIT

This closeout did not implement:

- Strategy runtime, Trader runtime or Live runtime.
- ExecutionClient implementation, OMS implementation or broker gateway.
- Signed endpoint, account endpoint / listenKey or private WebSocket runtime.
- Account snapshot runtime, real account read or real order lifecycle.
- Submit / cancel / replace, execution report, broker fill or reconciliation.
- Live PRO Console, trading button, live command, order form or L4 capability.

## MTP-232-STAGE-CODE-AUDIT-HANDOFF

Parent Codex Project Closure / final Stage Code Audit must still separately confirm:

- Linear Project status is `Completed/type=completed` with non-empty `completedAt`.
- MTP-224 through MTP-232 are Done / completed.
- PR / required check / merge evidence is complete through terminal issue MTP-232.
- root `main` has fast-forwarded to the terminal merge commit.
- Post-issue ledger evidence exists for all issues.
- Final Stage Code Audit Report is written under `docs/audit/`.
- Root Docs Refresh Gate only syncs already-occurred facts and does not create the next Project / Issue or promote a next Todo.

## MTP-232-STAGE-CLOSEOUT-VALIDATION

MTP-232 validation must pass:

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

The required PR evidence must confirm no Symphony / Graphify / code-index / Figma, no `.codex/*` / `.build/*` / `graphify-out/*`, no final Stage Code Audit Report, no Project `Completed` mutation and no next Project / Issue / Todo promotion.
