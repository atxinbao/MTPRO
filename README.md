# MTPRO

MTPRO 是 SwiftPM-first、local-first 的 macOS 原生专业交易工作台。它以 Research -> Backtest -> Report -> Paper -> guarded runtime evidence 的可追溯链路为基础，最终目标是专业版交易工作台：Live trading、实盘监控、实盘执行控制、实盘风险控制、实盘审计、事故回放和停机控制。

Latest completed release construction scope: `MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening`。

Historical guard retains previous Latest completed release construction scope: `MTPRO Release v0.10.0 Production Cutover Readiness Gate`。
Historical guard retains previous Latest completed release construction scope: `MTPRO Release v0.9.0 Testnet No-order Observability`。
Historical guard retains previous Latest completed release construction scope: `MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring`。

当前最新完成范围：`MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening`。它收口本地 readiness artifact store、manifest atomic IO、canonical JSON SHA256、bundle validation、shadow dry-run parity、Dashboard real artifact state、readiness CLI local artifact commands、fixed-point capital / exposure policy、kill switch / no-trade state model、auditable approval workflow transitions 和 final audit / release docs closure。v0.11.0 construction closeout 不创建 public tag / GitHub Release；production cutover 仍未授权。v0.10.0 已通过独立 public release publication gate 发布 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.10.0`，tag target commit：`7b0e1f8bb6a671cd3b96f7e7b020b803f8cea4b4`。该 publication 不授权 production cutover。

Historical completed release construction scope：`MTPRO Release v0.9.0 Testnet No-order Observability`。它是 testnet read-only no-order observability、persistent monitor session、signed account snapshot freshness、private stream heartbeat / staleness、monitor recovery observe、Dashboard observability timeline、alert read-model、Portfolio reconciliation timeline、Risk policy application audit、run monitor export bundle、validation lanes split、Dashboard / CLI operator UX 和 final audit / docs / runbook closure。v0.7.0 和 v0.8.0 均已通过各自独立 release publication gate 发布 stable GitHub Release；v0.8.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.8.0`。v0.9.0 也已通过独立 release publication gate 发布 stable GitHub Release；v0.9.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.9.0`，target commit：`4296bf73673fe0fd8f09e34c40ef2a3a9ba7e55c`。v0.9.1 patch evidence 收口 v0.9.0 audit hardening：Dashboard macOS v0.9 focused guard、`mtpro verify v0.9.0` wording、monitor store binding 和 probe / monitor naming；v0.9.1 已通过独立 release publication gate 发布 stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.9.1`，tag peeled commit：`d041f0dd304075562a85e494695697290972288f`。v0.8.1 patch evidence 只收口 release publication docs alignment、Dashboard macOS guard、CLI wording、local session wording、status artifact role、private stream redaction 和 patch docs；v0.9.0 construction closeout、v0.9.0 / v0.9.1 public GitHub Release publication 和 production cutover 仍是独立 gate；已发布事实、patch evidence、v0.9.0 construction evidence 和 v0.10.0 readiness evidence 均不授权 production cutover。

Historical completed release construction scope：`MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring`。

Historical completed release construction scope：`MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity`。

MTPRO 借鉴 `nautilus_trader` 的 Kernel / MessageBus / Cache / Engine / Adapter 分层思想，也参考 `macos-trader` 的产品语义；不引入 NautilusTrader 作为运行依赖，不复制 `macos-trader` 整仓代码。

## 当前边界

| 项 | 当前事实 |
| --- | --- |
| Current maturity statement | `MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening complete with production trading disabled by default and production cutover not authorized` |
| Active venue / products / strategies | `activeVenue == Binance`；`activeProductTypes == [spot, usdsPerpetual]`；`activeStrategies == [ema, rsi]` |
| Runtime modes | `runtimeModes == [local-dry-run, testnet-read-only-monitor, recovery-observe, production-blocked]` |
| Production default | `productionTradingEnabledByDefault == false` |
| Production capability | `productionCapabilityGatedNotMissing == true` |
| Historical boundary | `oldPublicReadOnlyPaperOnlyEMAOnlyIsHistorical == true` |

Production trading、production secret、production endpoint、production broker connection、testnet / production submit / cancel / replace、production OMS 和 production cutover 都没有默认启用，也没有被 v0.11.0 授权。后续执行只能来自 Human 指定的唯一 live queue source，并且必须经过 Parent Codex queue preflight。

