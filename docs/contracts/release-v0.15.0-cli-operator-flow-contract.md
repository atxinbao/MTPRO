# Release v0.15.0 CLI Operator Flow Contract

日期：2026-06-23  
执行者：Codex

## Scope

`GH-1073-VERIFY-V0150-CLI-OPERATOR-FLOW` 定义 `mtpro testnet-execution` 的 operator CLI flow。该 flow 只允许 Binance Spot Testnet，必须显式传入 `--testnet`、`--action submit|cancel|cancel-replace`、`--operator-confirm CONFIRM_BINANCE_SPOT_TESTNET_EXECUTION`、`--intent-id` 和 `--network-event-log-id`。

该合同把 CLI 输入压缩成脱敏 evidence 摘要，证明 operator 已确认 testnet execution，并要求真实 network action 继续走 v0.15.0 guarded runtime 和 append-only network execution event log。它不读取 secret，不创建 production fallback，不连接 production endpoint / broker endpoint，不提交 production order。

## Validation Anchors

- GH-1073-VERIFY-V0150-CLI-OPERATOR-FLOW
- TVM-RELEASE-V0150-CLI-OPERATOR-FLOW
- V0150-008-EXPLICIT-TESTNET-MODE
- V0150-008-OPERATOR-CONFIRMATION-REQUIRED
- V0150-008-REDACTED-OUTPUT
- V0150-008-NO-PRODUCTION-FALLBACK
- V0150-008-APPEND-ONLY-EVIDENCE-REFERENCE
- V0150-008-NO-PRODUCTION-CUTOVER

## Contract Facts

- ReleaseV0150BinanceSpotTestnetCLIOperatorFlow
- ReleaseV0150BinanceSpotTestnetCLIOperatorInput
- ReleaseV0150BinanceSpotTestnetCLIOperatorEvidence
- cliCommand=testnet-execution
- explicitTestnetModeRequired=true
- operatorConfirmationRequired=true
- redactedOutputPrinted=true
- noProductionFallback=true
- appendOnlyChecksummedEvidenceRequired=true
- existingGuardedRuntimeRequired=true
- venueName=Binance
- executionProductScope=Binance Spot Testnet
- rawSecretPrinted=false
- rawCredentialPrinted=false
- rawOrderIdentityPrinted=false
- rawBrokerPayloadPrinted=false
- productionTradingEnabledByDefault=false
- productionSecretAutoRead=false
- productionEndpointConnected=false
- brokerEndpointConnected=false
- productionOrderSubmitted=false
- productionCutoverAuthorized=false

## CLI Surface

Canonical command:

```bash
swift run mtpro testnet-execution \
  --testnet \
  --action submit \
  --operator-confirm CONFIRM_BINANCE_SPOT_TESTNET_EXECUTION \
  --intent-id gh1073-intent \
  --network-event-log-id gh1073-network-event-log \
  --output redacted
```

Allowed actions:

- `submit`
- `cancel`
- `cancel-replace`

Fail-closed cases:

- missing `--testnet`
- missing or wrong operator confirmation phrase
- non-redacted output mode
- unknown action
- `--production`
- `--production-endpoint`
- `--broker-endpoint`

## Boundary

`ReleaseV0150BinanceSpotTestnetCLIOperatorFlow` does not create a foundation networking request/session, does not read environment secrets, and does not directly perform network I/O. It only proves the operator-facing command contract and prints redacted evidence handles. The actual testnet submit / cancel / cancel-replace runtime remains bounded by the existing #1068 / #1069 / #1070 guarded runtime and #1071 append-only event log.
