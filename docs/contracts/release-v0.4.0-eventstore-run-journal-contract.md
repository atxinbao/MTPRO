# Release v0.4.0 Event Store Run Journal Contract

日期：2026-06-13
执行者：Codex

## Scope

`V040-10-EVENTSTORE-RUN-JOURNAL`

GH-703 在 `Database` target 内定义 append-only Event Store run journal。该 journal 只消费 v0.4.0 unified evidence envelope identity，按同一个 runID 写入 DataEngine、Trader、RiskEngine、ExecutionEngine、OMS、ExecutionClient adapter 和 projection-ready 事件，并提供 deterministic replay state。

## Required Evidence

- `V040-10-APPEND-ONLY-RUN-EVENTS`：records 必须按 Event Store 自身 sequence 追加，previousChecksum 必须串联。
- `V040-10-RUNID-CORRELATION-CAUSATION-REPLAY`：replay 必须重建单一 runID、correlationID 和 causation trail。
- `V040-10-DASHBOARD-CLI-PROJECTION-REPLAY`：replay state 必须能作为后续 Dashboard / CLI projection 输入。
- `V040-10-NO-PRODUCTION-EVENTSTORE-CUTOVER`：production Event Store runtime、production endpoint、secret、order、cutover、mutable rewrite 和 raw broker payload 必须保持 false。
- `TVM-RELEASE-V040-EVENTSTORE-RUN-JOURNAL`：trading validation matrix anchor。

## Boundary

GH-703 不连接 production broker，不读取 secret，不写 production Event Store，不暴露 raw database schema 给 Dashboard，不授权 trading execution，不实现 Dashboard / CLI surface，不启动 #704 之后的能力。Production cutover 仍由后续单独 gate 管理。

## Validation

- `swift test --filter TargetGraphTests/testGH703EventStoreRunJournalAppendsAndReplaysOneRunIDChain`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
