# Release v0.21.0 Binance Spot Controlled Canary Operator Runbook

日期：2026-07-03

执行者：Codex

## Purpose

本文档是 #1284 / V0210-012 的 operator runbook。它把 #1273..#1283 已完成的 v0.21.0 Binance Spot controlled production canary evidence 压成操作顺序、停止条件、rollback 流程和审计证据清单。本文档只定义 operator 如何执行和证明 canary procedure；它不新增 runtime capability，不创建 tag / GitHub Release，不授权 production cutover。

## Anchors

- `GH-1284-VERIFY-V0210-CANARY-OPERATOR-RUNBOOK`
- `TVM-RELEASE-V0210-CANARY-OPERATOR-RUNBOOK`
- `V0210-012-CANARY-OPERATOR-RUNBOOK`
- `V0210-012-START-OBSERVE-CANCEL-ROLLBACK`
- `V0210-012-INCIDENT-STOP-CONDITIONS`
- `V0210-012-EVIDENCE-COLLECTION`
- `V0210-012-NO-PRODUCTION-CUTOVER`
- `V0210-012-NO-TAG-OR-RELEASE-PUBLICATION`

## Preconditions

- #1273..#1283 均 closed / done。
- Operator 已确认 v0.21.0 仍是 Binance Spot only controlled canary；Futures / OKX 不在本 runbook scope。
- Operator 已确认 production trading 默认关闭：`productionTradingEnabledByDefault=false`。
- Operator 已确认 production cutover 仍未授权：`productionCutoverAuthorized=false`。
- Operator 已确认 kill switch、no-trade gate、RiskEngine pre-trade gate、symbol allowlist、notional cap、quantity cap、order type limit 和 order count window 均已通过本地 evidence 验证。
- 所有 credential evidence 只允许使用 redacted credential reference / approval evidence；raw API key、secret、signature input、raw order id、raw broker payload 和 raw account payload 不进入仓库、Dashboard、CLI 输出、PR 或 release docs。

## Operator Start Procedure

1. 从最新 `main` 或当前 #1284 PR branch 开始，确认 open PR / active issue 符合 WIP=1。
2. 运行 `git diff --check` 和 `bash checks/automation-readiness.sh`，确认 runbook anchors、boundary anchors 和 verifier wiring 均存在。
3. 运行 GH-1273..GH-1283 的 focused v0.21.0 verifiers，确认 controlled canary contract、environment profile、credential approval、signed-account preflight、snapshot redaction、hard limits、pre-trade gate、controlled submit evidence、cancel rollback guard、OMS reconciliation 和 read-only status surface 均为 ready。
4. 在 Human operator approval evidence 存在时，按 GH-1280 生成单笔 controlled submit request evidence；该 evidence 必须保持 redacted，并且必须绑定 idempotency key、audit event、`BTCUSDT`、`LIMIT`、`10.00 USDT` notional cap 和 `0.00100000 BTC` quantity cap。
5. 使用 `mtpro canary-status status` 只读观察 canary state、gate stack、risk decision、order lifecycle、cancel / rollback 和 reconciliation summary。

## Observe Procedure

Operator 观察期间只允许读取 evidence：

```bash
swift run mtpro canary-status status
swift run mtpro canary-status events
swift run mtpro canary-status reconciliation
```

Expected read-only evidence includes:

- `dashboardReadOnly=true`
- `cliReadOnly=true`
- `tradingButtonVisible=false`
- `orderFormVisible=false`
- `liveCommandVisible=false`
- `submitCancelReplaceEnabled=false`
- `productionEndpointConnected=false`
- `brokerEndpointConnected=false`
- `rawOrderIDVisible=false`
- `rawBrokerPayloadVisible=false`
- `realOrderSent=false`
- `productionCutoverAuthorized=false`
- `boundaryHeld=true`

## Cancel Procedure

1. 仅在 explicit cancel approval evidence 存在时，按 GH-1281 生成 single canary order scope 的 redacted cancel request evidence。
2. 运行 `swift run mtpro canary-status events`，确认 cancel request、cancel outcome 和 rollback guard 都进入 event rows。
3. 运行 `swift run mtpro canary-status reconciliation`，确认 reconciliation evidence 能重构同一笔 canary lifecycle。
4. 若缺少 cancel approval、redacted canary order reference、audit event、status rollback guard 或 single canary order scope，流程必须 fail closed，不生成 cancel request evidence。

## Rollback Procedure

Rollback 的目标是回到 no-trade / no-cutover state，而不是扩大交易能力：

1. 设置或确认 kill switch blocked。
2. 设置或确认 no-trade gate blocked。
3. 停止任何后续 submit evidence generation。
4. 保留已生成的 redacted lifecycle event rows、cancel outcome、rollback guard 和 reconciliation evidence。
5. 记录 rollback reason、operator id reference、timestamp reference、evidence checksum reference 和 post-rollback canary status。
6. 再次运行 `mtpro canary-status status`，确认 `productionCutoverAuthorized=false`、`realOrderSent=false`、`submitCancelReplaceEnabled=false` 和 `boundaryHeld=true`。

## Incident Stop Conditions

出现以下任一情况，operator 必须立即停止流程，进入 rollback / evidence collection：

- 缺少 Human operator approval evidence。
- 缺少 credential secret-read approval reference 或该 reference 未 redacted。
- risk gate、kill switch、no-trade gate、hard-limit gate 任一未通过。
- symbol、notional、quantity、order type 或 order count window 不符合 GH-1278 hard limits。
- status surface 暴露 raw order id、raw broker payload、raw account payload、secret value、signature input 或 endpoint response。
- Dashboard 出现 trading button、order form、live command、submit / cancel / replace control。
- CLI 尝试提供 `submit`、`cancel`、`replace` 等 command path，而不是 read-only `status`、`events`、`reconciliation`。
- workflow 尝试连接 production endpoint / broker endpoint，或把 runbook 解释成 production cutover approval。

## Evidence Collection

每次 canary rehearsal / operation 必须收集以下 redacted evidence：

- GH-1273 controlled canary contract evidence。
- GH-1274 productionLive environment profile evidence。
- GH-1275 credential secret-read approval redacted evidence。
- GH-1276 signed account read-only preflight redacted status evidence。
- GH-1277 live account snapshot redaction / freshness evidence。
- GH-1278 hard-limit pass / reject evidence。
- GH-1279 RiskEngine / kill switch / no-trade gate audit evidence。
- GH-1280 controlled submit request evidence。
- GH-1281 controlled cancel / rollback evidence。
- GH-1282 OMS event log / reconciliation evidence。
- GH-1283 Dashboard / CLI read-only status output.
- #1284 runbook verifier output：`bash checks/verify-v0.21.0-canary-operator-runbook.sh`。

## Closeout Validation

```bash
git diff --check
bash checks/verify-v0.21.0-canary-operator-runbook.sh
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Non-Authorization

#1284 不创建下一 Project / Issue，不推进下一 Todo，不启动 Linear / Symphony / Graphify / code-index / Figma，不创建 tag / GitHub Release，不授权 production cutover，不默认启用 production trading，不读取 production secret value，不连接 production endpoint / broker endpoint，不新增 submit / cancel / replace runtime，不暴露 trading button、order form 或 live command。