## 必读入口

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

## 文档地图

| 文件 / 目录 | 作用 |
| --- | --- |
| `GOAL.md` | Project Charter：目标、受众、永久硬边界和成功标准 |
| `BLUEPRINT.md` | Canonical Blueprint：Root Blueprint + Complete Blueprint |
| `environment.md` | 本地环境、验证入口、外部系统能力和禁区 |
| `architecture.md` | Engineering Module Map / 工程模块地图：模块边界、依赖方向、数据流和不变量 |
| `docs/roadmap.md` | Construction Plan：根据蓝图和工程模块定义施工顺序、完成进度和下一阶段 handoff |
| `docs/domain/context.md` | Shared Language：领域术语、禁止混用词和 production-disabled-by-default 语义 |
| `docs/automation/` | Parent Codex、Execution Agent、PR automation、Post-Issue Ledger、readiness guards、AEP 方法论和从 `mattpocock/skills` 吸收的方法 |
| `docs/validation/` | 最近验证摘要、长期验证计划、trading validation matrix |
| `docs/audit/` | Project / release 级 Stage Code Audit 和 audit inputs |
| `docs/operators/`、`docs/release/` | release / operation runbook 和 release notes |

根文档层级：`GOAL.md` 定义目标和硬边界；`BLUEPRINT.md` 定义完整蓝图；`environment.md`、`architecture.md`、`docs/roadmap.md` 只能承接和细化蓝图，不能推翻它。

## 当前证据入口

