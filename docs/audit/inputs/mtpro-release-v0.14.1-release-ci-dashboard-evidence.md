# MTPRO Release v0.14.1 Release CI / Dashboard Evidence Input

日期：2026-06-22

执行者：Codex

## Scope

GH-1059 / `V141-001 Add release CI and macOS Dashboard evidence for v0.14.x` 只补强 v0.14.x release evidence chain。它把 v0.14.0 public release、terminal PR、Linux required checks、macOS Dashboard build / smoke、tag push workflow 和 `checks/run.sh` 输出路径写成可验证 audit input。

v0.14.1 是 hardening patch，不新增 runtime pipeline。它不实现 v0.15.0 real signed Binance Spot testnet runner，不读取真实 secret，不连接 production endpoint / broker endpoint，也不发送真实订单。

## Validation Anchors

- `GH-1059-VERIFY-V0141-RELEASE-CI-DASHBOARD-EVIDENCE`
- `TVM-RELEASE-V0141-RELEASE-CI-DASHBOARD-EVIDENCE`
- `V0141-001-RELEASE-CI-DASHBOARD-EVIDENCE`
- `V0141-001-V0140-TAG-RELEASE-CHECKS`
- `V0141-001-DASHBOARD-MACOS-EVIDENCE`
- `V0141-001-NO-PRODUCTION-CUTOVER`

## v0.14.0 Release Evidence

| Evidence | Current fact |
| --- | --- |
| GitHub Release | `https://github.com/atxinbao/MTPRO/releases/tag/v0.14.0` |
| Release title | `MTPRO v0.14.0 Testnet Trading Closed Loop / Execution Engine Foundation` |
| Release state | stable；`isDraft=false`；`isPrerelease=false` |
| Published at | `2026-06-21T22:50:08Z` |
| Tag | `v0.14.0` |
| Tag peeled commit | `5ec84cd02adb425fb533fdf7337673746b51c8be` |
| Release target commitish | `5ec84cd02adb425fb533fdf7337673746b51c8be` |

## PR / Checks Evidence

| Evidence | Current fact |
| --- | --- |
| Terminal PR | PR #1058 `Add v0.14 read-only execution dashboard` |
| PR URL | `https://github.com/atxinbao/MTPRO/pull/1058` |
| PR state | `MERGED` |
| PR merged at | `2026-06-21T22:48:51Z` |
| PR merge commit | `5ec84cd02adb425fb533fdf7337673746b51c8be` |
| PR workflow run | `27919195332` |
| Required check | `checks` SUCCESS |
| Linux check | `linux-checks` SUCCESS |
| macOS Dashboard check | `dashboard-macos` SUCCESS |

## Tag Push Workflow Evidence

| Evidence | Current fact |
| --- | --- |
| Tag push Actions run | `27919993831` |
| Run title | `Add v0.14 read-only execution dashboard (#1058)` |
| Run status | `completed` |
| Run conclusion | `success` |
| Linux job | `linux-checks` SUCCESS；includes Swift toolchain verification, sqlite headers, `git diff --check`, and `bash checks/run.sh` |
| macOS Dashboard job | `dashboard-macos` SUCCESS；includes macOS Swift toolchain verification, focused Dashboard guards, `swift build --product Dashboard`, and `DASHBOARD_SMOKE=1 swift run Dashboard` |
| Aggregate job | `checks` SUCCESS |

## Guarded Commands

Required local / CI evidence commands:

```bash
bash checks/verify-v0.14.0-read-only-execution-dashboard.sh
bash checks/verify-v0.14.1-release-ci-dashboard-evidence.sh
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

The macOS `dashboard-macos` required job must run `bash checks/verify-v0.14.1-release-ci-dashboard-evidence.sh` before Dashboard build and smoke.

## Boundary

- production trading remains disabled by default.
- production cutover remains unauthorized.
- no production secret read.
- no production endpoint connection.
- no broker endpoint connection.
- no production order.
- no real submit / cancel / replace.
- no Dashboard trading button, order form, live command, or command surface.
- no v0.15.0 signed testnet runner implementation.

This document is an audit input for the v0.14.1 hardening patch. It does not create or move a tag, does not create a GitHub Release, and does not promote any v0.15.0 issue.

