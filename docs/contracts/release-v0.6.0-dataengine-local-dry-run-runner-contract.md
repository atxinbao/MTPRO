# Release v0.6.0 DataEngine Local Dry-run Runner Contract

日期：2026-06-14

执行者：Codex

本文档服务 GitHub fallback issue `GH-759 V060-005 Add DataEngine real local dry-run runner`。

## V060-005-DATAENGINE-LOCAL-DRY-RUN-RUNNER

`V060-005-DATAENGINE-LOCAL-DRY-RUN-RUNNER`

DataEngine 必须提供一个本地 dry-run runner。该 runner 只消费 deterministic local fixture / catalog input，经由现有 DataEngine operational dry-run path 生成 typed `DataEngineMarketEvent` envelope，并把同一批 envelope 写入本地 append-only run journal。

## V060-005-LOCAL-FIXTURE-CATALOG-ONLY

`V060-005-LOCAL-FIXTURE-CATALOG-ONLY`

Runner 输入只允许来自本地 deterministic market input 和 instrument catalog。GH-759 不连接 Binance live/testnet network，不读取 credential，不解析 production secret，不连接 production endpoint / broker endpoint。

## V060-005-DATAENGINE-MARKET-EVENT-JOURNAL-WRITE

`V060-005-DATAENGINE-MARKET-EVENT-JOURNAL-WRITE`

每个 DataEngine market event 必须携带 runID、streamID、sequence、payload type 和 `sha256:` envelope checksum evidence。Runner 必须把这些 envelope 追加到 `ReleaseV050DurableLocalRunJournal`，再通过 `ReleaseV060LocalRunJournalWriter` 写出 `events.jsonl`、`projection.json`、`summary.json`、`_RUN_STATUS.json` 和 `manifest.json`。

## V060-005-BINANCE-SPOT-USDM-PERP-BOUNDARY

`V060-005-BINANCE-SPOT-USDM-PERP-BOUNDARY`

GH-759 只覆盖 Binance venue，product boundary 只允许 Spot 与 USD-M Perpetual。任何 non-Binance venue、非 Spot / USD-M Perpetual product、signed/account/private-stream/order capability 都不属于本 issue scope。

## V060-005-NO-NETWORK-SECRET-ORDER

`V060-005-NO-NETWORK-SECRET-ORDER`

GH-759 不实现 URLSession / URLRequest runtime，不保存或读取 API key / secret，不生成 HMAC / signature，不调用 ExecutionClient、broker、OMS 或 submit / cancel / replace。production trading 仍默认关闭，production cutover 仍未授权。

## TVM-RELEASE-V060-DATAENGINE-LOCAL-DRY-RUN-RUNNER

`TVM-RELEASE-V060-DATAENGINE-LOCAL-DRY-RUN-RUNNER`

Validation 入口：

- `swift test --filter TargetGraphTests/testGH759DataEngineLocalDryRunRunnerWritesMarketEventsToLocalRunJournal`
- `bash checks/verify-v0.6.0-dataengine-local-dry-run-runner.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

GH-759 不使用 Linear，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不连接 production endpoint，不读取 production secret，不调用 broker，不提交真实订单，不授权 production cutover。
