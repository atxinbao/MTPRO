# MTP-45 阶段审计输入材料

日期：2026-05-19

执行者：Codex

## 定位

本文档是 `MTPRO Paper Execution Workflow v1` 的 MTP-45 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-38`、`MTP-39`、`MTP-40`、`MTP-41`、`MTP-42`、`MTP-44`、`MTP-45` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed` 后，由 Parent Codex 单独输出到：

```text
docs/audit/mtpro-paper-execution-workflow-v1-stage-code-audit.md
```

本文档不授权下一 Project planning，不创建 Linear Project / Issue，不修改 Linear status，不推进下一 issue，不启动下一阶段 `symphony-issue`。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO Paper Execution Workflow v1`。
- Project ID：`1cfdb412-e08a-42f7-9393-906746552441`。
- Project URL：`https://linear.app/atxinbao/project/mtpro-paper-execution-workflow-v1-295c4d6a3684`。
- `MTP-38`、`MTP-39`、`MTP-40`、`MTP-41`、`MTP-42`、`MTP-44`：`Done`。
- `MTP-43`、`MTP-46`：`Duplicate`，不进入有效 issue queue。
- `MTP-45`：`In Progress`。
- 当前 issue scope 仅限 validation docs、automation evidence、known boundaries 和 Stage Code Audit 输入材料。

## Issue / PR evidence input

