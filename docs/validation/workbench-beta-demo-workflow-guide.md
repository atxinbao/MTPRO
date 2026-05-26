# Workbench Beta Demo Workflow Guide

日期：2026-05-27

执行者：Codex

## 定位

`MTP-124-DEMO-WORKFLOW-GUIDE`

本文档解释 local Workbench beta demo workflow 如何从 MTP-119 到 MTP-123 串联成同一条 deterministic acceptance evidence chain。它只服务 operator 理解和验证 local macOS Workbench beta，不新增 Runtime job、App read model、Dashboard behavior、production release 或 live readiness。

## Demo Workflow Map

`MTP-124-ACCEPTANCE-WORKFLOW-REFERENCE`

```text
MTP-119 local launch / install / environment verification
-> MTP-120 deterministic demo scenario / fixture wiring
-> MTP-121 Workbench first-run default demo state
-> MTP-122 Report / Dashboard / Events beta acceptance path
-> MTP-123 reproducible beta acceptance checklist / script
-> MTP-124 docs index / operator guide / demo workflow guide
```

该 workflow 只把已完成 L1 Paper Runtime、L1.5 Data Catalog / Scenario Replay 和 L2 Simulated Exchange / Backtest Parity evidence productize 成 local demo / acceptance path。它不是 production trading engine、production data platform、production matching runtime、真实 exchange runtime、broker / OMS readiness 或 live readiness。

## Stable Demo Identity

| 字段 | 固定值 |
| --- | --- |
| scenario id | `mtp-104-btcusdt-1m-first-scenario` |
| dataset version | `dataset-v1` |
| fixture version | `fixture-v1` |
| symbol / timeframe | `BTCUSDT` / `1m` |
| replay window | `1704067200...1704067380` |
| checksum | `fnv1a64:3c6cd4ff13cd4062` |
| freshness | `fresh` |
| quality verdict | `accepted` |
| report input version | `mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|fnv1a64:3c6cd4ff13cd4062|fresh|accepted` |

## Evidence Chain

| Stage | Evidence | Operator 判断 |
| --- | --- | --- |
| Local environment | `uname -s`、`swift --version`、`swift package resolve` | 本地 macOS + SwiftPM path 可运行 |
| Scenario replay | `scenarioReplayEvidence=1`、`scenarioQualityGates=6` | L1.5 deterministic scenario evidence 可被 Workbench 消费 |
| Simulated parity | `simulatedParityEvidence=1` | L2 simulated exchange / backtest parity evidence 可被 Workbench 消费 |
| First-run state | `defaultDemoState=default demo`、`defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario` | Workbench 启动后默认选择同一 demo |
| Acceptance path | `betaAcceptancePaths=1`、`betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario`、`betaAcceptanceTrace=5` | Report / Dashboard / Events 使用同一 demo scenario |
| Boundary evidence | `readModelOnly=true`、`workbenchReadModelOnly=true`、`liveMonitoringHealth=blocked` | UI 仍只消费 Read Model / ViewModel，Live 能力仍 blocked |

## Operator Demo Steps

1. 打开 `docs/index.md`，确认当前要验证的是 local Workbench beta，不是 production release 或 live readiness。
2. 阅读 `docs/validation/workbench-beta-operator-guide.md` 的前置边界和 quick path。
3. 运行 `bash checks/workbench-beta-acceptance.sh`。
4. 在 `.codex/beta-acceptance/<run-id>/dashboard-smoke.log` 中确认 stable smoke handles。
5. 在 `.codex/beta-acceptance/<run-id>/summary.log` 中确认 checklist 通过。
6. 若失败，按 operator guide 的 troubleshooting table 定位，不绕过 forbidden boundary。

## Known Limitations

`MTP-124-KNOWN-LIMITATIONS`

- Demo workflow 固定一个 deterministic fixture，不提供多 scenario browsing。
- Demo workflow 不下载真实历史数据，不运行 Runtime replay job，不启动 production scheduler。
- Demo workflow 不暴露 database schema、Runtime object、Adapter request 或 Core object inspector。
- Demo workflow 不包含 screenshot review、Figma sync、Graphify refresh、production packaging 或 release signing。
- Demo workflow 不替代 GitHub required check；PR 前仍必须运行 `bash checks/run.sh`。

## Forbidden Boundary

`MTP-124-FORBIDDEN-CAPABILITY-BOUNDARY`

Demo workflow 不得被解释为以下能力：

- production release、notarization、App Store distribution、auto-update、production deployment 或 cloud operations。
- live readiness、real account readiness、broker readiness 或 Live PRO Console readiness。
- signed endpoint、account endpoint、listenKey、API key / secret read。
- broker adapter、exchange execution adapter、`LiveExecutionAdapter`、OMS。
- real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation。
- trading button、live command、order-level command UI、emergency stop、shutdown 或 restore。

## Troubleshooting Pointers

`MTP-124-TROUBLESHOOTING-POINTERS`

- Scenario handle drift：检查 MTP-120 `WorkbenchBetaDemoScenarioSelection` 是否仍固定 `mtp-104-btcusdt-1m-first-scenario`。
- First-run handle drift：检查 MTP-121 `WorkbenchBetaFirstRunReadModel` / `DashboardViewModel.defaultWorkbenchBetaDemo` 是否仍消费同一 fixture。
- Acceptance trace drift：检查 MTP-122 `WorkbenchBetaAcceptancePathReadModel` 和 `PaperWorkflowEvidenceExplorerSection.workbenchBetaAcceptancePath`。
- Script failure：检查 MTP-123 `checks/workbench-beta-acceptance.sh` 和 `docs/validation/workbench-beta-acceptance-checklist.md`。
- Required gate failure：按 `bash checks/run.sh` 的阶段顺序定位，不通过 Graphify、Figma、signed endpoint、broker 或 live command 绕过。
