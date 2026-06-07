# L4 Audit Trail / Incident Replay Contract

日期：2026-06-07  
执行者：Codex

## Scope

`GH-467-AUDIT-TRAIL-INCIDENT-REPLAY` 固定 `MTPRO L4 Live Production / Trading Commands v1`
第 16/21 个 GitHub fallback queue item 的 command audit trail 和 incident replay evidence。

本合同只实现 deterministic local evidence：它消费 GH-463 sandbox command path evidence 和 GH-466 reconciliation
evidence，把 command intent、risk decision、execution request、broker report、OMS transition 和 reconciliation
outcome 写成 append-only audit entries，并从这些 entries 生成 deterministic incident replay。它不实现 production
incident ops，不上传外部审计系统，不读取真实 broker replay，不捕获 secret 或 raw broker payload，也不暴露 Live
command surface。

## GH-467 Command Evidence Trace

`GH-467-COMMAND-EVIDENCE-TRACE` 固定每条 command evidence 必须可追踪：

- command intent：来自 GH-463 RiskEngine-approved command proposal。
- risk decision：来自 GH-463 risk decision identity。
- execution request：来自 GH-459 sandbox request envelope / response identity。
- broker report：来自 GH-460 normalized sandbox broker report event。
- OMS transition：来自 GH-462 local OMS transition record。
- reconciliation outcome：来自 GH-466 reconciliation record 和 matched / mismatched / stale / missing status。

Trace 不包含 secret、API key、signature、raw broker payload、account endpoint payload 或真实 broker statement。

## GH-467 Append-only Audit Trail

`GH-467-APPEND-ONLY-AUDIT-TRAIL` 固定 audit trail entry sequence 必须从 1 开始连续递增，且 entry 创建后不可变。
本地 evidence 可以用 deterministic digest 证明 replay 输入稳定，但不写入外部审计系统、不上传日志、不创建 production
audit runtime。

## GH-467 Deterministic Incident Replay

`GH-467-DETERMINISTIC-INCIDENT-REPLAY` 固定 incident replay 只能消费本地 append-only audit entries，并输出 sandbox
lifecycle replay evidence。Replay 必须覆盖 submit / cancel / replace command kinds、所有 audit stages，以及 GH-466 的
matched / mismatched / stale / missing reconciliation statuses。

Replay 不读取 production broker report，不调用 broker gateway，不执行 repair，不产生真实订单命令。

## GH-467 No Secret / Raw Payload

`GH-467-NO-SECRET-RAW-PAYLOAD` 固定 audit trail 和 replay input/output 不能包含：

- API key、secret、signature。
- raw broker payload。
- account endpoint payload。
- listenKey 或 private stream payload。
- production broker replay payload。

如果上述任一能力被打开，GH-467 evidence 必须拒绝构造。

## Validation

`TVM-L4-AUDIT-TRAIL-INCIDENT-REPLAY` 对应验证：

- `testGH467AuditTrailIncidentReplayBuildsAppendOnlyReplayEvidence`
- `testGH467AuditTrailIncidentReplayRejectsExternalAuditRawPayloadAndReplayBypass`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Non-authorization

`GH-467-NON-AUTHORIZATION`：本合同不授权 GH-468 Dashboard / Live PRO Console read-only-to-command split，
不授权 GH-469 guarded submit / cancel / replace UI，不授权 GH-470 sandbox validation matrix closure，不授权
GH-471 production cutover。合并本 issue 后，MTPRO 仍没有 production incident ops、external audit upload、
production broker replay、real broker gateway、Live PRO Console command surface、order form、trading button 或 real
submit / cancel / replace。
