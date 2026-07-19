# MTPRO v0.33.0 Demo Validation Stage Code Audit

Date: 2026-07-19  
Executor: Codex

Anchors: `GH-1549-CLOSE-V0330-DEMO-VALIDATION-AUDIT-RELEASE-NOTES`, `TVM-RELEASE-V0330-DEMO-VALIDATION-PRODUCTION-CLOSURE-BLOCKED`, `V0330-008-DEMO-VALIDATION-AUDIT-RELEASE-NOTES`, `V0330-008-BINANCE-SPOT-USDM-FUTURES-ONLY`, `V0330-008-NO-PRODUCTION-CUTOVER`.

## Scope

This audit closes the v0.33.0 Demo validation queue for Binance Spot and Binance USD-M Futures. It records the successful Demo workflow evidence for issues #1544 and #1545 and the merged local evidence/status implementation for #1546-#1548.

Observed Demo workflow evidence:

- Spot: workflow run [#29653672291](https://github.com/atxinbao/MTPRO/actions/runs/29653672291), submit/status/cancel completed with HTTP 200 and final `CANCELED` state.
- USD-M Futures: workflow run [#29653822831](https://github.com/atxinbao/MTPRO/actions/runs/29653822831), submit/status/cancel completed with HTTP 200 and final `CANCELED` state.
- Both artifacts were redacted and reported `rawSecretPersisted=false` and `rawResponsePersisted=false`.

## 原始发布决策

The Demo evidence decision is accepted only when both product artifacts are independently present, provenance-bound, checksum-backed, and boundary-valid:

```text
demoValidationDecision=accepted
backendClosureDecision=blocked
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

The new `ReleaseV0330DemoValidationEvidenceBundle` rejects missing product evidence, mismatched source commits, invalid workflow provenance, unexpected product/action sets, production flag drift, and boundary violations. The status CLI fails with a non-zero exit code for a missing or invalid bundle; the Dashboard surface is read-model-only.

## Boundary

- Active venue: Binance only.
- Active products: Spot and USD-M Futures only.
- Environment: Binance Demo Network for the observed runs.
- No production endpoint, production secret, or production order was used.
- Demo validation does not authorize production backend closure or production cutover.
- No trading control is exposed by the Dashboard status surface.

## Validation

- `swift test --filter ReleaseV0330DemoValidationTests`
- `bash checks/verify-v0.33.0-demo-validation.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

This report is a Demo validation closeout, not a production trading authorization or a claim of observed production canary success.

## Human Demo Parity 后端收口补充审计

Human 于 2026-07-19 确认：MTPRO 当前 Binance Spot 与 USD-M Futures 的生产网络和 Demo Network 复用相同的订单计划、审批、风险门禁、submit / status / cancel 传输、持久化与只读证据逻辑；后端功能验收允许以已完成的 Demo Network 双产品证据为准，不再要求额外生产 canary。

本补充审计同时修复 v0.33.0 tag 暴露的 Linux `CryptoKit` 构建回归，并把 required `checks` 聚合门禁调整为：PR 继续使用 fast lane，tag / release 分支 /手工完整验证必须等待 Linux、macOS Dashboard 和 release publication matrix 全部成功。

最终后端功能收口事实：

```text
demoValidationDecision=accepted
backendClosureDecision=accepted-demo-network-parity
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

该结论只关闭 Binance Spot + USD-M Futures 后端功能建设，不授权生产 secret 自动读取、生产 endpoint 自动连接、默认生产交易、无限额交易或 Dashboard 交易控制。既有 `v0.33.0` tag 不移动；冻结基线由 `v0.33.0` 与本次 closure PR 的 merge commit 共同标识。
