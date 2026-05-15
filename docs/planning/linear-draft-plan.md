# MTPRO Linear 草案

日期：2026-05-14

执行者：Codex

状态：已写入 Linear；保留为规划证据

本文档最初是 MTPRO 的 Linear 规划草案。用户确认后，已按本文档写入 Linear；后续以 Linear 和 PR 证据链作为执行事实源。

本文档本身不授权 Codex 执行，不授权 Symphony，不授权 Graphify 更新，不授权 Binance、策略、UI 或数据库适配器实现。

## 来源

- 仓库：`/Users/mac/Documents/MTPRO`
- 基线提交：`a141648 Bootstrap MTPRO skeleton`
- `GOAL.md`：`/Users/mac/Documents/MTPRO/GOAL.md`
- `ARCHITECTURE.md`：`/Users/mac/Documents/MTPRO/ARCHITECTURE.md`
- `ROADMAP.md`：`/Users/mac/Documents/MTPRO/ROADMAP.md`
- AI Engineering Protocol：`/Users/mac/code/ai-engineering-protocol/docs/ai-engineering-protocol.md`
- Roadmap to Linear Orchestration Protocol：`/Users/mac/code/ai-engineering-protocol/docs/protocols/roadmap-to-linear-orchestration-protocol.md`

## 目标 Linear 团队

- 团队名称：NautilusTrade Pro
- 团队标识：MTP
- 团队 ID：MTP
- Linear 返回显示名称：Macostrader Pro

## 工作流状态映射

| 协议状态 | Linear 团队状态 | 说明 |
| --- | --- | --- |
| 唯一可执行状态 | `Todo` | 已用于 `MTP-8` |
| 进行中状态 | `In Progress` | 后续执行时使用 |
| 审查状态 | `In Review` | 建议映射；不可执行 |
| 完成状态 | `Done` | 建议映射；不可执行 |
| 取消状态 | `Canceled` | 建议映射；不可执行 |

## 流程边界

- 本文档不是执行授权。
- 已获得人工确认并完成 Linear Setup。
- Linear 已成为执行事实源；当前执行门槛是同一 Project 中唯一 configured executable issue。
- Symphony 只能调度当前唯一可执行 Linear 事项。
- Codex 执行代理只创建 PR，不合并 PR。
- PR 合并由 GitHub PR Automation 处理。
- Graphify 在默认流程中只能作为只读上下文。
- MTPRO 不创建单独的 test-mode onboarding Project / Issues。
- `ROADMAP.md` 不授权执行。

## Linear 项目草案

- 名称：MTPRO 引导
- 摘要：macOS 原生交易研究工作台，从 Binance 公开只读数据到回测和 Paper 一致性闭环。
- 描述：MTPRO 是用于重构 `macos-trader` 产品语义的新独立 Swift-only macOS 项目。项目采用契约优先和 AEP v2 流程推进，第一版禁止真实交易、签名端点、账户端点和真实经纪商动作；优先建立核心模型与事件日志、Binance 只读行情、内核与缓存、回测与 Paper 一致性、持久化投影和工作台可观察面。
- 负责人：待确认
- 优先级：待确认
- 开始日期：待确认
- 目标日期：待确认

## 引导完成状态

| 门槛 | 状态 | 证据 |
| --- | --- | --- |
| 项目定义 | 已完成基线审查 | 根文档、契约文档、验证计划已创建 |
| 引导基线提交 | 已完成 | `a141648 Bootstrap MTPRO skeleton` |
| Bootstrap PR | 已创建 | Draft PR：`https://github.com/atxinbao/MTPRO/pull/1` |
| Human Review | 已确认 | 用户已在 2026-05-14 确认草案 |
| Linear Setup | 已完成 | 已创建 Project `MTPRO 引导`、9 个里程碑和 `MTP-7` 到 `MTP-15` |
| Automation Readiness | 已通过 | GitHub PR Automation、WIP=1、Graphify 只读边界、GitHub remote 和 GitHub + Linear 关联已确认 |
| Test-mode onboarding Project / Issues | 不适用 | MTPRO 不创建单独 test Project / test Issues，下一次真实 PR 验证 GitHub PR Automation |
| 是否允许开发执行 | 是，仅限当前唯一 issue | 当前仅 `MTP-8` 为 configured executable issue |

