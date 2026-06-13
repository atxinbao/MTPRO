# Release v0.3.0 Portfolio Projection Rehearsal Contract

日期：2026-06-13

执行者：Codex

本文档定义 GH-665 / V030-09 的 Portfolio projection rehearsal evidence 合同。该合同只授权 Portfolio target 内的本地 rehearsal fill projection、Spot / USDⓈ-M Perpetual 产品级投影和 EMA / RSI attribution evidence；不授权 production account sync、account endpoint read、broker position sync、reconciliation runtime、真实 broker connection 或真实订单。

## V030-09-PORTFOLIO-PROJECTION-REHEARSAL

- Issue：GH-665。
- Upstream：GH-664 / `TVM-RELEASE-V030-EVENT-STORE-REHEARSAL-EVIDENCE`。
- Downstream：GH-666。
- Queue range：GH-657..GH-670。
- Release：v0.3.0。
- Project：MTPRO Release v0.3.0 Runtime Rehearsal v1。

GH-665 在 `Portfolio` target 内输出 rehearsal Portfolio projection evidence。该 evidence 消费 GH-664 Event Store replay state，但不 import ExecutionClient、ExecutionEngine、RiskEngine 或 broker runtime object。

## V030-09-SPOT-PORTFOLIO-PROJECTION

Spot projection 必须来自本地 rehearsal fill evidence：

- product type 固定为 `spot`。
- venue 固定为 Binance。
- fill 必须带 source replay event ID 和 source replay sequence。
- source evidence anchor 必须为 `TVM-RELEASE-V030-EVENT-STORE-REHEARSAL-EVIDENCE`。
- projection 只计算 rehearsal net position、gross fill quantity、gross notional、fee 和 average fill price。

## V030-09-PERP-PORTFOLIO-PROJECTION

USDⓈ-M Perpetual projection 必须来自本地 rehearsal fill evidence：

- product type 固定为 `usdsPerpetual`。
- venue 固定为 Binance。
- projection 不执行 leverage / margin action。
- projection 不读取真实 account balance，不同步 broker position，不执行 reconciliation runtime。

## V030-09-EMA-RSI-ATTRIBUTION

Attribution evidence 必须同时覆盖：

- EMA。
- RSI。
- Spot。
- USDⓈ-M Perpetual。

Attribution 只对 rehearsal fill notional 和 fee 做可审计归因，不代表真实策略收益、真实账户权益或 broker fill reconciliation。

## V030-09-NO-PRODUCTION-ACCOUNT-SYNC

GH-665 必须保持以下能力关闭：

- production trading。
- production endpoint auto-connect。
- production secret auto-read。
- production order submission。
- production cutover authorization。
- production account sync。
- account endpoint read。
- broker position sync。
- raw broker payload exposure。
- reconciliation runtime。
- Dashboard command surface。
- CommandGateway bypass。

## TVM-RELEASE-V030-PORTFOLIO-PROJECTION-REHEARSAL

Validation evidence 必须同时落在：

- `Sources/Portfolio/ReleaseV030PortfolioProjectionRehearsal.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/validation-plan.md`
- `docs/automation/automation-readiness.md`
- `checks/automation-readiness.sh`

Required validation：

- `swift test --filter TargetGraphTests/testGH665PortfolioProjectionRehearsalProjectsSpotPerpAndAttributionFromReplayEvidence`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

GH-665 不使用 Linear，不启动 Symphony / `symphony-issue`，不运行 Graphify / code-index，不修改 Figma，不创建下一 Project / Issue，不推进下一阶段 Todo。

GH-665 不连接 production endpoint，不读取 production secret，不发送真实订单，不读取 account endpoint，不同步 broker position，不保存或暴露 raw broker payload，不执行 broker reconciliation，不打开 Dashboard command surface，不授权 production cutover。
