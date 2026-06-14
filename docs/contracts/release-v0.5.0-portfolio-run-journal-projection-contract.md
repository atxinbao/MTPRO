# Release v0.5.0 Portfolio Run Journal Projection Contract

日期：2026-06-14  
执行者：Codex

## Scope

GH-736 定义 `Portfolio` target 内的 run journal derived read-model projection：

- `V050-11-PORTFOLIO-RUN-JOURNAL-PROJECTION`
- `V050-11-JOURNAL-REPLAY-DERIVED-POSITION-EXPOSURE`
- `V050-11-PNL-MARGIN-LIKE-REHEARSAL-METRICS`
- `V050-11-INSTRUMENT-CATALOG-PRECISION-SOURCE`
- `V050-11-NO-BROKER-ACCOUNT-PAYLOAD`
- `TVM-RELEASE-V050-PORTFOLIO-RUN-JOURNAL-PROJECTION`

实现入口是 `Sources/Portfolio/ReleaseV050PortfolioRunJournalProjection.swift`：

- `ReleaseV050PortfolioRunJournalProjection`
- `ReleaseV050PortfolioRunJournalProjectionEvidence`
- `ReleaseV050PortfolioRunJournalFillEvidence`
- `ReleaseV050PortfolioRunJournalProductProjection`
- `ReleaseV050PortfolioRunJournalProjectionState`
- `ReleaseV050PortfolioRunJournalProjectionContract`

## Source Chain

Projection 只能消费 GH-731 `ReleaseV050DurableLocalRunJournal` replay 出来的 typed envelopes。允许的输入证据是：

- GH-729 `ReleaseV050InstrumentCatalog` product / precision metadata。
- GH-731 append-only local run journal records。
- GH-734 `StrategyIntentEvent` / `RiskDecisionEvent` typed envelopes。
- GH-735 `OMSLifecycleEvent.simulatedFilled` 与 accepted `ExecutionClientDryRunEvent.submit`。

Projection 必须按 `runID` 可重放，必须保留 source journal checksum、journal sequence、source strategy id、risk decision id、OMS order id 和 dry-run submit evidence。

## Projection Semantics

Portfolio projection 是 rehearsal / dry-run read model，不是 broker truth。

`ReleaseV050PortfolioRunJournalProjection.project(journal:instrumentCatalog:)` 必须：

- 从 run journal replay 还原 typed event chain。
- 只把 `simulatedFilled` OMS state 与 accepted dry-run submit 解释为 fill-like read-model input。
- 使用 `ReleaseV050InstrumentCatalogEntry` 的 `tickSize`、`stepSize`、`minNotional`、precision policy 和 product identity 计算 position、exposure、PnL-like 与 margin-like fields。
- 输出 product projection 和 run-level projection state。
- 保持 `projectionByRunID=true`、`sourceChainAuditable=true`、`readModelOnly=true`、`brokerTruth=false`。

## Non-goals

GH-736 不实现：

- broker account read。
- real position / margin / leverage / PnL sync。
- broker fill parser。
- reconciliation runtime。
- production OMS。
- real submit / cancel / replace。
- production endpoint / broker endpoint / account endpoint / listenKey / private WebSocket runtime。
- production cutover authorization。

## Forbidden Capability Audit

以下字段必须保持 false：

- `productionAccountSynced`
- `accountEndpointRead`
- `brokerPositionRead`
- `brokerMarginRead`
- `brokerLeverageRead`
- `realPnLRead`
- `rawBrokerPayloadStored`
- `reconciliationRuntimeExecuted`
- `productionTradingEnabledByDefault`
- `productionEndpointConnected`
- `productionSecretAutoReadEnabled`
- `productionOrderSubmitted`
- `productionCutoverAuthorized`

`ReleaseV050PortfolioRunJournalFillEvidence.accountEndpointReadRejectedProbe()` 必须证明 account endpoint payload 不能进入 projection input。

## Required Validation

- `swift test --filter TargetGraphTests/testGH736PortfolioProjectionDerivesReadModelFromRunJournalAndOMSDryRunEvidence`
- `bash checks/verify-v0.5.0-portfolio.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
