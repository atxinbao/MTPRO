# Release v0.20.0 Binance Spot Production-shadow No-order Capability Guard

日期：2026-06-30
执行者：Codex

## Scope

本合同对应 #1246 / GH-1246，固定 v0.20.0 Binance Spot production-shadow profile 的 no-order capability guard。

上游依赖：

- #1239 / GH-1239：v0.20.0 production-shadow / read-only live readiness 顶层合同。
- #1241 / GH-1241：Binance Spot production-shadow read-only endpoint allowlist。

本合同只证明 profile 不能创建、路由或执行 submit / cancel / replace，不实现 ExecutionClient order runtime，不触达 broker，不打开 production endpoint。

## Validation Anchors

- GH-1246-VERIFY-V0200-NO-ORDER-CAPABILITY-GUARD
- TVM-RELEASE-V0200-NO-ORDER-CAPABILITY-GUARD
- V0200-008-BINANCE-SPOT-PRODUCTION-SHADOW-NO-ORDER-CAPABILITY-GUARD
- V0200-008-SUBMIT-BLOCKED
- V0200-008-CANCEL-BLOCKED
- V0200-008-REPLACE-BLOCKED
- V0200-008-DASHBOARD-CLI-CANNOT-BYPASS
- V0200-008-NO-REAL-ORDER-INTENT
- V0200-008-NO-PRODUCTION-CUTOVER

## Blocked Capability Matrix

| Capability | Surface | Required State | Evidence |
| --- | --- | --- | --- |
| submit | ExecutionClient | blocked | `submit-blocked` |
| cancel | ExecutionClient | blocked | `cancel-blocked` |
| replace | ExecutionClient | blocked | `replace-blocked` |
| submit | Dashboard | bypass blocked | `dashboard-bypass-blocked` |
| cancel | CLI | bypass blocked | `cli-bypass-blocked` |

所有 evidence 必须包含：

- `order-capability=<blocked>`
- `real-order-intent=<not-created>`
- `transport=<not-invoked>`
- `order-payload=<not-persisted>`

## Dashboard / CLI Bypass Policy

Dashboard / CLI 只能展示或输出 no-order blocked evidence。它们不得创建 trading button、order form、live command、CLI order command、transport request 或 broker request。

## Forbidden Persistence / Runtime

本合同明确禁止：

- 不创建真实 order intent。
- 不生成 signed order material。
- 不触达 `/api/v3/order`。
- 不打开 endpoint connection。
- 不保存 order payload。
- 不提交 / 取消 / 替换订单。
- 不运行 Spot canary。
- 不引入 Futures runtime。
- 不引入 OKX active implementation。
- 不创建 tag / GitHub Release。
- Production cutover not authorized。

## Verification

验证入口：

- `swift test --filter TargetGraphTests/testGH1246ReleaseV0200NoOrderCapabilityGuard`
- `bash checks/verify-v0.20.0-no-order-capability-guard.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

该合同不读取 production secret，不连接 production endpoint / broker endpoint，不发送真实订单，不授权 production cutover。
