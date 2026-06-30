# Release v0.20.0 Binance Spot Production-shadow Credential Reference Readiness Contract

日期：2026-06-30
执行者：Codex
Issue：#1242 / GH-1242
上游：#1241 / GH-1241
下游：#1243 / GH-1243

## 验证锚点

- GH-1242-VERIFY-V0200-CREDENTIAL-REFERENCE-READINESS
- TVM-RELEASE-V0200-CREDENTIAL-REFERENCE-READINESS
- V0200-004-BINANCE-SPOT-PRODUCTION-SHADOW-CREDENTIAL-READINESS
- V0200-004-CREDENTIAL-IDENTITY-ONLY
- V0200-004-MISSING-REFERENCE-FAILS-CLOSED
- V0200-004-REDACTED-AUDIT-EVIDENCE
- V0200-004-NO-SECRET-VALUE-READ
- V0200-004-NO-ENDPOINT-CONNECTION
- V0200-004-NO-PRODUCTION-CUTOVER

## 范围

GH-1242 只固定 Binance Spot `productionShadow` 的 credential reference readiness：

- credential reference 只保存 profile identity、namespace key 和 redacted evidence reference。
- present reference 只证明 identity-only readiness。
- missing reference 必须 fail closed，并生成可审计的脱敏 evidence。
- invalid reference 必须 fail closed，并生成 namespace mismatch evidence。
- audit evidence 必须 append-only，并且只能包含 `<redacted>` 摘要。

## 非目标

GH-1242 不实现以下能力：

- 不读取 production secret value。
- 不保存 raw credential material。
- 不自动读取 secret provider。
- 不记录 API key、secret key 或 listenKey。
- 不连接 production endpoint / broker endpoint。
- 不实现 signed account endpoint runtime。
- 不实现 private stream runtime。
- 不提交 / 取消 / 替换订单。
- 不运行 Spot canary。
- 不实现 Binance USDⓈ-M Futures runtime。
- 不实现 OKX active implementation。
- 不创建 tag / GitHub Release。
- 不授权 production cutover。

## Credential Reference Evidence

Credential reference 继续复用 v0.19.0 credential profile registry 和 #1240 environment profile：

- profile id：`binance-spot-productionShadow-credential-profile-ref`
- namespace key：`binance/spot/productionShadow/binance-spot-productionShadow-credential-profile-ref`
- redacted evidence reference：`redacted-credential-profile:binance:spot:productionShadow`
- redacted summary：`credential-reference=<redacted>; state=present; action=identity-only`

这些字段是 identity-only readiness contract，不是 secret material。任何 missing / invalid reference 都必须保留同一个 namespace 和 redacted reference，并以 fail-closed failure class 表达，不得降级为可连接 endpoint 或可发单状态。

## Fail-closed Evidence

GH-1242 的 fail-closed 分类：

- `required credential reference missing`
- `credential namespace mismatch`
- `secret value access attempted`
- `raw credential material present`

其中 deterministic fixture 固定两条可审计失败路径：

- missing reference：`required credential reference missing`
- invalid reference：`credential namespace mismatch`

任何 `secret value access attempted` 或 `raw credential material present` 都是 forbidden capability，不是可接受 readiness。

## 验证命令

- `swift test --filter TargetGraphTests/testGH1242ReleaseV0200CredentialReferenceReadiness`
- `bash checks/verify-v0.20.0-credential-reference-readiness.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

GH-1242 是 read-only production-shadow readiness evidence。production trading 默认关闭；production cutover not authorized；不会读取 production secret；不会连接 production endpoint / broker endpoint；不会发送真实订单或 testnet order。
