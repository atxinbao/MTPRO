# Release v0.6.0 Portfolio Journal Projection Contract

日期：2026-06-14

执行者：Codex

本文档服务 GitHub fallback issue `GH-763 V060-009 Add Portfolio projection from real journal`。

## V060-009-PORTFOLIO-JOURNAL-PROJECTION

`V060-009-PORTFOLIO-JOURNAL-PROJECTION`

Portfolio 必须提供一个 v0.6.0 本地 projection runner。该 runner 只消费已经由 DataEngine、Strategy、RiskEngine、ExecutionEngine / OMS dry-run runner 写成的同一条 local run journal，并从 journal replay 重建 Portfolio projection evidence。

## V060-009-JOURNAL-REPLAY-TO-PROJECTION-JSON

`V060-009-JOURNAL-REPLAY-TO-PROJECTION-JSON`

`ReleaseV060PortfolioJournalProjectionRunner` 必须先 replay `ReleaseV050DurableLocalRunJournal`，再复用 `ReleaseV050PortfolioRunJournalProjection` 生成 projection evidence。生成的 projection evidence 必须通过 `ReleaseV060LocalRunJournalWriter` 写入 `projection.json`，不能绕过 writer 或 manifest contract。

## V060-009-FIXED-POINT-EXPOSURE-NOTIONAL-QUANTITY

`V060-009-FIXED-POINT-EXPOSURE-NOTIONAL-QUANTITY`

Projection 必须继续使用 fixed-point quantity / notional / price / money semantics：`targetQuantity` 为 quantity，`notionalExposure` 和 `grossExposure` 为 notional，`projectedPnLLike` 为 money。该证据只服务本地 read model，不等同于 broker truth。

## V060-009-MANIFEST-VALIDATED-PROJECTION-ARTIFACT

`V060-009-MANIFEST-VALIDATED-PROJECTION-ARTIFACT`

`projection.json` 必须作为 completed run required artifact 纳入 `manifest.json`，并通过 `ReleaseV060LocalRunJournalWriter.validateRunManifest(runID:)` 校验 bytes 和 `sha256:` checksum。缺失或损坏的 projection artifact 不能被视为完成证据。

## V060-009-NO-BROKER-ACCOUNT-PAYLOAD

`V060-009-NO-BROKER-ACCOUNT-PAYLOAD`

GH-763 不读取 broker account state，不读取 production account、margin、leverage 或 real PnL payload，不连接 production endpoint / broker endpoint，不提交订单，不授权 production cutover。所有 Portfolio projection 都是 local journal-derived read-model evidence。

## TVM-RELEASE-V060-PORTFOLIO-JOURNAL-PROJECTION

`TVM-RELEASE-V060-PORTFOLIO-JOURNAL-PROJECTION`

Validation 入口：

- `swift test --filter TargetGraphTests/testGH763PortfolioJournalProjectionRebuildsProjectionJSONFromRealRunJournal`
- `bash checks/verify-v0.6.0-portfolio-journal-projection.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

GH-763 不使用 Linear，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不连接 production endpoint，不读取 production secret，不调用 broker，不提交真实订单，不授权 production cutover。
