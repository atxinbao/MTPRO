# Release v0.2.0 Binance Spot + USDⓈ-M Perpetual + EMA/RSI NTPRO Alignment Contract

日期：2026-06-11

执行者：Codex

本文档服务 GitHub fallback issue `GH-563 V020-01 Define v0.2.0 Binance Spot + USDⓈ-M Perpetual + EMA/RSI contract`。

本文档定义 `MTPRO Release v0.2.0` 的顶层合同、active scope、NTPRO scoped 100% alignment matrix、验收矩阵和 no-default-production-trading 门禁。Release v0.2.0 的唯一 active venue 是 Binance，唯一 active product types 是 Spot 和 USDⓈ-M Perpetual，唯一 active concrete strategies 是 EMA 和 RSI。本文档不实现 runtime，不读取 secret，不连接 production endpoint，不提交真实订单，不启动 Symphony，不运行 Graphify / code-index，不使用 Linear，不修改 Figma。

## GH-563-RELEASE-V020-BINANCE-SPOT-PERP-EMA-RSI-CONTRACT

`GH-563-RELEASE-V020-BINANCE-SPOT-PERP-EMA-RSI-CONTRACT`

Release v0.2.0 contract 是 GH-563 至 GH-596 的共同上层合同。后续 issue 只能在自己的 scope 内逐项补齐 Binance Spot / Binance USDⓈ-M Perpetual、EMA / RSI、NTPRO scoped alignment、runtime evidence、dry-run / testnet evidence、guard evidence、docs evidence 和 release audit evidence，不得用一个 issue 越级打开 production trading。

合同固定：

- milestone：`MTPRO Release v0.2.0`
- queue range：`GH-563..GH-596`
- activeVenue == Binance
- activeProductTypes == [spot, usdsPerpetual]
- activeStrategies == [ema, rsi]
- productionTradingEnabledByDefault == false
- Binance 是 release v0.2.0 唯一 active venue。
- Spot 和 USDⓈ-M Perpetual 是 release v0.2.0 唯一 active product types。
- EMA 和 RSI 是 release v0.2.0 唯一 active concrete strategies。
- NTPRO scoped 100% alignment 只表示合同、边界、证据链和验证口径对齐，不复制 NTPRO 代码，不引入 NTPRO runtime dependency，不扩大 MTPRO 当前 release scope。
- Production endpoint、production secret、production broker connection 和 production order command 不属于默认路径。
- CommandGateway、RiskEngine、ExecutionEngine、OMS、Event Store 和 validation gates 不能被绕过。
- final release closure 必须在 GH-596 后单独证明 issue / PR / checks / merge / validation evidence 完整。

## GH-563-BINANCE-SPOT-PERP-ACTIVE-SCOPE

`GH-563-BINANCE-SPOT-PERP-ACTIVE-SCOPE`

Release v0.2.0 的 active venue / product scope 只包含：

- Binance Spot public market data、account read、private stream、testnet command evidence 和 release docs evidence。
- Binance USDⓈ-M Perpetual public market data、account read、private stream、testnet command evidence 和 release docs evidence。
- Spot / Perpetual product routing 必须保留 product identity、source identity、risk gate identity、execution gate identity 和 event evidence identity。
- Spot 与 USDⓈ-M Perpetual 不能混用 margin、position、order、leverage、funding、execution report 或 account snapshot 语义。

非 Binance venue 不属于 release v0.2.0 active scope。非 Spot / USDⓈ-M Perpetual product types 不属于 release v0.2.0 active scope。

## GH-563-EMA-RSI-ACTIVE-STRATEGY-SCOPE

`GH-563-EMA-RSI-ACTIVE-STRATEGY-SCOPE`

Release v0.2.0 的 active concrete strategy scope 只包含：

- EMA strategy lifecycle、signal、proposal、risk query 和 release validation evidence。
- RSI strategy lifecycle、signal、proposal、risk query 和 release validation evidence。
- EMA / RSI strategy evidence 必须保持 Trader-owned strategy layout，不得回到平级 `Sources/Strategies` active root。
- EMA / RSI 只能输出 paper/live-neutral proposal evidence；它们不能直连 ExecutionClient、broker、OMS、CommandGateway bypass 或 Dashboard live command。
- EMA / RSI 必须由 CommandGateway、RiskEngine、ExecutionEngine、OMS 和 Event Store gate 约束，不能直接生成 executable order command。

