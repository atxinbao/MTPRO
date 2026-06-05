import DomainModel
import Foundation

/// MTP-188 将 OMSFutureGate 放入 ExecutionEngine 目标目录，但仍只作为 future-gated boundary。
///
/// 该合同用来说明：当前 ExecutionEngine 只能处理 paper / simulated lifecycle evidence，不能实现
/// OMS、order router、venue routing、real order state store、submit / cancel / replace、execution report、
/// broker fill 或 reconciliation。字段全部是静态边界证据，不会触发任何真实执行动作。
public struct OMSFutureGateBoundary: Codable, Equatable, Sendable {
    public let boundaryID: Identifier
    public let allowedPlacement: String
    public let isFutureGateOnly: Bool
    public let implementsOMS: Bool
    public let routesVenueOrders: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let consumesExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let performsReconciliation: Bool

    public var boundaryHeld: Bool {
        allowedPlacement == "Sources/ExecutionEngine/OMSFutureGate/"
            && isFutureGateOnly
            && implementsOMS == false
            && routesVenueOrders == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && consumesExecutionReport == false
            && recordsBrokerFill == false
            && performsReconciliation == false
    }

    private enum CodingKeys: String, CodingKey {
        case boundaryID
        case allowedPlacement
        case isFutureGateOnly
        case implementsOMS
        case routesVenueOrders
        case submitsRealOrder
        case cancelsRealOrder
        case replacesRealOrder
        case consumesExecutionReport
        case recordsBrokerFill
        case performsReconciliation
    }

    public init(
        boundaryID: Identifier = try! Identifier("mtp-188-oms-future-gate-boundary"),
        allowedPlacement: String = "Sources/ExecutionEngine/OMSFutureGate/",
        isFutureGateOnly: Bool = true,
        implementsOMS: Bool = false,
        routesVenueOrders: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        consumesExecutionReport: Bool = false,
        recordsBrokerFill: Bool = false,
        performsReconciliation: Bool = false
    ) throws {
        try Self.validateBoundary(
            allowedPlacement: allowedPlacement,
            isFutureGateOnly: isFutureGateOnly,
            implementsOMS: implementsOMS,
            routesVenueOrders: routesVenueOrders,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            consumesExecutionReport: consumesExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            performsReconciliation: performsReconciliation
        )

        self.boundaryID = boundaryID
        self.allowedPlacement = allowedPlacement
        self.isFutureGateOnly = isFutureGateOnly
        self.implementsOMS = implementsOMS
        self.routesVenueOrders = routesVenueOrders
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.consumesExecutionReport = consumesExecutionReport
        self.recordsBrokerFill = recordsBrokerFill
        self.performsReconciliation = performsReconciliation
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            boundaryID: try container.decode(Identifier.self, forKey: .boundaryID),
            allowedPlacement: try container.decode(String.self, forKey: .allowedPlacement),
            isFutureGateOnly: try container.decode(Bool.self, forKey: .isFutureGateOnly),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            routesVenueOrders: try container.decode(Bool.self, forKey: .routesVenueOrders),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            consumesExecutionReport: try container.decode(Bool.self, forKey: .consumesExecutionReport),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill),
            performsReconciliation: try container.decode(Bool.self, forKey: .performsReconciliation)
        )
    }

    private static func validateBoundary(
        allowedPlacement: String,
        isFutureGateOnly: Bool,
        implementsOMS: Bool,
        routesVenueOrders: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        consumesExecutionReport: Bool,
        recordsBrokerFill: Bool,
        performsReconciliation: Bool
    ) throws {
        guard allowedPlacement == "Sources/ExecutionEngine/OMSFutureGate/" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedPlacement",
                expected: "Sources/ExecutionEngine/OMSFutureGate/",
                actual: allowedPlacement
            )
        }
        guard isFutureGateOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("isFutureGateOnly")
        }
        for capability in [
            ("implementsOMS", implementsOMS),
            ("routesVenueOrders", routesVenueOrders),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("consumesExecutionReport", consumesExecutionReport),
            ("recordsBrokerFill", recordsBrokerFill),
            ("performsReconciliation", performsReconciliation)
        ] where capability.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}
