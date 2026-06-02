# MTPRO Data Catalog / Scenario Replay v1 阶段审计输入材料

日期：2026-05-26

执行者：Codex

## 定位

`MTP-109-DATA-CATALOG-SCENARIO-REPLAY-STAGE-AUDIT-INPUT`

本文档是 `MTPRO Data Catalog / Scenario Replay v1` 的 MTP-109 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-103`、`MTP-104`、`MTP-105`、`MTP-106`、`MTP-107`、`MTP-108`、`MTP-109` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed`、`type=completed`、`completedAt` 非空后，由 Parent Codex 单独输出到：

```text
docs/audit/mtpro-data-catalog-scenario-replay-v1-stage-code-audit.md
```

本文档不授权下一 Project planning，不创建 Linear Project / Issue，不修改 Linear status，不推进下一 issue，不启动下一阶段 `symphony-issue`，不实现 final Stage Code Audit Report、Root Docs Refresh Gate、Simulated Exchange / Backtest Parity、production data platform、large-scale ingestion pipeline、automatic download / repair、signed endpoint、account endpoint、listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、live runtime、live command、Live PRO Console 或交易按钮。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO Data Catalog / Scenario Replay v1`。
- Project ID：`9442e43b-dd07-4095-86e8-3ef270727d16`。
- Project URL：`https://linear.app/atxinbao/project/mtpro-data-catalog-scenario-replay-v1-033026a9bc16`。
- `MTP-103`、`MTP-104`、`MTP-105`、`MTP-106`、`MTP-107`、`MTP-108`：`Done`。
- `MTP-109`：`In Progress`。
- 当前 issue scope 仅限 validation matrix、automation readiness anchors、Project evidence chain、forbidden capability evidence、no Graphify / no Figma / no unauthorized Linear mutation confirmation 和 Stage Code Audit 输入材料。

## Issue / PR evidence input