非 EMA / RSI concrete strategy 不属于 release v0.2.0 active scope。

## GH-563-NTPRO-SCOPED-ALIGNMENT-MATRIX

`GH-563-NTPRO-SCOPED-ALIGNMENT-MATRIX`

NTPRO scoped 100% alignment 是 release v0.2.0 的 scoped alignment contract，只对齐 MTPRO 当前 release 范围内的术语、边界、证据链和 validation gate，不复制 NTPRO 代码，不把 NTPRO repository 当作 runtime dependency。

| Alignment domain | Release v0.2.0 required alignment | MTPRO boundary |
| --- | --- | --- |
| Venue scope | Binance-only | 不新增 OKX、Bybit、Coinbase、Kraken 或其他 venue |
| Product scope | Spot + USDⓈ-M Perpetual only | 不新增 Options、COIN-M、margin lending、portfolio margin 或 cross-venue products |
| Strategy scope | EMA + RSI only | 不新增 grid、market making、arbitrage、momentum、mean reversion 或 custom active strategy |
| Command routing | CommandGateway before order-capable path | Strategy / Trader / Dashboard 不能绕过 CommandGateway |
| Risk routing | RiskEngine before ExecutionEngine | proposal 不得绕过 RiskEngine |
| Execution routing | ExecutionEngine / OMS before ExecutionClient | ExecutionClient 不能被 Trader / Strategy / Dashboard 直接调用 |
| Event evidence | Event Store / append-only evidence before release closure | runtime evidence 必须可审计、可回放、可验证 |
| Validation | `git diff --check`、`bash checks/automation-readiness.sh`、`bash checks/run.sh` | required validation 不依赖 production secret / production endpoint |
| Production default | productionTradingEnabledByDefault == false | production trading 仍需后续显式 release gate、operator confirmation、risk approval 和 kill switch pass |

## GH-563-ACCEPTANCE-MATRIX

`GH-563-ACCEPTANCE-MATRIX`

| Issue | Release v0.2.0 acceptance domain | Boundary |
| --- | --- | --- |
| GH-563 / V020-01 | Top-level Binance Spot + USDⓈ-M Perpetual + EMA/RSI contract | 不实现 runtime，不打开 production trading |
| GH-564 / V020-02 | v0.2.0 ownership / module / package gap retirement | 不新增非 release scope target graph |
| GH-565 / V020-03 | real target smoke tests for release v0.2.0 modules | smoke 不等于 runtime authorization |
| GH-566 / V020-04 | Binance Spot public market data runtime path | public market data 不授权 order command |
| GH-567 / V020-05 | Binance USDⓈ-M Perpetual public market data runtime path | perpetual market data 不授权 leverage / margin action |
| GH-568 / V020-06 | Spot signed account read runtime | no production secret by default |
| GH-569 / V020-07 | USDⓈ-M signed account read runtime | no production endpoint by default |
| GH-570 / V020-08 | Spot private stream / account snapshot runtime | no raw listenKey exposure |
| GH-571 / V020-09 | USDⓈ-M private stream / account snapshot runtime | no broker command surface |
| GH-572 / V020-10 | account / position / balance / margin read-model mapping | read-model-only evidence |
| GH-573 / V020-11 | Trader runtime lifecycle for Binance Spot / Perp accounts | no direct ExecutionClient path |
| GH-574 / V020-12 | EMA runtime consolidation for v0.2.0 | EMA only inside active EMA scope |
| GH-575 / V020-13 | RSI runtime addition for v0.2.0 | RSI only inside active RSI scope |
| GH-576 / V020-14 | Strategy coordination and proposal parity for EMA / RSI | paper/live-neutral proposal isolation |
| GH-577 / V020-15 | RiskEngine live pre-trade gate for Spot / Perp | no RiskEngine bypass |
| GH-578 / V020-16 | CommandGateway gated submit / cancel / replace contract | no direct UI / strategy command |
| GH-579 / V020-17 | ExecutionEngine OMS lifecycle for Spot / Perp | OMS before ExecutionClient |
| GH-580 / V020-18 | Binance Spot ExecutionClient testnet SCR | testnet only |
| GH-581 / V020-19 | Binance USDⓈ-M ExecutionClient testnet SCR | testnet only, no production leverage action |
| GH-582 / V020-20 | Spot execution report / broker fill parser | no raw production payload |
| GH-583 / V020-21 | USDⓈ-M execution report / broker fill parser | no raw production payload |
| GH-584 / V020-22 | reconciliation and portfolio update path | no repair command |
| GH-585 / V020-23 | Dashboard live monitoring surfaces | read-model-only surface |
| GH-586 / V020-24 | Dashboard controlled command surface | production disabled by default |
| GH-587 / V020-25 | kill switch / no-trade / rollback controls | must block submit / cancel / replace |
| GH-588 / V020-26 | Binance Spot dry-run and testnet validation suite | no production fallback |
| GH-589 / V020-27 | Binance USDⓈ-M dry-run and testnet validation suite | no production fallback |
| GH-590 / V020-28 | release v0.2.0 no-default-production-trading guards | required automation readiness guard |
| GH-591 / V020-29 | NTPRO scoped alignment validation evidence | scoped alignment only, no NTPRO runtime dependency |
| GH-592 / V020-30 | release docs and operator runbook | no production cutover authorization |
| GH-593 / V020-31 | release validation matrix closeout | stage audit input only when scoped |
| GH-594 / V020-32 | final Stage Code Audit input | no next Project / Issue |
| GH-595 / V020-33 | Root Docs Refresh input | sync only completed facts |
| GH-596 / V020-34 | final release closure | production trading remains disabled by default |

