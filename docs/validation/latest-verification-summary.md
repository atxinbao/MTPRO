# MTPRO Latest Verification Summary

日期：2026-07-20

执行者：Codex

状态：Canonical

## 作用

本文档是当前验证状态的轻量入口，只记录冻结基线、最近验证、核心边界和证据导航。

逐 issue 验证流水已归档到：

- `docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md`
- `docs/history/validation-pre-canonicalization-2026-07-20/verification.md`

历史文件属于 `Historical evidence`，用于审计、追溯和 debug，不定义当前产品目标。

## 当前冻结基线

| 项目 | 当前事实 |
| --- | --- |
| Active venue | `Binance` |
| Active products | `spot`、`usdsPerpetual` |
| Stable release | `v0.33.0` |
| Release tag commit | `19d5d6bcc24ae6cc243396cea57d1c01499b23fe` |
| Release URL | `https://github.com/atxinbao/MTPRO/releases/tag/v0.33.0` |
| Release published at | `2026-07-19T11:53:40Z` |
| Backend decision | `accepted-demo-network-parity` |
| Production cutover | `false` |
| Default production trading | `false` |

权威状态：

```text
activeVenue=Binance
activeProducts=spot,usdsPerpetual
backendClosureDecision=accepted-demo-network-parity
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

## 当前验收结论

v0.33.0 已完成 Binance Demo Network 双产品后端证据验收：

- Spot submit / status / cancel。
- USD-M Futures submit / status / cancel。
- RiskEngine、ExecutionEngine、OMS、reconciliation、rollback 和 incident 证据关联。
- 证据 root、provenance、checksum、redaction 和 realpath containment 校验。
- 缺失、损坏或不一致证据 fail closed。
- CLI 对无效证据返回非零退出码。
- Dashboard 只读消费已验证状态。

这不是 production cutover 授权。Demo Network parity 不能自动升级为生产 endpoint、生产 secret 或真实资金交易授权。

## 后端维护收口

`GH-1579-V0330-BACKEND-MAINTENANCE-CLOSEOUT` 记录 #1574-#1579 维护线已经关闭。

维护收口事实：

```text
patchReleaseDecision=not-warranted
v0.33.1TagCreated=false
v0.33.0TagMoved=false
backendClosureDecision=accepted-demo-network-parity
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

维护线完成：

- 收紧 ExecutionClient ownership。
- 统一 Demo evidence validation owner。
- 清理 Core 对 ExecutionClient 的不必要 re-export。
- 保留明确的 Adapters / Persistence / Runtime compatibility envelope。
- macOS / Linux 全矩阵验证通过。

## 模块验证矩阵

| 模块 | 当前验证状态 |
| --- | --- |
| DomainModel | typed identity、order、product 与 evidence contracts 已进入真实 target |
| MessageBus | command / event / query / replay contracts 已进入真实 target |
| DataClient | Binance Spot / USD-M Futures adapter ownership 已明确 |
| DataEngine | ingest、replay、data quality ownership 已明确 |
| Trader | `Accounts + Strategies + Coordination` 容器边界成立 |
| Strategies | 当前策略能力以 release contracts 和真实 target 为准 |
| Portfolio | paper / Demo projection 与 replay evidence 可验证 |
| RiskEngine | pre-trade、kill switch、no-trade 和额度 gate 可验证 |
| ExecutionEngine | lifecycle 与 OMS coordination 可验证 |
| ExecutionClient | Binance Demo transport 与证据边界可验证 |
| Database | append-only event、projection、SQLite / DuckDB ownership 已明确 |
| Dashboard | read-only 状态消费，不绕过后端 gate |
| CLI | 本地运行、验证和 operator evidence 命令可验证 |

## 生产边界

以下能力不是永久禁止，但当前仍需独立 production cutover gate：

- 生产 secret 读取。
- 生产 endpoint 连接。
- 生产 submit / status / cancel / replace。
- 真实资金账户和仓位同步。
- 生产额度放权。
- Dashboard 生产交易控制。

任何放权必须同时具备：

1. Human / operator 明确批准。
2. credential scope 和 redaction 审计。
3. endpoint / product / symbol allowlist。
4. capital、notional、exposure 和频率限制。
5. RiskEngine、kill switch、no-trade、OMS 和 reconciliation。
6. rollback、incident 和 immutable evidence。

## 最近完整验证

最近文档治理前的后端维护全量验证：

```text
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
861 tests / 0 failures
MTPRO checks passed.
```

文档 canonicalization 继续使用同一验证门槛，不修改业务能力或 production authorization。

## 当前验证入口

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

按版本验证时，使用 `checks/verify-v<version>.sh` 或对应 focused verifier。当前脚本索引以 `checks/run.sh` 为准。

## 当前证据入口

### Release

- `docs/release/mtpro-release-v0.33.0-demo-validation-notes.md`
- `docs/release/index.md`

### Audit

- `docs/audit/mtpro-release-v0.33.0-demo-validation-stage-code-audit.md`
- `docs/audit/mtpro-v0.33.0-backend-maintenance-stage-code-audit.md`
- `docs/audit/index.md`

### Contracts

- `docs/contracts/release-v0.33.0-observed-canary-backend-closure-contract.md`
- `docs/contracts/v0330-backend-maintenance-ownership-contract.md`
- `docs/contracts/index.md`

### Historical validation

- `docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md`
- `docs/history/validation-pre-canonicalization-2026-07-20/verification.md`

## 阅读规则

- 当前事实从 `README.md`、`GOAL.md`、`architecture.md` 和本文档读取。
- 发布边界从对应 release notes 读取。
- 阶段验收从 Stage Code Audit 读取。
- 逐 issue anchor 从历史验证快照读取。
- 历史文字不得覆盖当前 Canonical 事实。

## 边界

本文档是验证摘要，不授权：

- 修改或移动既有 release tag。
- 创建 patch release。
- production cutover。
- 自动读取生产 secret。
- 自动连接生产 endpoint。
- 自动发送生产订单。
- 从历史 planning record 启动执行。
