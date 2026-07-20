# MTPRO Roadmap

Date: 2026-07-20

Executor: Codex

Status: Canonical

## 当前状态

MTPRO 后端以 v0.33.0 Demo parity 为冻结基线：

```text
activeVenue=Binance
activeProducts=spot,usdsPerpetual
backendClosureDecision=accepted-demo-network-parity
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

Binance Spot 与 USD-M Futures 的 Demo submit / status / cancel、风险、OMS、对账、证据校验和只读状态路径已经验收。当前不再新增没有明确缺陷或产品决策来源的后端功能版本。

## 路线 A：后端维护

优先级从高到低：

1. 可复现缺陷和 fail-closed 回归。
2. macOS / Linux 构建与测试稳定性。
3. ownership、重复实现和 compatibility envelope 清理。
4. 大文件和历史验证脚本拆分，缩短反馈时间。
5. Demo evidence、release artifact 和文档事实一致性。
6. 依赖、性能和可观测性维护。

维护规则：

- 每个问题独立 issue / PR。
- 不改写既有 release tag。
- 用户可见行为或 release artifact 修复才考虑 patch release。
- 无能力变化的清理不得暗示 production authorization。

## 路线 B：前端产品化

下一产品阶段以当前冻结后端作为输入，重点建设：

- operator 总览。
- 运行、账户和组合状态。
- 风险、kill switch 和 no-trade 状态。
- 订单、OMS、对账和事件审计视图。
- 失败分类、下一步操作和 incident drilldown。
- 安全、清晰、可审计的命令审批体验。

前端默认保持只读。未来命令入口必须消费后端真实授权结果，不能在 UI 内自行放权。

## 路线 C：Production Cutover

Production cutover 不是当前已授权路线。启动前至少需要新的独立计划和以下证据：

1. Human 明确授权、时间窗口和责任人。
2. production credential 隔离、读取和脱敏审计。
3. production endpoint allowlist 与连接 preflight。
4. symbol、product、notional、order count 和时间窗口硬限额。
5. RiskEngine、kill switch、no-trade 和 run lock。
6. OMS、reconciliation、rollback 和 incident evidence。
7. CLI / Dashboard 状态、操作 runbook 和停止路径。
8. 全矩阵验证、独立 Stage Audit 和回退方案。

在上述 gate 完成前：

```text
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

## 当前不在路线内

- OKX、Bybit 或其他 venue。
- 非 Spot / USD-M Futures 产品。
- 从 Demo 证据自动推导 production approval。
- Dashboard 默认交易按钮或无审批命令。
- 用历史 planning record 作为当前执行授权。

## 历史入口

逐版本 issue anchor、planning record、contract、release note 和 Stage Audit 已从本路线图移出。历史证据继续保留在：

- `docs/planning/projects/`
- `docs/contracts/`
- `docs/release/`
- `docs/audit/`
- `docs/history/`

当前文档导航见 `docs/index.md`，生命周期规则见 `docs/documentation-policy.md`。
