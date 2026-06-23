# MTPRO Release v0.15.1 Real Testnet Execution Hardening Patch Stage Code Audit

日期：2026-06-23

执行者：Codex

## Scope

`MTPRO Release v0.15.1 Real Testnet Execution Hardening Patch` 收口 GitHub fallback issues `#1094..#1100`。本 patch 是 v0.15.0 stable release 后的 hardening closeout，只记录 `v0.15.1` closeout evidence；如需发布 `v0.15.1`，必须走独立 Release Publication Gate。本 patch 不创建下一 Project / Issue。

## Issue Evidence

- #1094：`GH-1094-VERIFY-V0151-V0150-RELEASE-FACT-SYNC`，同步 v0.15.0 publication facts。
- #1095：`GH-1095-VERIFY-V0151-INJECTED-TRANSPORT-WORDING`，固定 injected transport / manual proof / future URLSession runner split。
- #1096：`GH-1096-VERIFY-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT`，增加 concrete URLSession Spot Testnet transport guard。
- #1097：`GH-1097-VERIFY-V0151-CLI-TESTNET-EXECUTION-RUNTIME`，增加 CLI guarded runtime wiring。
- #1098：`GH-1098-VERIFY-V0151-RUNTIME-INTERNAL-GATES`，把 RiskEngine、kill switch、no-trade 和 operator confirmation gate 放入 runtime 内部。
- #1099：`GH-1099-VERIFY-V0151-CLIENT-ORDER-IDENTITY-CHAIN`，固定 deterministic client order identity handoff。
- #1100：`GH-1100-VERIFY-V0151-CODABLE-DECODE-CLOSEOUT`，补齐 Codable decode-time validation 与 patch closeout。

## GH-1100 Decode Closeout Evidence

- `TVM-RELEASE-V0151-CODABLE-DECODE-CLOSEOUT`
- `V0151-007-CODABLE-DECODE-VALIDATION`
- `V0151-007-CORRUPTED-JSON-FAILS-CLOSED`
- `V0151-007-CHECKSUM-MISMATCH-FAILS-CLOSED`
- `V0151-007-PRODUCTION-HOST-MUTATION-REJECTED`
- `V0151-007-NO-PRODUCTION-CUTOVER`

新增 `ReleaseV0151CodableDecodeBoundary`，并在 submit / cancel / cancel-replace evidence、network event artifact、network event log、OMS snapshot、OMS observation / failure / reconciliation report 的 `init(from:)` 中重新检查 deterministic id、checksum、redaction flags、testnet host/path、lifecycle 和 production 禁区。损坏 JSON、checksum mismatch、production host mutation 和 production boundary mutation 必须在 decode 阶段 fail-closed。

## Validation

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/verify-v0.15.1-codable-decode-closeout.sh`
- `bash checks/run.sh`

Focused test：`testGH1100ReleaseV0151CodableDecodeValidationFailsClosedOnMutatedArtifacts`。

## Boundary Audit

- `v0.15.1` publication 必须由独立 Release Publication Gate 显式触发。
- 本 closeout 不自动发布 patch release。
- 不授权 production cutover。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不提交 production order。
- 不扩大到非 Binance venue。
- 不扩大到非 Spot execution scope。

## Residual Risk

v0.15.1 只强化 v0.15.0 real Binance Spot Testnet execution evidence 的 decoding、wording、CLI 和 transport guard。Production cutover、production credential policy、real broker enablement、capital/risk approval 和 operator release gate 仍然必须单独规划、单独授权。

## Next Handoff

后续是否发布 `v0.15.1` tag / GitHub Release，必须由独立 Release Publication Gate 决定；本 Stage Code Audit 不自动发布、不推进下一阶段。