## 里程碑

| 顺序 | 里程碑 | 来源 Roadmap 阶段 | 架构模块 | 产出 | 依赖 |
| --- | --- | --- | --- | --- | --- |
| 1 | 引导基线 | 引导定义与构建骨架 | 根文档 / 契约 / SwiftPM 骨架 | 基线提交作为项目定义和骨架记录 | 无 |
| 2 | 核心模型与事件日志 | 核心领域模型与事件日志契约 | `MTPROCore` | 领域模型、事件信封、命令、查询和只追加事件日志契约明确 | 引导基线 |
| 3 | Binance 只读行情 | Binance 只读行情适配器 | `MTPROAdapters` | Binance 公开只读行情适配器和测试夹具契约完成 | 核心模型与事件日志 |
| 4 | 内核与缓存 | 交易内核、数据引擎与缓存 | `MTPROCore` | actor 内核、消息总线、缓存、数据引擎边界完成 | Binance 只读行情 |
| 5 | EMA 回测与 Paper 一致性 | EMA 交叉回测与 Paper 一致性 | `MTPROCore` / `MTPROApp` | EMA 交叉回测与 Paper 一致性验证链路完成 | 内核与缓存 |
| 6 | 订单簿策略 | 订单簿失衡策略 | `MTPROCore` / `MTPROAdapters` | 订单簿失衡研究策略链路完成 | EMA 回测与 Paper 一致性 |
| 7 | SQLite / DuckDB 投影 | SQLite / DuckDB 投影与重放 | `MTPROPersistence` | 事件日志重放、SQLite 运行投影、DuckDB 分析投影完成 | 订单簿策略 |
| 8 | 工作台看板 | Trader Workstation 看板 | `MTPROApp` | Market / Strategy / Backtest / Paper / Risk / Portfolio / Events 的 ViewModel 和最小产品面完成 | SQLite / DuckDB 投影 |
| 9 | 验证与自动化就绪 | 验证加固与自动化就绪 | 验证 / 自动化边界 | 验证矩阵、自动化就绪、证据链和发布就绪完成 | 工作台看板 |

## Linear 事项计划

引导基线里程碑已由本地基线提交记录。Linear Setup 时建议将引导基线作为里程碑证据记录，不创建可执行事项；如果 Linear 必须有对应事项，可创建只记录用的已完成事项，并保持不可执行。

| 顺序 | Linear 事项标题 | 里程碑 | 架构模块 | 初始状态 | 是否可由 Codex 执行 | 依赖 | 必须验证 | 必须证据 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0 | 记录引导基线 | 引导基线 | 根文档 / 契约 / SwiftPM 骨架 | `Done` 或仅记录、不可执行 | 否 | 无 | 已有 `swift test`；已有 `git diff --check` | 基线提交 `a141648`；`verification.md` |
| 1 | 核心领域模型与事件日志契约 | 核心模型与事件日志 | `MTPROCore` | Linear Setup 后唯一 `Todo` | 写入 Linear 后是 | 引导基线 | `swift test`；核心单元测试；只追加契约测试 | PR 证据；验证日志；Graphify 上下文状态 |
| 2 | Binance 公开只读行情适配器契约 | Binance 只读行情 | `MTPROAdapters` | `Backlog` 或 `Planned` | 前序事项 Done 后是 | 核心领域模型与事件日志契约 | `swift test`；适配器契约测试；测试夹具测试；无签名端点测试 | PR 证据；Binance 边界确认；Graphify 上下文状态 |
| 3 | 交易内核、数据引擎与缓存边界 | 内核与缓存 | `MTPROCore` | `Backlog` 或 `Planned` | 前序事项 Done 后是 | Binance 公开只读行情适配器契约 | `swift test`；actor / 消息总线 / 缓存测试；确定性重放检查 | PR 证据；并发边界证据；Graphify 上下文状态 |
| 4 | EMA 回测与 Paper 一致性契约 | EMA 回测与 Paper 一致性 | `MTPROCore` / `MTPROApp` | `Backlog` 或 `Planned` | 前序事项 Done 后是 | 交易内核、数据引擎与缓存边界 | `swift test`；回测测试夹具测试；Paper / 回测一致性测试 | PR 证据；一致性证据；Graphify 上下文状态 |
| 5 | 订单簿失衡策略研究链路 | 订单簿策略 | `MTPROCore` / `MTPROAdapters` | `Backlog` 或 `Planned` | 前序事项 Done 后是 | EMA 回测与 Paper 一致性契约 | `swift test`；订单簿测试夹具测试；策略信号测试 | PR 证据；策略边界证据；Graphify 上下文状态 |
| 6 | SQLite / DuckDB 投影与重放边界 | SQLite / DuckDB 投影 | `MTPROPersistence` | `Backlog` 或 `Planned` | 前序事项 Done 后是 | 订单簿失衡策略研究链路 | `swift test`；临时数据库测试；重放重建测试 | PR 证据；投影证据；Graphify 上下文状态 |
| 7 | Trader Workstation 看板 ViewModel 契约 | 工作台看板 | `MTPROApp` | `Backlog` 或 `Planned` | 前序事项 Done 后是 | SQLite / DuckDB 投影与重放边界 | `swift test`；ViewModel 测试；快照或状态契约测试 | PR 证据；UI 边界证据；Graphify 上下文状态 |
| 8 | 验证加固与自动化就绪 | 验证与自动化就绪 | 验证 / 自动化边界 | `Backlog` 或 `Planned` | 前序事项 Done 后是 | Trader Workstation 看板 ViewModel 契约 | `swift test`；验证矩阵；PR 证据检查；自动化就绪清单 | PR 证据；就绪证据；Graphify 上下文状态 |

