# MTPRO Trader-Owned Strategies Layout Correction v1

日期：2026-06-02

执行者：Codex

## 文档定位

本文是 `MTPRO Trader-Owned Strategies Layout Correction v1` 的 docs-only planning record。

本文承接 `MTPRO Target Module Physical Layout / Source Migration v1` 已完成的 target module physical directories 和 compatibility envelope，同时修正其中 `Strategies` 与 `Trader` 的归属关系：`TradingStrategy` 在架构心智上属于 `Trader` 管理的 strategy instances / strategy definitions，不应作为与 `Trader` 平级的长期 canonical module。

本文不创建 Linear Project / Issue，不修改 Linear status，不推进 Todo，不启动 `@002 / PAR`，不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma，不移动 production source，不修改 `Package.swift`，不拆 SwiftPM target graph，不写业务代码。

本文不授权 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。

## Project name

`MTPRO Trader-Owned Strategies Layout Correction v1`

## Target maturity

`Trader-owned strategy module layout correction before L4`

该阶段不改变旧 `Final Product Goal Progress 9 / 9 (100%)`，不更新旧 `Engine Maturity Roadmap Progress 4 / 4 (100%)`，也不把 L4 live production capability 写成当前 execution scope。

## Target Engines / Modules

- Trader
- Trader / Accounts
- Trader / Strategies
- Trader / StrategyBindings
- Trader / Coordination
- Portfolio
- RiskEngine
- ExecutionEngine
- ExecutionClient future gate
- Workbench / validation evidence boundary

## Project goal

把当前平级 canonical strategy layout：

```text
Sources/Strategies/
  EMA/
  OrderBookImbalance/
```

修正为 Trader-owned strategy layout：

```text
Sources/Trader/
  Accounts/
  Strategies/
    EMA/
    OrderBookImbalance/
    <FutureStrategy>/
  StrategyBindings/
  Coordination/
```

同时更新 root docs、validation anchors、`Package.swift` source path 和 compatibility envelope 说明，保证 strategy 仍只输出 signals / proposals，不直连 `ExecutionClient`、broker、OMS 或 live command。

## Scope

- 修正 architecture boundary language。
- 将 `Sources/Strategies/<strategy>` canonical path 改为 `Sources/Trader/Strategies/<strategy>`。
- 保留 `Portfolio`、`RiskEngine`、`ExecutionEngine`、`ExecutionClient` 独立模块边界。
- 明确 `Trader = Accounts + Strategies + StrategyBindings + Coordination`。
- 明确 `Trader/Strategies/<strategy>` 存放每个策略的 lifecycle、signals、proposals、quoter / hedger boundary。
- 明确 `Trader/Coordination` 串联 account、strategy、portfolio、risk、execution context，但不执行真实交易。
- 将 `Trader/StrategyBindings` 收口为通用 binding protocol / adapter contract，不作为具体策略代码落点。
- 后续迁移 EMA 和 OrderBookImbalance 源码路径。
- 更新 validation anchors，防止 `Sources/Strategies` 继续作为 canonical path。

## Non-goals

- 不在 planning record 中移动 production source。
- 不在 planning record 中修改 `Package.swift`。
- 不拆 SwiftPM target graph。
- 不实现 Strategy runtime。
- 不实现 Trader runtime。
- 不实现 Live runtime。
- 不实现 `ExecutionClient` implementation。
- 不实现 OMS implementation。
- 不实现 broker gateway。
- 不实现 real order lifecycle。
- 不实现 submit / cancel / replace。
- 不实现 execution report / broker fill / reconciliation。
- 不实现 account endpoint / listenKey / private WebSocket runtime。
- 不实现 Live PRO Console / trading button / live command / order form。
- 不把 `Adapters` target 改名为 `DataClient`。
- 不处理 `Persistence` / `App` / `Core` target split。
- 不运行 Graphify。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。

## Target layout correction

本 Project 修正后的 canonical strategy path 是：

```text
Sources/Trader/
  Accounts/
  Strategies/
    EMA/
      Lifecycle/
      Quoter/
      Hedger/
      Signals/
      Proposals/
    OrderBookImbalance/
      Lifecycle/
      Signals/
      Proposals/
    <future-strategy>/
  StrategyBindings/
  Coordination/
```

边界语言：

- `Trader` 是 account + strategy instances + coordination 的容器。
- `Trader/Strategies/<strategy>` 是具体 strategy definition / strategy instance readiness 的源码落点。
- `Trader/Strategies/<strategy>` 可以定义 lifecycle、signals、proposals、quoter / hedger boundary。
- `Trader/Coordination` 串联 account、strategy、portfolio、risk、execution context，但只能停留在 coordination / proposal / read-model / future-gated context，不执行真实交易。
- `Trader/StrategyBindings` 只作为通用 binding protocol / adapter contract，不作为 EMA、OrderBookImbalance 或未来具体策略代码落点。
- `Portfolio`、`RiskEngine`、`ExecutionEngine` 和 `ExecutionClient` 继续保持独立模块。
- strategy 不得直连 `ExecutionClient`、broker、OMS、signed endpoint、real order lifecycle、Live PRO Console、trading button 或 live command。