| Issue | Evidence domain | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- | --- |
| `MTP-103` | Data Catalog / Scenario Replay terminology、target engine boundary、local-first deterministic versioned boundary 和 forbidden capability baseline | [#201 MTP-103 Define Data Catalog / Scenario Replay boundary](https://github.com/atxinbao/MTPRO/pull/201) | `7c6ef70c82e792028a37e898d8d132366dcf89fb` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26417006911/job/77763553055) |
| `MTP-104` | Scenario manifest、scenario id、dataset version、single-symbol / single-timeframe identity 和 deterministic serialization | [#202 MTP-104 add scenario manifest contract](https://github.com/atxinbao/MTPRO/pull/202) | `55e4cab9b53d25dabf46bc5ca46d95a5437399f9` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26417862951/job/77766104268) |
| `MTP-105` | First deterministic scenario fixture、fixture version、fixed window、fixed record order 和 checksum preimage | [#203 MTP-105 add deterministic scenario fixture](https://github.com/atxinbao/MTPRO/pull/203) | `b778d0499f80d45b4e022477cae19a8768cf08df` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26418602630/job/77768325813) |
| `MTP-106` | Replay window、cursor summary、checksum / parity evidence、freshness evidence 和 data quality gate input identity | [#204 Add scenario replay evidence](https://github.com/atxinbao/MTPRO/pull/204) | `a102aa7b368f6ad6a9be918a4af5157a025828f0` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26421486345/job/77776929764) |
| `MTP-107` | Data quality gates、accepted / marked / rejected verdict 和 report input versioning | [#205 MTP-107 Add data quality gates and report input versioning](https://github.com/atxinbao/MTPRO/pull/205) | `77658c489a71db3fc5a578b925a8e22bdc5888eb` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26422352679/job/77779425516) |
| `MTP-108` | Workbench / Report / Events read-model-only scenario replay evidence surface、quality gate timeline 和 Dashboard smoke handles | [PR #206 MTP-108 add scenario replay evidence surface](https://github.com/atxinbao/MTPRO/pull/206) | `e56f9f01176579a354d6773133ab0e4fb8f91eef` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26423244139/job/77781879821) |
| `MTP-109` | validation matrix、automation readiness anchors、Project evidence chain、forbidden capability evidence 和 Stage Code Audit 输入材料收口 | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` |

## Data Catalog / Scenario Replay validation evidence chain

`MTP-109-DATA-CATALOG-SCENARIO-REPLAY-VALIDATION-EVIDENCE-CHAIN`

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-DATA-CATALOG-SCENARIO-REPLAY` | MTP-103 定义 terminology / boundary；MTP-104 定义 manifest / scenario id / dataset version；MTP-105 定义 first deterministic fixture；MTP-106 定义 replay window / cursor / checksum / freshness；MTP-107 定义 quality gates / report input versioning；MTP-108 将 evidence 接入 Workbench / Report / Events read-model-only surface；MTP-109 收口 validation matrix、automation readiness 和 stage audit input。 | 审计时确认 scenario replay evidence 全部来自本地 deterministic fixture / read model / ViewModel，不读取 Runtime object、Persistence schema、adapter request、secret、signed endpoint、account endpoint、listenKey、broker state、真实账户或外部 execution venue。 |
| `TVM-REPORT-EVIDENCE` | MTP-108 将 scenario id、dataset version、fixture version、replay window、checksum、freshness status、quality verdict 和 report input version identity 接入 Report evidence。 | 审计时确认 Report 只消费 App read model / ViewModel，不暴露 database schema、Runtime object、adapter request、broker action、real account state、execution report、broker fill 或 trading authorization。 |
| `TVM-PAPER-WORKFLOW-CONTROL-SHELL` | MTP-108 将 scenario replay evidence 接入 Workbench summary / drill-down 与 Event Timeline / Evidence Explorer，Dashboard smoke 新增 `scenarioReplayEvidence` 和 `scenarioQualityGates` handles。 | 审计时确认 Workbench / Dashboard / Event Timeline 没有新增 query language、command surface、database console、download console、order form、order-level command、live command、Live PRO Console 或交易按钮。 |
| Dashboard smoke | MTP-108 后 smoke summary 包含 `scenarioReplayEvidence=0`、`scenarioQualityGates=0`，同时保留 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`controls=start,pause,close,reset`、`timelineItems=42`、Live blocked gates、Live execution control gates、Live risk gates、Live incident / stop gates、Live monitoring health 和 Live monitoring errors。 | 审计时确认 smoke 能定位八个 Dashboard sections、read-model-only boundary、scenario replay handles 和 Live forbidden gates。 |
| Deterministic tests | MTP-103 至 MTP-107 Core tests 覆盖 terminology、manifest、fixture、replay evidence、quality gates 和 report input versioning；MTP-108 App test 覆盖 Report / Workbench / Events / Dashboard smoke / read-model-only boundary。 | 审计时确认 deterministic validation 不依赖真实 Binance 网络、secret、account endpoint、listenKey、broker、真实账户、production runtime operations 或人工验收。 |

## Forbidden capability evidence

`MTP-109-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`

MTP-103 至 MTP-108 继续固定以下能力在当前 Project 中全部禁止：

- no scenario manifest parser。
- no Runtime replay job。
- no production data platform。
- no production data observability。
- no large-scale ingestion pipeline。
- no cloud data lake。
- no automatic download。
- no automatic repair。
- no production scheduler / retention cleanup / archive storage tiering。
- no database schema exposure。
- no adapter request exposure。
- no Runtime object read。
- no secret read。
- no API key。
- no signed endpoint。
- no account endpoint。
- no listenKey。
- no broker action。
- no broker adapter。
- no exchange execution adapter。
- no `LiveExecutionAdapter`。
- no OMS。
- no real order lifecycle。
- no real submit / cancel / replace。
- no execution report runtime / ingestion。
- no broker fill runtime / recorder / fact。
- no reconciliation runtime。
- no real account / broker position read。
- no Simulated Exchange / Backtest Parity runtime。
- no Live PRO Console。
- no live command。
- no command surface / order-level command。
- no query language。
- no order form。
- no trading button。
- no Graphify update。
- no Figma modification。
- no unauthorized Linear mutation。

## Read-model-only boundary evidence

- `ScenarioManifest` 只表达 local scenario input identity，不解析 manifest file，不暴露 schema / adapter request。
- `DeterministicScenarioFixture` 只保存本地 BTCUSDT / 1m fixture records、fixed window 和 deterministic summary pre-structure，不读取网络。
- `ScenarioReplayEvidence` 只从 MTP-105 deterministic fixture 派生 replay window、cursor、checksum 和 freshness，不运行 production retention engine。
- `ScenarioDataQualityReportInputEvidence` 只汇总 quality gates 与 report input version identity，不做 production data observability、automatic download / repair 或 broker / account reconciliation。
- `ScenarioReplayEvidenceReadModel` / `ScenarioReplayEvidenceViewModel` 只复制稳定字段供 Report / Workbench / Events 展示，不读取 Runtime object、SQLite / DuckDB schema、adapter request 或外部系统 payload。
- `DashboardShellSnapshot` 的 `scenarioReplayEvidence` / `scenarioQualityGates` 是 smoke handles，不表示 command surface、query language、database console、download console、live command 或 trading authorization。

## Automation readiness evidence

`MTP-109-AUTOMATION-READINESS-STAGE-CLOSEOUT`

- `checks/automation-readiness.sh` 检查本 MTP-109 输入材料、latest verification summary、Trading Validation Matrix、validation plan、data catalog contract、automation readiness doc、MTP-103 至 MTP-108 source / test anchors 和 Dashboard smoke handles。
- GitHub PR Automation 仍负责 required check `checks`、squash auto-merge、branch cleanup 和 Linear bot auto Done。
- child Codex 只在当前 issue workspace 内提交文档、验证证据和 handoff marker；`.codex/*` 与 `graphify-out/*` 不进入 PR。
- Graphify post-merge resource relationship graph refresh 仍由 Symphony host-side Post-Issue Ledger 执行，不由 child Codex 在 sandbox 内强制执行。
- MTP-109 不修改 active Project pointer；Project closure、Linear Project `Completed` status、最终 Stage Code Audit Report、Root Docs Refresh Gate 和当前阶段完成进度条仍归 Parent Codex 边界。

## Validation evidence

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 机械检查 MTP-109 stage audit input、contract、matrix、validation plan、latest summary、source / test anchors 和 Dashboard smoke handles，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；Swift tests 242 个通过、0 failures，最终输出 `MTPRO checks passed.`。 |

## Known boundaries

- 本 Project 只建立 local-first data catalog / scenario replay 数据地基，不实现完整 Data Engine production platform。
- Scenario manifest 是输入身份合同，不是 manifest file parser、file loader、database primary key、Runtime job id、broker order id 或真实订单 id。
- First deterministic fixture 只保存本地 BTCUSDT / 1m records，不依赖真实 Binance 网络或 API key。
- Replay evidence 只表达本地 deterministic window、cursor、checksum 和 freshness，不实现 production retention engine、真实历史下载器、cloud archive 或 runtime replay job。
- Data quality gates 只服务 local scenario replay 与 report reproducibility，不是生产数据质量平台、自动下载 / 自动修复系统或 broker / account reconciliation。
- Report input versioning 只追溯 scenario id、dataset version、fixture version、replay window、checksum、freshness 和 quality verdict，不实现 Simulated Exchange / Backtest Parity runtime。
- Report / Dashboard / Event Timeline 只消费 App read model / ViewModel，不提供 command surface、query language、database console、download console、schema inspector、Runtime inspector、live command、order form 或交易按钮。
- Binance 边界仍是 public read-only market data；required validation 不依赖真实 Binance 网络、真实 API key、真实账户或 broker state。
- Stage audit input 只准备 Parent Codex 审计材料，不替代最终 Stage Code Audit Report。

## Root Docs Delta input

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-109 输入结论 |
| --- | --- |
| `GOAL.md` | 本 Project 完成后只证明 Local Data Catalog / Scenario Replay 的 local-first deterministic data foundation 已形成；不代表 Simulated Exchange / Backtest Parity、production data platform、Live trading、broker / OMS、signed endpoint、account endpoint / listenKey、Live PRO Console 或 trading button 已实现。 |
| `BLUEPRINT.md` | Scenario replay evidence 可以作为后续 Simulated Exchange / Backtest Parity、Workbench beta demo path 和 report reproducibility 的数据地基；Future Live、signed endpoint、broker、OMS 和 Live PRO Console 仍属于 Future Construction Zones。 |
| `environment.md` | 本 Project 未新增 required validation 入口、secret 读取、broker credential、外部写能力、signed endpoint、account endpoint、listenKey、真实账户读取或网络必需验证；统一验证入口仍是 `bash checks/run.sh`。 |
| `architecture.md` | Core / App / Dashboard 边界继续成立；scenario replay evidence 沿 local deterministic fixture -> replay evidence -> quality / report input version -> read model / ViewModel -> Workbench evidence surface 流动，不读取 adapter、Runtime object、SQLite / DuckDB schema、真实账户 / broker state 或 production operations state。 |
| `docs/roadmap.md` | Project 完成后需要由 Parent Codex 设置或确认 Linear Project `Completed`，再通过 Stage Code Audit Report、Root Docs Refresh Gate 和当前阶段完成进度条同步已发生事实；MTP-109 不直接修改下一阶段路线，不创建下一 Project / Issue。 |

## Stage Code Audit handoff checklist

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-103`、`MTP-104`、`MTP-105`、`MTP-106`、`MTP-107`、`MTP-108`、`MTP-109`。
- Linear Project completion evidence：Project status `Completed`、`type=completed`、`completedAt` 非空。
- Issue / PR evidence：PR #201、#202、#203、#204、#205、#206 和 MTP-109 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：terminology、manifest identity、fixture version、fixed window / record order、replay cursor、checksum / freshness、data quality gates、report input versioning、Report / Dashboard / Event Timeline read-model-only evidence、Dashboard smoke scenario replay handles、manifest parser、Runtime replay job、production data platform、automatic download / repair、schema leakage、adapter request leakage、Runtime object read、Graphify update、Figma change、Linear mutation、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、live command、order form、query language 和 trading button 禁区。
- Known CI Boundary：如本 Project 没有新增临时 CI 平台边界，应明确记录无新增；若 MTP-109 PR 暴露失败，按事实记录。
- Root Docs Delta：检查 `GOAL.md`、`BLUEPRINT.md`、`environment.md`、`architecture.md`、`docs/roadmap.md`。
- Current Phase Progress Bar：Root Docs Refresh Gate closure 后由 `@002 / PAR` 按 `GOAL.md` / `docs/roadmap.md` 目标切片输出，不按 Project closure count 直接计算目标完成度。
- Residual Notes For Human Planning：下一阶段只作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
