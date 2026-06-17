# MTPRO Release v0.9.1 v0.9.0 Audit Hardening Patch Notes

日期：2026-06-18

执行者：Codex

## Summary

v0.9.1 不发布 tag，不创建 GitHub Release。它只记录 v0.9.0 release 后的 audit hardening patch evidence。

本 patch 修正：

- v0.9.0 stable GitHub Release publication facts 的文档和 verifier 口径。
- Dashboard macOS lane 对 v0.9.0 focused guards 的显式执行顺序。
- `mtpro verify` 当前输出的 v0.9.0 wording。
- `testnet-read-only-probe` 与 `testnet-read-only-monitor` 的当前 / legacy 命名边界。
- `mtpro monitor` CLI actions 与 `ReleaseV090TestnetReadOnlyMonitorSessionStore` 的真实本地 artifact 绑定。

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