| Issue | Evidence domain | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- | --- |
| `MTP-38` | Paper-only execution workflow contract、stage order 和事件边界 | [#74 [codex] MTP-38 define paper execution workflow contract](https://github.com/atxinbao/MTPRO/pull/74) | `75e5de5f3277c42bf2473ed3e467d9d4387ab84a` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26096501615/job/76735545401) |
| `MTP-39` | Paper order intent / lifecycle 最小模型和 deterministic fixture | [#76 MTP-39 新增 paper order intent / lifecycle](https://github.com/atxinbao/MTPRO/pull/76) | `315f9572c6ae58c3d558819769b2cd55541a544d` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26097733822/job/76739910224) |
| `MTP-40` | Simulated fill evidence 最小模型、fixed cost evidence 复用和 paper-only capability flags | [#79 MTP-40 新增 simulated fill evidence](https://github.com/atxinbao/MTPRO/pull/79) | `7a02620e7078bc2325c55d573be26673c51f33ca` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26099487466/job/76746199884) |
| `MTP-41` | Proposal -> risk decision -> paper execution decision -> order / fill 本地链路 | [#80 [codex] MTP-41 paper execution decision flow](https://github.com/atxinbao/MTPRO/pull/80) | `8e1cbf60dcfde301ee4698fcdc211dc2bd5419ea` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26100710262/job/76750616170) |
| `MTP-42` | Paper execution events -> append-only event log -> replay -> portfolio projection | [#82 MTP-42 wire paper execution replay projection](https://github.com/atxinbao/MTPRO/pull/82) | `920c1f3b31d5d5173830dca71004c7fed2e77773` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26102599990/job/76757480635) |
| `MTP-44` | Paper execution workflow evidence -> Report / Dashboard read model | [#83 [codex] Add paper execution workflow report evidence](https://github.com/atxinbao/MTPRO/pull/83) | `761e0c3f964d4169e115edfa4969ba0c531aad53` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26103747285/job/76761704620) |
| `MTP-45` | validation summary、matrix 收口、automation evidence 和 Stage Code Audit 输入 | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` |

## Paper execution workflow validation evidence chain

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-PAPER-EXECUTION-WORKFLOW` | Workflow contract 固定 proposal -> risk decision -> paper execution decision -> paper order -> simulated fill -> portfolio projection 的 stage order、event stream boundary 和 paper-only capability flags。 | 审计时确认 PR #74、#76、#79、#80、#82、#83 共同保持本地 paper-only workflow，不实现完整 OMS、生产级 event sourcing、schema migration、signed endpoint、broker action 或真实订单行为。 |
| `TVM-PAPER-ORDER-LIFECYCLE` | Core order intent / lifecycle model 覆盖 allowed risk decision -> `intentCreated`、blocked risk decision -> `rejectedByRisk`、source risk decision sequence、workflow stage 和 `.paper` stream。 | 审计时确认 PR #76 不把 paper order intent 解释为真实订单、执行授权、cancel / replace 或 broker action。 |
| `TVM-PAPER-SIMULATED-FILL` | Simulated fill evidence 覆盖 allowed paper order intent -> deterministic simulated fill、fixed fee / slippage cost evidence、source order sequence 和 paper-only capability flags。 | 审计时确认 PR #79 不引入真实撮合、真实成交回报、broker fill、account update、动态滑点或交易所费率表。 |
| `TVM-PAPER-EXECUTION-DECISION` | Allowed risk decision 生成 paper execution decision、paper order intent 和 simulated fill evidence；blocked risk decision 不生成 paper order。 | 审计时确认 PR #80 不把 allowed decision 解释为真实订单授权，不把 blocked decision 解释为 broker rejection。 |
| `TVM-PAPER-SESSION-REPLAY` | Paper execution decision / order / fill facts 写入 append-only `.paper` stream，经 deterministic replay 汇总 workflow evidence。 | 审计时确认 PR #82 和 PR #83 以 append-only facts source 为边界，拒绝不可追溯 replay，不引入 broker event replay 或外部 execution venue。 |
| `TVM-PORTFOLIO-EXPOSURE` | Replayed simulated fill evidence 驱动 paper-only portfolio projection update，并由 SQLite runtime projection / read model 消费。 | 审计时确认 PR #82 不允许 portfolio projection 直接来自 risk decision、broker fill、account update、真实账户状态、margin、leverage 或 broker position。 |
| `TVM-REPORT-EVIDENCE` | Report / Dashboard read model 展示 decision IDs、paper order IDs、simulated fill IDs、workflow replay streams、portfolio update IDs、chain coverage 和 paper-only boundary flags。 | 审计时确认 PR #83 只消费 read model / ViewModel，不新增 UI command、risk control command、position management command、交易执行入口或数据库 schema 泄漏。 |

## Automation readiness evidence

- `checks/automation-readiness.sh` 检查本 MTP-45 输入材料、latest verification summary、Trading Validation Matrix 和 validation plan 中的 MTP-45 anchors。
- GitHub PR Automation 仍负责 required check `checks`、squash auto-merge、branch cleanup 和 Linear bot auto Done。
- child Codex 只在当前 issue workspace 内提交文档 / 验证证据和 handoff marker；`.codex/*` 与 `graphify-out/*` 不进入 PR。
- Graphify post-merge resource relationship graph refresh 仍由 Symphony host-side Post-Issue Ledger 执行，不由 child Codex 在 sandbox 内强制执行。
- MTP-45 不修改 active Project pointer；Project closure、Linear Project `Completed` status、最终 Stage Code Audit Report 和 Root Docs Refresh Gate 仍归 Parent Codex 边界。

## Validation evidence

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；确认 MTP-45 输入材料、matrix、latest summary 和 automation anchors 完整。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test`；93 个 XCTest 通过，输出 `MTPRO checks passed.`。 |

## Known boundaries

- 本 Project 只覆盖本地 paper-only execution workflow evidence chain。
- 不接 Live trading、signed endpoint、account endpoint、listenKey user data stream 或真实 broker action。
- 不提交、取消、替换或撮合真实订单。
- 不实现完整 execution engine、完整 OMS、完整风险引擎、broker rejection fallback、margin、leverage 或真实账户余额。
- Paper order intent 只代表本地 paper-only order evidence，不代表真实订单、broker order、exchange order 或执行授权。
- Simulated fill evidence 只代表 deterministic paper-only fill evidence，不代表真实成交、execution report、broker fill、account update 或 broker position。
- Portfolio projection 只从 replayed simulated fill evidence 派生，不读取真实账户余额、margin、leverage、broker position 或 account endpoint。
- Report / Dashboard 只消费稳定 read model / ViewModel，不暴露 SQLite / DuckDB schema、SQL、ORM model、runtime object 或 adapter request。
- Stage audit input 只准备 Parent Codex 审计材料，不替代最终 Stage Code Audit Report。

## Root Docs Delta input

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-45 输入结论 |
| --- | --- |
| `GOAL.md` | 项目目标仍是 Research -> Backtest -> Paper 一致性工作台；MTP-38 至 MTP-45 只建立本地 paper-only execution workflow evidence，不改变 Live 禁区。 |
| `ENVIRONMENT.md` | 本 Project 未新增本地依赖或验证入口；统一验证入口仍是 `bash checks/run.sh`。 |
| `ARCHITECTURE.md` | Core / Persistence / App / Dashboard 既有模块边界继续成立；新增事实沿着 paper-only workflow contract、append-only event log、runtime projection 和 read-model-only Dashboard 路径流动。 |
| `ROADMAP.md` | Project 完成后需要由 Parent Codex 设置或确认 Linear Project `Completed`，再通过 Stage Code Audit Report 和 Root Docs Refresh Gate 同步已发生事实；MTP-45 不直接修改下一阶段路线，不创建下一 Project / Issue。 |

## Stage Code Audit handoff checklist

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-38`、`MTP-39`、`MTP-40`、`MTP-41`、`MTP-42`、`MTP-44`、`MTP-45`；`MTP-43` 和 `MTP-46` 为 Duplicate，不进入有效 issue queue。
- Linear Project completion evidence：Project status `Completed`、`type=completed`、`completedAt` 非空。
- Issue / PR evidence：PR #74、#76、#79、#80、#82、#83 和 MTP-45 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：Live trading、signed endpoint、account endpoint、broker action、真实订单、真实成交、broker fill、account update、数据库 schema leakage、Report execution authorization 和 UI execution surface 禁区。
- Known CI Boundary：如本 Project 没有新增临时 CI 平台边界，应明确记录无新增；若 MTP-45 PR 暴露失败，按事实记录。
- Root Docs Delta：检查 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md`、`ROADMAP.md`。
- Residual Notes For Human Planning：下一阶段只作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