## Linear 事项草案

### 0. 记录引导基线

来源：

- Roadmap 阶段：Bootstrap Definition and Build Skeleton
- 架构模块：根文档 / 契约 / SwiftPM 骨架

Linear 放置：

- 里程碑：引导基线
- 初始状态：`Done` 或仅记录、不可执行
- 可执行状态：不适用
- 标签：`type:bootstrap`、`area:docs`
- 优先级：未指定

范围：

- 记录已完成的项目定义和 SwiftPM 骨架基线。

非目标：

- 不执行新的代码修改。
- 不实现 Binance 适配器。
- 不实现回测引擎。
- 不实现 Paper 执行。
- 不实现 UI。
- 不实现数据库适配器。

证据：

- 基线提交：`a141648 Bootstrap MTPRO skeleton`
- 验证：`swift test` 通过；`git diff --check` 通过

### 1. 核心领域模型与事件日志契约

来源：

- Roadmap 阶段：Core Domain Model and Event Log Contract
- 架构模块：`MTPROCore`

Linear 放置：

- 里程碑：核心模型与事件日志
- 初始状态：`Todo`
- 可执行状态：`Todo`
- 标签：`area:core`、`type:contract`
- 优先级：高

执行边界：

- Linear Setup 后，本事项应是唯一可执行事项。

范围：

- 定义核心 symbol、timeframe、market event、domain event、command、query、event envelope。
- 定义只追加事件日志契约和重放契约。
- 为后续回测与 Paper 一致性保留统一事件语义。
- 增加核心单元测试，覆盖正常路径、边界值和拒绝 Live action 的约束。

非目标：

- 不接 Binance 网络。
- 不实现真实持久化适配器。
- 不实现内核运行时。
- 不实现 strategy。
- 不实现 UI。
- 不实现 LiveExecutionAdapter。

Codex 指令：

- 优先修改 `MTPROCore` 和 `MTPROCoreTests`。
- 保持契约优先，只定义领域模型、事件和本地可测试契约。
- 不得引入数据库、网络、UI 或签名端点依赖。

验证：

- `swift test`
- 核心领域模型测试
- 事件信封测试
- 只追加事件日志契约测试

证据要求：

- PR 正文包含来源目标、Roadmap 阶段、架构模块。
- PR 正文包含边界确认。
- PR 正文包含验证输出摘要。
- Graphify 上下文状态标记为只读或不可用。

### 2. Binance 公开只读行情适配器契约

来源：

- Roadmap 阶段：Binance Read-only Market Data Adapter
- 架构模块：`MTPROAdapters`

Linear 放置：

