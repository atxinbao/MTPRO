# Swift Style Configuration

日期：2026-06-07  
执行者：Codex

## GH-437-SWIFT-STYLE-CONFIGURATION

MTPRO 使用仓库根目录 `.swift-format` 作为 Swift 代码风格配置基线。当前配置只固定低噪声布局规则：

- `lineLength`: 120
- indentation: 4 spaces
- maximum blank lines: 1
- respect existing line breaks: true

本阶段不做全仓格式化，不修改语义代码，不把 formatter 强制接入 `checks/run.sh`。原因是当前本地环境没有检测到已安装的 `swift-format` / `swiftformat` / `swiftlint`，直接接入验证会让本地和 GitHub required check 变脆。

## Local command

安装 Apple `swift-format` 后，可本地只读检查：

```bash
swift-format lint --configuration .swift-format --recursive Sources Tests Package.swift
```

需要格式化时必须单独授权，不允许在 unrelated issue 中顺手格式化全仓：

```bash
swift-format format --configuration .swift-format --in-place --recursive Sources Tests Package.swift
```

## Validation boundary

- `git diff --check` 继续作为当前必跑 whitespace / patch formatting check。
- `bash checks/automation-readiness.sh` 只验证 `.swift-format` 和本文档存在，并验证本阶段没有把 formatter 强制接入 `checks/run.sh`。
- `bash checks/run.sh` 继续覆盖构建、Dashboard smoke 和 XCTest。

## Non-goals

- 不新增 SwiftLint 规则集。
- 不新增 CI-only formatter requirement。
- 不执行全仓 reformat。
- 不修改 SwiftPM target graph。
- 不改业务代码。
- 不实现 Trader / Strategy / Live runtime。
- 不实现 ExecutionClient / OMS / broker gateway。
