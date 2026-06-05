@_exported import DomainModel
@_exported import MessageBus
@_exported import Cache
@_exported import TraderStrategies
@_exported import Trader
@_exported import Portfolio
@_exported import RiskEngine
@_exported import ExecutionClient
@_exported import ExecutionEngine

/// GH-398 兼容导入面把已经迁入真实 architecture targets 的类型继续暴露给旧
/// `import Core` 调用方。
///
/// Core 仍是 compatibility envelope，不重新拥有 Trader、Strategy、Portfolio、RiskEngine、
/// ExecutionEngine 或 ExecutionClient 实现。这里不新增 Trader runtime、Strategy runtime、Live
/// runtime、ExecutionClient implementation、OMS、broker gateway 或真实账户读取能力。
