# MTPRO Release v0.9.1 v0.9.0 Audit Hardening Patch Notes

日期：2026-06-18

执行者：Codex

## Summary

v0.9.1 是 v0.9.0 release 后的 audit hardening patch release。它已通过独立 release publication gate 发布 stable GitHub Release；该 publication 不授权 production cutover。

本 patch 修正：

- v0.9.0 stable GitHub Release publication facts 的文档和 verifier 口径。
- Dashboard macOS lane 对 v0.9.0 focused guards 的显式执行顺序。
- `mtpro verify` 当前输出的 v0.9.0 wording。
- `testnet-read-only-probe` 与 `testnet-read-only-monitor` 的当前 / legacy 命名边界。
- `mtpro monitor` CLI actions 与 `ReleaseV090TestnetReadOnlyMonitorSessionStore` 的真实本地 artifact 绑定。

## Publication Fact

- stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.9.1`
- release tag：`v0.9.1`
- release title：`MTPRO v0.9.1 Audit Hardening Patch`
- release type：stable release；非 draft；非 prerelease
- tag peeled commit：`d041f0dd304075562a85e494695697290972288f`
- publication timestamp：`2026-06-17T19:45:42Z`

v0.9.1 的 patch evidence closeout、public release publication 和 production cutover 是三个独立 gate。已发布 tag 只固定 source identity，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 testnet 或 production order。

## Current Runtime Modes

```text
runtimeModes = local-dry-run, testnet-read-only-monitor, recovery-observe, production-blocked
legacyRuntimeModes = testnet-read-only-probe
```

`testnet-read-only-probe` 只保留为历史 CLI 兼容路径，不是 v0.9.x 当前主口径。

## Validation

```bash
bash checks/verify-v0.9.1.sh
```

该命令聚合：

- `checks/verify-v0.9.1-dashboard-macos-v090-guards.sh`
- `checks/verify-v0.9.1-cli-verify-v090-wording.sh`
- `TargetGraphTests/testV091DashboardGuardAndCLIMonitorStoreBindingPatch`

## Boundaries

- production trading 仍默认关闭。
- production cutover 仍未授权。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不发送 testnet 或 production order。
- 不实现 production OMS。
- 不新增 Dashboard trading button、order form 或 live command。
- 不推进下一版本。
