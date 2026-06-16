# MTPRO Release v0.8.1 Release Publication + Dashboard Guard Patch Notes

日期：2026-06-16

执行者：Codex

## Release Type

v0.8.1 是 v0.8.0 public release publication 后的 patch evidence closeout。它收口 GitHub fallback queue `GH-835..GH-841` 的 release publication docs alignment、Dashboard macOS focused guard、CLI verification wording、local session vs broker session wording、status artifact role、private stream redaction 和 patch audit / docs / release notes。

本文档是 v0.8.1 patch closeout 的 release notes evidence。它不创建 Git tag，不创建 GitHub Release，不移动已有 release，不授权 production cutover，不创建下一 Project / Issue。Do not create the release tag unless explicitly requested after merge.

## Scope

- GH-835：同步 v0.8.0 stable GitHub Release 已存在的文档事实，并保持 construction closeout、release publication 和 production cutover 三段 gate 分离。
- GH-836：让 required `dashboard-macos` job 在 Dashboard build / smoke 前运行 v0.8 focused Dashboard read-only / safe local controls guards。
- GH-837：把 `mtpro verify` active operator wording 对齐到 v0.8.0 / GH-820 final audit guard，并保留 v0.7 CLI checks 为 historical guard evidence。
- GH-838：把 CLI local operator session evidence 和 broker session evidence 拆成 `localSessionCreated=true` / `brokerSessionStarted=false`。
- GH-839：把 `status.json` 明确为 v0.8+ canonical operator status artifact，并把 `_RUN_STATUS.json` 明确为 compatibility run-status mirror。
- GH-840：强化 manual private stream monitoring proof redaction，`redactedStreamURL` 只允许 `<redacted-listen-key>` placeholder 和 `listenKeyReferenceHash`，不得泄露 raw listenKey 或 listenKey reference。
- GH-841：输出 patch Stage Code Audit Report、patch release notes 和 `checks/verify-v0.8.1.sh` aggregate verifier。

## Validation

本 patch closeout 的本地验证入口：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.8.1.sh
bash checks/run.sh
```

`checks/verify-v0.8.1.sh` 串联 v0.8.1 focused guards，并检查 patch audit、release notes、validation plan、trading validation matrix、automation readiness 和 latest verification summary 的 evidence anchors。

## Release Notes

v0.8.1 closes the release publication and Dashboard guard patch evidence chain:

- Binance-only active venue remains fixed。
- Active products remain Spot + USDⓈ-M Perpetual。
- Active strategies remain EMA + RSI。
- Runtime modes remain local-dry-run / testnet-read-only-monitor / recovery-observe / production-blocked。
- v0.8.0 stable GitHub Release documentation is aligned with the actual release URL and tag evidence。
- Dashboard macOS required checks now run v0.8 read-only monitor and safe local control guards before build / smoke。
- `mtpro verify` wording points to v0.8.0 / GH-820 final audit evidence。
- CLI run output separates local operator session creation from broker session state。
- Status artifact naming is explicit: `status.json` canonical, `_RUN_STATUS.json` compatibility mirror。
- Private stream proof redaction no longer embeds raw listenKey, listenKey reference or redacted listenKey reference in the stream URL。
- `checks/verify-v0.8.1.sh` provides a patch-level local verification entry point。

## Boundary Evidence

- production trading remains disabled by default。
- no production secret auto-read。
- no production endpoint auto-connect。
- no production broker connection。
- no production order authorization。
- no signed production account endpoint / listenKey / private WebSocket fallback。
- no testnet or production submit / cancel / replace。
- no testnet order routing。
- no production OMS。
- no broker fill / reconciliation runtime。
- no Dashboard production command。
- no Dashboard trading button / order form / live command。
- no Live PRO Console runtime authorization。
- no production cutover authorization。
- no non-Binance venue。
- no non-Spot / non-USDSM active product。
- no non-EMA / non-RSI active strategy。

## Non-Authorization

本 release notes 不创建下一 Project / Issue，不推进 Todo，不启动 Linear / Symphony / Graphify / code-index / Figma，不授权 production cutover，不读取 secret，不连接 production endpoint，不连接 broker endpoint，不发送真实 order，不创建 v0.8.1 tag，不创建 GitHub Release。

## Evidence Anchors

- `GH-835-V081-V080-ACTUAL-GITHUB-RELEASE`
- `GH-836-VERIFY-V081-DASHBOARD-MACOS-V080-GUARDS`
- `GH-837-VERIFY-V081-CLI-VERIFY-V080-WORDING`
- `GH-838-VERIFY-V081-LOCAL-VS-BROKER-SESSION`
- `GH-839-VERIFY-V081-STATUS-ARTIFACT-ROLE`
- `GH-840-VERIFY-V081-PRIVATE-STREAM-REDACTION`
- `GH-841-VERIFY-V081-PATCH-AUDIT-DOCS-RELEASE-NOTES`
