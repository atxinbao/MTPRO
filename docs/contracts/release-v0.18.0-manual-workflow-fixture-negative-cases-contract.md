# Release v0.18.0 Manual Workflow Fixture Negative Cases Contract

日期：2026-06-28  
执行者：Codex

## Scope

#1183 / GH-1183 adds manual workflow fixture upload / download negative cases for the v0.18.0 venue/product-aware operator lifecycle recovery queue.

This contract depends on:

- #1177 closed / done
- #1178 closed / done

## Validation Anchors

- `GH-1183-VERIFY-V0180-MANUAL-WORKFLOW-FIXTURE-NEGATIVE-CASES`
- `TVM-RELEASE-V0180-MANUAL-WORKFLOW-FIXTURE-NEGATIVE-CASES`
- `V0180-008-DEPENDENCIES-GH1177-GH1178-DONE`
- `V0180-008-CORRUPT-BUNDLE-FAILS-CLOSED`
- `V0180-008-MISSING-FIELDS-FAIL-CLOSED`
- `V0180-008-WRONG-VENUE-PRODUCT-ENVIRONMENT-FAILS-CLOSED`
- `V0180-008-FAILED-VALIDATION-STATE-REJECTS-WORKFLOW`
- `V0180-008-FAILED-CHECKS-CANNOT-PASS-WITH-FAILED-STATUS-STRING`
- `V0180-008-NO-PRODUCTION-CUTOVER`

## Contract

`ReleaseV0180ManualWorkflowFixtureNegativeCaseSuite` is the canonical v0.18.0 local fixture negative-case surface for manual workflow upload/download evidence.

It must cover these cases:

- corrupt bundle fixture
- missing required field fixture
- wrong venue fixture
- wrong product fixture
- wrong environment fixture
- failed validation state fixture

Every case must produce failed checks and `workflowStatus=failed`. A failed uploaded or downloaded bundle cannot satisfy the manual workflow by merely printing a failed status string inside an otherwise successful shell path.

## Boundary

This is local artifact evidence only.

- `noProductionNetworkFlow=true`
- `noSecretUpload=true`
- `noOrderArtifactGeneratedFromWorkflowAlone=true`
- `productionTradingEnabledByDefault=false`
- `productionSecretReadEnabled=false`
- `productionEndpointConnectionEnabled=false`
- `productionBrokerConnectionEnabled=false`
- `productionOrderSubmitCancelReplaceEnabled=false`
- `productionCutoverAuthorized=false`

GH-1183 does not upload secrets, does not connect endpoint / broker, does not submit / cancel / replace orders, does not create tag / GitHub Release, and does not authorize production cutover. production cutover not authorized。

## Validation

- `swift test --filter TargetGraphTests/testGH1183ManualWorkflowFixtureNegativeCasesFailClosed`
- `bash checks/verify-v0.18.0-manual-workflow-fixture-negative-cases.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
