# MTPRO Release v0.15.0 Real Binance Testnet Execution MVP Notes

日期：2026-06-23

执行者：Codex

## Summary

v0.15.0 是 Real Binance Testnet Execution MVP construction closeout。它把 v0.14.x 的 local execution evidence chain 推进到 Binance Spot Testnet signed execution evidence：testnet credential reference、signed request construction、submit、cancel、cancel-replace、append-only network event log、OMS state sync / reconciliation、CLI operator flow、Dashboard read-only execution status 和 failure simulation。

本说明是 #1076 closeout notes。#1076 本身不创建 `v0.15.0` tag，不创建 GitHub Release，不推进下一阶段，不授权 production cutover。后续独立 Release Publication Gate 已发布 `v0.15.0` stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.15.0`，tag peeled commit `1590b6c40e6ca7887cff0ca59b2f74e4fe7e3ece`，publication timestamp `2026-06-23T01:26:30Z`。

v0.15.0 的 execution wording 必须按 #1095 hardening 理解：它提供 signed execution runtime contracts、injected Spot Testnet transport protocol evidence、deterministic mock proof 和 operator manual proof runbook，不表示仓库已经内置 URLSession network runner，也不表示 `mtpro` CLI 默认具备真实联网执行器。具体 concrete URLSession transport 是 v0.15.1 后续 #1096 的独立 hardening slice。

## Completed Queue

- #1066：定义 v0.15.0 contract / v0.14.1 preflight gate，确认 v0.15.0 只进入 Binance Spot Testnet execution MVP。
- #1067：新增 testnet credential reference / signed request builder，输出 redacted HMAC evidence，不执行 network action。
- #1068：新增 real Spot Testnet submit runtime evidence，要求 explicit operator confirmation 和 injected Spot Testnet transport。
- #1071：新增 append-only network execution event log，固定 redacted request / response identity 和 checksum chain。
- #1069：新增 real Spot Testnet cancel runtime evidence，基于 prior submit evidence 和 redacted testnet order identity。
- #1070：新增 Spot Testnet cancel-replace emulation，使用 cancel + new submit，native replace 保持 unsupported / fail-closed。
- #1072：新增 OMS state sync + reconciliation，从 append-only event log 推导 expected / observed state。
- #1073：新增 CLI operator flow，要求显式 testnet confirmation，输出 redacted evidence。
- #1074：新增 Dashboard read-only testnet execution status surface，只消费 local read-model artifacts。
- #1075：新增 failure simulation，覆盖 rejected request、timeout、rate-limit、stale credential、bad signature、cancel-not-found 和 reconciliation mismatch。
- #1076：收口 release CI、manual Spot Testnet workflow、Stage Code Audit、release notes 和 production-disabled proof。

## Validation

Validation anchors:

- `GH-1076-VERIFY-V0150-RELEASE-CI-MANUAL-TESTNET-AUDIT`
- `TVM-RELEASE-V0150-RELEASE-CI-MANUAL-TESTNET-AUDIT`
- `V0150-011-STAGE-CODE-AUDIT`
- `V0150-011-MANUAL-TESTNET-WORKFLOW`
- `V0150-011-RELEASE-NOTES`
- `V0150-011-VALIDATION-SUITE`
- `V0150-011-PRODUCTION-DISABLED-PROOF`
- `V0150-011-NO-PRODUCTION-CUTOVER`

Carry-forward anchors:

- `GH-1066-VERIFY-V0150-CONTRACT-PREFLIGHT`
- `GH-1067-VERIFY-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST`
- `GH-1068-VERIFY-V0150-REAL-SPOT-TESTNET-SUBMIT-RUNTIME`
- `GH-1071-VERIFY-V0150-NETWORK-EXECUTION-EVENT-LOG`
- `GH-1069-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-RUNTIME`
- `GH-1070-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-REPLACE-RUNTIME`
- `GH-1072-VERIFY-V0150-OMS-STATE-SYNC-RECONCILIATION`
- `GH-1073-VERIFY-V0150-CLI-OPERATOR-FLOW`
- `GH-1074-VERIFY-V0150-DASHBOARD-TESTNET-EXECUTION-STATUS`
- `GH-1075-VERIFY-V0150-FAILURE-SIMULATION-REAL-SIGNED-TRANSPORT`

Focused verifier:

```bash
bash checks/verify-v0.15.0-release-ci-manual-testnet-audit.sh
```

Full local validation remains:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.15.0-release-ci-manual-testnet-audit.sh
bash checks/run.sh
```

## Manual Testnet Workflow

The operator workflow is documented in `docs/operators/release-v0.15.0-real-binance-testnet-execution-mvp-runbook.md`.

Manual workflow guardrails:

- Use Binance Spot Testnet only.
- Use testnet credential references only.
- Require explicit operator confirmation before any Spot Testnet submit / cancel / cancel-replace rehearsal.
- Use injected Spot Testnet transport protocol or documented operator manual proof; do not treat v0.15.0 as a built-in URLSession runner.
- Persist only redacted request / response identity and append-only checksum evidence.
- Review Dashboard status from local read-model artifacts only.
- Stop on production host, production secret, broker endpoint, raw secret output, unredacted order identity, missing operator confirmation or reconciliation mismatch.

## Boundaries

- `productionTradingEnabledByDefault=false`
- `productionSecretAutoRead=false`
- `productionEndpointConnected=false`
- `brokerEndpointConnected=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`
- Binance only.
- Spot Testnet only for v0.15.0 execution MVP.
- No Futures / USDⓈ-M Perpetual execution in v0.15.0 MVP.
- No production endpoint fallback.
- No production secret read.
- No production broker connection.
- No production order submit / cancel / replace.
- No Dashboard trading button.
- No Dashboard order form.
- No Dashboard live command.
- No Linear / Symphony / Graphify / code-index / Figma.

## Operator Meaning

v0.15.0 表示 MTPRO 已具备可审计的 Binance Spot Testnet signed execution MVP construction evidence。它不是 production cutover，不是 production readiness approval，也不允许默认真实交易。

v0.15.0 也不是 out-of-the-box built-in URLSession runner release。CLI operator flow 和 runtime evidence 要么使用 injected transport protocol 形成 redacted evidence，要么引用 operator manual proof；未来 concrete network runner 必须由后续 issue 单独实现、验证和收口。

后续独立 public GitHub Release publication 已完成：`v0.15.0` stable GitHub Release 位于 `https://github.com/atxinbao/MTPRO/releases/tag/v0.15.0`，tag peeled commit 为 `1590b6c40e6ca7887cff0ca59b2f74e4fe7e3ece`，publication timestamp 为 `2026-06-23T01:26:30Z`。该 publication 只固定 v0.15.0 release identity，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。
