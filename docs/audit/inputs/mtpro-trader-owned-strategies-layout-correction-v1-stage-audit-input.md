# MTPRO Trader-Owned Strategies Layout Correction v1 阶段审计输入材料

日期：2026-06-02

执行者：Codex

## 定位

`MTP-197-TRADER-OWNED-STRATEGIES-LAYOUT-STAGE-CLOSEOUT`

本文档是 `MTPRO Trader-Owned Strategies Layout Correction v1` 的 MTP-197 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

`MTP-197-STAGE-AUDIT-INPUT-MATERIAL`

本文档只准备 stage audit input material，集中收口 MTP-191 至 MTP-196 的 Trader-owned strategy path correction evidence、validation matrix anchors、automation readiness anchors、compatibility envelope treatment、forbidden direct execution path audit、no Graphify / no Figma / no `.codex/*` / no `graphify-out/*` PR boundary 和 Parent Codex handoff checklist。

`MTP-197-NO-FINAL-STAGE-CODE-AUDIT`

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-191` 至 `MTP-197` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed`、`type=completed`、`completedAt` 非空后，由 Parent Codex 单独输出。本文档不授权下一 Project planning，不创建 Linear Project / Issue，不推进下一阶段，不启动下一阶段 `@002 / PAR`、Symphony 或 `symphony-issue`，不实现 final Stage Code Audit Report、Root Docs Refresh Gate、SwiftPM target graph split、Strategy runtime、Trader runtime、ExecutionClient implementation、OMS implementation、broker adapter、real order lifecycle、signed endpoint、account endpoint / listenKey、private stream runtime、account snapshot runtime、Live PRO Console、trading button、live command 或 order form。

`MTP-197-TRADER-OWNED-STRATEGIES-STAGE-AUDIT-INPUT`

