# MTP-30 阶段审计输入材料

日期：2026-05-19

执行者：Codex

## 定位

本文档是 `MTPRO Trading Validation and Parity Hardening` 的 MTP-30 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-24` 至 `MTP-30` 全部进入 Linear `Done` 后，由 Parent Codex 单独输出到：

```text
docs/audit/mtpro-trading-validation-and-parity-hardening-stage-code-audit.md
```

本文档不授权下一 Project planning，不创建 Linear Project / Issue，不修改 Linear status，不启动下一阶段 `symphony-issue`。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO Trading Validation and Parity Hardening`。
- Project ID：`8903f10f-c2b5-4c40-87f3-2ede69364df3`。
- `MTP-24` 至 `MTP-29`：`Done`。
- `MTP-30`：`In Progress`。
- 当前 issue scope 仅限 validation summary、trading validation matrix、automation evidence 和 Stage Code Audit 输入材料。

## Issue / PR evidence input

| Issue | Evidence domain | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- | --- |
| `MTP-24` | Trading Validation Matrix 和验收证据边界 | [#52 MTP-24 定义 Trading Validation Matrix](https://github.com/atxinbao/MTPRO/pull/52) | `210a8acbc04193ff7782b8d8de7bcfe9f31a8e99` | `checks` success |
| `MTP-25` | EMA Backtest / Paper signal timeline parity | [#53 MTP-25 harden EMA parity validation](https://github.com/atxinbao/MTPRO/pull/53) | `0329e7c88b567d369bef3887311c0aba8a992fa7` | `checks` success |
| `MTP-26` | Order Book Imbalance research parity 和 bias evidence | [#55 MTP-26 harden order book imbalance parity evidence](https://github.com/atxinbao/MTPRO/pull/55) | `babd7303f5caa90921e9d5d712d49e330a88b61d` | `checks` success |
| `MTP-27` | fees / slippage 假设、fixture 和最小计算边界 | [#56 MTP-27 define fixed execution cost evidence](https://github.com/atxinbao/MTPRO/pull/56) | `fdfd25da8a4342ed0a5bc7089737644a6e29d6a4` | `checks` success |
| `MTP-28` | risk blocker evidence 和 portfolio exposure 只读指标 | [#57 Add risk blocker and portfolio exposure evidence](https://github.com/atxinbao/MTPRO/pull/57) | `a42018fc61c65937e4c39a7fe01e732671653b42` | `checks` success |
| `MTP-29` | Report / Dashboard trading validation evidence summary | [#58 MTP-29 汇总 Report / Dashboard 交易验证证据](https://github.com/atxinbao/MTPRO/pull/58) | `f34fc38c036210ec90f60f5ec465f9482eac027e` | `checks` success |
| `MTP-30` | validation summary、matrix 收口、automation evidence 和 Stage Code Audit 输入 | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` |

## Trading validation evidence chain

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-EMA-PARITY` | Core deterministic fixture 覆盖 EMA strategy config、`MarketDataQuery`、query range、warm-up、timestamp 和 signal timeline parity。 | 审计时确认 MTP-25 PR #53 和 `Tests/CoreTests/CoreTests.swift` 仍覆盖 range-too-narrow 拒绝边界。 |
| `TVM-ORDER-BOOK-IMBALANCE-PARITY` | Core parity 比较 direct contract 与 research event flow，DuckDB analytical projection 保留 snapshot / delta input source。 | 审计时确认 MTP-26 PR #55 保持 ask dominance research-only，不引入 short、margin 或真实订单动作。 |
| `TVM-FEES-SLIPPAGE` | Core deterministic fixed cost fixture 覆盖 maker / taker fee、fixed slippage、gross notional、rounding 和 Backtest / Paper cost parity。 | 审计时确认 MTP-27 PR #56 没有引入交易所费率表、动态滑点模型、真实成交或 broker fill。 |
| `TVM-RISK-BLOCKER` | Core / SQLite / App evidence 覆盖 proposed Paper action context、risk profile、blocker reason、source sequence 和 read-only ViewModel。 | 审计时确认 MTP-28 PR #57 没有引入完整风险引擎、实时风控、broker fallback 或 signed endpoint。 |
| `TVM-PORTFOLIO-EXPOSURE` | Paper-only exposure projection 覆盖 portfolio ID、symbol / timeframe、paper quantity、reference price 和 gross exposure notional。 | 审计时确认 MTP-28 PR #57 保持 exposure 为 Paper projection，不表达 margin、leverage、account endpoint 或真实 broker balance。 |
| `TVM-REPORT-EVIDENCE` | App / Dashboard 汇总 projection-level parity、cost evidence、risk blocker evidence 和 portfolio exposure evidence。 | 审计时确认 MTP-29 PR #58 不把 Report 当作交易执行授权，不暴露 SQLite / DuckDB schema，不替代 Core 层完整 parity。 |

## Automation readiness evidence

- `checks/automation-readiness.sh` 继续检查 GitHub workflow、PR template、WIP=1、Graphify ignore、Post-Issue Ledger、verified operations、trading validation matrix 和本 MTP-30 输入材料。
- GitHub PR Automation 仍负责 required check `checks`、squash auto-merge、branch cleanup 和 Linear bot auto Done。
- child Codex 只在当前 issue workspace 内提交代码 / 文档 / 验证证据和 handoff marker；`.codex/*` 与 `graphify-out/*` 不进入 PR。
- Graphify post-merge resource relationship graph refresh 仍由 Symphony host-side Post-Issue Ledger 执行，不由 child Codex 在 sandbox 内强制执行。
- MTP-30 不修改 active Project pointer；Project 切换和 next issue 调度仍归 Parent Codex queue preflight。

## Validation evidence

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；确认 MTP-30 输入材料、matrix 和 automation anchors 完整。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、`swift build --product MTPRODashboard`、dashboard smoke run 和 `swift test`；66 个 XCTest 通过，输出 `MTPRO checks passed.` |

## Known boundaries

- 本 Project 只覆盖 Research / Backtest / Paper readiness 的验证硬化。
- 不接 Live trading、signed endpoint、account endpoint、listenKey user data stream 或真实 broker action。
- 不提交、取消或替换真实订单。
- 不实现完整费用模型、交易所费率表、动态滑点模型或执行成本优化。
- 不实现完整风险引擎、实时风控、仓位管理、保证金、杠杆、真实账户余额或完整 Paper execution workflow。
- Report / Dashboard 只消费稳定 read model / projection snapshot，不暴露 SQLite / DuckDB schema、SQL、ORM model、runtime object 或 adapter request。

## Root Docs Delta input

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-30 输入结论 |
| --- | --- |
| `GOAL.md` | 当前目标仍是 Research -> Backtest -> Paper 一致性工作台；MTP-24 至 MTP-30 只强化验证证据，不改变目标。 |
| `ENVIRONMENT.md` | 本 Project 未新增本地运行依赖；统一验证入口仍是 `bash checks/run.sh`。 |
| `ARCHITECTURE.md` | Core / Persistence / App / Dashboard 的既有模块边界继续成立；新增 evidence 仍归属 read model / projection / validation 层。 |
| `ROADMAP.md` | Project 完成后需要由 Parent Codex 通过 Root Docs Refresh Gate 同步已发生事实；MTP-30 不直接修改下一阶段路线。 |

## Stage Code Audit handoff checklist

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-24` 到 `MTP-30`。
- Issue / PR evidence：PR #52、#53、#55、#56、#57、#58 和 MTP-30 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：Live trading、signed endpoint、broker action、真实订单、数据库 schema leakage 和 Report execution authorization 禁区。
- Known CI Boundary：如本 Project 没有新增临时 CI 平台边界，应明确记录无新增；若 MTP-30 PR 暴露失败，按事实记录。
- Root Docs Delta：检查 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md`、`ROADMAP.md`。
- Residual Notes For Human Planning：下一阶段只作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
