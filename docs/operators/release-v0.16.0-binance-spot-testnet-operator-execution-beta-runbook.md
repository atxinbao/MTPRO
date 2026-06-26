# Release v0.16.0 Binance Spot Testnet Operator Execution Beta Runbook

日期：2026-06-25

执行者：Codex

## Purpose

本文档是 #1112 closeout runbook。它把 #1101..#1111 的 operator beta 证据压成执行和审计顺序，服务 v0.16.0 construction closeout。它不是 production cutover runbook，也不是自动生产交易授权。

## Anchors

- `GH-1112-VERIFY-V0160-STAGE-AUDIT-RELEASE-DOCS`
- `TVM-RELEASE-V0160-STAGE-AUDIT-RELEASE-DOCS`
- `V0160-012-STAGE-CODE-AUDIT`
- `V0160-012-RELEASE-NOTES`
- `V0160-012-OPERATOR-RUNBOOK`
- `V0160-012-VALIDATION-MATRIX`
- `V0160-012-STALE-WORDING-GUARD`
- `V0160-012-NO-PRODUCTION-CUTOVER`
- `V0160-012-NO-TAG-OR-RELEASE-PUBLICATION`

## Preconditions

- #1101..#1111 均 closed / done。
- operator 使用 Binance Spot Testnet credential profile。
- operator 已确认 redaction policy。
- raw API key、secret、signature input、raw order identity 和 raw broker payload 不进入仓库、CI、Dashboard 或 PR。
- production trading 默认关闭，production cutover 未授权。

## Operator Evidence Path

1. 按 #1102 建立 durable run id。
2. 按 #1103 运行 `spot-testnet-submit`，输出 redacted submit artifact path 和 checksum。
3. 按 #1105 运行 submit 后 status query，输出 redacted status artifact path 和 checksum。
4. 按 #1104 运行 `spot-testnet-cancel`，输出 redacted cancel artifact path 和 checksum。
5. 按 #1105 运行 cancel 后 status query，输出 redacted status artifact path 和 checksum。
6. 按 #1107 运行 OMS observed-status reconciliation，确认 reconciliation passed。
7. 按 #1106 export redacted evidence bundle。
8. 按 #1108 在 Dashboard 只读核对 artifact rows、action sequence、checksums 和 reconciliation result。
9. 按 #1111 manual workflow 验证 redacted evidence bundle。
10. 按 #1112 closeout verifier 固定 Stage Code Audit、release notes、runbook、validation matrix 和 stale wording guard。

## Stop Rules

立即停止并丢弃本次 operator evidence 的情况：

- 缺少 explicit operator confirmation。
- evidence bundle 包含 raw credential、raw secret、raw order identity、raw broker payload 或 production endpoint。
- `submit -> status -> cancel -> status -> reconciliation passed` 顺序不完整。
- checksum reference 缺失或不是 `sha256:`。
- beta safety guard 阻断 quantity、orders-per-run、cooldown、symbol allowlist 或 credential profile。
- workflow 尝试读取 secrets 或连接 production endpoint / broker endpoint。
- operator 要求授权 production cutover、production order 或 production trading。

## Closeout Validation

```bash
bash checks/verify-v0.16.0-stage-audit-release-docs.sh
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Non-Authorization

#1112 不创建 tag / GitHub Release，不创建下一 Project / Issue，不推进下一 Todo，不启动 Linear / Symphony / Graphify / code-index / Figma，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。
