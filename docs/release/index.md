# Release Evidence Index

日期：2026-07-20

执行者：Codex

状态：Canonical index

## 当前稳定版本

| 项 | 值 |
| --- | --- |
| Release | `v0.33.0` |
| Title | `MTPRO v0.33.0 Binance Demo Validation` |
| Commit | `19d5d6bcc24ae6cc243396cea57d1c01499b23fe` |
| Published | `2026-07-19T11:53:40Z` |
| URL | `https://github.com/atxinbao/MTPRO/releases/tag/v0.33.0` |

当前说明：

- `mtpro-release-v0.33.0-demo-validation-notes.md`

## 目录规则

`docs/release/` 保存所有历史 release notes 和 publication policy。旧版本说明保持原路径，不因版本过期删除。

- 版本说明：`mtpro-release-v<version>-*-notes.md`
- 发布规则：`release-publication-policy.md`
- 实际 tag / publishedAt 事实以 GitHub Release 与当前索引为准。

## 解释边界

v0.33.0 表示 Binance Spot + USD-M Futures Demo Network 后端证据链已验收：

```text
backendClosureDecision=accepted-demo-network-parity
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

发布说明不授权移动既有 tag、自动 production cutover、secret 读取或生产订单。

