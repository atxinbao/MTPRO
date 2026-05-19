# 最近验证摘要

日期：2026-05-19

执行者：Codex

## 定位

本文档是 MTPRO 最近验证和当前边界的轻量入口。

Agent / Graphify 默认读取本文档，不默认读取完整 `verification.md`。

完整 `verification.md` 只用于审计、追溯和 debug。

本文档不替代 PR evidence、Linear evidence、Stage Code Audit Report 或完整验证历史。

## 当前基线

- 当前 Project 状态必须从 Linear live-read 获取；仓库文档不固定 current issue、current Todo 或 active Project pointer。
- `MTPRO Paper Execution Workflow v1` 已写入 Linear；Project-level planning record 位于 `docs/planning/projects/mtpro-paper-execution-workflow-v1-plan.md`。
- 当前 Project 尚未完成；完成状态必须以 Linear Project status `Completed` 为准，并记录 `type=completed`、`completedAt` 非空。
- Project 全部有效 issues `Done` 只是 closure 前置条件；不能替代 Linear Project status `Completed`。
- Stage Code Audit Report 必须覆盖完整 Linear Project。
- Root Docs Refresh Gate 只同步已发生事实；Root Docs Delta 不决定下一阶段方向。
- 本轮 MTP-42 paper execution event log / replay / projection focused Core 链路已通过 `swift test --filter CoreTests/testPaperExecution`；最终 `bash checks/run.sh` 结果见本文件最近验证表和 `verification.md` 追加记录。
- 当前 main 已包含 `docs/reference/nautilus-trader/` reference study 汇总文档；它只作为 Linear 外 Product / Design / Architecture 参考和 root docs delta proposal，不授权执行。

## 最近工程事实

- `MTPRO NautilusTrader Reference Study` 已形成 @003 / PRD、@004 / DSG、@005 / ARC 三份角色文档，并由 @000 / AIE 汇总入口和 root docs delta proposal。
- Reference study 只服务 Human + `@001 / PLN` 后续规划判断，不写 Linear、不创建 Project / Issue、不推进 `Todo`、不启动 Symphony、不写业务代码。
- `MTPRO Paper Session Runtime v1` 已完成，planning record 位于 `docs/planning/projects/mtpro-paper-session-runtime-v1-plan.md`，Stage Code Audit Report 位于 `docs/audit/mtpro-paper-session-runtime-v1-stage-code-audit.md`。
- `MTP-37` 产生 Project 级 Stage Audit Input，路径为 `docs/audit/inputs/mtpro-paper-session-runtime-v1-stage-audit-input.md`。
- `MTP-38` 固化 `TVM-PAPER-EXECUTION-WORKFLOW`，定义 paper-only execution workflow contract。
- `MTP-39` 固化 `TVM-PAPER-ORDER-LIFECYCLE`，定义 paper order intent / lifecycle 的本地 paper-only evidence。
- `MTP-40` 固化 `TVM-PAPER-SIMULATED-FILL`，定义 allowed paper order intent -> deterministic simulated fill evidence 的本地 paper-only value model。
- `MTP-41` 固化 `TVM-PAPER-EXECUTION-DECISION`，定义 allowed risk decision -> paper order intent -> simulated fill evidence，以及 blocked risk decision 不生成 paper order 的本地 paper-only decision flow。
- `MTP-42` 串联 paper execution decision / order / simulated fill facts -> append-only event log -> deterministic replay -> replayed simulated fill evidence -> paper-only portfolio projection。
- 历史 `MTP-30` 阶段收口已迁入 `docs/audit/inputs/`，`docs/validation/` 不再存放 `MTP-xx` 命名的阶段输入文件。
- `@000 / AIE` 是当前 Codex / AI Engineer 协作入口；`@003 / PRD`、`@004 / DSG`、`@005 / ARC` 是 Linear 外 reference / root docs 角色。

## 最近验证

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 由 `bash checks/run.sh` 串联执行；覆盖 MTP-42 变更与当前 main reference study 文档合并状态。 |
| `bash checks/automation-readiness.sh` | pass | MTPRO automation readiness checks passed；确认当前 paper execution workflow anchors 和 root docs routing 可被机械检查定位。 |
| `swift build --product Dashboard` | pass | macOS dashboard executable 构建通过。 |
| `DASHBOARD_SMOKE=1 swift run Dashboard` | pass | Dashboard smoke 通过，sections=8，readModelOnly=true。 |
| `swift test --filter CoreTests/testPaperExecution` | pass | 8 个 focused XCTest，0 failures；覆盖 MTP-41 decision 和 MTP-42 event append / replay / projection focused path。 |
| `swift test` | pass | 93 个 XCTest，0 failures；覆盖 MTP-42 后完整 Core / Persistence / Runtime / App 回归。 |
| `bash checks/run.sh` | pass | 统一验证入口通过，输出 `MTPRO checks passed.`。 |

## 当前边界

- NautilusTrader reference study 不复制 NautilusTrader 代码，不引入 NautilusTrader 作为运行依赖，不直接修改 root docs，不写 Linear，不授权执行。
- Paper execution / order / fill / portfolio 语义全部是 paper-only evidence，不代表真实订单、真实成交、broker fill、account state 或 Live fallback。
- MTP-42 只定义 paper execution facts 写入、replay 和 portfolio projection 串联；portfolio update 只能从 replay 后的 paper-only simulated fill evidence 派生。
- MTP-41 只定义 paper execution decision 本地链路和 deterministic fixture；blocked risk decision 不生成 paper order，allowed decision 只生成 paper-only order / fill evidence。
- MTP-41 issue 本身不写 event log、不新增 replay / projection / ViewModel；MTP-42 只把已存在的 paper execution facts 串入 event log / replay / projection，不实现完整 execution engine、完整风险引擎、broker rejection fallback、真实撮合、真实成交回报、broker fill、account update、broker action、signed endpoint 或真实订单行为。
- Report / Dashboard 只展示 read model / ViewModel，不提供交易执行入口。
- Trading Validation Matrix 是 evidence routing 入口，不替代 Linear issue contract、PR evidence 或 Stage Code Audit Report。
- `docs/audit/inputs/` 只放阶段审计输入材料，不授权下一 Project planning 或 execution。
- `docs/audit/inputs/mtpro-paper-session-runtime-v1-stage-audit-input.md` 是 Paper Session Runtime 的阶段审计输入，不替代 canonical Stage Code Audit Report。
- 临时 CI 平台边界只记录在对应 Stage Code Audit Report；当前 main 无已知遗留 failing PR run。
- 不修改 Linear status。
- 不创建 Linear Project / Issue。
- 不启动 Symphony。
- 不运行 Graphify full rebuild。
- 不接 Live trading、signed endpoint、account endpoint、broker action 或真实订单行为。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

## 完整历史

完整验证流水账见 `../../verification.md`。
