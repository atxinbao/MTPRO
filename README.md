# MTPRO

Date: 2026-07-20

Executor: Codex

Status: Canonical

MTPRO 是一个 SwiftPM-first、local-first 的 macOS 原生交易系统。当前产品范围只支持：

- Venue：Binance
- Product：Spot、USD-M Futures
- 运行环境：本地、回测、模拟、Binance Demo Network

OKX、Bybit 和其他交易所不属于当前产品目标。后续若扩展 venue，必须通过新的产品决策、模块合同和独立验收进入当前范围。

## 当前基线

当前后端冻结基线由两部分共同组成：

1. GitHub Release [`v0.33.0`](https://github.com/atxinbao/MTPRO/releases/tag/v0.33.0)，tag commit `19d5d6bcc24ae6cc243396cea57d1c01499b23fe`。
2. v0.33.0 发布后的 closure / maintenance 合并链；当前代码以 `main` 为准。

权威状态：

```text
activeVenue=Binance
activeProducts=spot,usdsPerpetual
backendClosureDecision=accepted-demo-network-parity
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

这表示 Binance Spot 与 USD-M Futures 的 Demo Network submit / status / cancel 后端证据链已经验收。它不表示生产切换已授权，也不表示生产交易默认开启。

## 已具备能力

- 统一 DomainModel、MessageBus、DataEngine、Trader、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient 边界。
- Binance Spot 与 USD-M Futures 的数据、订单计划、审批、风险、执行、OMS、对账和证据链。
- Demo Network 双产品 submit / status / cancel 验证。
- 本地 append-only 事件与运行证据、失败关闭校验、脱敏和 provenance 检查。
- CLI 操作入口和只读 Dashboard 状态展示。
- macOS 与 Linux SwiftPM 验证矩阵。

## 生产边界

生产能力不是永久禁止项，但必须通过独立 production cutover 决策放权。当前默认保持：

- 不自动读取生产密钥。
- 不自动连接生产 endpoint。
- 不自动提交、取消或替换生产订单。
- Dashboard 不提供默认生产交易控制。
- Demo Network 证据不能自动升级为生产授权。

## 本地启动

```bash
swift build
swift run mtpro help
swift run Dashboard
```

完整验证：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

环境要求和外部系统边界见 [`environment.md`](environment.md)。

## 文档入口

新读者按以下顺序阅读：

1. [`GOAL.md`](GOAL.md)：当前产品目标和验收状态。
2. [`BLUEPRINT.md`](BLUEPRINT.md)：后端、前端和 production cutover 的分层蓝图。
3. [`architecture.md`](architecture.md)：当前模块、数据流和依赖方向。
4. [`environment.md`](environment.md)：运行、验证和外部系统约束。
5. [`docs/roadmap.md`](docs/roadmap.md)：维护路线和下一阶段。
6. [`docs/index.md`](docs/index.md)：完整文档导航。
7. [`docs/documentation-policy.md`](docs/documentation-policy.md)：文档生命周期规则。

v0.33.0 的权威证据：

- [`docs/release/mtpro-release-v0.33.0-demo-validation-notes.md`](docs/release/mtpro-release-v0.33.0-demo-validation-notes.md)
- [`docs/audit/mtpro-release-v0.33.0-demo-validation-stage-code-audit.md`](docs/audit/mtpro-release-v0.33.0-demo-validation-stage-code-audit.md)
- [`docs/audit/mtpro-v0.33.0-backend-maintenance-stage-code-audit.md`](docs/audit/mtpro-v0.33.0-backend-maintenance-stage-code-audit.md)

旧版本逐 issue 锚点已从本页退休，保存在历史证据目录和 Git 历史中。
