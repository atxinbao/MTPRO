# Audit Evidence Index

日期：2026-07-20

执行者：Codex

状态：Canonical index

## 作用

`docs/audit/` 保存阶段验收、修复关闭和项目收口证据。目录内报告默认属于 `Historical evidence`，不能单独授权当前能力。

## 当前基线

1. `mtpro-release-v0.33.0-demo-validation-stage-code-audit.md`
   - Binance Spot + USD-M Futures Demo Network evidence 验收。
2. `mtpro-v0.33.0-backend-maintenance-stage-code-audit.md`
   - v0.33.0 发布后 ownership / compatibility / validation 维护收口。

## 查找规则

- Release 审计：`mtpro-release-v<version>-*-stage-code-audit.md`
- Project 审计：`mtpro-<project>-stage-code-audit.md`
- Patch 审计：文件名包含 patch / repair / hardening。

目录当前保留全部历史报告，不按数量删除。需要某个版本的当前语义时，应同时读取对应 `docs/release/` 说明和当前 Canonical 文档。

## 状态解释

- 报告里的 completed / accepted 只适用于其明确范围。
- 旧报告里的 future / blocked / pending 可能已被后续版本替代。
- 后续事实以更晚的 release、audit 和当前 `docs/validation/latest-verification-summary.md` 为准。

