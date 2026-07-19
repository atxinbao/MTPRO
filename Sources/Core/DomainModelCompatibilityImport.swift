@_exported import DomainModel
@_exported import MessageBus
@_exported import Cache
@_exported import DataEngine
@_exported import TraderStrategies
@_exported import Trader
@_exported import Portfolio
@_exported import RiskEngine
@_exported import ExecutionEngine

/// GH-398 / GH-415 兼容导入面把已经迁入真实 architecture targets 的类型继续暴露给旧
/// `import Core` 调用方。
///
/// Core 仍是 compatibility envelope，不重新拥有 DataEngine、Trader、Strategy、Portfolio、
/// RiskEngine 或 ExecutionEngine 实现。ExecutionClient 不再通过 Core 传递暴露，调用方必须显式
/// 导入真实 owner。这里不新增 Trader runtime、Strategy
/// runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway 或真实账户读取能力。
