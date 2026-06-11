import Foundation

/// TargetExposureIntent 表示策略输出给执行前链路的目标敞口意图。
///
/// Release v0.2.0 当前支持 long、short、flat 和 hold 四类目标敞口。该类型只描述
/// strategy intent，不是订单指令、不绕过 RiskEngine，也不授权 ExecutionClient 或 broker action。
public enum TargetExposureIntent: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case targetLong
    case targetShort
    case targetFlat
    case hold

    /// 是否需要构造后续 product-aware order intent。
    public var requiresOrderIntent: Bool {
        switch self {
        case .targetLong, .targetShort, .targetFlat:
            true
        case .hold:
            false
        }
    }

    /// 在指定产品类型下，是否允许进入 order intent 构造前置阶段。
    public func isPreOrderAllowed(for productType: ProductType) -> Bool {
        switch (productType, self) {
        case (.spot, .targetShort):
            false
        default:
            true
        }
    }
}
