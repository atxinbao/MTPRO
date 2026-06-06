# L4 Execution Report / Broker Fill Parser Contract

日期：2026-06-07  
执行者：Codex

## Scope

`GH-460-EXECUTION-REPORT-BROKER-FILL-PARSER` 固定 `MTPRO L4 Live Production / Trading Commands v1`
第 09/21 个 GitHub fallback queue item 的 sandbox report parser 输出路径。

本合同只实现本地 deterministic sandbox execution report / broker fill parser、replayable parsed event 和 audit
evidence。它不解析 production raw payload，不把 raw payload 传入 Dashboard，不生成真实 broker fill fact，
不推进 OMS state transition，不执行 reconciliation，也不授权 production trading。

## GH-460 Execution Report / Broker Fill Parser

`GH-460-EXECUTION-REPORT-BROKER-FILL-PARSER` 的 canonical Swift evidence 位于：

- `Sources/ExecutionClient/FutureGate/L4ExecutionClientSandboxReportParser.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift`

`L4ExecutionClientSandboxReportParser` 只读取 GH-460 的 sandbox fixture，并依赖 GH-459
`L4ExecutionClientSandboxCommandEvidence` 作为 upstream gate。Parser 只输出 normalized parsed event，不保存或暴露
exchange 原始 JSON、HTTP header、signature、secret、account payload、broker payload 或 production endpoint。

## GH-460 Sandbox Report Kind Coverage

`GH-460-SANDBOX-REPORT-KIND-COVERAGE` 固定 parser 必须覆盖：

- fill
- partial fill
- reject
- cancel acknowledgement

这些 kind 只代表 sandbox fixture 被解析后的 evidence taxonomy，不代表真实 exchange execution report 或真实 broker fill。

## GH-460 Replayable Audit Evidence

`GH-460-REPLAYABLE-AUDIT-EVIDENCE` 固定：

- parsed events 必须按 replay sequence `1,2,3,4` 输出。
- 每个 parsed event 必须带 report identity、client order identity、trace / digest identity、status 和 normalized quantity。
- Replay evidence 必须证明 event audit evidence attached。
- Replay evidence 不写 EventLog，不推进 OMS，不更新 Portfolio，不执行 reconciliation。

## GH-460 Raw Payload Dashboard Block

`GH-460-RAW-PAYLOAD-DASHBOARD-BLOCK` 固定：

- Dashboard 只能消费 normalized evidence / digest identity，不能读取 raw payload。
- Raw account payload、raw private payload、raw broker payload、Runtime object、Adapter request、schema 或 production endpoint
  都不得作为 Dashboard input。
- 当前 issue 不创建 Live PRO Console，不创建 order form，不暴露 trading button 或 live command。

## GH-460 Production Parser Disabled

`GH-460-PRODUCTION-PARSER-DISABLED` 固定：

- production raw payload source 必须被拒绝。
- production parser 默认关闭。
- GH-471 前不得通过配置、fixture、UI 或 hidden flag 打开 production cutover。
- 任何 production execution report、broker fill 或 real order lifecycle 解释都不属于本 issue scope。

## Forbidden Capabilities

当前 issue 继续禁止：

- production raw payload interpreted
- raw payload sent to Dashboard
- broker gateway touched
- real broker fill recorded
- real execution report ingested
- OMS state transition produced
- reconciliation produced
- Live command surface touched
- production trading enabled by default

## Validation

`TVM-L4-EXECUTION-REPORT-BROKER-FILL-PARSER` 对应验证：

- `testGH460ExecutionClientSandboxReportParserProducesReplayableAuditEvidence`
- `testGH460ExecutionClientSandboxReportParserRejectsProductionRawPayloadAndDashboardBypass`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Non-authorization

`GH-460-NON-AUTHORIZATION`：本合同不授权 GH-461 OMS order lifecycle，不授权 GH-463
ExecutionEngine -> ExecutionClient wiring，不授权 GH-466 reconciliation，不授权 GH-471 production cutover。合并本 issue
后，`ExecutionClient` 仍不是 production broker gateway，parser 仍不能解释 production raw payload。
