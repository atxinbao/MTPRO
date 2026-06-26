# MTPRO GitHub Review Fast Path v1

日期：2026-06-26

执行者：Codex

## 定位

本文档定义 MTPRO GitHub PR review 的 fast path / 快速审查路径。它只优化 reviewer 读取顺序、证据打包和审查分级，不改变 MTPRO 的执行授权边界。

本文档不是 Linear Project Draft，不创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不替代 Parent Codex queue preflight，不替代 GitHub required checks，不替代 Stage Code Audit，不授权 production cutover、production trading、broker action 或真实订单。

## 为什么需要

MTPRO 过去的每个 issue PR 都倾向于携带完整执行合同、边界确认、validation evidence、PR evidence、merge handoff 和 release / audit wording。这个方式安全，但对低风险 PR 会造成重复审查成本。

本 fast path 的目标是把 GitHub review 从“每个 PR 都做完整阶段审查”改为“先分级，再按风险读取证据”：

```text
PR diff
-> review tier classification
-> review packet
-> focused reviewer checklist
-> required checks / auto-merge handoff
```

## 不变的硬边界

Fast path 不改变以下规则：

- WIP=1、唯一 configured executable issue、依赖满足和执行合同完整仍由 Parent Codex queue preflight 守护。
- `bash checks/run.sh` 仍是最终本地验证入口。
- GitHub required check `checks` 仍必须通过。
- GitHub auto-merge、squash merge、branch cleanup 和 Linear bot Done 仍属于 GitHub PR Automation / Parent Codex evidence chain。
- Stage Code Audit 仍是 Project 级 closure 产物，不下沉为每个小 PR 的完整重审。
- `.codex/*`、`graphify-out/*`、secret、本地 evidence bundle 原文和未脱敏 broker payload 不进入 PR。
- production cutover、production secret、production endpoint、broker endpoint、real submit / cancel / replace、LiveExecutionAdapter、production OMS、trading button、order form 和 live command 仍默认关闭或 gated。

## Review Tier / 审查分级

| Tier | 名称 | 适用范围 | 默认 review 方式 | 不适用条件 |
| --- | --- | --- | --- | --- |
| A | Fast docs / evidence path | docs-only、PR template、operator wording、release wording、checks 里的只读 review packet 或 anchor-only 变更 | reviewer 只看 review packet、diff、禁区词、validation 摘要和 required checks | 触碰 production code、credential、runtime、transport、OMS、RiskEngine、ExecutionClient 或 workflow dispatch |
| B | Focused implementation path | 普通 production code、测试、非敏感 CLI / Dashboard read-model 变更 | reviewer 看改动模块、focused test、`bash checks/run.sh`、边界证明和 issue scope | 触碰 signed endpoint、account endpoint、listenKey、broker、OMS、RiskEngine gate、real order lifecycle、production cutover |
| C | Full sensitive path | testnet / live / credential / signed request / OMS / RiskEngine / production cutover / manual workflow / release publication 相关变更 | 保留完整深审：issue contract、diff、tests、runbook、redaction、fail-closed、manual evidence、Stage Audit input | 无 |

Tier 只决定 reviewer 的阅读深度，不决定 merge 权限。任何 tier 都不能绕过 required checks、branch protection、WIP=1 或禁区边界。

## Review Packet

每个 PR 可以先生成 review packet：

```bash
bash checks/review-packet.sh
```

脚本只读本地 Git 状态，不修改文件，不访问网络，不读取 secret，不调用 Binance，不修改 Linear，不启动 Graphify / Symphony。

Review packet 应包含：

- base ref、merge base、当前分支和 worktree 状态。
- changed files。
- 初步 review tier 建议。
- `.codex/*` / `graphify-out/*` 是否进入 diff。
- changed files 内的 sensitive boundary keyword hits。
- 建议 reviewer checklist。
- 建议 validation commands。

Review packet 是审查入口，不是审查结论。脚本输出中出现 sensitive keyword 不一定表示违规；如果文档是在定义 forbidden capability，reviewer 应确认 wording 是否保持 `gated / blocked / not authorized`。

