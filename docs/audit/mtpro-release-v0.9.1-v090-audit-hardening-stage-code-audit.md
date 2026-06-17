# MTPRO Release v0.9.1 v0.9.0 Audit Hardening Patch Stage Code Audit

日期：2026-06-18

执行者：Codex

## Scope

`MTPRO Release v0.9.1 v0.9.0 Audit Hardening Patch` 只收口 v0.9.0 tag 静态审计发现的边界漂移风险：

- v0.9.0 public release publication facts 必须写入 release notes、Stage Code Audit、release publication policy、latest verification summary 和 aggregate verifier。
- Dashboard macOS lane 必须显式运行 v0.9.0 Dashboard focused guards，且位于 Dashboard build / smoke 之前。
- `mtpro verify` 当前输出必须是 `mtpro verify v0.9.0`，同时保留 v0.8.0 / v0.7.0 historical checks。
- CLI runtime mode 当前口径必须是 `local-dry-run / testnet-read-only-monitor / recovery-observe / production-blocked`，`testnet-read-only-probe` 只作为 legacy mode。
- `mtpro monitor start/status/recover/stop/export` 必须绑定 `ReleaseV090TestnetReadOnlyMonitorSessionStore`，而不是只输出字符串 evidence。

## Evidence Chain

- `checks/verify-v0.9.1-dashboard-macos-v090-guards.sh`
- `checks/verify-v0.9.1-cli-verify-v090-wording.sh`
- `checks/verify-v0.9.1.sh`
- `Tests/TargetGraphTests/TargetGraphTests.swift::testV091DashboardGuardAndCLIMonitorStoreBindingPatch`
- `.github/workflows/checks.yml` Dashboard macOS focused guard step
- `Sources/MTPROCLI/main.swift` v0.9.0 verify wording and monitor store binding

Validation anchors:

- `V091-002-VERIFY-DASHBOARD-MACOS-V090-GUARDS`
- `TVM-RELEASE-V091-DASHBOARD-MACOS-V090-GUARDS`
- `V091-003-VERIFY-CLI-VERIFY-V090-WORDING`
- `TVM-RELEASE-V091-CLI-VERIFY-V090-WORDING`
- `V091-006-VERIFY-PATCH-AUDIT-DOCS-RUNBOOK`
- `TVM-RELEASE-V091-PATCH-AUDIT-DOCS-RUNBOOK`

## Audit Findings Closed

| Finding | Closeout |
| --- | --- |
| v0.9.0 publication docs wording drift | v0.9.0 release URL and target commit are now part of release notes, Stage Code Audit, publication policy, latest verification summary, README and `checks/verify-v0.9.0.sh`. |
| Dashboard macOS lane lacked explicit v0.9 Dashboard guard | `.github/workflows/checks.yml` now runs `checks/verify-v0.9.1-dashboard-macos-v090-guards.sh` before Dashboard build / smoke. |
| `mtpro verify` still spoke as v0.8.0 | `mtpro verify` now prints `mtpro verify v0.9.0`, `issue=GH-856`, and v0.9.0 validation / verification anchors while retaining historical v0.8.0 and v0.7.0 checks. |
| probe / monitor naming drift | Current help output lists `testnet-read-only-monitor`; `testnet-read-only-probe` remains explicit legacy compatibility only. |
| CLI monitor actions were evidence-only | `mtpro monitor` now writes / reads `ReleaseV090TestnetReadOnlyMonitorSessionStore` artifacts and emits store status checksum evidence. |

## Boundaries

- production trading 仍默认关闭。
- production cutover 仍未授权。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不发送 testnet 或 production order。
- 不新增 trading button、order form、live command。
- 不实现 production OMS。
- 不创建下一 Project / Issue。
- v0.9.1 不发布 tag；它是 v0.9.0 后的 audit hardening patch evidence。

## Validation

Required local validation:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.9.1.sh
bash checks/run.sh
```

`checks/verify-v0.9.1.sh` also runs the v0.9.0 Dashboard focused guards, CLI verify wording guard, and `TargetGraphTests/testV091DashboardGuardAndCLIMonitorStoreBindingPatch`.
