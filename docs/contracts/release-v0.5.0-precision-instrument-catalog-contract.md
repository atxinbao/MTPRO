# Release v0.5.0 Precision Primitives / InstrumentCatalog Contract

日期：2026-06-14

执行者：Codex

本文档服务 GitHub fallback issue `GH-729 V050-04 Precision primitives & InstrumentCatalog`。

GH-729 只定义 runtime correctness foundation：fixed-point precision primitives、Binance Spot / USDⓈ-M Perpetual InstrumentCatalog 和 strict ProductType parsing。它不连接 exchangeInfo endpoint、不连接 broker、不读取 secret、不发送真实订单、不授权 production cutover。

## V050-04-PRECISION-PRIMITIVES-INSTRUMENT-CATALOG

`V050-04-PRECISION-PRIMITIVES-INSTRUMENT-CATALOG`

权威 source anchor：

- `Sources/DomainModel/ReleaseV050PrecisionInstrumentCatalog.swift`
- `Sources/DomainModel/ProductType.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH729PrecisionPrimitivesAndInstrumentCatalogAreStrict`
- `checks/verify-v0.5.0-instrument-catalog.sh`
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RELEASE-V050-PRECISION-INSTRUMENT-CATALOG`

合同固定：

- issue：`GH-729`
- upstream issue：`GH-726`
- previous issue：`GH-728`
- downstream issues：`GH-734`、`GH-736`、`GH-739`
- active venue：`binance`
- active products：`spot`、`usdsPerpetual`
- active catalog symbol：`BTCUSDT`

## V050-04-FIXED-POINT-MONEY-NOTIONAL-EXPOSURE-PRICE-QUANTITY

`V050-04-FIXED-POINT-MONEY-NOTIONAL-EXPOSURE-PRICE-QUANTITY`

GH-729 定义 `ReleaseV050FixedPointValue` 和 `ReleaseV050PrecisionPolicy`：

- `money`
- `notional`
- `exposure`
- `price`
- `quantity`

这些 precision primitives 使用 `minorUnits + scale` 的 fixed-point 语义。它们不使用 Double 近似值表达 tickSize、stepSize、minQty 或 minNotional 的 runtime foundation。

## V050-04-BINANCE-SPOT-PERP-INSTRUMENT-FILTERS

`V050-04-BINANCE-SPOT-PERP-INSTRUMENT-FILTERS`

`ReleaseV050InstrumentCatalogEntry` 必须显式记录：

- venue
- productType
- symbol
- baseAsset
- quoteAsset
- marginAsset
- precisionPolicy
- tickSize
- stepSize
- minQty
- minNotional
- contractSize
- fundingIntervalHours
- tradingStatus

Spot row 不允许 margin asset、contract size 或 funding interval。USDⓈ-M Perpetual row 必须保留 USDT margin asset、contract size 和 8h funding interval。

## V050-04-STRICT-PRODUCTTYPE-PARSING

`V050-04-STRICT-PRODUCTTYPE-PARSING`

`ProductType(contractValue:)` 必须只接受显式 v0.5.0 active product：

- `spot`
- `usdsPerpetual`
- `usds-perpetual`
- `usds_perpetual`

以下 broad / ambiguous strings 必须拒绝：

- `perpetual`
- `futures`
- `usdm`
- `usdmPerpetual`
- `usdsmPerpetual`
- `coinMPerpetual`

## TVM-RELEASE-V050-PRECISION-INSTRUMENT-CATALOG

`TVM-RELEASE-V050-PRECISION-INSTRUMENT-CATALOG`

Required validation：

- `swift test --filter TargetGraphTests/testGH729PrecisionPrimitivesAndInstrumentCatalogAreStrict`
- `bash checks/verify-v0.5.0-instrument-catalog.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## Non-authorization

GH-729 不授权：

- Linear / Symphony / Graphify / code-index / Figma。
- production secret read。
- production endpoint connection。
- exchangeInfo runtime polling。
- broker gateway。
- signed endpoint runtime。
- real submit / cancel / replace。
- production OMS。
- Live PRO Console production command。
- production cutover。
- non-Binance venue。
- non-Spot / non-USDⓈ-M product。
- 下一 Project / Issue / milestone 自动启动。
