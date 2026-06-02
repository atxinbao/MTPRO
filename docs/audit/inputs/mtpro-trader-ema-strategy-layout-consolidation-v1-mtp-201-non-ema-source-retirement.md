# MTPRO Trader EMA Strategy Layout Consolidation v1 MTP-201 非 EMA active source 退休证据

日期：2026-06-02

执行者：Codex

## 定位

`MTP-201-NON-EMA-ACTIVE-SOURCE-RETIREMENT`

本文档是 `MTP-201` 的 source retirement / evidence output。MTP-201 使用 `MTP-200` audit input，把当前 active concrete strategy source layout 收口为 only `Sources/Trader/Strategies/EMA/`，并把 OrderBookImbalance 从 active Trader strategy path 退休为 Core research evidence。

`MTP-201-EMA-ONLY-ACTIVE-SOURCE-LAYOUT`

当前 active concrete strategy source files only:

- `Sources/Trader/Strategies/EMA/EMACross.swift`
- `Sources/Trader/Strategies/EMA/StrategySignals.swift`
- `Sources/Trader/Strategies/EMA/PaperActionProposal.swift`

`Sources/Trader/Strategies/OrderBookImbalance/` 已退休，不再作为 current active strategy source root。

## Source 退休

`MTP-201-ORDERBOOKIMBALANCE-RESEARCH-EVIDENCE-RECLASSIFICATION`

| 退休前 | 退休后 | 分类 |
| --- | --- | --- |
| `Sources/Trader/Strategies/OrderBookImbalance/OrderBookImbalance.swift` | `Sources/Core/Research/OrderBookImbalanceResearchEvidence.swift` | historical research / parity / persistence evidence |
| `Package.swift` source root `"Trader/Strategies/OrderBookImbalance"` | removed | no active non-EMA strategy package root |
| `Tests/CoreTests/CoreTests.swift` path validation | updated | asserts active strategy layout only includes EMA |
| `TraderStrategyBindingsBoundaryFixture` concrete roots | updated | concrete active roots only include EMA |

保留的 OrderBookImbalance public types 继续服务本地 research command / event / persistence tests。它们不授权 Strategy runtime、Trader runtime、ExecutionClient、OMS、broker command、signed/account endpoint、private stream runtime、Live PRO Console、trading button、live command 或 order form。

## 验证证据

`MTP-201-SOURCE-RETIREMENT-VALIDATION`

必须执行的本地验证：

- `swift test --filter CoreTests/testTraderOwnedStrategyPathValidationCoversCanonicalOldBindingAndExecutionGuards`
- `swift test --filter CoreTests/testOrderBookImbalanceStrategyGeneratesStableSignalFixture`
- `swift test --filter CoreTests/testOrderBookImbalanceResearchParityEvidenceCoversBiasAndInputSources`
- `swift test --filter CoreTests/testOrderBookImbalanceRejectsInvalidConfigurationAndInputs`
- `git diff --check`
- `bash checks/run.sh`

## 边界证据

`MTP-201-FORBIDDEN-RUNTIME-GUARD`

- 不拆 SwiftPM target graph。
- 不新增 SwiftPM target、product 或 dependency。
- 不实现 Strategy runtime 或 Trader runtime。
- 不实现 ExecutionClient、OMS、broker gateway、broker command、signed/account endpoint、private stream runtime、Live PRO Console、trading button、live command 或 order form。
- 不移动 StrategyBindings；该 boundary 由 MTP-202 处理。
- 不启动 Symphony，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。