- 里程碑：Binance 只读行情
- 初始状态：`Backlog` 或 `Planned`
- 可执行状态：`Todo`
- 标签：`area:adapters`、`type:market-data`
- 优先级：高

范围：

- 实现 Binance 公开行情只读适配器边界。
- 支持 `exchangeInfo`、`klines`、近期成交、最优买卖价、有限深度快照、深度增量的契约。
- 限制标的为 `BTCUSDT`、`ETHUSDT`、`BNBUSDT`、`SOLUSDT`、`XRPUSDT`。
- 限制 timeframe 为 `1m`、`5m`。
- 使用测试夹具和契约测试固化公开只读语义。

非目标：

- 不使用 API key。
- 不调用签名端点。
- 不调用账户端点。
- 不提交、取消、替换订单。
- 不使用 listenKey user data stream。
- 不实现 strategy。

验证：

- `swift test`
- 适配器契约测试
- 测试夹具解码测试
- 禁止能力测试

证据要求：

- PR 证据明确 Binance 只读边界。
- 验证记录必须说明未调用签名端点。
- 必须声明 Graphify 上下文状态。

### 3. 交易内核、数据引擎与缓存边界

来源：

- Roadmap 阶段：TradingKernel / DataEngine / Cache
- 架构模块：`MTPROCore`

Linear 放置：

- 里程碑：内核与缓存
- 初始状态：`Backlog` 或 `Planned`
- 可执行状态：`Todo`
- 标签：`area:core`、`type:runtime-boundary`
- 优先级：高

范围：

- 建立 actor 内核边界。
- 建立 MessageBus、DataEngine、Cache 的最小可测试契约。
- 将只读行情事件转入缓存和事件流。
- 保持确定性重放能力。

非目标：

- 不实现 Live 执行。
- 不提交订单。
- 不实现数据库适配器。
- 不实现 SwiftUI 页面。

验证：

- `swift test`
- actor 隔离测试
- MessageBus 契约测试
- Cache determinism 测试

证据要求：

- PR 证据说明并发边界。
- 验证记录包含确定性重放相关测试。
- 必须声明 Graphify 上下文状态。

### 4. EMA 回测与 Paper 一致性契约

来源：

- Roadmap 阶段：EMA Cross Backtest and Paper Parity
- 架构模块：`MTPROCore` / `MTPROApp`

Linear 放置：

- 里程碑：EMA 回测与 Paper 一致性
- 初始状态：`Backlog` 或 `Planned`
- 可执行状态：`Todo`
- 标签：`area:strategy`、`type:parity`
- 优先级：高

范围：

- 实现 EMA 交叉策略契约。
- 实现回测事件流。
- 实现 Paper 会话事件流。
- 建立回测与 Paper 一致性验证。

非目标：

- 不实现 Live trading。
- 不连接 broker。
- 不提交真实订单。
- 不实现订单簿失衡策略。
- 不实现完整 Dashboard 页面。

验证：

- `swift test`
- EMA 信号测试夹具测试
- 回测结果测试
- Paper / 回测一致性测试

证据要求：

- PR 证据包含一致性解释。
- 验证记录必须包含测试夹具和一致性结果。
- 必须声明 Graphify 上下文状态。

### 5. 订单簿失衡策略研究链路

来源：

- Roadmap 阶段：Order Book Imbalance Strategy
- 架构模块：`MTPROCore` / `MTPROAdapters`

Linear 放置：

- 里程碑：订单簿策略
- 初始状态：`Backlog` 或 `Planned`
- 可执行状态：`Todo`
- 标签：`area:strategy`、`type:market-microstructure`
- 优先级：中

范围：

- 定义订单簿快照、增量和读模型输入。
- 实现失衡信号契约。
- 将订单簿失衡接入研究链路。
- 通过测试夹具验证边界和信号稳定性。

非目标：

- 不接签名端点。
- 不做 futures leverage / margin action。
- 不提交真实订单。
- 不扩展到未确认 symbol universe。

验证：

- `swift test`
- 订单簿测试夹具测试
- 失衡信号测试
- 边界拒绝测试

证据要求：

- PR 证据说明订单簿数据来源仍为公开只读。
- 验证记录包含信号测试夹具结果。
- 必须声明 Graphify 上下文状态。

### 6. SQLite / DuckDB 投影与重放边界

