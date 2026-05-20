# MTPRO Complete Blueprint Design

日期：2026-05-20

执行者：Codex

## 定位

本文档是兼容入口。

MTPRO 的 Root Blueprint 和 Complete Blueprint 已统一到根目录：

- `BLUEPRINT.md`

`BLUEPRINT.md` 是唯一 canonical blueprint，包含：

- Root Blueprint
- Final Product Blueprint
- System Architecture Blueprint
- Workbench / UX Blueprint
- Complete Capability Map
- Current Construction Scope
- Future Construction Zones
- Live / signed endpoint / broker / OMS gated boundary
- Linear Planning Handoff

本文档不再维护独立蓝图正文，避免 `BLUEPRINT.md` 与 `docs/design/mtpro-complete-blueprint.md` 双写漂移。

## 边界

- 本文档不创建 Linear Project / Issue。
- 本文档不修改 Linear status。
- 本文档不推进 `Todo`。
- 本文档不启动 Symphony。
- 本文档不运行 Graphify update。
- 本文档不写业务代码。

## 维护规则

- Human + `@000 / AIE` 维护完整蓝图时，只修改 `BLUEPRINT.md`。
- `docs/design/mtpro-complete-blueprint.md` 只保留为旧链接兼容和 discovery pointer。
- 角色职责、Project 调度规则、阶段完成进度条和自动化 closure 规则不在本文档重复定义，统一由 `AGENTS.md`、`docs/planning/project-role-map.md` 和 `docs/automation/parent-codex-supervision.md` 维护。
