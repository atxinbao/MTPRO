# MTPRO

MTPRO 是 SwiftPM-first、local-first 的 macOS 原生专业交易工作台。

它先建设 Research -> Backtest -> Report -> Paper 的可追溯证据链；最终目标是专业版交易工作台，包含 Live trading、实盘监控台、实盘执行控制、实盘风险控制和实盘审计 / 事故回放 / 停机控制。最新完成的 release construction scope 是 `MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge`：activeVenue == Binance，activeProductTypes == [spot, usdsPerpetual]，activeStrategies == [ema, rsi]，runtimeModes == [dry-run, testnet-guarded, production-blocked]，productionTradingEnabledByDefault == false。v0.5.0 是 guarded testnet runtime foundation closure；它不表示 production cutover、真实 broker、production endpoint、production secret read 或真实订单已获授权。v0.4.0 继续作为 historical unified runtime rehearsal pipeline evidence 保留。

MTPRO 借鉴 `nautilus_trader` 的 Kernel / MessageBus / Cache / Engine / Adapter 分层思想，也参考 `macos-trader` 的既有产品语义，但不引入 NautilusTrader 作为运行依赖，不复制 `macos-trader` 整仓代码。

## 默认读取

Agent 进入仓库时按以下顺序读取：

1. `README.md`
2. `AGENTS.md`
3. `GOAL.md`
4. `BLUEPRINT.md`
5. `environment.md`
6. `architecture.md`
7. `docs/roadmap.md`
8. `docs/domain/context.md`
9. `docs/validation/latest-verification-summary.md`

完整 `verification.md` 只在审计、追溯或 debug 时读取。

## 文档分工

| 文件 | 作用 |
| --- | --- |
| `GOAL.md` | Project Charter：为什么建、服务谁、永久硬边界和成功标准 |
| `BLUEPRINT.md` | Canonical Blueprint：Root Blueprint + Complete Blueprint，定义最终产品 / 系统 / 设计蓝图和 Current / Future 边界 |
| `environment.md` | Environment Boundary：本地环境、验证入口、外部系统能力和禁区 |
| `architecture.md` | Engineering Module Map / 工程模块地图：根据蓝图拆工程模块、边界、数据流、接口关系和不变量 |
| `docs/roadmap.md` | Construction Plan：根据蓝图和工程模块定义施工顺序、目标进度和下一阶段 handoff |
| `docs/domain/context.md` | Shared Language：领域术语、禁止混用词、release-gated / production-disabled-by-default 语义 |
| `docs/automation/agent-engineering-practices.md` | 从 `mattpocock/skills` 吸收的 feedback loop、tracer bullet、diagnose、architecture deepening 方法 |
| `docs/planning/` | Project Planning Record、角色编号和 Linear 草案规则 |
| `docs/automation/` | Parent Codex、Codex Execution Agent、GitHub PR Automation、Post-Issue Ledger 和 verified operations 边界 |
| `docs/validation/` | 最近验证摘要、长期验证计划、trading validation matrix |
| `docs/audit/` | Project 级 Stage Code Audit Reports 和 stage audit inputs |
| `verification.md` | append-only 完整验证流水账，仅用于审计、追溯和 debug |

`environment.md`、`architecture.md` 是根目录高权重承接文档，`docs/roadmap.md` 是施工路线文档。它们只能承接并细化 `BLUEPRINT.md`，不能推翻 `GOAL.md` 或 `BLUEPRINT.md`。

## 当前边界

