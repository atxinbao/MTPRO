# MTPRO Verification Registry

日期：2026-07-20

执行者：Codex

状态：Canonical

## 定位

本文档是当前验证注册表和历史导航，不再承载逐 issue 追加流水。

旧版 18,810 行验证流水保持原样归档在：

`docs/history/validation-pre-canonicalization-2026-07-20/verification.md`

旧版轻量摘要归档在：

`docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md`

历史快照属于 `Historical evidence`，仍由旧 checks / tests 读取，不是当前能力授权。

## 当前冻结事实

```text
activeVenue=Binance
activeProducts=spot,usdsPerpetual
backendClosureDecision=accepted-demo-network-parity
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

Stable release：

- Tag：`v0.33.0`
- Commit：`19d5d6bcc24ae6cc243396cea57d1c01499b23fe`
- URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.33.0`
- Published：`2026-07-19T11:53:40Z`

发布后的代码、维护和文档变更以当前 `main` 为准，不移动既有 tag。

## 最近关闭证据

`GH-1579-V0330-BACKEND-MAINTENANCE-CLOSEOUT`

```text
patchReleaseDecision=not-warranted
v0.33.1TagCreated=false
v0.33.0TagMoved=false
backendClosureDecision=accepted-demo-network-parity
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

后端维护线 #1574-#1579 已关闭。PR #1580-#1584 的 required checks 成功；完整本地矩阵通过 `861 tests / 0 failures`。

## 当前验证命令

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

成功标准：

```text
all required scripts exit 0
all XCTest suites report 0 failures
MTPRO checks passed.
```

## 当前证据注册

| 类型 | 入口 |
| --- | --- |
| Latest summary | `docs/validation/latest-verification-summary.md` |
| Current release | `docs/release/mtpro-release-v0.33.0-demo-validation-notes.md` |
| Release index | `docs/release/index.md` |
| Demo audit | `docs/audit/mtpro-release-v0.33.0-demo-validation-stage-code-audit.md` |
| Maintenance audit | `docs/audit/mtpro-v0.33.0-backend-maintenance-stage-code-audit.md` |
| Audit index | `docs/audit/index.md` |
| Closure contract | `docs/contracts/release-v0.33.0-observed-canary-backend-closure-contract.md` |
| Maintenance contract | `docs/contracts/v0330-backend-maintenance-ownership-contract.md` |
| Contract index | `docs/contracts/index.md` |
| Historical summary | `docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md` |
| Historical ledger | `docs/history/validation-pre-canonicalization-2026-07-20/verification.md` |

## 追加规则

后续验证记录按以下方式维护：

1. 当前冻结结论更新 `docs/validation/latest-verification-summary.md`。
2. 版本级证据进入 `docs/release/` 和 `docs/audit/`。
3. 合同进入 `docs/contracts/`。
4. 不再把逐 issue 全文追加到本文件。
5. 需要保留的大型流水按日期或阶段写入 `docs/history/validation-*`。

## 边界

- 本文件不替代 GitHub checks、PR evidence 或 Stage Code Audit。
- 历史通过不保证当前未验证改动通过。
- Demo Network 验收不授权 production cutover。
- 本文件不授权 secret 读取、production endpoint 连接或生产订单。
