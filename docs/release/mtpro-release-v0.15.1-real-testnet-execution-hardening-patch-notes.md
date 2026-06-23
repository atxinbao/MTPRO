# MTPRO Release v0.15.1 Real Testnet Execution Hardening Patch Notes

日期：2026-06-23

执行者：Codex

## Summary

`MTPRO Release v0.15.1 Real Testnet Execution Hardening Patch` 是 v0.15.0 后的 hardening patch closeout。它收口 GitHub fallback issues `#1094..#1100`，强化 v0.15.0 real Binance Spot Testnet execution MVP 的 publication wording、transport guard、CLI runtime、internal gate、client order identity chain 和 Codable decode validation。

## Evidence

- `GH-1094-VERIFY-V0151-V0150-RELEASE-FACT-SYNC`
- `GH-1095-VERIFY-V0151-INJECTED-TRANSPORT-WORDING`
- `GH-1096-VERIFY-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT`
- `GH-1097-VERIFY-V0151-CLI-TESTNET-EXECUTION-RUNTIME`
- `GH-1098-VERIFY-V0151-RUNTIME-INTERNAL-GATES`
- `GH-1099-VERIFY-V0151-CLIENT-ORDER-IDENTITY-CHAIN`
- `GH-1100-VERIFY-V0151-CODABLE-DECODE-CLOSEOUT`

## GH-1100 Closeout

- `TVM-RELEASE-V0151-CODABLE-DECODE-CLOSEOUT`
- `V0151-007-CODABLE-DECODE-VALIDATION`
- `V0151-007-CORRUPTED-JSON-FAILS-CLOSED`
- `V0151-007-CHECKSUM-MISMATCH-FAILS-CLOSED`
- `V0151-007-PRODUCTION-HOST-MUTATION-REJECTED`
- `V0151-007-NO-PRODUCTION-CUTOVER`

Submit / cancel / cancel-replace evidence、network event log、OMS snapshot 和 reconciliation report 在 Codable decode 阶段重新校验 deterministic id、checksum、redaction、testnet endpoint 和 production 禁区。损坏 JSON、checksum mismatch、production host mutation 和 production boundary mutation 不得解码为可信 evidence。

## Boundary

本 patch 只记录 `v0.15.1` closeout evidence；若需要发布 `v0.15.1`，必须走独立 Release Publication Gate。本 patch 不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order。
