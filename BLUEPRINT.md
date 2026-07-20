# MTPRO Blueprint

Date: 2026-07-20

Executor: Codex

Status: Canonical

## 蓝图定位

本蓝图定义 MTPRO 当前产品结构和后续工作分层。产品范围固定为 Binance Spot 与 Binance USD-M Futures。

```text
Market Data
-> DataEngine
-> MessageBus
-> Trader / Strategies
-> Portfolio
-> RiskEngine
-> ExecutionEngine / OMS
-> ExecutionClient
-> Binance Demo or explicitly authorized environment
-> Event Store / Reconciliation / Dashboard
```

## 后端冻结基线

v0.33.0 已完成 Binance Demo Network 双产品后端验收：

```text
backendClosureDecision=accepted-demo-network-parity
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

冻结表示当前后端能力和证据合同可作为前端产品化与后续维护的稳定输入。冻结不阻止缺陷修复，也不等于 production cutover。

## 系统分层

### 领域与事件层

- `DomainModel`：产品、订单、账户、组合、策略和执行领域类型。
- `MessageBus`：统一 event / command / query / replay spine。
- `Database`、`Cache`：持久事实、投影和可重建状态。

### 数据与策略层

- `DataClient/Binance`：Binance 数据和账户输入适配。
- `DataEngine`：ingest、replay、quality 和运行数据路径。
- `Trader`：Accounts、Strategies 和 Coordination 容器。
- 当前策略代码以仓库中的 active strategy source 为准；策略不得直连外部执行。

### 风险与执行层

- `Portfolio`：基于事实和成交证据生成组合投影。
- `RiskEngine`：执行前风险、额度、kill switch 和 no-trade gate。
- `ExecutionEngine`：订单生命周期、OMS 和执行协调。
- `ExecutionClient`：Binance 外部传输与证据边界。

### 产品界面层

- `MTPROCLI`：operator 命令、状态和验证入口。
- `Dashboard`：只读状态、风险、订单、OMS、对账和审计视图。
- 界面不能自行生成 production authorization。

## 工作路线

### 已完成后端

- Binance Spot 与 USD-M Futures 双产品领域和执行合同。
- Demo Network submit / status / cancel。
- OMS、event log、reconciliation、rollback 和 incident evidence。
- 风险门禁、额度、kill switch / no-trade 证据。
- CLI / Dashboard 共享的验证状态。
- macOS / Linux 自动验证。

### 当前后端维护

- 降低 compatibility envelope 和重复 ownership。
- 拆分过大文件和验证脚本，保持行为不变。
- 缩短验证反馈时间，同时保留 release 全矩阵。
- 修复可复现缺陷；没有用户可见变化时不创建 patch release。

### 前端产品化

- 建立面向 operator 的运行总览和异常解释。
- 将账户、组合、风险、订单、OMS、对账、事件证据组织为可追踪工作流。
- 默认只读；任何命令入口必须消费后端授权状态。

### Production Cutover Future Gate

Production cutover 是独立决策，不由后端冻结自动触发。至少需要：

- 明确环境和 Human approval。
- 生产凭证读取与脱敏审计。
- endpoint allowlist 和网络 preflight。
- 额度、风险、kill switch、no-trade 和 run lock。
- OMS / reconciliation / rollback / incident 完整证据。
- 独立验证、发布和回退计划。

## 设计不变量

- active venue 只有 Binance。
- active products 只有 Spot 与 USD-M Futures。
- Research、Backtest、Paper、Demo 和未来 Production 复用领域合同与事件语义。
- 环境差异封装在 adapter、clock、configuration 和授权 gate，不复制策略或 OMS 业务路径。
- production trading 默认关闭。
- OKX / Bybit 不进入当前 source、runtime 或发布承诺。
- 历史 issue anchors 只保存在历史证据中，不再写入当前蓝图。
