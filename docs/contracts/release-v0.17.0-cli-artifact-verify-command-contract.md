# Release v0.17.0 CLI Artifact Verify Command Contract

日期：2026-06-27

执行者：Codex

## #1145 / GH-1145

GH-1145-VERIFY-V0170-CLI-ARTIFACT-VERIFY-COMMAND

TVM-RELEASE-V0170-CLI-ARTIFACT-VERIFY-COMMAND

V0170-007-LOCAL-ARTIFACT-BUNDLE-VERIFY

V0170-007-LOCAL-ONLY-NO-NETWORK

V0170-007-DETERMINISTIC-VALIDATION-REPLAY-OUTPUT

V0170-007-REDACTED-OUTPUT

V0170-007-NO-PRODUCTION-CUTOVER

## Goal

GH-1145 增加 `mtpro verify-operator-beta-artifact-bundle <storageRoot> <runID>` CLI artifact verify command，用于 operator 在本地复核 v0.17.0 operator beta artifact bundle。

## Scope

- 命令只接收本地 artifact store root 和 runID。
- 命令复用 GH-1140 `ReleaseV0170OperatorBetaArtifactBundleReplayValidator`。
- 输出 deterministic validation / replay result，包括 pass/fail status、schema / checksum / action sequence / reconciliation 状态、replayed kinds、manifest checksum、record checksum count 和 failure reasons。
- 输出必须显式声明 local-only、no-network、redacted output 和 production cutover 未授权。
- 将命令接入 `MTPROStrictCLI` 的 supported commands 和 public help。

## Non-goals

- 不新增 artifact bundle schema。
- 不读取 credential value。
- 不读取 production secret。
- 不连接 testnet endpoint。
- 不连接 production endpoint。
- 不连接 broker endpoint。
- 不实现 submit / cancel / replace。
- 不创建 tag / GitHub Release。
- 不授权 production cutover。

## CLI behavior

`ReleaseV0170CLIArtifactVerifyCommand` 必须满足：

- `cliCommand == verify-operator-beta-artifact-bundle`。
- `localArtifactBundleVerify == true`。
- `localOnlyNoNetwork == true`。
- `deterministicValidationReplayOutput == true`。
- `redactedOutputOnly == true`。
- `productionTradingEnabledByDefault == false`。
- `productionSecretReadEnabled == false`。
- `productionEndpointConnectionEnabled == false`。
- `productionBrokerConnectionEnabled == false`。
- `productionOrderSubmitCancelReplaceEnabled == false`。
- `productionCutoverAuthorized == false`。

## Validation

- `swift test --filter TargetGraphTests/testGH1145ReleaseV0170CLIArtifactVerifyCommand`
- `bash checks/verify-v0.17.0-cli-artifact-verify-command.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

GH-1145 是本地 CLI artifact verify command。它只读取本地 redacted artifact store，不读取 credential value，不连接 endpoint，不发送 testnet 或 production order，不创建 tag / GitHub Release，不启动下一 milestone，不授权 production cutover。