## Milestones

| Milestone | Goal | Must complete | Exit evidence |
| --- | --- | --- | --- |
| M1 Boundary Correction | 修正 Trader-owned strategy module boundary，明确 `Sources/Trader/Strategies/<strategy>` 是 canonical path。 | root boundary language、target layout correction、non-authorization boundary。 | architecture delta proposal、no source move evidence、first issue candidate。 |
| M2 Docs And Anchors | 更新 root docs、architecture boundary、domain language 和 validation anchors，移除 `Sources/Strategies/<strategy>` 作为 canonical path 的语义。 | root docs anchor delta、compatibility envelope note、old path supersession policy。 | docs anchor evidence、no production source move evidence。 |
| M3 Source Path Migration | 迁移 EMA 和 OrderBookImbalance 到 Trader-owned path，保持 behavior 和 tests 不变。 | EMA path migration、OrderBookImbalance path migration、source path / import / test update。 | moved files summary、no behavior change evidence、checks output。 |
| M4 StrategyBindings Reclassification | 把 `StrategyBindings` 固定为 binding protocol / coordination adapter，不作为具体 strategy code 落点。 | binding protocol / adapter contract language、concrete strategy code exclusion。 | StrategyBindings boundary evidence、no strategy implementation landing evidence。 |
| M5 Validation Closeout | 收口 compatibility envelope、automation readiness、forbidden path audit 和 stage audit input material。 | path validation、validation matrix、automation readiness、stage audit input。 | validation matrix evidence、compatibility envelope audit、stage audit input material。 |

## Corrected issue order

1. Define Trader-owned strategy module boundary correction.
2. Update root docs strategy path anchors.
3. Migrate EMA strategy into `Sources/Trader/Strategies/EMA`.
4. Migrate OrderBookImbalance strategy into `Sources/Trader/Strategies/OrderBookImbalance`.
5. Reclassify `StrategyBindings` as binding protocol / coordination adapter only.
6. Add architecture path validation for Trader-owned strategies.
7. Close validation matrix / compatibility envelope / stage audit input.

仓库 planning record 只保存 Project 级计划摘要和 issue order。完整 Linear issue body 后续以 Linear 写入内容为准，不在仓库长期复制维护。

## Corrected dependencies

- Issue 2 depends on Issue 1.
- Issue 3 depends on Issue 2.
- Issue 4 depends on Issue 2.
- Issue 5 depends on Issue 3, Issue 4.
- Issue 6 depends on Issue 3, Issue 4, Issue 5.
- Issue 7 depends on Issue 6.

## Candidate issue summaries

| Issue | Summary | Boundary |
| --- | --- | --- |
| 1. Define Trader-owned strategy module boundary correction | 定义 Trader-owned strategy canonical layout、module ownership、dependency direction 和 forbidden path taxonomy delta。 | docs / contract only；不移动 source；不改 `Package.swift`。 |
| 2. Update root docs strategy path anchors | 将 root docs、architecture boundary、domain context 和 migration contract 中的 canonical strategy path anchor 从 `Sources/Strategies/<strategy>` 修正为 `Sources/Trader/Strategies/<strategy>`，并标注旧路径 compatibility / supersession。 | docs anchor correction only；不迁 production source。 |
| 3. Migrate EMA strategy into `Sources/Trader/Strategies/EMA` | 把 EMA strategy source、tests references 和 validation anchors 迁入 Trader-owned path，保持 behavior unchanged。 | path migration only；不实现 Strategy runtime。 |
| 4. Migrate OrderBookImbalance strategy into `Sources/Trader/Strategies/OrderBookImbalance` | 把 OrderBookImbalance strategy source、tests references 和 validation anchors 迁入 Trader-owned path，保持 strategy semantics unchanged。 | path migration only；不实现 live command 或 broker path。 |
| 5. Reclassify `StrategyBindings` as binding protocol / coordination adapter only | 固定 `Trader/StrategyBindings` 只承载 generic binding protocol / adapter contract，不承载具体 strategy code。 | classification / anchor correction；不实现 Trader runtime。 |
| 6. Add architecture path validation for Trader-owned strategies | 增加 deterministic local validation，检查 canonical strategy path、old path non-canonical、StrategyBindings non-strategy-code 和 no direct execution path。 | validation only；不拆 target graph。 |
| 7. Close validation matrix / compatibility envelope / stage audit input | 汇总 validation matrix、automation readiness、compatibility envelope、forbidden path audit 和 stage audit input material。 | closeout only；不输出最终 Stage Code Audit Report。 |

## Validation requirements

