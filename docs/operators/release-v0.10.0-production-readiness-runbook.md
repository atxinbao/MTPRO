# MTPRO Release v0.10.0 Production Readiness Runbook

日期：2026-06-18

执行者：Codex

## GH-889-VERIFY-V0100-INCIDENT-ROLLBACK-RUNBOOK

`TVM-RELEASE-V0100-INCIDENT-ROLLBACK-RUNBOOK`

`V0100-012-INCIDENT-ROLLBACK-READINESS-RUNBOOK`

`V0100-012-PRODUCTION-READINESS-RUNBOOK-MD`

`V0100-012-INCIDENT-ROLLBACK-READINESS-JSON`

`V0100-012-INCIDENT-CLASSIFICATION`

`V0100-012-STOP-PROCEDURE`

`V0100-012-ROLLBACK-PROCEDURE`

`V0100-012-OPERATOR-CHAIN`

`V0100-012-EVIDENCE-EXPORT`

`V0100-012-POST-INCIDENT-AUDIT`

`V0100-012-KILL-SWITCH-CHECKLIST`

`V0100-012-NO-TRADE-CHECKLIST`

`V0100-012-PRODUCTION-CAPABILITIES-DISABLED`

本文档是 `MTPRO Release v0.10.0 Production Cutover Readiness Gate` 的生产事件与回滚就绪 runbook。它只定义人工事件分类、停止、回滚、证据导出、事后审计、kill switch checklist 和 no-trade checklist。它不授权 production cutover，不读取 production secret，不连接 production endpoint 或 broker endpoint，不提交、取消或替换 testnet 或 production 订单。

## Scope

| 项 | GH-889 reference-only fact |
| --- | --- |
| issue | `GH-889 / V0100-012` |
| upstream | `GH-888 CutoverApprovalWorkflow` |
| runbook file | `docs/operators/release-v0.10.0-production-readiness-runbook.md` |
| evidence artifact | `incident_rollback_readiness.json` |
| runbook checksum | `runbookChecksum=sha256:` |
| evidence checksum | `evidenceChecksum=sha256:` |
| incident classification | `incidentClassificationCovered=true` |
| stop procedure | `stopProcedureCovered=true` |
| rollback procedure | `rollbackProcedureCovered=true` |
| operator chain | `operatorChainCovered=true` |
| evidence export | `evidenceExportCovered=true` |
| post-incident audit | `postIncidentAuditCovered=true` |
| kill switch checklist | `killSwitchChecklistCovered=true` |
| no-trade checklist | `noTradeChecklistCovered=true` |
| production cutover | `production_cutover_blocked=true` / `productionCutoverBlocked=true` / `productionCutoverAuthorized=false` |
| order permission | `orderSubmissionEnabled=false` / `productionTradingEnabled=false` |
| secret / order payload | `no_secret_value=true` / `noSecretValue=true` / `no_order_payload=true` / `noOrderPayload=true` |

## V0100-012-INCIDENT-CLASSIFICATION

事件分类只用于人工 review 和 evidence 标注，不触发交易权限。GH-889 固定以下分类：

- monitor anomaly
- credential exposure suspected
- endpoint policy drift
- risk limit breach
- command surface regression
- readiness evidence mismatch

任一分类出现时，operator 必须先保持 `productionCutoverAuthorized=false`、`orderSubmissionEnabled=false` 和 `productionTradingEnabled=false`，然后进入 stop procedure。

## V0100-012-STOP-PROCEDURE

停止流程是人工流程，不是自动 broker command：

1. 标记当前 run 为 incident-review。
2. 确认 kill switch checklist 和 no-trade checklist 仍为 active。
3. 冻结后续 production cutover review，不改变 production readiness bundle。
4. 导出 redacted local evidence，禁止导出 secret value、raw account payload 或 order payload。
5. 在 GitHub issue / PR evidence 中记录 stop reason。

## V0100-012-ROLLBACK-PROCEDURE

回滚流程只允许回滚到上一个已验证的 reference evidence state：

1. 确认没有 production endpoint / broker endpoint 连接输出。
2. 确认没有 testnet 或 production submit / cancel / replace。
3. 选定上一个通过 `bash checks/run.sh` 的 main commit 作为 rollback reference。
4. 记录 rollback candidate、evidence checksum 和人工 operator review。
5. 回滚结论只能解除 incident review，不得授权 production cutover。

## V0100-012-OPERATOR-CHAIN

operator chain 必须至少包含：

- primary operator：确认事件分类和 stop reason。
- reviewer：确认 rollback candidate 和 redacted evidence。
- risk reviewer：确认 capital / exposure / no-trade 边界仍有效。
- release owner：确认是否继续当前 readiness queue。

该 chain 只产生人工审计 evidence，不产生 live command 或 order form。

## V0100-012-EVIDENCE-EXPORT

导出 evidence 必须满足：

- `incident_rollback_readiness.json` exists。
- `no_secret_value=true`。
- `no_order_payload=true`。
- redacted run ID、issue ID、commit SHA、validation command 和 checksum 可见。
- raw credential、raw listenKey、raw account response、broker response 和 order payload 不得出现。

## V0100-012-POST-INCIDENT-AUDIT

post-incident audit 必须回答：

- 事件分类是否准确。
- stop procedure 是否执行。
- rollback procedure 是否需要。
- kill switch checklist 是否保持 active。
- no-trade checklist 是否保持 active。
- evidence export 是否 redacted。
- 是否需要新的 planning issue。该判断不在 GH-889 内创建下一 issue。

## V0100-012-KILL-SWITCH-CHECKLIST

- [ ] kill switch state remains active。
- [ ] cutover remains blocked if kill switch is active。
- [ ] command surface remains disabled。
- [ ] Dashboard 只显示 read-model evidence。
- [ ] CLI 只输出 local evidence。

## V0100-012-NO-TRADE-CHECKLIST

- [ ] no-trade state remains active。
- [ ] submit / cancel / replace remains disabled。
- [ ] production OMS runtime remains disabled。
- [ ] trading button、order form 和 live command 不可见也不可用。
- [ ] production trading remains disabled by default。

## V0100-012-PRODUCTION-CAPABILITIES-DISABLED

GH-889 结束后仍必须保持：

- `productionCutoverAuthorized=false`
- `orderSubmissionEnabled=false`
- `productionTradingEnabled=false`
- `productionEndpointConnectionEnabled=false`
- `productionBrokerConnectionEnabled=false`
- `productionSecretValueRead=false`
- `testnetOrderSubmissionEnabled=false`
- `productionOrderSubmissionEnabled=false`
- `orderPayloadCreated=false`
- `brokerCommandCreated=false`
- `productionOMSRuntimeEnabled=false`
- `tradingButtonVisible=false`
- `orderFormVisible=false`
- `liveCommandEnabled=false`

该 runbook 只证明 incident / rollback readiness 已有人工操作路径和 deterministic evidence anchor。它不是 production cutover，不是 broker enablement，不是 OMS runtime，也不是真实交易授权。