| 类别 | 锚点 / 文件 |
| --- | --- |
| v0.11.0 | `GH-924-VERIFY-V0110-FINAL-AUDIT-RELEASE-DOCS`；`docs/audit/mtpro-release-v0.11.0-production-readiness-evidence-runtime-integrity-hardening-stage-code-audit.md`；`docs/release/mtpro-release-v0.11.0-production-readiness-evidence-runtime-integrity-hardening-notes.md`；`checks/verify-v0.11.0.sh`；construction closeout 不创建 public tag / GitHub Release；不授权 production cutover |
| v0.10.0 | `GH-891-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK`；`docs/audit/mtpro-release-v0.10.0-production-cutover-readiness-gate-stage-code-audit.md`；`docs/operators/release-v0.10.0-production-cutover-readiness-gate-runbook.md`；`docs/release/mtpro-release-v0.10.0-production-cutover-readiness-gate-notes.md`；`checks/verify-v0.10.0.sh`；stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.10.0`；tag target commit：`7b0e1f8bb6a671cd3b96f7e7b020b803f8cea4b4`；construction closeout、public release publication 和 production cutover 仍是独立 gate；不授权 production cutover |
| v0.9.1 patch release | `V091-006-VERIFY-PATCH-AUDIT-DOCS-RUNBOOK`；`docs/audit/mtpro-release-v0.9.1-v090-audit-hardening-stage-code-audit.md`；`docs/release/mtpro-release-v0.9.1-v090-audit-hardening-notes.md`；`checks/verify-v0.9.1.sh`；stable GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.9.1`；tag peeled commit：`d041f0dd304075562a85e494695697290972288f`；不授权 production cutover |
| v0.9.0 | `GH-856-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK`；`docs/audit/mtpro-release-v0.9.0-testnet-no-order-observability-stage-code-audit.md`；`docs/operators/release-v0.9.0-testnet-no-order-observability-runbook.md`；`docs/release/mtpro-release-v0.9.0-testnet-no-order-observability-notes.md`；`checks/verify-v0.9.0.sh` |
| v0.8.1 patch evidence | `GH-841-RELEASE-V081-PATCH-AUDIT-DOCS-RELEASE-NOTES`；`docs/audit/mtpro-release-v0.8.1-release-publication-dashboard-guard-patch-stage-code-audit.md`；`docs/release/mtpro-release-v0.8.1-release-publication-dashboard-guard-patch-notes.md`；`checks/verify-v0.8.1.sh` |
| v0.8.0 | `GH-820-RELEASE-V080-FINAL-AUDIT-DOCS-RUNBOOK`；`docs/audit/mtpro-release-v0.8.0-persistent-operator-runtime-testnet-read-only-monitoring-stage-code-audit.md`；`docs/operators/release-v0.8.0-operator-persistent-runtime-testnet-readonly-monitoring-runbook.md`；`docs/operators/release-v0.8.0-validation-lanes-runbook.md`；`docs/release/mtpro-release-v0.8.0-persistent-operator-runtime-testnet-read-only-monitoring-notes.md`；`checks/verify-v0.8.0.sh` |
| v0.7.0 | `GH-792-RELEASE-V070-FINAL-AUDIT-DOCS-RUNBOOK`；`docs/audit/mtpro-release-v0.7.0-operator-runtime-session-testnet-read-only-connectivity-stage-code-audit.md`；`docs/operators/release-v0.7.0-operator-runtime-session-testnet-readonly-connectivity-runbook.md`；`docs/release/mtpro-release-v0.7.0-operator-runtime-session-testnet-read-only-connectivity-notes.md`；`checks/verify-v0.7.0.sh` |
| Release publication policy | `docs/release/release-publication-policy.md`；`GH-808-RELEASE-PUBLICATION-POLICY`；`GH-835-V081-V080-ACTUAL-GITHUB-RELEASE`；`GH-879-V0100-V091-ACTUAL-GITHUB-RELEASE`；v0.7.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.7.0`；v0.8.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.8.0`；v0.9.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.9.0`；v0.9.1 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.9.1`；v0.10.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.10.0`；construction closeout、public release publication 和 production cutover remain separate gates |
| v0.6.0 | Historical `MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening`；`GH-766-RELEASE-V060-FINAL-AUDIT-ROOT-DOCS`；`docs/audit/mtpro-release-v0.6.0-local-operational-runtime-testnet-read-only-probe-hardening-stage-code-audit.md`；`docs/operators/release-v0.6.0-operator-local-operational-runtime-testnet-readonly-probe-runbook.md`；`docs/release/mtpro-release-v0.6.0-local-operational-runtime-testnet-read-only-probe-hardening-notes.md`；`checks/verify-v0.6.0.sh` |
| v0.5.0 | Historical `MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge`；`GH-739-RELEASE-V050-FINAL-AUDIT-RELEASE-DOCS`；`docs/audit/mtpro-release-v0.5.0-guarded-testnet-runtime-foundation-stage-code-audit.md`；`docs/operators/release-v0.5.0-operator-guarded-testnet-runtime-foundation-runbook.md`；`docs/release/mtpro-release-v0.5.0-guarded-testnet-runtime-foundation-notes.md`；`checks/verify-v0.5.0.sh` |
| v0.4.0 | `GH-709-RELEASE-V040-FINAL-STAGE-AUDIT-RELEASE-DOCS`；Historical release v0.4.0 evidence anchor |
| v0.3.0 | `GH-670-RELEASE-V030-FINAL-STAGE-AUDIT-RELEASE-DOCS`；Historical release v0.3.0 Stage Code Audit Report |
| v0.2.0 | `GH-596-RELEASE-V020-ROOT-DOCS-REFRESH`；`GH-564-RELEASE-V020-ROOT-DOCS-BOUNDARY-REFRESH`；Historical Latest completed release construction scope: `MTPRO Release v0.2.0`；`docs/audit/mtpro-release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-stage-code-audit.md` |

## 代码结构

`Sources/` 以 module boundary 组织：`DomainModel`、`MessageBus`、`DataClient`、`DataEngine`、`Cache`、`Database`、`Trader`、`Portfolio`、`RiskEngine`、`ExecutionEngine`、`ExecutionClient` 和 `Dashboard`。详细依赖方向、数据流和禁止边界见 `architecture.md`。

## 本地验证

```bash
bash checks/run.sh
```

轻量当前 release guard：

```bash
bash checks/verify-v0.11.0.sh
bash checks/verify-v0.10.0.sh
bash checks/verify-v0.9.1.sh
bash checks/verify-v0.9.0.sh
bash checks/verify-v0.8.1.sh
bash checks/verify-v0.8.0.sh
```

历史 v0.7 release guard：

```bash
bash checks/verify-v0.7.0.sh
```

`checks/run.sh` 串联 whitespace、automation readiness、release verifiers、Dashboard build / smoke 和 Swift tests。

## AEP 方法论

执行链路固定为 Human planning -> live queue source -> Parent Codex queue preflight -> unique Todo -> Codex Execution Agent -> GitHub PR Automation -> Stage Code Audit -> Root Docs / release docs refresh -> next Human planning。规则落点见 `AGENTS.md`、`docs/domain/context.md` 和 `docs/automation/agent-engineering-practices.md`。
