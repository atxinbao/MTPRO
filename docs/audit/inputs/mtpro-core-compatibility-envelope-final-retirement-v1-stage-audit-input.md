# MTPRO Core Compatibility Envelope Final Retirement v1 Stage Audit Input

日期：2026-06-13

执行者：Codex

本文档是 GitHub issue [GH-636](https://github.com/atxinbao/MTPRO/issues/636) 的 Stage Code Audit 输入材料。它只收口 GH-631 至 GH-635 的已完成事实、validation matrix、automation readiness anchors、retained compatibility envelope shim matrix、真实 module owner map 和 forbidden capability audit。本文档不是最终 Stage Code Audit Report，不创建下一 Project / Issue，不推进下一阶段 Todo，不授权 production cutover。

## GH-636-FINAL-ENVELOPE-RETIREMENT-CLOSEOUT

`GH-636-FINAL-ENVELOPE-RETIREMENT-CLOSEOUT`

CEFR closeout 结论：

- `Core` 不再被解释为 active business implementation owner，只保留 legacy import surface、rich cross-module payload bridge、read-model-only historical evidence 和 deterministic validation bridge。
- `Adapters` 只保留 DataClient re-export compatibility surface。
- `Persistence` 只保留 Database projection adapter shim。
- `Runtime` 只保留 DataEngine / Database ingest / replay workflow shim。
- 真实 active implementation owner 必须落到 `DataClient`、`DataEngine`、`MessageBus`、`Portfolio`、`RiskEngine`、`ExecutionEngine`、`ExecutionClient`、`Trader`、`TraderStrategies`、`Dashboard` 或对应 foundation owner。

## GH-636-ISSUE-PR-EVIDENCE-CHAIN

`GH-636-ISSUE-PR-EVIDENCE-CHAIN`

| Issue | Status evidence | PR | Merge commit | Required check |
| --- | --- | --- | --- | --- |
| [GH-631](https://github.com/atxinbao/MTPRO/issues/631) | closed / done at `2026-06-12T18:04:49Z` | [PR #637](https://github.com/atxinbao/MTPRO/pull/637) | `e3279b0c102ba47e56304d3ad98d203819ef3ecc` | `checks` SUCCESS, run `27433607386`, job `81089868011` |
| [GH-632](https://github.com/atxinbao/MTPRO/issues/632) | closed / done at `2026-06-12T18:19:34Z` | [PR #638](https://github.com/atxinbao/MTPRO/pull/638) | `c1aa7634c658833171f2956bbc7102be3e7e5bdc` | `checks` SUCCESS, run `27434433895`, job `81092665875` |
| [GH-633](https://github.com/atxinbao/MTPRO/issues/633) | closed / done at `2026-06-12T18:30:50Z` | [PR #639](https://github.com/atxinbao/MTPRO/pull/639) | `02c50ea24488e430664073833d076af88fbddff5` | `checks` SUCCESS, run `27434972116`, job `81094474040` |
| [GH-634](https://github.com/atxinbao/MTPRO/issues/634) | closed / done at `2026-06-12T18:47:32Z` | [PR #640](https://github.com/atxinbao/MTPRO/pull/640) | `4041b7eb82e490ee6deb2c2bfe6781cc772bb778` | `checks` SUCCESS, run `27435884082`, job `81097564951` |
| [GH-635](https://github.com/atxinbao/MTPRO/issues/635) | closed / done at `2026-06-12T18:58:40Z` | [PR #641](https://github.com/atxinbao/MTPRO/pull/641) | `75cb1cf157244c3e4234ad4f866ae2eab06a2634` | `checks` SUCCESS, run `27436433195`, job `81099461141` |

## GH-636-REAL-MODULE-OWNER-MAP-COMPLETE

`GH-636-REAL-MODULE-OWNER-MAP-COMPLETE`

| Owner | Completed ownership evidence |
| --- | --- |
| `DataClient` | owns Binance public market data sources and `AdaptersCompatibility.swift` re-export shim |
| `DataEngine` | owns ScenarioReplay / DataQuality active source contracts and DataEngine ingest handoff evidence |
| `MessageBus` | owns rich routing compatibility classification and neutral bus boundaries |
| `Database` | owns Persistence / Runtime envelope retirement contract, local projection adapters and replay projection evidence |
| `Portfolio` | owns active portfolio projection sources and parity ownership contract |
| `RiskEngine` | owns pre-trade risk and blocked evidence boundaries; no broker or command bypass |
| `ExecutionEngine` | owns active paper / simulated execution evidence and parity ownership contract |
| `ExecutionClient` | owns gated external execution boundary and future-gate contracts; production remains disabled by default |
| `Trader` | owns account context, coordination and strategy binding container, not execution client access |
| `TraderStrategies` | owns EMA / RSI strategy proposal evidence under `Sources/Trader/Strategies` |
| `Dashboard` | owns read-model-only UI surfaces and must not consume runtime object, adapter request or schema |

## GH-636-RETAINED-ENVELOPE-SHIM-MATRIX

`GH-636-RETAINED-ENVELOPE-SHIM-MATRIX`

| Envelope | Retained role | Allowed retention reason |
| --- | --- | --- |
| `Core` | compatibility envelope only; not active business implementation owner | legacy import surface; rich cross-module payload bridge; read-model-only historical evidence; deterministic validation bridge |
| `Adapters` | DataClient compatibility re-export only | re-export compatibility surface |
| `Persistence` | Database projection adapter shim only | projection adapter shim |
| `Runtime` | DataEngine / Database replay-ingest workflow shim only | ingest / replay workflow shim |

## GH-636-AUTOMATION-READINESS-CLOSEOUT

`GH-636-AUTOMATION-READINESS-CLOSEOUT`

Required mechanical anchors:

- `GH-636-FINAL-ENVELOPE-RETIREMENT-CLOSEOUT`
- `GH-636-ISSUE-PR-EVIDENCE-CHAIN`
- `GH-636-REAL-MODULE-OWNER-MAP-COMPLETE`
- `GH-636-RETAINED-ENVELOPE-SHIM-MATRIX`
- `GH-636-AUTOMATION-READINESS-CLOSEOUT`
- `GH-636-NO-PRODUCTION-CUTOVER-AUTHORIZATION`
- `TVM-CEFR-FINAL-ENVELOPE-RETIREMENT-CLOSEOUT`
- `testGH636FinalEnvelopeRetirementCloseoutMatrixCoversCompletedEvidenceWithoutProductionCutover`

Required validation:

- `swift test --filter TargetGraphTests/testGH636FinalEnvelopeRetirementCloseoutMatrixCoversCompletedEvidenceWithoutProductionCutover`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## GH-636-NO-PRODUCTION-CUTOVER-AUTHORIZATION

`GH-636-NO-PRODUCTION-CUTOVER-AUTHORIZATION`

GH-636 does not authorize:

- production trading;
- production secret read, print or storage;
- production endpoint connection;
- signed endpoint, account endpoint, listenKey or private WebSocket runtime;
- broker gateway, broker adapter or automatic broker connection;
- real submit / cancel / replace;
- production OMS;
- execution report, broker fill or reconciliation runtime;
- Live PRO Console production command, trading button, live command or order form;
- production cutover.

Production defaults remain:

- `productionTradingEnabledByDefault == false`
- `productionSecretReadEnabledByDefault == false`
- `productionEndpointConnectionEnabledByDefault == false`
- `productionOrderSubmitEnabledByDefault == false`
- `productionBrokerConnectionEnabledByDefault == false`
- `productionCutoverAuthorized == false`

## GH-636-STAGE-CODE-AUDIT-HANDOFF

`GH-636-STAGE-CODE-AUDIT-HANDOFF`

After GH-636 PR merge, Parent Codex must verify:

- open PR = 0;
- open issue = 0, unless a later Human-approved queue exists;
- no `todo` / `in-progress` / `in-review` active conflict;
- `main == origin/main`;
- worktree clean;
- no next Project / Issue is created or promoted by this closeout.
