# L4 Credential Environment Gate Contract

日期：2026-06-07

执行者：Codex

本文档服务 GitHub fallback issue `GH-453 L4: 02/21 Define credential / environment / sandbox / production gate`。

本文档定义 `MTPRO L4 Live Production / Trading Commands v1` 的 credential source identity、sandbox-only enablement gate、production cutover blocker 和 local / CI validation 边界。它不授权 Linear，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不读取或保存真实 API key / secret，不连接 signed endpoint、account endpoint、listenKey、private stream、sandbox endpoint 或 production endpoint，不实现 ExecutionClient adapter、OMS、Live PRO Console、order form 或真实 submit / cancel / replace。

## GH-453-L4-CREDENTIAL-ENVIRONMENT-GATE-CONTRACT

`GH-453-L4-CREDENTIAL-ENVIRONMENT-GATE-CONTRACT`

GH-453 是 GH-452 顶层 L4 command contract 的 credential / environment gate 细化。它只定义配置身份和 validation rule，不创建 runtime credential store。

当前权威 source anchor：

- `Sources/ExecutionClient/FutureGate/L4CredentialEnvironmentGateContract.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH453L4CredentialEnvironmentGateDefinesSandboxOnlyContract`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH453L4CredentialEnvironmentGateRejectsSecretAndProductionDefault`

合同固定：

- upstream issue：`GH-452`
- queue range：`GH-452..GH-472`
- maturity slice：`MTPRO L4 Live Production / Trading Commands v1`
- credential source identity 必须存在，但只能是身份，不是 secret value。
- sandbox-only enablement gate 必须存在，但当前不连接 sandbox network。
- production 默认关闭，production cutover 必须等到 `GH-471`。
- local validation 必须拒绝 secret value。
- CI validation 必须拒绝 production default。
- required validation 必须保持 network-independent。

## GH-453-CREDENTIAL-SOURCE-IDENTITY

`GH-453-CREDENTIAL-SOURCE-IDENTITY`

Credential source identity 只允许保存以下类型：

| Identity | Canonical environment key | Evidence |
| --- | --- | --- |
| venue environment | `MTPRO_L4_VENUE_ENVIRONMENT` | 环境身份，不连接 endpoint。 |
| credential reference | `MTPRO_L4_CREDENTIAL_REFERENCE` | 外部 credential 引用，不保存 API key 或 secret value。 |
| sandbox-only flag | `MTPRO_L4_SANDBOX_ONLY` | sandbox-only gate 身份，不在 validation 中连接网络。 |
| production cutover flag | `MTPRO_L4_PRODUCTION_CUTOVER` | 必须保持 blocked，直到 GH-471 production cutover gate。 |
| forbidden credential value | `MTPRO_L4_CREDENTIAL_VALUE` | 必须在仓库、日志、fixture、文档和 validation output 中保持缺席。 |

这些 key 是 identity / gate contract，不是运行时环境变量读取授权。当前 GH-453 不读取任何 key 的 value。

## GH-453-SANDBOX-ONLY-ENABLEMENT-GATE

`GH-453-SANDBOX-ONLY-ENABLEMENT-GATE`

Sandbox gate 的含义是后续 issue 可以在 sandbox scope 内逐步实现能力，但必须先证明：

```text
credential source identity
-> secret value redaction
-> sandbox-only enablement gate
-> production disabled by default
-> local / CI validation
```

GH-453 不实现 sandbox network connection。`connectsSandboxNetwork == false` 是本 issue 的验收边界，后续 GH-455 / GH-459 才能在各自 scope 内处理 read-only signed account runtime 或 sandbox submit / cancel / replace。

## GH-453-PRODUCTION-CUTOVER-BLOCKED-UNTIL-GH-471

`GH-453-PRODUCTION-CUTOVER-BLOCKED-UNTIL-GH-471`

Production gate 在 GH-453 中只能定义为 blocked：

- `productionDisabledByDefault == true`
- `productionTradingEnabledByDefault == false`
- `productionCutoverRequiresGH471 == true`
- `productionCutoverAllowedBeforeGH471 == false`
- `connectsProductionNetwork == false`

任何配置、环境变量、UI、test fixture 或 hidden flag 都不能在 #471 前打开 production trading。

## GH-453-LOCAL-CI-SECRET-PRODUCTION-VALIDATION

`GH-453-LOCAL-CI-SECRET-PRODUCTION-VALIDATION`

Local / CI validation 必须证明：

- 不读取 credential value。
- 不打印 credential value。
- 不保存 secret。
- 不构造 API-key header。
- 不生成 request signature。
- 不调用 signed endpoint、account endpoint 或 listenKey。
- 不打开 private stream。
- 不连接 sandbox 或 production network。
- 不实现 ExecutionClient adapter、OMS、Live command、Live PRO Console、order form 或真实订单命令。

Required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## GH-453-NON-AUTHORIZATION

`GH-453-NON-AUTHORIZATION`

GH-453 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- 真实 API key / secret 读取、保存、打印或提交。
- signed endpoint、account endpoint、listenKey 或 private stream runtime。
- sandbox 或 production network connection。
- ExecutionClient adapter implementation。
- OMS implementation。
- submit / cancel / replace。
- execution report、broker fill 或 reconciliation。
- Live PRO Console command surface。
- order form / trading button。
- production cutover 或 real trading enablement。