- `GH-739-RELEASE-V050-FINAL-AUDIT-RELEASE-DOCS`
- Historical release v0.4.0 evidence anchor: `GH-709-RELEASE-V040-FINAL-STAGE-AUDIT-RELEASE-DOCS`
- Historical release v0.3.0 evidence anchor: `GH-670-RELEASE-V030-FINAL-STAGE-AUDIT-RELEASE-DOCS`
- `GH-564-RELEASE-V020-ROOT-DOCS-BOUNDARY-REFRESH`
- Latest completed release construction scope: `MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge`
- v0.5.0 release semantic: guarded testnet runtime foundation closure, not production cutover
- v0.4.0 release semantic: historical unified runtime rehearsal pipeline closure, not production cutover
- v0.3.0 release semantic: historical deterministic rehearsal evidence release, not a real testnet / shadow runtime runner
- v0.3.1 release semantic: historical rehearsal evidence hardening patch, still no production cutover
- activeVenue == Binance
- activeProductTypes == [spot, usdsPerpetual]
- activeStrategies == [ema, rsi]
- runtimeModes == [dry-run, testnet-guarded, production-blocked]
- historicalV040RehearsalModes == [dry-run, shadow, testnet-guarded, production-blocked]
- productionTradingEnabledByDefault == false
- productionCapabilityGatedNotMissing == true
- oldPublicReadOnlyPaperOnlyEMAOnlyIsHistorical == true
- Stage Code Audit Report: `docs/audit/mtpro-release-v0.5.0-guarded-testnet-runtime-foundation-stage-code-audit.md`
- Operator guarded testnet runtime foundation runbook: `docs/operators/release-v0.5.0-operator-guarded-testnet-runtime-foundation-runbook.md`
- Release notes: `docs/release/mtpro-release-v0.5.0-guarded-testnet-runtime-foundation-notes.md`
- Historical release v0.4.0 Stage Code Audit Report: `docs/audit/mtpro-release-v0.4.0-unified-runtime-rehearsal-pipeline-stage-code-audit.md`
- Historical release v0.4.0 Operator rehearsal runbook: `docs/operators/release-v0.4.0-operator-runtime-rehearsal-runbook.md`
- Historical release v0.4.0 Release notes: `docs/release/mtpro-release-v0.4.0-unified-runtime-rehearsal-pipeline-notes.md`
- Historical release v0.3.0 Stage Code Audit Report: `docs/audit/mtpro-release-v0.3.0-testnet-shadow-production-rehearsal-stage-code-audit.md`
- Historical release v0.3.0 Operator rehearsal runbook: `docs/operators/release-v0.3.0-operator-rehearsal-runbook.md`
- Historical release v0.2.0 evidence anchor: `GH-596-RELEASE-V020-ROOT-DOCS-REFRESH`
- Historical Latest completed release construction scope: `MTPRO Release v0.2.0`
- Historical Stage Code Audit Report: `docs/audit/mtpro-release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-stage-code-audit.md`
- Production capability 是 gated capability，不是缺失能力：只有后续 issue 明确授权、CommandGateway / RiskEngine / ExecutionEngine / OMS / Event Store / kill switch / no-trade / validation gates 全部通过时，才允许在 bounded scope 内推进。
- Production trading 默认关闭；production secret、production endpoint、production broker connection 和 real submit / cancel / replace 不得自动启用。
- Event Log 是 append-only facts source。
- SQLite / DuckDB 只作为 projection。
- Dashboard 只消费 ViewModel / Read Model / Command Model，不直接读取 adapter、database schema 或 runtime object；Workbench 只作为 historical product wording，不再是 active source module。
- `docs/roadmap.md`、planning record、Backlog issue、label、priority、assignee 或文档摘要都不授权执行。

正式开发只能来自 Human 指定的唯一 live queue source。`MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge` 使用 GitHub fallback issue queue；Linear 不参与本阶段执行。

```text
GitHub milestone / issues
-> Parent Codex queue preflight
-> unique Todo
-> Codex Execution Agent
-> GitHub PR Automation
```

## 代码结构

```text
Sources/
  DomainModel/       领域模型、事件、命令和 shared semantics
  MessageBus/        内部 command / event / request-response spine
  DataClient/        venue-scoped market/account/private evidence input boundary
  DataEngine/        ingest / replay / data quality / scenario boundary
  Cache/             instruments / market data / orders / positions cache boundary
  Database/          SQLite / DuckDB projection and persistence boundary
  Trader/            accounts + strategies(EMA/RSI release scope) + coordination container
  Portfolio/         portfolio / position / exposure read-model context
  RiskEngine/        paper / simulated / future live risk gate boundary
  ExecutionEngine/   paper / simulated execution lifecycle boundary
  ExecutionClient/   gated external execution client boundary
  Dashboard/         SwiftPM macOS dashboard shell
```

## 本地验证

```bash
bash checks/run.sh
```

`checks/run.sh` 串联 whitespace、automation readiness、Dashboard build / smoke 和 Swift tests。

## AEP 方法论

MTPRO 采用 AEP 编号方法论：

```text
0. New Project Initialization
1. Human Project Planning
2. Construction Plan / Linear Draft
3. Linear execution contract
4. Parent Codex project supervision
5. Codex Execution Agent single issue execution
6. GitHub PR Automation
7. Stage Code Audit
8. Root Docs Refresh / Current Phase Progress Bar
9. Next Human Project Planning
```

规则落点见 `AGENTS.md`、`docs/domain/context.md` 和 `docs/automation/agent-engineering-practices.md`。
