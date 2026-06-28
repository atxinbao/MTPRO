# Release v0.18.0 Beta Safety Profile Drift Detector Contract

日期：2026-06-28  
执行者：Codex

## Scope

#1184 / GH-1184 为 `MTPRO Release v0.18.0 Venue/Product-aware Operator Lifecycle Recovery Foundation` 增加 beta safety profile drift detector。该 detector 只消费本地 redacted evidence，验证 v0.17 beta safety profile evidence 是否仍属于同一个 venue / product / environment / accountProfile / runID scope。

依赖证据：

- #1177 closed / done：run artifact lifecycle manifest 已记录 venue / product / environment namespace。
- #1181 closed / done：operator-visible failure classification 和 next-action CLI 已完成。
- #1183 closed / done：manual workflow fixture upload / download negative cases 已完成。

## Required Anchors

- GH-1184-VERIFY-V0180-BETA-SAFETY-PROFILE-DRIFT-DETECTOR
- TVM-RELEASE-V0180-BETA-SAFETY-PROFILE-DRIFT-DETECTOR
- V0180-009-DEPENDENCIES-GH1177-GH1181-GH1183-DONE
- V0180-009-VENUE-PRODUCT-ENVIRONMENT-SCOPE
- V0180-009-BINANCE-SPOT-TO-OKX-SWAP-REUSE-REJECTED
- V0180-009-BINANCE-SPOT-TO-USDM-FUTURES-REUSE-REJECTED
- V0180-009-WRONG-ENVIRONMENT-REUSE-REJECTED
- V0180-009-CROSS-PRODUCT-EVIDENCE-REUSE-FAILS-CLOSED
- V0180-009-NO-PRODUCTION-CUTOVER

## Contract

`ReleaseV0180BetaSafetyProfileDriftDetector` 是 GH-1184 的唯一 drift detector 入口。

Detector 必须记录：

- expected scope：venue、product、environment、accountProfile、runID。
- observed scope：venue、product、environment、accountProfile、runID。
- source evidence：`ReleaseV0170BetaSafetyPolicyProfileEvidence` 的 evidence id、issue id、venue、product 和 boundary state。
- drift flags：venue drift、product drift、environment drift、account profile drift、runID drift、unsupported expected / observed venue-product pair。
- validation status：无 drift 时为 `passed`；任一 drift 时为 `failed`。

Binance Spot evidence 不得被复用为 OKX Swap、Binance USDⓈ-M Futures 或任何未支持 product evidence。上述复用必须设置 failed validation，并通过 `CoreError.liveTradingBoundaryForbiddenCapability` fail closed。

## Boundary

GH-1184 只建立本地 evidence detector。它不实现 OKX runtime，不激活新 venue / product runtime，不创建 tag / GitHub Release，不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 submit / cancel / replace 真实订单。

必须保持：

- productionTradingEnabledByDefault=false
- productionSecretReadEnabled=false
- productionEndpointConnectionEnabled=false
- productionBrokerConnectionEnabled=false
- productionOrderSubmitCancelReplaceEnabled=false
- productionCutoverAuthorized=false

## Validation

必跑命令：

```bash
swift test --filter TargetGraphTests/testGH1184BetaSafetyProfileDriftDetectorRejectsCrossVenueProductReuse
bash checks/verify-v0.18.0-beta-safety-profile-drift-detector.sh
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```
