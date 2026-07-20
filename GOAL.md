# MTPRO Goal

Date: 2026-07-20

Executor: Codex

Status: Canonical

## 产品目标

MTPRO 的目标是建设一个 Binance 原生交易系统，统一支撑：

- Binance Spot
- Binance USD-M Futures
- Research / Backtest / Paper / Demo / Production 共用的领域合同和事件驱动路径
- 数据、策略、账户、组合、风险、执行、OMS、对账、审计与操作界面

当前产品目标不包含 OKX、Bybit 或其他 venue。

## 当前完成状态

v0.33.0 已完成 Binance Demo Network 双产品后端验收。当前权威事实是：

```text
activeVenue=Binance
activeProducts=spot,usdsPerpetual
backendClosureDecision=accepted-demo-network-parity
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

后端冻结基线为 `v0.33.0` release snapshot 加发布后的 closure / maintenance 合并链。发布后维护可以修复缺陷、整理 ownership 和提高验证稳定性，但不得改写既有 tag。

## 当前验收定义

后端达到当前目标必须持续满足：

1. Spot 与 USD-M Futures 的 Demo submit / status / cancel 证据均独立存在。
2. 订单、OMS、reconciliation、rollback、incident 证据可关联、可校验、可脱敏。
3. CLI 对无效或缺失证据返回非零退出码。
4. Dashboard 只读消费同一份已验证状态。
5. macOS 与 Linux 验证矩阵通过。
6. 生产能力默认关闭，Demo 证据不自动授权 production cutover。

## 下一阶段目标

后端功能建设当前进入维护冻结，不继续堆叠无明确缺陷来源的功能版本。后续工作分为三条独立路线：

### 后端维护

- 构建和跨平台稳定性。
- ownership、重复实现和 compatibility envelope 清理。
- 测试性能、证据一致性和发布流程维护。
- 真实缺陷的 patch release。

### 前端产品化

- 基于只读后端状态构建清晰的 operator workflow。
- 统一运行、风险、订单、OMS、对账和事件审计视图。
- 保持界面命令能力与 production authorization 解耦。

### Production Cutover

- 仅在独立 Human approval、凭证、endpoint、额度、风险、kill switch、回滚和审计 gate 全部成立后推进。
- production cutover 的授权不能由 Demo 验收、文档更新或普通维护 PR 推导。

## 不变量

- Binance 是唯一 active venue。
- Spot 与 USD-M Futures 是唯一 active products。
- 默认生产交易关闭。
- 生产 secret 不自动读取。
- 生产 endpoint 不自动连接。
- 所有外部执行必须经过 RiskEngine、ExecutionEngine、OMS 和审计链。
- Dashboard 不得绕过后端 gate。
- 历史 audit、contract、release 和 planning 记录属于证据，不是当前目标定义。
