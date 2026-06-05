@_exported import DomainModel

/// GH-394 兼容导入面只把 `DomainModel` 的基础值对象继续暴露给旧 `import Core`
/// 调用方；真实实现所有权已经转移到 `DomainModel` target。这里不新增 Trader、
/// Strategy、Live、ExecutionClient、OMS、broker gateway 或真实账户读取能力。
