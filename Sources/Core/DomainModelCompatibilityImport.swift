@_exported import DomainModel
@_exported import Cache

/// GH-394 / GH-396 兼容导入面只把已迁入真实 target 的基础值对象和 Cache read model
/// 继续暴露给旧 `import Core` 调用方；真实实现所有权已经转移到 `DomainModel` /
/// `Cache` target。这里不新增 Trader、Strategy、Live、ExecutionClient、OMS、broker
/// gateway 或真实账户读取能力。
