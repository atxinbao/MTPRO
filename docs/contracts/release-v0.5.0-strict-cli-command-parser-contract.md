# Release v0.5.0 Strict CLI Command Parser Contract

日期：2026-06-14

执行者：Codex

本文档服务 GitHub fallback issue `GH-727 V050-02 Strict CLI command parser`。

本文档定义 `mtpro` executable 的 v0.5.0 strict command parser。该 parser 只负责命令入口、help/status/run/verify shape、历史只读命令白名单和未知命令失败语义；不实现 runtime、不连接 endpoint、不读取 secret、不发送真实订单、不授权 production cutover。

## V050-02-STRICT-CLI-COMMAND-PARSER

`V050-02-STRICT-CLI-COMMAND-PARSER`

GH-727 的 source anchor：

- `Sources/MTPROCLI/main.swift` 中的 `MTPROStrictCLI`
- `checks/verify-v0.5.0-cli.sh`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH727StrictCLICommandParserRejectsUnknownFallback`
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RELEASE-V050-STRICT-CLI-COMMAND-PARSER`

`MTPROStrictCLI` 必须成为 `main.swift` 的唯一 top-level router。未知命令必须在进入旧 release surface 前失败，并输出 `mtpro.strict.arguments`。

## V050-02-HELP-RUN-STATUS-VERIFY-SHAPE

`V050-02-HELP-RUN-STATUS-VERIFY-SHAPE`

v0.5.0 新 shape 固定为：

- `help`
- `run`
- `status [runID]`
- `verify`

`help` 必须列出完整支持命令集合。`run` 在 GH-727 中只能输出 blocked dry-run shape，不启动 runtime。`status` 只能显式桥接到 v0.4.0 read-model-only `unified-run-status`。`verify` 只输出本地验证入口和 strict parser 证据，不执行 shell、不连接 endpoint。GH-737 后新增的 `run-observer` 也是显式只读 observer route，不属于未知命令 fallback。

## V050-02-LEGACY-COMMAND-WHITELIST

`V050-02-LEGACY-COMMAND-WHITELIST`

历史命令只能通过白名单显式路由：

- `rehearsal-status`
- `unified-run-status`
- `run-observer`
- `verify-fast`
- `verify-release`

白名单以外的 `spot`、`perp`、`strategy`、`risk`、`execution`、`submit`、`cancel`、`replace` 或任何未知 token 都不得 fallback 到旧 v0.2 / v0.3 / v0.4 surface。

## V050-02-UNKNOWN-COMMAND-FAILS-NONZERO

`V050-02-UNKNOWN-COMMAND-FAILS-NONZERO`

未知命令必须满足：

- process exits non-zero。
- output 包含 `mtpro error:`。
- output 包含 `mtpro.strict.arguments`。
- 不输出 `mtpro verify-fast pass`。
- 不输出 `mtpro rehearsal-status blocked`。
- 不输出 `mtpro unified-run-status blocked`。

## V050-02-NO-PRODUCTION-CLI-SIDE-EFFECT

`V050-02-NO-PRODUCTION-CLI-SIDE-EFFECT`

GH-727 CLI parser 必须保持：

- `productionTradingEnabledByDefault=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`
- `testnetConnected=false` for `run`
- `runtimeStarted=false` for `run`

## TVM-RELEASE-V050-STRICT-CLI-COMMAND-PARSER

`TVM-RELEASE-V050-STRICT-CLI-COMMAND-PARSER`

Required validation：

- `swift test --filter TargetGraphTests/testGH727StrictCLICommandParserRejectsUnknownFallback`
- `bash checks/verify-v0.5.0-cli.sh`
- `bash checks/verify-v0.5.0-preflight.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## V050-02 Non-authorization

GH-727 不授权：

- runtime implementation。
- testnet endpoint connection。
- testnet credential value read。
- production trading。
- production secret read。
- production endpoint connection。
- production broker connection。
- production order submission。
- production cutover authorization。
- signed endpoint / account endpoint / listenKey。
- private WebSocket runtime。
- real submit / cancel / replace。
- trading button / live command / order form。
- Live PRO Console command。