## Reviewer 快速读取顺序

### Tier A

1. 读取 review packet 的 tier、changed files 和 boundary keyword hits。
2. 检查 diff 是否只触碰 docs / PR template / review tooling。
3. 检查文档是否明确“不替代 WIP=1 / checks / Stage Audit / production gates”。
4. 确认 `git diff --check` 和 `bash checks/review-packet.sh` 通过。
5. 确认 required check `checks` 通过或已排队。

Tier A 不需要重新审完整 root docs、完整 validation matrix 或历史 release audit，除非 diff 修改这些文件本身或 review packet 报告 C 类敏感路径。

### Tier B

1. 按 issue scope 读取目标模块和相关 tests。
2. 确认 fastest feedback loop：focused fixture / module test / Dashboard smoke。
3. 确认 `bash checks/run.sh` 结果。
4. 对照 review packet 检查敏感词是否为当前 scope 内合理证据。
5. 确认没有把 paper / read-model / testnet evidence 升级成 production capability。

### Tier C

Tier C 保留完整审查：

1. 读取 issue execution contract。
2. 读取相关 root docs、contracts、validation plan、trading validation matrix 和 runbook。
3. 检查 credential / redaction / endpoint allowlist / fail-closed / checksum / audit trail。
4. 检查 manual evidence 或 workflow dispatch 是否保持显式 operator confirmation。
5. 运行 focused verifier、`bash checks/run.sh`，并等待 GitHub required checks。
6. 必要时将 residual risk 写入 Stage Code Audit input 或 Project closeout。

## PR Template 要求

PR 模板应记录：

- Review tier：A / B / C。
- `checks/review-packet.sh` 是否已运行。
- Fast path 是否适用。
- 如果选择 Tier A，为什么没有触碰 production behavior。
- 如果选择 Tier B，focused feedback loop 是什么。
- 如果选择 Tier C，哪些敏感 boundary 触发完整审查。

这些字段只压缩 reviewer 读取成本，不减少必须验证的事实。

## Parent Codex 使用规则

Parent Codex 可以在 queue supervision 中使用 review packet 辅助判断 PR review 成本，但不能把它当作执行授权。

允许：

- 在 ready-for-review 前生成 review packet 摘要。
- 在 PR body 中引用 review packet 的 tier 和 changed files。
- 对 Tier A PR 建议 fast docs / evidence review。
- 对 Tier C PR 明确要求 full sensitive review。

禁止：

- 用 review packet 替代 Linear live-read。
- 用 review packet 推进 `Backlog -> Todo`。
- 用 review packet 替代 `bash checks/run.sh` 或 GitHub required checks。
- 用 Tier A / B 绕过 production cutover、credential、broker、OMS 或 real order 边界。
- 用 fast path 直接 merge PR。

## Stage Code Audit 关系

Fast path 的核心优化是把重复 review 下沉为 PR packet，把完整阶段审查保留在 Project closure：

```text
issue PR review: classify + focused evidence
Project closure: Stage Code Audit Report
Root Docs Refresh Gate: only completed facts
```

Stage Code Audit 仍必须覆盖完整 Project，包括 Project scope / issue range、Linear 或 GitHub fallback evidence、PR evidence、Validation、Boundary Audit、Known CI Boundary、Root Docs Delta、Residual Notes For Human Planning 和 Next Human Project Planning Handoff。

## 验收标准

- Reviewer 可以在 1 分钟内知道 PR 是 Tier A / B / C。
- Tier A PR 不需要重复完整 Stage Audit 级审查。
- Tier B PR 聚焦 module diff、focused tests 和 boundary evidence。
- Tier C PR 保持完整敏感审查。
- 所有 PR 仍保留 WIP=1、required checks、`checks/run.sh`、GitHub PR Automation 和 Parent Codex handoff。
- production cutover not authorized，production trading disabled by default，broker / production endpoint / real order / LiveExecutionAdapter 不因 fast path 获得授权。
