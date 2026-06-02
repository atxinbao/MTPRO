# Trader Accounts / Coordination Compatibility Contract

日期：2026-06-03

执行者：Codex

本文档是 `MTPRO Trader Accounts / Coordination Compatibility Consolidation v1` 的 MTP-205 contract-first evidence。它只定义 Trader container、Accounts、EMA strategy、Coordination / RiskBinding 和 retired active paths 的当前兼容合同，不移动 production source，不修改 `Package.swift`，不拆 SwiftPM target graph，不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient、OMS、broker command、signed/account endpoint、private stream runtime、Live PRO Console、trading button、live command 或 order form。

## MTP-205 Trader Accounts / Coordination Compatibility Contract

`MTP-205-TRADER-ACCOUNTS-COORDINATION-COMPATIBILITY-CONTRACT`

MTP-205 将当前 Trader container 的 active relationship 固定为 `Trader = Accounts + Strategies/EMA + Coordination`。这句话只表达当前 MTPRO 的 source layout / contract / validation 口径，不表示 Trader runtime、strategy scheduler、live coordinator、broker gateway 或 account session runtime 已实现。

`MTP-205-TRADER-CONTAINER-AUTHORITATIVE-RELATIONSHIP`

`Trader` 是 account context、当前 EMA strategy evidence 和 local coordination adapter 的容器。当前 contract component set 是：

- `Sources/Trader/Accounts/`
- `Sources/Trader/Strategies/EMA/`
- `Sources/Trader/Coordination/RiskBinding/`

旧 `Trader = Accounts + Strategies + StrategyBindings + Coordination` 只能作为 MTP-191 / MTP-195 historical evidence 保留；MTP-205 之后的 current / active / forward-looking wording 必须使用 `Trader = Accounts + Strategies/EMA + Coordination`。

`MTP-205-TRADER-ACCOUNTS-IDENTITY-SOURCE-FUTURE-GATE`

`Trader/Accounts` 只表达 account identity、source identity 和 future real account gate。它不能拥有 cash、positions、PnL、exposure、margin、leverage、buying power、real account payload、broker account state、account endpoint payload、listenKey state 或 private stream runtime state。Portfolio financial state 继续属于 `Sources/Portfolio/`，future real account read 仍需要独立 Human + `@001 / PLN` planning、Linear issue、Parent Codex queue preflight 和 validation gate。

`MTP-205-EMA-ONLY-STRATEGY-CURRENT-ACTIVE-GUARD`

当前 active concrete strategy only `EMA`，canonical active path only `Sources/Trader/Strategies/EMA/`。非 EMA strategy 名称只能作为 future candidate、future-gated label、historical evidence 或 compatibility debt 出现，不得写成 current active strategy、execution-ready strategy、Package.swift active source root、Trader runtime input、ExecutionClient request、OMS command、broker order、Live PRO Console command、trading button 或 order form input。

`MTP-205-RISKBINDING-COORDINATION-BOUNDARY`

`RiskBinding` 位于 `Sources/Trader/Coordination/RiskBinding/`，只表达 proposal / risk / portfolio / execution evidence 的 local coordination adapter contract。它不是 concrete strategy implementation landing path，不承载 EMA lifecycle、signals、proposal implementation、quoter、hedger 或 strategy-specific business rules，也不得成为 ExecutionClient gateway、broker gateway、OMS gateway、executable order command、live command 或 real order lifecycle shortcut。

`MTP-205-STRATEGYBINDINGS-SOURCES-STRATEGIES-RETIRED-ACTIVE-PATHS`

`Sources/Trader/StrategyBindings/` 不再是 current active source root，不再是 first-level Trader strategy directory，也不再承载 active binding implementation。旧 `Sources/Trader/StrategyBindings/` wording 只能保留在 historical audit、superseded planning、migration-source evidence 或 compatibility notes 中。

`Sources/Strategies/` 不再是 current active strategy source path。旧 `Sources/Strategies/<strategy>`、`Sources/Strategies/EMA/` 或 `Sources/Strategies/OrderBookImbalance/` wording 只能作为 historical / compatibility / superseded / migration-source context，不得写回 canonical active path。

`MTP-205-PACKAGE-COMPATIBILITY-ENVELOPE-CLEANUP-ENTRY`

`Package.swift` 当前仍承担 compatibility envelope 的本地构建职责。MTP-205 不修改 `Package.swift`，只为 MTP-209 提供 cleanup input：后续清理 stale `Strategies` compatibility excludes 时，必须保持 `Core` compatibility envelope buildability，不新增 SwiftPM target、product 或 dependency，不拆 target graph，不把 cleanup 解读为 Strategy runtime、Trader runtime 或 L4 authorization。

`MTP-205-FORBIDDEN-CAPABILITY-TAXONOMY`

MTP-205 禁止以下 capability：Strategy runtime、Trader runtime、Live runtime、live coordinator、broker gateway、ExecutionClient implementation、ExecutionClient request、OMS implementation、OMS command、broker command、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、broker position sync、broker account state read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、runtime object exposure、adapter request exposure、database schema exposure 和 credential / secret / keychain storage。

`MTP-205-TRADER-ACCOUNTS-COORDINATION-COMPATIBILITY-VALIDATION`

MTP-205 validation 必须证明本文档、Project Planning Record、`docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/automation/automation-readiness.md` 和 `docs/validation/latest-verification-summary.md` 均包含 Trader Accounts / Coordination compatibility anchors；并且 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh` 通过。完整 gate 仍以 PR required check `checks`、merge evidence、root main fast-forward、Linear Done 和 post-issue ledger evidence 为准。
