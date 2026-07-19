# MTPRO v0.33.0 Demo Validation Notes

Date: 2026-07-19  
Executor: Codex

Anchors: `GH-1549-CLOSE-V0330-DEMO-VALIDATION-AUDIT-RELEASE-NOTES`, `TVM-RELEASE-V0330-DEMO-VALIDATION-PRODUCTION-CLOSURE-BLOCKED`, `V0330-008-DEMO-VALIDATION-AUDIT-RELEASE-NOTES`, `V0330-008-BINANCE-SPOT-USDM-FUTURES-ONLY`, `V0330-008-NO-PRODUCTION-CUTOVER`.

v0.33.0 validates Binance Spot + USD-M Futures Demo submit/status/cancel evidence with strict caps, artifact redaction, trusted provenance and fail-closed local status evaluation. The Demo workflow evidence is not production evidence.

The production boundary remains explicit:

- production trading remains disabled by default;
- no production secret is read automatically;
- no production endpoint is connected;
- no production order is submitted, cancelled, or replaced;
- `backendClosureDecision=accepted-demo-network-parity`;
- `productionCutoverAuthorized=false`.

The status CLI and Dashboard surface are read-only. A missing, malformed, provenance-mismatched, or boundary-invalid Demo bundle is a validation failure and must return a non-zero CLI exit status.

## Human Demo Parity 后端收口

Human 于 2026-07-19 确认以 Binance Demo Network 的 Spot 与 USD-M Futures 双产品验证作为后端功能验收标准。有效 Demo bundle 的当前结论为：

```text
backendClosureDecision=accepted-demo-network-parity
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

这表示后端功能版本可以在 closure PR 通过完整验证后冻结，不表示生产切换或默认生产交易已经授权。`v0.33.0` tag 保持不变，closure PR merge commit 作为发布后的冻结补充基线。

## Post-release Backend Maintenance Fact

`GH-1579-V0330-BACKEND-MAINTENANCE-CLOSEOUT` records the completed post-release
maintenance queue #1574-#1579. The queue hardened cross-platform validation,
split one oversized compatibility boundary, consolidated Demo evidence
validation and removed the stale Core-to-ExecutionClient re-export. It did not
change the accepted Demo execution behavior or add a production capability.

```text
patchReleaseDecision=not-warranted
v0.33.1TagCreated=false
v0.33.0TagMoved=false
backendClosureDecision=accepted-demo-network-parity
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

The release tag remains
`19d5d6bcc24ae6cc243396cea57d1c01499b23fe`. The maintenance merge chain is a
supplemental backend baseline, not a replacement release snapshot.
