# MTPRO

MTPRO 是 SwiftPM-first、local-first 的 macOS 原生专业交易工作台。它以 Research -> Backtest -> Report -> Paper -> guarded runtime evidence 的可追溯链路为基础，最终目标是专业版交易工作台：Live trading、实盘监控、实盘执行控制、实盘风险控制、实盘审计、事故回放和停机控制。

Latest completed release construction scope: `MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring`。

当前最新完成范围：`MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring`。它是 persistent no-order operator runtime、manual Binance testnet read-only monitoring、read-only Dashboard / CLI operations、Risk policy profile、Portfolio reconciliation review、validation lanes split 和 final audit / docs / runbook closure。v0.7.0 和 v0.8.0 均已通过各自独立 release publication gate 发布 stable GitHub Release；v0.8.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.8.0`。construction closeout、public GitHub Release publication 和 production cutover 仍是三个独立 gate；已发布事实不授权 production cutover。

Historical completed release construction scope：`MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity`。

MTPRO 借鉴 `nautilus_trader` 的 Kernel / MessageBus / Cache / Engine / Adapter 分层思想，也参考 `macos-trader` 的产品语义；不引入 NautilusTrader 作为运行依赖，不复制 `macos-trader` 整仓代码。

## 当前边界

| 项 | 当前事实 |
| --- | --- |
| Current maturity statement | `MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring complete with production trading disabled by default` |
| Active venue / products / strategies | `activeVenue == Binance`；`activeProductTypes == [spot, usdsPerpetual]`；`activeStrategies == [ema, rsi]` |
| Runtime modes | `runtimeModes == [local-dry-run, testnet-read-only-monitor, recovery-observe, production-blocked]` |
| Production default | `productionTradingEnabledByDefault == false` |
| Production capability | `productionCapabilityGatedNotMissing == true` |
| Historical boundary | `oldPublicReadOnlyPaperOnlyEMAOnlyIsHistorical == true` |

Production trading、production secret、production endpoint、production broker connection、testnet / production submit / cancel / replace、production OMS 和 production cutover 都没有默认启用，也没有被 v0.8.0 授权。后续执行只能来自 Human 指定的唯一 live queue source，并且必须经过 Parent Codex queue preflight。

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
| v0.8.0 | `GH-820-RELEASE-V080-FINAL-AUDIT-DOCS-RUNBOOK`；`docs/audit/mtpro-release-v0.8.0-persistent-operator-runtime-testnet-read-only-monitoring-stage-code-audit.md`；`docs/operators/release-v0.8.0-operator-persistent-runtime-testnet-readonly-monitoring-runbook.md`；`docs/operators/release-v0.8.0-validation-lanes-runbook.md`；`docs/release/mtpro-release-v0.8.0-persistent-operator-runtime-testnet-read-only-monitoring-notes.md`；`checks/verify-v0.8.0.sh` |
| v0.7.0 | `GH-792-RELEASE-V070-FINAL-AUDIT-DOCS-RUNBOOK`；`docs/audit/mtpro-release-v0.7.0-operator-runtime-session-testnet-read-only-connectivity-stage-code-audit.md`；`docs/operators/release-v0.7.0-operator-runtime-session-testnet-readonly-connectivity-runbook.md`；`docs/release/mtpro-release-v0.7.0-operator-runtime-session-testnet-read-only-connectivity-notes.md`；`checks/verify-v0.7.0.sh` |
| Release publication policy | `docs/release/release-publication-policy.md`；`GH-808-RELEASE-PUBLICATION-POLICY`；`GH-835-V081-V080-ACTUAL-GITHUB-RELEASE`；v0.7.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.7.0`；v0.8.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.8.0`；construction closeout、public release publication 和 production cutover remain separate gates |
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
bash checks/verify-v0.8.0.sh
```

历史 v0.7 release guard：

```bash
bash checks/verify-v0.7.0.sh
```

`checks/run.sh` 串联 whitespace、automation readiness、release verifiers、Dashboard build / smoke 和 Swift tests。

## AEP 方法论

执行链路固定为 Human planning -> live queue source -> Parent Codex queue preflight -> unique Todo -> Codex Execution Agent -> GitHub PR Automation -> Stage Code Audit -> Root Docs / release docs refresh -> next Human planning。规则落点见 `AGENTS.md`、`docs/domain/context.md` 和 `docs/automation/agent-engineering-practices.md`。
