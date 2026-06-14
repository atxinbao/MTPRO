# Live Risk Gate Contract

日期：2026-05-22

执行者：Codex

本文档定义 `MTPRO Live Risk Gate Contract v1` 的 future risk decision、exposure / notional / frequency / loss / drawdown / circuit breaker / no-trade 边界。它不实现 live risk runtime、真实账户风控、real pre-trade allow / reject、production no-trade state 或 emergency stop。

## Shared Boundary

| 能力 | 当前状态 |
| --- | --- |
| future risk decision | taxonomy / future gate only |
| exposure / order notional | future gate / blocked evidence |
| frequency / loss / drawdown | future gate / blocked evidence |
| circuit breaker / no-trade | future gate / blocked evidence |
| paper risk evidence | cannot upgrade to live risk |
| Dashboard / Report / Timeline | read-model-only |

## Anchor Ledger

| Anchor | 压缩说明 |
| --- | --- |
| MTP-82-LIVE-RISK-TERMINOLOGY | live risk terminology |
| MTP-82-FUTURE-RISK-DECISION-TAXONOMY | future risk decision taxonomy |
| MTP-82-PAPER-RISK-LIVE-RISK-SEPARATION | paper risk 与 live risk 隔离 |
| MTP-82-NO-LIVE-RISK-RUNTIME | 当前无 live risk runtime |
| MTP-82-LIVE-RISK-GATE-VALIDATION | live risk gate validation |
| MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES | exposure / order notional future gates |
| MTP-83-FORBIDDEN-ACCOUNT-POSITION-MARGIN-LEVERAGE-TESTS | forbidden account / position / margin / leverage tests |
| MTP-83-NO-REAL-PRE-TRADE-ALLOW-REJECT | 无 real pre-trade allow / reject |
| MTP-83-PAPER-EXPOSURE-NO-LIVE-EXPOSURE-UPGRADE | paper exposure 不升级为 live exposure |
| MTP-83-LIVE-RISK-GATE-VALIDATION | validation anchor |
| MTP-84-FREQUENCY-LOSS-DRAWDOWN-FUTURE-GATES | frequency / loss / drawdown future gates |
| MTP-84-FORBIDDEN-FREQUENCY-LOSS-DRAWDOWN-RUNTIME-TESTS | forbidden runtime tests |
| MTP-84-NO-REAL-PNL-EQUITY-OR-DRAWDOWN-ENFORCEMENT | 不执行 real PnL / equity / drawdown enforcement |
| MTP-84-PAPER-RISK-EXPOSURE-NO-LIVE-RISK-UPGRADE | paper risk / exposure 不升级为 live risk |
| MTP-84-LIVE-RISK-GATE-VALIDATION | validation anchor |
| MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES | circuit breaker / no-trade future gates |
| MTP-85-FORBIDDEN-CIRCUIT-BREAKER-NO-TRADE-RUNTIME-TESTS | forbidden circuit breaker / no-trade tests |
| MTP-85-NO-CIRCUIT-BREAKER-OR-NO-TRADE-STATE-RUNTIME | 无 circuit breaker 或 no-trade state runtime |
| MTP-85-PAPER-RISK-EXPOSURE-NO-CIRCUIT-BREAKER-UPGRADE | paper evidence 不升级为 circuit breaker |
| MTP-85-LIVE-RISK-GATE-VALIDATION | validation anchor |
| MTP-86-PAPER-RISK-LIVE-DECISION-ISOLATION-CONTRACT | paper risk / live decision isolation contract |
| MTP-86-PAPER-RISK-EVIDENCE-NO-FUTURE-LIVE-RISK-DECISION | paper evidence 不等于 future live risk decision |
| MTP-86-PAPER-EXPOSURE-NO-REAL-ACCOUNT-RISK-INPUT | paper exposure 不读取 real account risk input |
| MTP-86-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY | Report / Dashboard / Timeline read-model-only |
| MTP-86-LIVE-RISK-GATE-VALIDATION | validation anchor |
| MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE | live risk gate blocked evidence |
| MTP-87-LIVE-RISK-GATES-BLOCKED-REASONS | blocked reasons |
| MTP-87-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT | deterministic blocked evidence snapshot |
| MTP-87-READ-MODEL-ONLY-NO-COMMAND-SURFACE | read-model-only，无 command surface |
| MTP-87-LIVE-RISK-GATE-VALIDATION | validation anchor |
| MTP-88-LIVE-RISK-GATE-STAGE-CLOSEOUT | stage closeout |
| MTP-88-STAGE-AUDIT-INPUT-MATERIAL | Stage Audit input material |
| MTP-88-NO-FINAL-STAGE-CODE-AUDIT | 不生成 final Stage Code Audit |
| MTP-88-LIVE-RISK-GATE-VALIDATION-EVIDENCE-CHAIN | validation evidence chain |
| MTP-88-AUTOMATION-READINESS-STAGE-CLOSEOUT | automation readiness stage closeout |

## Validation Contract

- 禁止读取真实账户、真实持仓、margin、leverage、real PnL、equity。
- 禁止 real pre-trade allow / reject runtime。
- 禁止 circuit breaker / no-trade command runtime。
- paper risk evidence 只能作为 read-model-only evidence，不能升级为 live risk decision。
