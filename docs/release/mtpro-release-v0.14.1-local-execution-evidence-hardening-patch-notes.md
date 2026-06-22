# MTPRO Release v0.14.1 Local Execution Evidence Hardening Patch Notes

日期：2026-06-22

执行者：Codex

## Summary

v0.14.1 是 v0.14.0 public GitHub Release 之后的 local execution evidence hardening patch。它不新增 runtime pipeline，不实现真实 signed Binance testnet runner，不连接 broker endpoint，也不发送真实 testnet 或 production order。

本说明是 #1064 patch closeout notes。它只收口 #1059 至 #1064 的 release CI evidence、Codable decode validation、network-attempt wording、golden JSON contract tests、Dashboard local read-model artifact loading 和 hardening audit evidence。#1064 本身不创建 `v0.14.1` tag，不创建 GitHub Release，不移动既有 `v0.14.0` tag / release，也不推进 v0.15.0。

## Completed Queue

- #1059：固定 v0.14.0 public Release、terminal PR、Linux required checks、macOS Dashboard build / smoke、tag push workflow 和 `checks/run.sh` evidence。
- #1060：补强 v0.14.x local execution evidence / Dashboard read-model 的 Codable decode fail-closed validation。
- #1061：把 ambiguous adapter submit wording 改为 local evidence wording，并固定 `networkSubmitAttempted=false`、`networkCancelReplaceAttempted=false`。
- #1062：新增 golden JSON artifact 和 corrupted payload tests，覆盖 decode -> validate -> mutate -> fail contract。
- #1063：允许 Dashboard 从本地 read-model artifact JSON 加载已验证的 v0.14 execution surface，仍保持 read-only / no-command boundary。
- #1064：收口 v0.14.1 Stage Code Audit、release notes、latest verification、automation readiness 和 wording guard。

## Validation

Validation anchors:

- `GH-1064-VERIFY-V0141-PATCH-AUDIT-RELEASE-NOTES`
- `TVM-RELEASE-V0141-PATCH-AUDIT-RELEASE-NOTES`
- `V0141-006-PATCH-AUDIT`
- `V0141-006-RELEASE-NOTES`
- `V0141-006-VALIDATION-SUMMARY`
- `V0141-006-LOCAL-EVIDENCE-WORDING`
- `V0141-006-NO-PRODUCTION-CUTOVER`
- `V0141-006-NO-TAG-OR-RELEASE-PUBLICATION`

Carry-forward anchors:

- `GH-1059-VERIFY-V0141-RELEASE-CI-DASHBOARD-EVIDENCE`
- `GH-1060-VERIFY-V0141-CODABLE-DECODE-VALIDATION`
- `GH-1061-VERIFY-V0141-SUBMIT-EVIDENCE-NETWORK-GUARDS`
- `GH-1062-VERIFY-V0141-GOLDEN-JSON-CONTRACTS`
- `GH-1063-VERIFY-V0141-DASHBOARD-LOCAL-ARTIFACTS`

Focused verifier:

```bash
bash checks/verify-v0.14.1-patch-audit-release-notes.sh
```

Full local validation remains:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.14.1-patch-audit-release-notes.sh
bash checks/run.sh
```

## Boundaries

- v0.14.1 是 local execution evidence-chain hardening patch，不是真实 signed Binance testnet execution release；English guard anchor: not real signed Binance testnet execution release.
- production trading 仍默认关闭。
- production cutover 仍未授权。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不连接 signed Binance production endpoint。
- 不连接真实 broker。
- 不发送 testnet 或 production order。
- 不授权 real submit / cancel / replace。
- 不实现或启用 production OMS。
- 不启用 Dashboard trading button、order form、command surface 或 live command。
- 不创建 `v0.14.1` tag，不创建 `v0.14.1` GitHub Release。
- 不推进 v0.15.0 signed testnet runner。

## Operator Meaning

v0.14.1 表示 v0.14.0 的 execution closed-loop wording 已被收紧为本地 evidence chain：order intent、lifecycle、adapter boundary、OMS store、event sourcing、risk gate、kill switch、reconciliation、signal-to-execution pipeline、Dashboard read-only surface 和 local artifact loading 都可以被本地验证和审计，但它们不代表真实 Binance testnet order execution。

如果后续需要真实 signed Binance testnet runner，必须作为独立 v0.15.0 或后续 release gate 重新规划、重新授权，并显式满足 credential、signed endpoint、risk、OMS、kill switch、reconciliation、audit 和 operator confirmation gates。
