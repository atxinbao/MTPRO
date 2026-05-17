# Validation Plan

本文档定义 MTPRO 当前验证计划。

## 当前验证

```bash
swift test
bash checks/automation-readiness.sh
bash checks/run.sh
```

当前测试只验证 skeleton 和已确认边界：

- 项目名。
- Swift-only core。
- paper-only execution mode。
- TradingKernel actor boundary。
- MessageBus monotonic event stream。
- DataEngine read-only market event ingest。
- Cache deterministic replay projection。
- Binance read-only boundary。
- Binance public market data adapter contract。
- Binance public fixture decoding。
- Binance forbidden capability boundary。
- EMA cross strategy contract。
- EMA signal fixture。
- Backtest event flow。
- Paper session event flow。
- Backtest / Paper signal timeline parity。
- Order book snapshot / delta read model input。
- Order book imbalance signal fixture。
- Order book imbalance research event flow。
- Order book imbalance boundary rejection。
- Event Log replay persistence boundary。
- SQLite runtime projection boundary。
- DuckDB analytical projection boundary。
- Persistence projection isolation boundary。
- Top 5 USDT universe。
- `1m` / `5m` timeframe。
- Event Log / SQLite / DuckDB persistence boundary。
- Trader Workstation Dashboard 信息架构。
- Trader Workstation Dashboard ViewModel contract。
- Dashboard read model to ViewModel mapping。
- Dashboard ViewModel state snapshot contract。
- GitHub workflow required check contract。
- PR evidence template contract。
- WIP=1 queue boundary evidence contract。
- Linear issue execution contract。
- symphony-issue handoff marker evidence contract。
- Graphify resource relationship graph boundary contract。
- `.codex/*` 与 `graphify-out/*` 本地输出排除契约。

## MTP-15 验证矩阵

日期：2026-05-17

执行者：Codex

| 验证层 | 命令 / 证据 | 覆盖内容 | 通过标准 |
| --- | --- | --- | --- |
| 格式与 diff 卫生 | `git diff --check` | 空白、补丁格式、文本尾随空格 | 无错误输出 |
| 自动化就绪门槛 | `bash checks/automation-readiness.sh` | GitHub workflow、PR 模板、WIP=1、handoff marker、Graphify 边界、ignore 边界和验证文档 | 输出 `MTPRO automation readiness checks passed.` |
| 单元测试 | `swift test` | Core、Adapters、Persistence、App 既有 XCTest 契约 | 全部 XCTest 通过 |
| 冒烟测试 | `bash checks/run.sh` | 项目级本地验证入口串联 `git diff --check`、自动化就绪门槛和 `swift test` | 输出 `MTPRO checks passed.` |
| PR 证据检查 | `.github/pull_request_template.md` | Linked Linear Issue、Scope、Non-goals、Graphify、Validation、Evidence Chain、Pre-PR review、handoff marker、GitHub PR Automation Gate | PR body 填写后能逐项映射 MTP-15 evidence 要求 |
| 本地输出隔离 | `.gitignore`、`.graphifyignore`、Pre-PR review | `.codex/*`、`.codex/post-issue-ledger/*`、`graphify-out/*` 不进入 PR；Graphify 不纳入 `Sources/` 和 `Tests/` | `git status --short` 和 PR diff 中无被禁止输出 |
| Linear issue execution contract | Linear issue / `docs/planning/linear-draft-plan.md` / `AGENTS.md` | Scope、Non-goals、Codex Instructions、Validation、Boundary、PR Requirements 作为子 Codex 执行合同 | 子 Codex 不二次确认 issue scope，不重新定义边界 |

## MTP-15 当前验证补充

日期：2026-05-17

执行者：Codex

新增本地 shell gate：

- `checks/automation-readiness.sh` 检查 required check 名称必须为 `checks`。
- 检查 PR 模板包含 `Linked Linear Issue`、`WIP=1`、Graphify、symphony-issue Handoff、Parent Codex Supervision、Post-Issue Ledger 和 GitHub PR Automation Gate。
- 检查 `.gitignore` 排除 `.codex/` 与 `graphify-out/`。
- 检查 `.graphifyignore` 排除 `.codex/`、`graphify-out/`、`Sources/` 与 `Tests/`。
- 检查自动化文档明确 `MTP-15`、`WIP=1`、`symphony-issue handoff marker`、`host-side fallback`、`Post-Issue Ledger` 和 `read_only` 边界。
- 检查自动化文档明确 Linear issue execution contract，避免把子 Codex 执行前步骤变成人工确认环节。
- 检查 `docs/validation/validation-plan.md` 保留 MTP-15 验证矩阵和项目级验证入口。

## 后续验证

后续必须按阶段增加：

- market data replay tests。
- EMA cross backtest tests。
- paper / backtest parity tests。
- risk decision tests。
- persistence projection rebuild tests。
- UI ViewModel snapshot tests。

## MTP-14 当前验证补充

日期：2026-05-17

执行者：Codex

新增本地 XCTest 覆盖：

- `DashboardViewModel` 的 Market / Strategy / Backtest / Paper / Risk / Portfolio / Events source contract。
- SQLite runtime projection 和 DuckDB analytical projection 到 Dashboard read model / ViewModel 的字段映射。
- Dashboard ViewModel Codable round-trip 和稳定状态快照。

边界验证：

- ViewModel source contract 明确 `exposesDatabaseTables == false`。
- ViewModel source contract 明确 `exposesORMModels == false`。
- ViewModel source contract 明确 `exposesRuntimeObjects == false`。
- ViewModel source contract 明确 `callsBinanceAdapter == false`。
- ViewModel source contract 明确 `providesLiveOrderAction == false`。

## 当前禁止

当前不接真实 Binance 网络。

当前不写数据库。

当前不运行 live execution。
