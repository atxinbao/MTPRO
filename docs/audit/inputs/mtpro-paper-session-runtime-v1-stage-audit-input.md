# MTP-37 阶段审计输入材料

日期：2026-05-19

执行者：Codex

## 定位

本文档是 `MTPRO Paper Session Runtime v1` 的 MTP-37 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-31` 至 `MTP-37` 全部进入 Linear `Done` 后，由 Parent Codex 单独输出到：

```text
docs/audit/mtpro-paper-session-runtime-v1-stage-code-audit.md
```

本文档不授权下一 Project planning，不创建 Linear Project / Issue，不修改 Linear status，不启动下一阶段 `symphony-issue`。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO Paper Session Runtime v1`。
- Project ID：`b97c1070-b25e-4d36-a1c9-5ca8bd6e9d00`。
- Project URL：`https://linear.app/atxinbao/project/mtpro-paper-session-runtime-v1-524b3f883121`。
- `MTP-31` 至 `MTP-36`：`Done`。
- `MTP-37`：`In Progress`。
- 当前 issue scope 仅限 validation docs、automation evidence、known boundaries 和 Stage Code Audit 输入材料。

## Issue / PR evidence input

| Issue | Evidence domain | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- | --- |
| `MTP-31` | Paper Session lifecycle facts 和 `.paper` event log boundary | [#62 MTP-31 define Paper Session lifecycle](https://github.com/atxinbao/MTPRO/pull/62) | `b12099de8c28a3fccbc142239b0181da419f1007` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26049266906/job/76581455945) |
| `MTP-32` | Paper action proposal model、fixture 和 paper-only authorization | [#63 MTP-32 新增 Paper action proposal 最小模型](https://github.com/atxinbao/MTPRO/pull/63) | `4184933fde658fd8dd0dbe81f9820bc69492ed12` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26050249998/job/76584785176) |
| `MTP-33` | Strategy signal -> proposal -> risk blocker 本地 evidence 链路 | [#64 MTP-33 link paper proposals to risk blockers](https://github.com/atxinbao/MTPRO/pull/64) | `840e02230cd8e632c4cd417baa5b824c71bb7e52` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26051040064/job/76587403720) |
| `MTP-34` | Paper-only portfolio projection update path | [#65 MTP-34 新增 paper-only portfolio projection update path](https://github.com/atxinbao/MTPRO/pull/65) | `8250c7ab088077ff3f9ea277e252ff415a413cdd` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26052078591/job/76590891105) |
| `MTP-35` | Paper Session replay 和 deterministic evidence | [#66 MTP-35 add Paper Session replay evidence](https://github.com/atxinbao/MTPRO/pull/66) | `aa66ff53a6e96b558f2a994a8ec03d514ad8e9b0` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26053013626/job/76594084398) |
| `MTP-36` | Paper Session runtime evidence -> Report / Dashboard read model | [#67 MTP-36 汇总 Paper Session runtime evidence 到 Report / Dashboard read model](https://github.com/atxinbao/MTPRO/pull/67) | `7109184503a7b2addfa07f78cd2191a2eeed3ed0` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26054145509/job/76597907236) |
| `MTP-37` | validation summary、matrix 收口、automation evidence 和 Stage Code Audit 输入 | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` |

## Paper runtime validation evidence chain

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-PAPER-SESSION-LIFECYCLE` | Core lifecycle facts、`.paper` stream 写入边界和 deterministic lifecycle tests。 | 审计时确认 PR #62 只定义本地 paper-only facts，不把 lifecycle event 解释为真实订单、broker session 或账户状态。 |
| `TVM-PAPER-ACTION-PROPOSAL` | Core proposal model、long / flat signal 映射、deterministic sizing fixture、MTP-27 cost evidence 复用和 Codable 不变量。 | 审计时确认 PR #63 保持 `paperIntentOnly`，且 `isExecutableAsRealOrder == false`。 |
| `TVM-RISK-BLOCKER` | Paper action risk link、allowed / blocked deterministic decisions、source sequence 和 blocker evidence。 | 审计时确认 PR #64 不提供 broker fallback、Live execution fallback、真实风控通过或真实订单授权。 |
| `TVM-PORTFOLIO-EXPOSURE` | Allowed risk decision -> `PaperPortfolioProjectionUpdate` -> SQLite runtime projection -> Portfolio ViewModel。 | 审计时确认 PR #65 只生成 paper-only exposure projection，不读取真实账户余额、margin、leverage 或 broker position。 |
| `TVM-PAPER-SESSION-REPLAY` | Append-only event log replay -> lifecycle / proposal / risk blocker / portfolio projection deterministic summary。 | 审计时确认 PR #66 以 event log replay 为事实源，拒绝乱序 replay，不引入 broker event replay 或外部 execution venue。 |
| `TVM-REPORT-EVIDENCE` | Report / Dashboard 汇总 Paper runtime evidence、replay facts、proposal IDs、portfolio update IDs 和 paper-only boundary flags。 | 审计时确认 PR #67 只消费 read model / projection snapshot，不新增 UI command、risk control command、position management command 或交易执行入口。 |

## Automation readiness evidence

- `checks/automation-readiness.sh` 检查本 MTP-37 输入材料、latest verification summary、Trading Validation Matrix 和 validation plan 中的 MTP-37 anchors。
- GitHub PR Automation 仍负责 required check `checks`、squash auto-merge、branch cleanup 和 Linear bot auto Done。
- child Codex 只在当前 issue workspace 内提交文档 / 验证证据和 handoff marker；`.codex/*` 与 `graphify-out/*` 不进入 PR。
- Graphify post-merge resource relationship graph refresh 仍由 Symphony host-side Post-Issue Ledger 执行，不由 child Codex 在 sandbox 内强制执行。
- MTP-37 不修改 active Project pointer；Project 切换和 next Project planning 仍归 Parent Codex / Human + `@001 / PLN` 边界。

## Validation evidence

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；确认 MTP-37 输入材料、matrix、latest summary 和 automation anchors 完整。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test`；80 个 XCTest 通过，输出 `MTPRO checks passed.`。 |

## Known boundaries

- 本 Project 只覆盖本地 Paper Session runtime readiness。
- 不接 Live trading、signed endpoint、account endpoint、listenKey user data stream 或真实 broker action。
- 不提交、取消或替换真实订单。
- 不实现完整 execution engine、完整 order management system、margin、leverage 或真实账户余额。
- Paper action proposal 固定为本地意图证据，不代表订单、fill、broker action 或执行授权。
- Risk blocker evidence 只代表本地 Paper 风险阻断证据，不代表真实 broker 拒单、account state 或 Live fallback。
- Portfolio exposure 只代表 Paper projection 派生的 gross exposure evidence，不代表真实账户余额、margin、leverage、broker position 或真实成交。
- Report / Dashboard 只消费稳定 read model / projection snapshot，不暴露 SQLite / DuckDB schema、SQL、ORM model、runtime object 或 adapter request。

## Root Docs Delta input

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-37 输入结论 |
| --- | --- |
| `GOAL.md` | 项目目标仍是 Research -> Backtest -> Paper 一致性工作台；MTP-31 至 MTP-37 只建立本地 Paper Session runtime readiness，不改变 Live 禁区。 |
| `ENVIRONMENT.md` | 本 Project 未新增本地依赖或验证入口；统一验证入口仍是 `bash checks/run.sh`。 |
| `ARCHITECTURE.md` | Core / Persistence / App / Dashboard 既有模块边界继续成立；新增事实沿着 paper-only event log、runtime projection 和 read-model-only Dashboard 路径流动。 |
| `ROADMAP.md` | Project 完成后需要由 Parent Codex 通过 Root Docs Refresh Gate 同步已发生事实；MTP-37 不直接修改下一阶段路线，不创建下一 Project / Issue。 |

## Stage Code Audit handoff checklist

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-31` 到 `MTP-37`。
- Issue / PR evidence：PR #62、#63、#64、#65、#66、#67 和 MTP-37 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：Live trading、signed endpoint、broker action、真实订单、数据库 schema leakage、Paper proposal authorization 和 Report execution authorization 禁区。
- Known CI Boundary：如本 Project 没有新增临时 CI 平台边界，应明确记录无新增；若 MTP-37 PR 暴露失败，按事实记录。
- Root Docs Delta：检查 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md`、`ROADMAP.md`。
- Residual Notes For Human Planning：下一阶段只作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