来源：

- Roadmap 阶段：SQLite / DuckDB 投影与重放
- 架构模块：`MTPROPersistence`

Linear 放置：

- 里程碑：SQLite / DuckDB 投影
- 初始状态：`Backlog` 或 `Planned`
- 可执行状态：`Todo`
- 标签：`area:persistence`、`type:projection`
- 优先级：中

范围：

- 实现事件日志重放边界。
- 建立 SQLite 运行投影。
- 建立 DuckDB 分析投影。
- 确认数据库不直接作为 UI 展示模型。

非目标：

- 不让 UI 直接读取数据库表。
- 不把运行时对象直接持久化为 UI 契约。
- 不做破坏性数据库迁移。
- 不实现 Live 执行持久化。

验证：

- `swift test`
- 临时 SQLite 测试
- 临时 DuckDB 测试
- 重放重建测试
- 投影隔离测试

证据要求：

- PR 证据说明事实源和投影分离。
- 验证记录包含临时数据库路径和 rebuild 结果。
- 必须声明 Graphify 上下文状态。

### 7. Trader Workstation 看板 ViewModel 契约

来源：

- Roadmap 阶段：Trader Workstation Dashboard
- 架构模块：`MTPROApp`

Linear 放置：

- 里程碑：工作台看板
- 初始状态：`Backlog` 或 `Planned`
- 可执行状态：`Todo`
- 标签：`area:app`、`type:view-model`
- 优先级：中

范围：

- 实现 Market / Strategy / Backtest / Paper / Risk / Portfolio / Events 的 ViewModel 契约。
- 确认 ViewModel 只来自稳定读模型投影。
- 建立最小 SwiftUI 产品面前的 ViewModel 测试。

非目标：

- 不直接消费数据库表。
- 不直接消费 ORM model。
- 不直接消费运行时对象。
- 不直接调用 Binance 适配器。
- 不提供 live order button。

验证：

- `swift test`
- ViewModel 契约测试
- 读模型映射测试
- 快照或状态契约测试

证据要求：

- PR 证据说明前端边界。
- 验证记录包含 ViewModel 输入来源。
- 必须声明 Graphify 上下文状态。

### 8. 验证加固与自动化就绪

来源：

- Roadmap 阶段：验证加固与自动化就绪
- 架构模块：验证 / 自动化边界

Linear 放置：

- 里程碑：验证与自动化就绪
- 初始状态：`Backlog` 或 `Planned`
- 可执行状态：`Todo`
- 标签：`area:validation`、`type:readiness`
- 优先级：中

范围：

- 完成验证矩阵。
- 检查 GitHub + Linear 关联。
- 检查 PR 模板。
- 检查 WIP=1。
- 检查 GitHub PR Automation evidence。
- 检查 Graphify 只读边界。

非目标：

- 不启动 Symphony，除非已明确授权。
- 不运行 Graphify update。
- 不修改 Linear 状态。
- 不创建 Roadmap 外事项。
- 不绕过 GitHub PR Automation。

验证：

- `swift test`
- 完整本地验证矩阵
- PR 证据检查
- 自动化就绪清单

证据要求：

- PR 证据包含就绪清单。
- 验证记录包含所有命令和结果。
- 必须声明 Graphify 上下文状态。

## 人工审查开放问题

1. Linear 团队名称、团队标识、团队 ID 已确认：NautilusTrade Pro / MTP；Linear 返回显示名称为 Macostrader Pro。
2. 状态映射已确认：`Todo` / `In Progress` / `In Review` / `Done` / `Canceled`；非执行队列使用 `Backlog`。
3. 引导基线已创建为只记录用的 `Done` 事项：`MTP-7`。
4. 基线提交 `a141648` 是否需要先创建 Bootstrap PR，再进入 Linear Setup？
5. P1 / P2 review debt 是否在 Linear Setup 前处理，还是作为核心模型与事件日志事项之前的单独文档清理事项？
6. GitHub + Linear integration 是否已经配置，还是纳入自动化就绪前置检查？

## 人工确认

- Linear 写入授权：是，团队信息已补齐；进入 Linear Setup 前仍需确认是否立即写入 Linear
- 确认人：用户
- 确认日期：2026-05-14
- 确认说明：确认本草案可以进入 Linear Setup 准备阶段；本确认不授权开发执行。

