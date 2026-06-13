# MTPRO Release v0.3.1 Rehearsal Evidence Hardening Patch Notes

日期：2026-06-13

执行者：Codex

## Release Type

v0.3.1 是 rehearsal evidence hardening patch。它只收紧 `MTPRO Release v0.3.0 Testnet / Shadow Production Rehearsal` 的 deterministic evidence 边界，不新增 runtime pipeline、network connector、product type、strategy、broker capability、secret handling 或 production cutover。

## Scope

- GH-685：固定 v0.3.x CLI / Dashboard / Portfolio rehearsal product boundary 为 Spot + USDⓈ-M Perpetual，固定 active strategy boundary 为 EMA + RSI，避免未来枚举扩展静默扩大 v0.3.x evidence scope。
- GH-686：强化 Binance testnet mapping URL policy，要求 HTTPS、exact testnet host、无 user/password、无 path/query，拒绝 production host，并保持 `networkCallPerformed=false`。
- GH-687：澄清 v0.3.x release 语义：v0.3.0 是 deterministic rehearsal evidence release，v0.3.1 是 hardening patch，v0.3.x 不是 real testnet / shadow runtime runner；v0.4.0 只作为后续 planned unified runtime rehearsal pipeline stage 的 handoff 语义。
- GH-688：新增 v0.3.1 hardening guard 和本 patch release notes，确认 no v0.4.0 runtime pipeline is implemented。

## Validation

本 patch 的本地验证入口：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.3.0.sh
bash checks/verify-v0.3.1.sh
bash checks/run.sh
```

`checks/run.sh` 必须覆盖 `checks/verify-v0.3.1.sh`，使 v0.3.1 hardening guard 成为 required local validation path 的一部分。

## Boundary Evidence

- production trading remains disabled by default。
- no production secret auto-read。
- no production endpoint auto-connect。
- no production broker connection。
- no production order authorization。
- no real testnet runner。
- no shadow production feed runner。
- no Binance network call。
- no real submit / cancel / replace。
- no Dashboard command surface change。
- no v0.4.0 runtime pipeline is implemented。

## Release Notes

v0.3.1 只发布 v0.3.0 deterministic rehearsal evidence 的 hardening patch：

- Binance-only rehearsal evidence remains scoped to Spot + USDⓈ-M Perpetual。
- Active strategies remain EMA + RSI。
- testnet / shadow wording remains evidence-mode wording, not real runtime runner wording。
- Binance testnet URL policy rejects production host, HTTP scheme, userinfo, path and query drift。
- v0.4.0 remains separately planned and requires Human + `@001 / PLN` planning plus a new live queue source before any execution。

## Non-Authorization

本 patch notes 不创建下一 Project / Issue，不推进 Todo，不启动 Linear / Symphony / Graphify / code-index / Figma，不授权 production cutover，不读取 secret，不连接 production endpoint，不发送真实 order。
