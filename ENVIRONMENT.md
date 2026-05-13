# ENVIRONMENT.md

## 基线环境

- macOS：14+
- Swift：6+
- 构建系统：SwiftPM-first
- UI：SwiftUI
- 并发：Swift actor / AsyncSequence
- 网络：URLSession / URLSessionWebSocketTask

## 外部系统边界

当前允许：

- Binance public market data。
- 本地 SwiftPM build / test。

当前禁止：

- Linear API 写入。
- Symphony execution。
- Graphify update / scoped update / full rebuild。
- Binance signed endpoint。
- API key。
- account endpoint。
- order submit / cancel / replace。
- listenKey user data stream。

## 本地验证

```bash
swift test
```

当前不接 CI，不接远程流水线。
