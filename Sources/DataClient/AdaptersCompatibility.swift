@_exported import DataClient

/// GH-396 后 `Adapters` 只保留为 DataClient 的兼容 re-export。
///
/// Binance public read-only market data implementation 已由 `DataClient` target 拥有。
/// 这里不新增 signed endpoint、account endpoint、listenKey、private stream、broker adapter
/// 或 execution capability。
