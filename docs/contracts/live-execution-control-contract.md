# Live Execution Control Contract

日期：2026-05-22

执行者：Codex

本文档定义 `MTPRO Live Execution Control Contract v1` 的 real order command、submit / cancel / replace、execution report、broker fill、reconciliation 和 blocked evidence 边界。它不实现 live command、order form、ExecutionClient production adapter、OMS production runtime 或真实订单。

## Shared Boundary

| 能力 | 当前状态 |
| --- | --- |
| real order command | terminology / future gate only |
| submit / cancel / replace | forbidden in current scope |
| execution report / broker fill | future gate / blocked evidence only |
| reconciliation | blocked evidence only |
| Dashboard / Report / Timeline surface | read-model-only |
| command surface | not executable |

## Anchor Ledger

| Anchor | 压缩说明 |
| --- | --- |
| MTP-75-LIVE-EXECUTION-CONTROL-TERMINOLOGY | live execution control 只定义术语 |
| MTP-75-REAL-ORDER-COMMAND-TAXONOMY | real order command taxonomy 只作为 future gate |
| MTP-75-PAPER-REAL-COMMAND-ISOLATION | paper command 与 real command 隔离 |
| MTP-75-NO-EXECUTABLE-COMMAND-SURFACE | 当前无 executable command surface |
| MTP-76-SUBMIT-CANCEL-REPLACE-FUTURE-GATES | submit / cancel / replace 需要 future gates |
| MTP-76-FORBIDDEN-SUBMIT-CANCEL-REPLACE-CAPABILITY-TESTS | forbidden tests 覆盖 submit / cancel / replace |
| MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE | 当前无 real submit / cancel / replace |
| MTP-76-PAPER-INTENT-NO-REAL-COMMAND-UPGRADE | paper intent 不能升级为 real command |
| MTP-77-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-FUTURE-GATES | execution report / broker fill / reconciliation 都是 future gates |
| MTP-77-FORBIDDEN-REPORT-FILL-RECONCILIATION-CAPABILITY-TESTS | forbidden tests 覆盖 report / fill / reconciliation |
| MTP-77-SIMULATED-FILL-NO-BROKER-FILL-OR-EXECUTION-REPORT | simulated fill 不等于 broker fill 或 execution report |
| MTP-77-RECONCILIATION-BLOCKED-EVIDENCE-ONLY | reconciliation 只记录 blocked evidence |
| MTP-78-PAPER-REAL-COMMAND-ISOLATION-CONTRACT | paper / real command isolation contract |
| MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE | paper evidence 不升级为 real command |
| MTP-78-PAPER-PROJECTION-READ-MODEL-ONLY | paper projection 是 read-model-only |
| MTP-78-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY | Report / Dashboard / Timeline 只展示 read model |
| MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE | live execution control blocked evidence |
| MTP-79-EXECUTION-CONTROL-GATES-BLOCKED-REASONS | blocked reasons 记录 missing gates |
| MTP-79-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT | deterministic blocked evidence snapshot |
| MTP-79-READ-MODEL-ONLY-NO-COMMAND-SURFACE | read-model-only，无 command surface |
| MTP-80-DASHBOARD-REPORT-TIMELINE-EXECUTION-CONTROL-BLOCKED-EVIDENCE | Dashboard / Report / Timeline 展示 blocked evidence |
| MTP-80-EXECUTION-CONTROL-READ-MODEL-ONLY-SURFACE | execution control surface 是 read-model-only |
| MTP-80-NO-LIVE-COMMAND-OR-ORDER-FORM | 无 live command 或 order form |
| MTP-81-LIVE-EXECUTION-CONTROL-STAGE-CLOSEOUT | stage closeout |
| MTP-81-STAGE-AUDIT-INPUT-MATERIAL | Stage Audit input material |
| MTP-81-NO-FINAL-STAGE-CODE-AUDIT | 不生成 final Stage Code Audit |
| MTP-81-LIVE-EXECUTION-CONTROL-VALIDATION-EVIDENCE-CHAIN | validation evidence chain |

## Validation Contract

- 禁止真实 submit / cancel / replace。
- 禁止 execution report、broker fill、broker reconciliation runtime。
- 禁止 order form、live command、trading button。
- 所有 surface 必须保持 read-model-only，并能输出 deterministic blocked evidence。