本文档的审计输入范围只覆盖 Trader-owned strategy source layout correction，不把 closeout material 写成下一阶段 execution authorization。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO Trader-Owned Strategies Layout Correction v1`。
- Project ID：`9ec53497-71ee-4602-8185-ea2ce9ef59b2`。
- `MTP-191` 至 `MTP-196`：`Done`。
- `MTP-197`：当前 issue execution scope。
- 当前 issue scope 仅限 validation matrix、automation readiness anchors、compatibility envelope treatment、forbidden path audit、stage audit input material、no final Stage Code Audit、no Graphify / no Figma / no `.codex/*` / no `graphify-out/*` PR boundary。

## Issue / PR evidence input

`MTP-197-TRADER-OWNED-STRATEGIES-EVIDENCE-CHAIN`

| Issue | Evidence domain | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- | --- |
| `MTP-191` | Trader-owned strategy module boundary correction、canonical path、container split、StrategyBindings non-landing guard | [#317](https://github.com/atxinbao/MTPRO/pull/317) | `b989335a6d9061b1125eab9db4a458f9e39fa01a` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26783108164/job/78952288449) |
| `MTP-192` | root docs strategy path anchors、historical Strategies compatibility note、Trader container wording | [#318](https://github.com/atxinbao/MTPRO/pull/318) | `ef8ed4304563f04d2ed459490d935daa2138f948` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26784133197/job/78955694230) |
| `MTP-193` | EMA physical migration into `Sources/Trader/Strategies/EMA/` | [#319](https://github.com/atxinbao/MTPRO/pull/319) | `08161abdc032b067fdbe3bc43711fb3bfe44a30c` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26785482651/job/78960057148) |
| `MTP-194` | OrderBookImbalance physical migration into `Sources/Trader/Strategies/OrderBookImbalance/` | [#320](https://github.com/atxinbao/MTPRO/pull/320) | `6598ade6daf1ff809a94f84080fb75e20b102c40` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26786264244/job/78962658415) |
| `MTP-195` | StrategyBindings reclassified as generic binding protocol / coordination adapter | [#321](https://github.com/atxinbao/MTPRO/pull/321) | `2e1001a02ddaf353532532c5c23743be1ec6c743` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26787022322/job/78965069641) |
| `MTP-196` | deterministic local validation for Trader-owned strategy paths and forbidden path guards | [#322](https://github.com/atxinbao/MTPRO/pull/322) | `d85b2454b8591597d9fca3761925d68216f4d75f` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26787699501/job/78967200485) |
| `MTP-197` | validation matrix、compatibility envelope、forbidden path audit 和 stage audit input material closeout | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` |

## Trader-owned strategy layout closeout

`MTP-197-TRADER-OWNED-STRATEGY-LAYOUT-CLOSEOUT`

| Boundary | Current evidence | Audit interpretation |
| --- | --- | --- |
| Canonical concrete strategy path | `Sources/Trader/Strategies/<strategy>/`；当前 EMA 位于 `Sources/Trader/Strategies/EMA/`，OrderBookImbalance 位于 `Sources/Trader/Strategies/OrderBookImbalance/`。 | 具体 strategy lifecycle、signals、proposal implementation、quoter / hedger boundary 和 strategy-specific business rules 必须落在 Trader-owned strategy root。 |
| Superseded peer-level strategy path | `Sources/Strategies/EMA/` 与 `Sources/Strategies/OrderBookImbalance/` 不再保留 production source；`Sources/Strategies/<strategy>/` 只能作为 historical / compatibility / superseded / migration-source 文案保留。 | 任何 future docs 或 checks 不得把旧 peer-level path 写回 canonical future path。 |
| StrategyBindings | `Sources/Trader/StrategyBindings/PaperActionRiskLink.swift` 中 `TraderStrategyBindingsBoundaryEvidence` 固定 generic binding protocol / coordination adapter role。 | `StrategyBindings` 不是 concrete strategy implementation landing path，不承载 EMA、OrderBookImbalance 或未来具体策略实现。 |
| Compatibility envelope | `Core` target 名称继续编译 Trader-owned strategy source roots 和 StrategyBindings source root。 | 当前 Project 完成 source layout correction，不完成 SwiftPM target graph split。 |
| Validation | `testTraderOwnedStrategyPathValidationCoversCanonicalOldBindingAndExecutionGuards` 与 `checks/automation-readiness.sh` 机械检查 current files、old path absence、Package.swift source roots、StrategyBindings role 和 no direct execution guard。 | Stage Code Audit 可使用这些 checks 证明 path correction 有本地 deterministic evidence。 |

## Validation matrix closeout

`MTP-197-VALIDATION-MATRIX-CLOSEOUT`

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-TARGET-MODULE-PHYSICAL-LAYOUT-SOURCE-MIGRATION` | MTP-191 定义 Trader-owned strategy correction；MTP-192 更新 root docs anchors；MTP-193 / MTP-194 完成 EMA 与 OrderBookImbalance physical migration；MTP-195 固定 StrategyBindings 非具体策略落点；MTP-196 增加 deterministic path validation；MTP-197 收口 audit input。 | 审计时确认本 Project 只修正 Trader-owned strategy layout，不完成 SwiftPM target graph split，不实现 Strategy / Trader runtime，不授权 ExecutionClient、broker、OMS 或 live command capability。 |

## Automation readiness evidence

`MTP-197-AUTOMATION-READINESS-CLOSEOUT`

- `checks/automation-readiness.sh` 必须机械检查本 MTP-197 输入材料、MTP-191 至 MTP-196 anchors、validation matrix、validation plan、latest verification summary、automation readiness doc、current source file locations、old path absence、StrategyBindings role 和 no final Stage Code Audit boundary。
- GitHub PR Automation 仍负责 required check `checks`、squash merge、branch cleanup 和 Linear bot auto Done。
- `.codex/*` 与 `graphify-out/*` 不进入 PR。
- MTP-197 不设置 Linear Project `Completed`；Project closure、最终 Stage Code Audit Report、Root Docs Refresh Gate 和 final closure summary 仍归 Parent Codex closure flow。

## Forbidden implementation audit

`MTP-197-FORBIDDEN-IMPLEMENTATION-AUDIT`

本 Project 的 forbidden implementation audit 继续固定以下能力在当前 scope 中全部禁止：

- no SwiftPM target graph split as completion claim；no new product / dependency / target beyond compatibility envelope.
- no Strategy runtime、Trader runtime、strategy scheduler、live quoter、live hedger、Portfolio runtime、RiskEngine runtime、ExecutionEngine runtime、ExecutionClient implementation、OMS implementation、broker adapter 或 live coordinator。
- no signed endpoint、account endpoint / listenKey、listenKey create / keepalive、private WebSocket runtime、private stream runtime、account snapshot runtime、credential provider、API key input 或 secret storage。
- no real account read、broker position sync、real balance、real position、margin、leverage、buying power、real PnL、execution report、broker fill 或 reconciliation。
- no direct Strategy / Trader / StrategyBindings to ExecutionClient、broker command、OMS command、real order lifecycle、executable order command 或 live command path。
- no Live PRO Console implementation、trading button、live command、order form、broker connect UI、account connect UI、ExecutionClient request UI、OMS command UI 或 production operations command。
- no Graphify update、no Figma modification、no next Project / Issue creation、no next Todo promotion from this issue.

## Unresolved future gates

`MTP-197-UNRESOLVED-FUTURE-GATES`

后续仍必须独立处理：

- SwiftPM Target Split gate：把 `Core` compatibility envelope 转成真实 `Strategies` / `Trader` target graph 需要新的 Project Definition、dependency audit、migration order 和 validation matrix。
- Strategy runtime gate：strategy lifecycle runtime、scheduler、live quoter、live hedger 和 strategy process ownership 仍未授权。
- Trader runtime gate：Trader coordinator、account session runtime、broker gateway、OMS gateway 和 live coordinator 仍未授权。
- Execution gate：ExecutionClient、broker adapter、OMS、real order lifecycle、execution report、broker fill 和 reconciliation 仍未授权。
- Product surface gate：Future Live PRO Console、trading button、live command、order form 和 operations controls 仍未授权。
- Validation gate：后续 Project 需要新的 issue-specific validation matrix 和 post-issue evidence chain；不得复用本 closeout 作为 execution authorization。

## Validation evidence

`MTP-197-STAGE-CLOSEOUT-VALIDATION`

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | passed | 无输出。 |
| `bash checks/automation-readiness.sh` | passed | 已输出 `MTPRO automation readiness checks passed.`，并机械检查 MTP-197 stage audit input、matrix、validation plan、latest summary 和 automation readiness anchors。 |
| `bash checks/run.sh` | passed | 已通过 automation readiness、Dashboard build、Dashboard smoke 和 308 个 XCTest；Dashboard smoke 输出包含 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`timelineItems=82`、`strategyTraderReadinessSurface=6` 和 `liveMonitoringReadOnlyConsoleV2Surface=4`，最终输出 `MTPRO checks passed.`。 |

## Known boundaries

`MTP-197-NO-GRAPHIFY-FIGMA-NEXT-STAGE-MUTATION`

- Stage audit input 只准备 Parent Codex 审计材料，不替代最终 Stage Code Audit Report，不授权下一阶段 Project planning 或 execution。
- 本 issue 不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进下一阶段 Todo，不启动新的 `@002 / PAR`、Symphony 或 `symphony-issue`。
- 本 issue 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## Root Docs Delta input

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-197 输入结论 |
| --- | --- |
| `GOAL.md` | 本 Project 完成后只证明 Trader-owned strategy source layout correction；不代表 Strategy runtime、Trader runtime、broker readiness、Live PRO Console readiness、live runtime readiness 或真实交易授权。 |
| `BLUEPRINT.md` | Trader container 可以继续表达 `Accounts + Strategies + StrategyBindings + Coordination`；具体策略落点应使用 `Sources/Trader/Strategies/<strategy>/`，ExecutionClient、broker command、OMS、production operations 和 Live PRO Console 仍属于 Future Construction Zones。 |
| `environment.md` | 本 Project 未新增 required secret 读取、broker credential、外部写能力、signed endpoint、account endpoint、listenKey、真实账户读取或 production operations；统一验证入口仍是 `bash checks/run.sh`。 |
| `architecture.md` | 当前 source tree 已把 concrete strategy code 归入 Trader-owned strategy root，但 SwiftPM target graph 仍保留 compatibility envelope；不得把目录修正误写成 runtime implementation 完成。 |
| `docs/roadmap.md` | Project 完成后需要由 Parent Codex 设置或确认 Linear Project `Completed`，再通过 Stage Code Audit Report、Root Docs Refresh Gate 和 final closure summary 同步已发生事实；MTP-197 不直接修改下一阶段路线，不创建下一 Project / Issue。 |

## Stage Code Audit handoff checklist

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-191` 至 `MTP-197`。
- Linear Project completion evidence：Project status `Completed`、`type=completed`、`completedAt` 非空。
- Issue / PR evidence：PR #317 至 #322 和 MTP-197 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：Trader-owned strategy canonical path、historical `Sources/Strategies/<strategy>` compatibility note、EMA / OrderBookImbalance source placement、StrategyBindings non-landing guard、path validation, remaining compatibility envelope、forbidden implementation audit 和 unresolved future gates。
- Root Docs Delta：检查 `GOAL.md`、`BLUEPRINT.md`、`environment.md`、`architecture.md`、`docs/roadmap.md`。
- Residual Notes For Human Planning：SwiftPM target split、Strategy runtime、Trader runtime、ExecutionClient / broker / OMS / Live PRO Console 仍只能作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