## GH-563-NO-DEFAULT-PRODUCTION-TRADING

`GH-563-NO-DEFAULT-PRODUCTION-TRADING`

Release v0.2.0 可以在后续 issue scope 内逐步实现 Binance Spot / USDⓈ-M Perpetual dry-run 和 testnet evidence，但 production trading 必须默认关闭：

- productionTradingEnabledByDefault == false
- productionEndpointConnectionEnabledByDefault == false
- productionSecretReadEnabledByDefault == false
- productionOrderSubmitEnabledByDefault == false
- productionOrderCancelEnabledByDefault == false
- productionOrderReplaceEnabledByDefault == false
- productionOMSRuntimeEnabledByDefault == false
- productionDashboardCommandEnabledByDefault == false
- nonBinanceVenueEnabled == false
- nonSpotOrUSDSMProductEnabled == false
- nonEMAOrRSIActiveStrategyEnabled == false

这些 false flags 是 release v0.2.0 的验收边界，不是隐藏 feature flag。任何 PR 都不得通过配置、环境变量、Dashboard UI、testnet credential、dry-run command 或 operator runbook 默认启用 production trading。

## GH-563-VALIDATION-ANCHORS

`GH-563-VALIDATION-ANCHORS`

Required anchors：

- `GH-563-RELEASE-V020-BINANCE-SPOT-PERP-EMA-RSI-CONTRACT`
- `GH-563-BINANCE-SPOT-PERP-ACTIVE-SCOPE`
- `GH-563-EMA-RSI-ACTIVE-STRATEGY-SCOPE`
- `GH-563-NTPRO-SCOPED-ALIGNMENT-MATRIX`
- `GH-563-ACCEPTANCE-MATRIX`
- `GH-563-NO-DEFAULT-PRODUCTION-TRADING`
- `GH-563-VALIDATION-ANCHORS`
- `GH-563-NON-AUTHORIZATION`
- `TVM-RELEASE-V020-BINANCE-SPOT-PERP-EMA-RSI-NTPRO-ALIGNMENT`

Required validation：

- `swift test --filter TargetGraphTests/testGH563ReleaseV020ContractDefinesBinanceSpotPerpEMARSIBoundary`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## GH-563-NON-AUTHORIZATION

`GH-563-NON-AUTHORIZATION`

GH-563 不授权：

- 非 Binance venue。
- non-Binance venue。
- 非 Spot / USDⓈ-M Perpetual product。
- 非 EMA / RSI active strategy。
- Strategy / Trader / Dashboard 直连 ExecutionClient、broker、OMS 或 CommandGateway bypass。
- RiskEngine、ExecutionEngine、OMS、Event Store、kill switch 或 no-trade bypass。
- production secret、production endpoint、production broker connection 或 production trading。
- real submit / cancel / replace。
- raw signed payload、raw private stream payload、raw execution report 或 raw broker fill 暴露。
- Live PRO Console、trading button、live command 或 order form 默认启用。
- 创建下一 Project / Issue 或推进 release v0.2.0 之后的阶段。
- Symphony、Graphify、code-index、Linear 或 Figma 工作。

`TVM-RELEASE-V020-BINANCE-SPOT-PERP-EMA-RSI-NTPRO-ALIGNMENT`