## Linear Setup 结果

- Linear Project：`MTPRO 引导`
- Project ID：`3a8e07ff-0c15-47cf-b9d2-9a077dfa037e`
- Project URL：`https://linear.app/atxinbao/project/mtpro-引导-f3792087e333`
- Linear 团队标识：`MTP`
- Linear 返回团队显示名称：Macostrader Pro

里程碑：

| 顺序 | 里程碑 | Linear ID |
| --- | --- | --- |
| 1 | 引导基线 | `a862236d-5e00-41fe-933d-cdebd3932397` |
| 2 | 核心模型与事件日志 | `a7df8df7-d7f2-4889-aa8f-6fe5a66788aa` |
| 3 | Binance 只读行情 | `35fd20c6-4897-4bac-891e-200d594fccf2` |
| 4 | 内核与缓存 | `490398ea-7e8d-444b-98e2-be6ff8c9a3a6` |
| 5 | EMA 回测与 Paper 一致性 | `3347618b-c2a3-4d51-8719-b887c6c8c876` |
| 6 | 订单簿策略 | `87d51e69-0545-473d-bfb8-89f9e4bfeddd` |
| 7 | SQLite / DuckDB 投影 | `b6810298-97ff-4f52-b406-9383f19ca5d8` |
| 8 | 工作台看板 | `0ccca5fe-f798-46e7-aabd-553220603a67` |
| 9 | 验证与自动化就绪 | `3d6fe3d6-6e76-48cb-bc40-5c045090e96c` |

事项：

| Linear 事项 | 标题 | 状态 | URL |
| --- | --- | --- | --- |
| `MTP-7` | 记录引导基线 | `Done` | `https://linear.app/atxinbao/issue/MTP-7/记录引导基线` |
| `MTP-8` | 核心领域模型与事件日志契约 | `Todo` | `https://linear.app/atxinbao/issue/MTP-8/核心领域模型与事件日志契约` |
| `MTP-9` | Binance 公开只读行情适配器契约 | `Backlog` | `https://linear.app/atxinbao/issue/MTP-9/binance-公开只读行情适配器契约` |
| `MTP-10` | 交易内核、数据引擎与缓存边界 | `Backlog` | `https://linear.app/atxinbao/issue/MTP-10/交易内核数据引擎与缓存边界` |
| `MTP-11` | EMA 回测与 Paper 一致性契约 | `Backlog` | `https://linear.app/atxinbao/issue/MTP-11/ema-回测与-paper-一致性契约` |
| `MTP-12` | 订单簿失衡策略研究链路 | `Backlog` | `https://linear.app/atxinbao/issue/MTP-12/订单簿失衡策略研究链路` |
| `MTP-13` | SQLite / DuckDB 投影与重放边界 | `Backlog` | `https://linear.app/atxinbao/issue/MTP-13/sqlite-duckdb-投影与重放边界` |
| `MTP-14` | Trader Workstation 看板 ViewModel 契约 | `Backlog` | `https://linear.app/atxinbao/issue/MTP-14/trader-workstation-看板-viewmodel-契约` |
| `MTP-15` | 验证加固与自动化就绪 | `Backlog` | `https://linear.app/atxinbao/issue/MTP-15/验证加固与自动化就绪` |

队列确认：

- 唯一 `Todo`：`MTP-8`
- 基线记录：`MTP-7`，状态 `Done`
- 后续开发事项：`MTP-9` 到 `MTP-15`，状态 `Backlog`
- 开发执行仍未允许；下一步必须配置 GitHub remote、创建 Bootstrap PR，并验证 GitHub + Linear 关联。

## 草案边界确认

- 已调用 Linear API 完成 Linear Setup。
- 已创建 Linear 项目。
- 已创建 Linear 里程碑。
- 已创建 Linear 事项。
- 仅设置新建事项初始状态；未修改既有 Linear 状态。
- 未启动 Symphony。
- 未运行 Graphify update。
- 未运行 Graphify 范围更新。
- 未运行 Graphify 全量重建。
- 未提交 `graphify-out`。
- 未进入 Binance、策略、UI 或数据库适配器实现。
