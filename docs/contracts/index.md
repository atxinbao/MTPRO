# Contract Evidence Index

日期：2026-07-20

执行者：Codex

状态：Canonical index

## 作用

`docs/contracts/` 保存 release、模块、迁移和运行边界合同。合同默认是其创建阶段的 `Historical evidence`；是否仍为当前约束，需要由当前 Canonical 文档或后续合同确认。

## 当前相关合同

1. `release-v0.33.0-observed-canary-backend-closure-contract.md`
   - v0.33.0 Demo validation / backend closure evidence contract。
2. `v0330-backend-maintenance-ownership-contract.md`
   - 后端维护 ownership、compatibility envelope 和无能力扩张边界。

## 查找规则

- Release 合同：`release-v<version>-*.md`
- Module / architecture 合同：按模块或 migration 名称查找。
- 被后续合同替代的文档继续保留，不自动删除。

## 优先级

当合同冲突时：

```text
current Canonical docs
-> latest applicable contract
-> latest release / audit evidence
-> older historical contract
```

合同不能绕过 GitHub queue、required checks、Human approval 或 production cutover gate。

