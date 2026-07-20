# MTPRO Docs Index

日期：2026-07-20

执行者：Codex

状态：Canonical

## 定位

本文档是 MTPRO 当前文档入口。新读者应从当前权威文档开始，不应从历史 audit、release、contract 或 planning record 反推当前能力。

文档生命周期、退休和删除规则见 `docs/documentation-policy.md`。

## 默认阅读顺序

| 顺序 | 文档 | 状态 | 用途 |
| --- | --- | --- | --- |
| 1 | `README.md` | Canonical | 产品定位、冻结基线、运行入口和文档导航 |
| 2 | `AGENTS.md` | Current operational | Agent / Codex 仓库操作与验证规则 |
| 3 | `GOAL.md` | Canonical | 当前目标、成功标准和能力边界 |
| 4 | `BLUEPRINT.md` | Canonical | 产品、系统和交付蓝图 |
| 5 | `architecture.md` | Canonical | 当前模块、依赖方向和数据流 |
| 6 | `environment.md` | Canonical | 支持环境、工具链和运行事实 |
| 7 | `docs/roadmap.md` | Canonical | 当前状态、维护路线和下一阶段 |
| 8 | `docs/domain/context.md` | Canonical | 当前领域语言和术语 |
| 9 | `docs/validation/latest-verification-summary.md` | Canonical | 最近验证和冻结结论的轻量摘要 |
| 10 | `docs/documentation-policy.md` | Canonical | 文档生命周期和历史证据治理规则 |

`verification.md` 现在是当前验证注册表。逐 issue 历史流水位于
`docs/history/validation-pre-canonicalization-2026-07-20/`。

## 当前操作入口

| 任务 | 入口 |
| --- | --- |
| 完整本地验证 | `bash checks/run.sh` |
| 自动化准备检查 | `bash checks/automation-readiness.sh` |
| 当前环境说明 | `environment.md` |
| 当前架构边界 | `architecture.md`、`docs/architecture/module-boundary.md` |
| 最近验证结论 | `docs/validation/latest-verification-summary.md` |
| 验证证据注册 | `verification.md` |
| Audit 索引 | `docs/audit/index.md` |
| Release 索引 | `docs/release/index.md` |
| Contract 索引 | `docs/contracts/index.md` |
| Planning 索引 | `docs/planning/linear-draft-plan.md` |

## 历史证据

以下目录默认属于历史证据，不代表当前能力授权：

| 目录 | 内容 |
| --- | --- |
| `docs/audit/` | 阶段审计和项目关闭证据 |
| `docs/contracts/` | 版本、模块和迁移合同 |
| `docs/release/` | 已发布版本说明和边界 |
| `docs/planning/` | 已完成或未授权执行的规划记录 |
| `docs/validation/` | 当前验证入口及历史验证材料 |

目录索引已建立。历史文件保留原路径；大型旧验证流水使用日期化快照，
对应 checks / tests 读取历史快照，避免把旧 anchor 继续堆入当前摘要。

## 已退休入口的兼容记录

`MTP-124-DOCS-INDEX`

以下内容是 Historical evidence compatibility anchors。它们只用于保持旧验证和审计可追溯，不属于当前产品入口：

- `docs/validation/workbench-beta-operator-guide.md`
- `docs/validation/workbench-beta-demo-workflow-guide.md`
- `docs/validation/workbench-beta-acceptance-checklist.md`
- `MTP-124-BETA-NOT-LIVE-READINESS`
- `MTP-124-TROUBLESHOOTING-POINTERS`

Workbench 已从当前 active module / UI 口径退休。上述文件不得被解释为当前 Workbench 能力、live readiness 或 production trading 授权。

## 文档冲突处理

发现文档事实冲突时：

1. 以当前已合并代码、发布事实和验证结果为证据。
2. 修复 Canonical 文档，不改写历史审计的原始事实。
3. 将过期表述标记为 `Historical evidence` 或 `Superseded`。
4. 更新引用和自动化 guard 后再考虑移动或删除文件。
