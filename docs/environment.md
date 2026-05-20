# docs/environment.md

本文档是运行 / 验证 / 外部系统边界文档。它是 `BLUEPRINT.md` 的二级权重承接文档，只定义当前本地环境、验证入口和外部系统使用禁区，不定义产品目标、工程模块或施工路线。

本文档不能推翻 `BLUEPRINT.md`，也不授权 Linear Project / Issue、`Todo` 推进、Symphony 启动或业务代码修改。

## 基线环境

- macOS：14+
- Swift：6+
- 构建系统：SwiftPM-first
- UI：SwiftUI
- 并发：Swift actor / AsyncSequence
- 网络：URLSession / URLSessionWebSocketTask

## 本地验证

```bash
bash checks/run.sh
```

`checks/run.sh` 串联：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- macOS 本地：`swift build --product Dashboard`
- macOS 本地：`DASHBOARD_SMOKE=1 swift run Dashboard`
- Linux CI：跳过 macOS-only SwiftUI shell build / smoke，并继续运行 SwiftPM tests
- `swift test`

## 外部系统边界

允许在明确授权任务中使用：

- GitHub PR Automation。
- Linear 只读查询。
- Human 授权后的 Linear issue 状态推进。
- symphony-issue 本地调度。
- Graphify resource relationship graph read context。
- Post-Issue Ledger 中的 Graphify scoped resource relationship graph refresh。

默认禁止：

- Binance signed endpoint。
- API key。
- account endpoint。
- order submit / cancel / replace。
- listenKey user data stream。
- LiveExecutionAdapter。
- 未经 Human 授权创建 Linear Project / Issue。
- 未经 Human 授权启动 symphony-issue。
- Graphify full rebuild。
- 提交 `.codex/*` 或 `graphify-out/*`。
