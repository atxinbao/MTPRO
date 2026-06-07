# L4 Guarded Command UI Surface Contract

日期：2026-06-07
执行者：Codex

## Scope

`GH-469-GUARDED-SUBMIT-CANCEL-REPLACE-UI-SURFACE` 固定 `MTPRO L4 Live Production / Trading Commands v1`
第 18/21 个 GitHub fallback queue item 的 guarded submit / cancel / replace UI surface。

本合同只实现 deterministic Live PRO Console ViewModel / evidence：submit / cancel / replace controls 默认 disabled，
仅在 sandbox gate 下可用，并且每个 control 都必须展示 confirmation、blocked reason、incident stop 和 audit evidence。
Dashboard 继续 read-model-only。

## GH-469 Sandbox-gate-only Commands

`GH-469-SANDBOX-GATE-ONLY-COMMANDS` 固定 command controls 的唯一可用路径是 sandbox gate：

- RiskEngine evidence anchor：`GH-464-LIVE-RISK-PRETRADE-GATE`
- OMS evidence anchor：`GH-461-GH-462-OMS-LIFECYCLE-LOCAL-TRANSITION`
- ExecutionEngine sandbox evidence anchor：`GH-463-EXECUTIONENGINE-SANDBOX-PATH`
- Audit evidence anchor：`GH-467-AUDIT-TRAIL-INCIDENT-REPLAY`
- Split evidence anchor：`GH-468-DASHBOARD-LIVEPRO-READONLY-COMMAND-SPLIT`

这些 anchor 只作为 ViewModel evidence 被消费，不代表 Dashboard 直接依赖 RiskEngine / OMS / ExecutionEngine target。

## GH-469 Confirmation / Blocked / Incident Evidence

`GH-469-CONFIRMATION-BLOCKED-INCIDENT-EVIDENCE` 固定每个 guarded control 必须包含：

- confirmation prompt
- confirmation evidence ID
- blocked reason
- incident stop reason
- audit evidence ID

缺失任一项都必须被合同测试拒绝。

## GH-469 No Production Command Default

`GH-469-NO-PRODUCTION-COMMAND-DEFAULT` 固定 production gate 未满足时 UI 不可执行命令。GH-469 不读取 API key，
不存储 secret，不调用 signed endpoint，不接 broker，不提交 / 撤销 / 替换真实订单。

## Validation

`TVM-L4-GUARDED-COMMAND-UI-SURFACE` 对应验证：

- `testGH469GuardedCommandUISurfaceAllowsSandboxOnlySubmitCancelReplace`
- `testGH469GuardedCommandUISurfaceRejectsProductionBypassAndMissingEvidence`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Non-authorization

`GH-469-NON-AUTHORIZATION`：本合同不授权 GH-470 sandbox validation matrix closure，不授权 GH-471 production
cutover，不授权真实 broker gateway、production command、real order lifecycle、真实 submit / cancel / replace、
交易按钮或 order form。合并本 issue 后，MTPRO 仍没有默认 production trading 能力。
