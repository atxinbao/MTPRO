# MTPRO Documentation Lifecycle Policy

日期：2026-07-20

执行者：Codex

状态：Canonical

## 目的

本政策定义 MTPRO 文档的权威层级、维护责任和退休方式。目标是让当前事实保持简洁可读，同时保留版本发布、审计、合同和规划记录所需的历史证据。

MTPRO 采用以下原则：

> 权威文档瘦身，历史证据保留，过期口径显式退休。

历史文件数量不是删除理由。当前权威文档也不得继续把历史阶段描述为当前产品事实。

## 生命周期分类

| 分类 | 定义 | 维护要求 |
| --- | --- | --- |
| `Canonical` | 描述当前产品目标、架构、边界和环境事实的权威文档 | 内容必须与当前已发布或已合并事实一致；出现冲突时优先修复 |
| `Current operational` | 当前仍可执行的验证、运行、发布和维护说明 | 命令必须可运行；依赖、输入、输出和失败行为必须明确 |
| `Historical evidence` | 已完成版本、审计、合同、规划和验证记录 | 默认保留原路径和原始事实；不得作为当前能力授权 |
| `Superseded` | 已被新文档替代、但仍具有追溯或兼容价值的记录 | 必须标明替代文档或退休原因；不得出现在默认阅读路径 |
| `Delete candidate` | 无引用、无审计价值且内容重复或失效的文件 | 只有通过本政策的全部删除条件后才能删除 |

## 当前权威入口

以下文档共同构成当前权威层：

1. `README.md`
2. `GOAL.md`
3. `BLUEPRINT.md`
4. `architecture.md`
5. `environment.md`
6. `docs/roadmap.md`
7. `docs/architecture/module-boundary.md`
8. `docs/domain/context.md`
9. `docs/validation/latest-verification-summary.md`
10. `docs/index.md`

`AGENTS.md` 定义 Agent / Codex 的仓库操作规则，不替代产品或架构事实。

当权威入口之间存在冲突时，先停止扩散冲突，再通过独立 docs-only PR 统一口径。历史审计报告不能覆盖更新后的当前事实。

## 文档族责任

| 路径 | 生命周期 | 责任 |
| --- | --- | --- |
| `docs/audit/` | Historical evidence | 保存阶段审计、关闭结论和证据链 |
| `docs/contracts/` | Historical evidence 或 Current operational | 保存版本和模块合同；是否仍生效必须由索引标明 |
| `docs/release/` | Historical evidence | 保存发布说明、版本边界和发布事实 |
| `docs/planning/` | Historical evidence | 保存已完成或未授权执行的规划记录 |
| `docs/validation/` | Current operational 或 Historical evidence | 当前验证入口保持精简；阶段流水记录归档 |
| `verification.md` | Canonical summary + Historical evidence registry | 文件首页只保留冻结摘要和历史索引，详细流水按阶段归档 |

## 状态标识

新增或重写的重要文档应在标题后声明状态：

```text
状态：Canonical
```

可选状态为：

```text
Canonical
Current operational
Historical evidence
Superseded
Delete candidate
```

历史文件不要求一次性批量补标。触碰历史文件时，应在不改写原始事实的前提下增加状态说明。

## 当前事实与历史事实

当前权威文档只能描述当前确认事实。以下内容必须进入历史区或显式标记为已退休：

- 已退休模块、目录或产品口径。
- 已完成版本的 “next project” 或 “publication pending” 表述。
- 已被后续版本替代的策略、交易所或运行模式声明。
- 已完成 planning record 的执行入口。

历史证据可以保留当时成立的原始表述，但必须满足：

1. 不出现在默认阅读顺序中。
2. 不被引用为当前能力授权。
3. 索引能够说明其版本、状态或替代关系。

## 删除条件

只有同时满足以下条件，文档才能进入实际删除：

1. 内容完全重复或已经无效。
2. 没有 checks、测试、合同或其他文档引用。
3. 不是 release、audit、planning 或 validation evidence。
4. Git 历史足以恢复。
5. `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh` 全部通过。

不能确认任一条件时，文件应保留，并按 `Historical evidence` 或 `Superseded` 管理。

## 变更规则

文档清理应使用小步 docs-only PR：

1. 先建立分类、索引和兼容策略。
2. 再重写当前权威文档。
3. 然后压缩摘要并建立历史索引。
4. 最后清理过期术语和失效引用。

不得为了减少文件数量而批量删除 Markdown。不得在同一 PR 中同时重写权威事实、移动大批历史证据和修改业务实现。

## 验证要求

每个文档治理 PR 至少运行：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

若历史锚点被迁移到归档文件，必须先更新对应 checks / tests 的读取位置，并证明验证行为没有被弱化。

## 当前治理状态

`MTPRO Documentation Canonicalization / Historical Evidence Cleanup v1` 只负责文档治理，不授权交易能力变更、production cutover、secret 读取、production endpoint 连接或订单操作。

本政策建立后，后续 PR 将依次处理权威文档、验证摘要和历史索引。历史证据在完成引用迁移前保持原路径。