- 每个 issue 必须运行 `bash checks/run.sh`。
- 每个 issue 必须运行 `git diff --check`。
- 必须验证 `Sources/Strategies/<strategy>` 不再是 canonical path。
- 必须验证 `Sources/Trader/Strategies/<strategy>` 是 canonical path。
- 必须验证 `StrategyBindings` 不作为具体策略代码落点。
- 必须验证 strategy 不直连 `ExecutionClient` / broker / OMS / live command。
- 必须验证 `Package.swift` 只在对应 source migration issue 授权后更新 source path，不拆 target graph。
- 必须验证 no Strategy runtime / Trader runtime / Live runtime。
- 必须验证 no signed endpoint / account endpoint / listenKey / private WebSocket runtime。
- 必须验证 no broker gateway / OMS / `ExecutionClient` implementation。
- 必须验证 no real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation。
- 必须验证 no Live PRO Console / trading button / live command / order form。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

## Evidence requirements

- 每个 PR 必须包含 Linked Linear Issue、Scope / Non-goals、changed paths summary、validation output 和 boundary evidence。
- 每个 PR 必须包含 MTPRO-native PR evidence fields：Feedback Loop Evidence、Tracer Bullet / Fixture Evidence、Diagnose Evidence、Architecture Deepening Candidate。
- 每个 PR 前必须执行 Pre-PR Codex Code Review。
- 每个 PR 必须使用 GitHub PR Automation。
- 每个 PR 必须说明 no SwiftPM target graph split。
- 每个 PR 必须说明 no live / broker gateway / OMS / `ExecutionClient` implementation。
- Source migration PR 必须说明 old path -> new path mapping、behavior unchanged evidence 和 compatibility envelope delta。
- `.codex/*` 不进入 PR。
- `graphify-out/*` 不进入 PR。
- 如由 symphony-issue 执行，必须提供 handoff marker evidence。
- Issue 7 只准备 stage audit input material；Project 全部 Done 后 Stage Code Audit Report 必须由 Parent Codex 单独输出。

## First executable issue candidate

Issue 1：`Define Trader-owned strategy module boundary correction`

该 issue 只是 first executable candidate，不构成执行授权。

## WIP=1 / Queue Preflight Rule

- Project 执行必须保持 WIP=1。
- 所有 issue 初始状态必须是 `Backlog / non-executable`。
- `@001 / PLN` 不操作 `Backlog -> Todo`。
- Project 写入 Linear 后，由 Parent Codex queue preflight 判断唯一 eligible issue。
- Parent Codex queue preflight 必须确认 WIP=1、依赖满足、无 active conflict、execution contract 格式完整、source migration scope 清楚、validation requirements 完整后，才可推进唯一 eligible issue 到 Todo。

## Linear write boundary

- 本 planning record 不创建 Linear Project。
- 本 planning record 不创建 Linear Issues。
- 本 planning record 不修改 Linear status。
- 本 planning record 不推进 Todo。
- 本 planning record 不启动 `@002 / PAR`。
- 本 planning record 不启动 Symphony / symphony-issue。
- 后续完整 execution contract 以 Linear issue body 为准。
- Linear 写入后，所有 issue 初始必须保持 `Backlog / non-executable`。

## Repository record boundary

- 仓库 planning record 只保存 Project 级计划摘要和格式门槛。
- 仓库不复制维护完整 Linear issue body。
- 仓库 planning record 不授权执行。
- 后续 issue scope、Codex Instructions、Validation、Boundary、PR Requirements 和 Acceptance Criteria 以 Linear issue body 为准。
- 本文不授权移动 `Sources` 文件，不授权修改 `Package.swift` target graph，不授权写业务代码。

## Compatibility and risk notes

- 当前 `Sources/Strategies/EMA` 与 `Sources/Strategies/OrderBookImbalance` 是已完成 physical migration 的现状路径，但本 Project 将其降级为迁移前 compatibility path，不再作为长期 canonical path。
- `Package.swift` 当前 compatibility envelope 仍可编译现有 source roots；后续只有 source migration issue 才能调整 source path。
- `Trader/StrategyBindings` 需要保留为 binding protocol / coordination adapter contract；不能用它承载具体 strategy implementation。
- 历史 docs、Stage Audit 和 verification 中出现的 `Sources/Strategies/<strategy>` 作为历史事实保留；后续 issue 只做 forward-looking supersession / compatibility note，不静默改写历史 evidence。
- 本 Project 不处理空 `Sources/Adapters` artifact、`Adapters` target rename、`Persistence` / `App` / `Core` target split 或 SwiftPM target graph split。

## Final boundary confirmation

本文只记录 docs-only Project planning record。它不是 Project closure，不是 Linear write，不是 queue preflight，不是 source migration execution，不是 L4 authorization。

后续必须先由 Human 决定是否写入 Linear；Linear 写入后仍必须由 Parent Codex queue preflight 推进唯一 eligible issue，才允许执行任何 root docs anchor update、source migration、`Package.swift` source path update 或 validation change。
