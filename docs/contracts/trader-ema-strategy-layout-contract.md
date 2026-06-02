# Trader EMA Strategy Layout Contract

日期：2026-06-02

执行者：Codex

本文档是 `MTPRO Trader EMA Strategy Layout Consolidation v1` 的 MTP-198 contract-first evidence。它只定义 Trader-owned EMA-only strategy layout 的当前合同，不移动 production source，不修改 `Package.swift`，不拆 SwiftPM target graph，不实现 Strategy runtime、Trader runtime、ExecutionClient、OMS、broker command、signed/account endpoint、private stream runtime、Live PRO Console、trading button、live command 或 order form。

## MTP-198 EMA-only Trader Strategy Layout Contract

`MTP-198-EMA-ONLY-TRADER-STRATEGY-LAYOUT-CONTRACT`

MTP-198 将当前 active concrete strategy 固定为 `EMA`。当前唯一 canonical active concrete strategy path 是 `Sources/Trader/Strategies/EMA/`；该目录承载 EMA lifecycle、signals、paper/live-neutral proposal 和 strategy-specific evidence。除 EMA 外，任何具体策略名称都不得在当前阶段被写成 active implementation、current production strategy、Package.swift active source root 或 execution-ready strategy。

`MTP-198-CANONICAL-ACTIVE-EMA-PATH`

`Sources/Trader/Strategies/EMA/` 是当前唯一 active concrete strategy path。MTP-198 不改变该目录下既有 EMA source，也不改变 `Core` compatibility envelope；它只把“当前可规划和管理的 active strategy”收口为 EMA，避免后续把多个 strategy 候选和真实执行边界混在一起。

`MTP-198-NON-EMA-FUTURE-CANDIDATE-BOUNDARY`

`RSI`、`OrderBookImbalance`、`Momentum` 和 `MeanReversion` 只能作为 future strategy candidate / future-gated strategy label 出现。它们不得作为当前 active concrete strategy、不得进入 current active strategy source root、不得进入 Package.swift active strategy root、不得进入 Trader runtime、ExecutionClient request、OMS order、broker order、live command、order form 或 trading button。现有 `Sources/Trader/Strategies/OrderBookImbalance/` 只作为 MTP-194 已发生的 compatibility / superseded source placement debt 记录，后续必须由 MTP-200 audit 和 MTP-201 retirement / quarantine issue 处理。

`MTP-198-STRATEGYBINDINGS-NOT-FIRST-LEVEL-STRATEGY-DIRECTORY`

`Sources/Trader/StrategyBindings/` 不是 first-level Trader strategy directory，也不是 concrete strategy implementation landing path。它不能承载 EMA、RSI、OrderBookImbalance、Momentum、MeanReversion 或任何未来具体 strategy 的 lifecycle、signals、proposal implementation、quoter、hedger 或 strategy-specific business rules。

`MTP-198-TRADER-COORDINATION-BINDING-RESPONSIBILITY`

Binding / adapter semantics 归 `Sources/Trader/Coordination/` 责任边界管理。当 strategy instance 需要连接 account context、RiskEngine、Portfolio evidence 或 ExecutionEngine evidence 时，应该通过 `Trader/Coordination/<binding>/` 这类 coordination boundary 表达，例如后续可以规划 `Sources/Trader/Coordination/RiskBinding/`。该语义不授权当前创建目录、移动 source 或实现 Trader runtime。

`MTP-198-FORBIDDEN-STRATEGY-PATH-EXECUTION-BYPASS-TAXONOMY`

当前禁止路径包括：`Strategy -> ExecutionClient`、`Strategy -> broker command`、`Strategy -> OMS`、`Strategy -> executable order command`、`Strategy -> signed endpoint`、`Strategy -> account endpoint / listenKey`、`Strategy -> private WebSocket runtime`、`Strategy -> Live PRO Console`、`Strategy -> trading button`、`Strategy -> live command`、`Strategy -> order form`、`StrategyBindings -> concrete strategy`、`StrategyBindings -> ExecutionClient`、`StrategyBindings -> broker command` 和 `StrategyBindings -> OMS`。Paper proposal、signal、risk decision 和 portfolio projection 只能作为 deterministic local evidence，不得升级为真实交易命令。

`MTP-198-NO-SOURCE-MOVE-PACKAGE-RUNTIME-GUARD`

MTP-198 是 contract / docs boundary issue。它不移动 `Sources` 文件，不删除 `Sources/Trader/Strategies/OrderBookImbalance/`，不移动 `Sources/Trader/StrategyBindings/`，不修改 `Package.swift`，不新增 SwiftPM target、product 或 dependency，不做 target graph split，不写 Swift business code，不创建 Runtime object、Adapter request、ExecutionClient implementation、OMS implementation、broker adapter、signed/account/listenKey endpoint、private stream runtime、account snapshot runtime、Live PRO Console、trading button、live command 或 order form。

`MTP-198-EMA-ONLY-LAYOUT-VALIDATION`

MTP-198 validation 必须证明本文档、`docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/automation/automation-readiness.md` 和 `docs/validation/latest-verification-summary.md` 均包含 EMA-only Trader strategy layout anchors；并且 `bash checks/run.sh` 通过。完整 gate 仍以 PR required check `checks`、merge evidence、root main fast-forward、Linear Done 和 post-issue ledger evidence 为准。
