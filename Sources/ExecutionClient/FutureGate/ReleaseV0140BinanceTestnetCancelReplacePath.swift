import DomainModel
import Foundation

/// ReleaseV0140LocalOMSOrderIdentity 固定 GH-1030 cancel / replace 所需的本地 OMS order identity。
///
/// 该 identity 只从 GH-1029 submit evidence 派生本地订单身份；它不保存交易所原始 order id、
/// 不读取 broker fill，也不执行 reconciliation。cancel / replace 必须先证明该本地身份存在。
public struct ReleaseV0140LocalOMSOrderIdentity: Codable, Equatable, Sendable {
    public let localOrderID: Identifier
    public let intentID: Identifier
    public let strategyRunID: Identifier
    public let sourceSequence: Int
    public let productType: ProductType
    public let symbol: Symbol
    public let lifecycleState: OrderLifecycleState
    public let sourceSubmitPathID: Identifier
    public let sourceSubmitResponseID: Identifier
    public let exchangeOrderIDRedacted: Bool
    public let localOMSOrderIdentityOnly: Bool
    public let brokerFillIncluded: Bool
    public let reconciliationIncluded: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        localOrderID: Identifier,
        submitRequest: ReleaseV0140BinanceTestnetSubmitRequestEvidence,
        submitResponse: ReleaseV0140BinanceTestnetSubmitResponseEvidence,
        submitPath: ReleaseV0140BinanceTestnetSubmitPath,
        lifecycleState: OrderLifecycleState = .accepted,
        exchangeOrderIDRedacted: Bool = true,
        localOMSOrderIdentityOnly: Bool = true,
        brokerFillIncluded: Bool = false,
        reconciliationIncluded: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard submitRequest.boundaryHeld, submitResponse.boundaryHeld, submitPath.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetCancelReplace.unheldSubmitEvidence")
        }
        guard submitPath.requestID == submitRequest.requestID,
              submitPath.responseID == submitResponse.responseID,
              submitResponse.requestID == submitRequest.requestID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetCancelReplace.submitEvidenceLinks",
                expected: "linked GH-1029 submit request / response / path",
                actual: "unlinked submit evidence"
            )
        }
        guard Self.allowedLifecycleStates.contains(lifecycleState) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetCancelReplace.localOMSOrder.lifecycleState",
                expected: Self.allowedLifecycleStates.map(\.rawValue).sorted().joined(separator: ","),
                actual: lifecycleState.rawValue
            )
        }
        guard exchangeOrderIDRedacted, localOMSOrderIdentityOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetCancelReplace.unredactedLocalOrderIdentity")
        }
        try Self.forbid(brokerFillIncluded, "brokerFillIncluded")
        try Self.forbid(reconciliationIncluded, "reconciliationIncluded")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard localOrderID == Self.deterministicID(
            responseID: submitResponse.responseID,
            lifecycleState: lifecycleState
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetCancelReplace.localOrderID",
                expected: Self.deterministicID(responseID: submitResponse.responseID, lifecycleState: lifecycleState).rawValue,
                actual: localOrderID.rawValue
            )
        }

        self.localOrderID = localOrderID
        self.intentID = submitRequest.intentID
        self.strategyRunID = submitRequest.strategyRunID
        self.sourceSequence = submitRequest.sourceSequence
        self.productType = submitRequest.productType
        self.symbol = submitRequest.symbol
        self.lifecycleState = lifecycleState
        self.sourceSubmitPathID = submitPath.pathID
        self.sourceSubmitResponseID = submitResponse.responseID
        self.exchangeOrderIDRedacted = exchangeOrderIDRedacted
        self.localOMSOrderIdentityOnly = localOMSOrderIdentityOnly
        self.brokerFillIncluded = brokerFillIncluded
        self.reconciliationIncluded = reconciliationIncluded
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        Self.allowedLifecycleStates.contains(lifecycleState)
            && exchangeOrderIDRedacted
            && localOMSOrderIdentityOnly
            && brokerFillIncluded == false
            && reconciliationIncluded == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
    }

    public static let allowedLifecycleStates: Set<OrderLifecycleState> = [
        .accepted,
        .partiallyFilled,
        .replaced
    ]

    public static func deterministicID(
        responseID: Identifier,
        lifecycleState: OrderLifecycleState
    ) -> Identifier {
        .constant(
            "gh-1030-local-oms-order:\(responseID.rawValue):\(lifecycleState.rawValue)",
            field: "releaseV0140BinanceTestnetCancelReplace.localOrderID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetCancelReplace.localOMSOrder.\(field)")
        }
    }
}

/// ReleaseV0140BinanceTestnetCancelReplaceAdapterApproval 记录 testnet adapter 对 cancel / replace 的显式批准。
///
/// 该 approval 必须绑定本地 OMS identity 与 GH-1028 testnet endpoint。它只允许生成脱敏 evidence，
/// 不创建 URL request，不连接 broker，也不允许 fallback 到 production host。
public struct ReleaseV0140BinanceTestnetCancelReplaceAdapterApproval: Codable, Equatable, Sendable {
    public let approvalID: Identifier
    public let localOrderID: Identifier
    public let productType: ProductType
    public let endpointHost: String
    public let explicitTestnetMode: Bool
    public let cancelAllowed: Bool
    public let replaceAllowed: Bool
    public let localOMSOrderIdentityRequired: Bool
    public let adapterApprovalRedacted: Bool
    public let networkCancelReplacePerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        approvalID: Identifier,
        localOrder: ReleaseV0140LocalOMSOrderIdentity,
        endpoint: ReleaseV0140BinanceTestnetEndpointReference,
        explicitTestnetMode: Bool = true,
        cancelAllowed: Bool = true,
        replaceAllowed: Bool = true,
        localOMSOrderIdentityRequired: Bool = true,
        adapterApprovalRedacted: Bool = true,
        networkCancelReplacePerformed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard localOrder.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetCancelReplace.missingLocalOMSOrderIdentity")
        }
        guard endpoint.boundaryHeld, endpoint.productType == localOrder.productType else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetCancelReplace.approvalEndpoint",
                expected: localOrder.productType.rawValue,
                actual: endpoint.productType.rawValue
            )
        }
        guard explicitTestnetMode, cancelAllowed, replaceAllowed else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetCancelReplace.nonTestnetAdapterApproval")
        }
        guard localOMSOrderIdentityRequired, adapterApprovalRedacted else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetCancelReplace.unredactedOrIdentitylessApproval")
        }
        try Self.forbid(networkCancelReplacePerformed, "networkCancelReplacePerformed")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard approvalID == Self.deterministicID(
            localOrderID: localOrder.localOrderID,
            productType: endpoint.productType
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetCancelReplace.approvalID",
                expected: Self.deterministicID(localOrderID: localOrder.localOrderID, productType: endpoint.productType).rawValue,
                actual: approvalID.rawValue
            )
        }

        self.approvalID = approvalID
        self.localOrderID = localOrder.localOrderID
        self.productType = endpoint.productType
        self.endpointHost = endpoint.baseURL.host?.lowercased() ?? ""
        self.explicitTestnetMode = explicitTestnetMode
        self.cancelAllowed = cancelAllowed
        self.replaceAllowed = replaceAllowed
        self.localOMSOrderIdentityRequired = localOMSOrderIdentityRequired
        self.adapterApprovalRedacted = adapterApprovalRedacted
        self.networkCancelReplacePerformed = networkCancelReplacePerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        explicitTestnetMode
            && cancelAllowed
            && replaceAllowed
            && localOMSOrderIdentityRequired
            && adapterApprovalRedacted
            && networkCancelReplacePerformed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
            && endpointHost == ReleaseV0140BinanceTestnetEndpointReference.expectedHost(for: productType)
    }

    public static func deterministicID(
        localOrderID: Identifier,
        productType: ProductType
    ) -> Identifier {
        .constant(
            "gh-1030-binance-testnet-cancel-replace-approval:\(localOrderID.rawValue):\(productType.rawValue)",
            field: "releaseV0140BinanceTestnetCancelReplace.approvalID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetCancelReplace.approval.\(field)")
        }
    }
}

/// ReleaseV0140BinanceTestnetCancelReplaceRequestEvidence 记录 cancel / replace request 的脱敏证据。
///
/// request 必须消费现有本地 OMS order identity，并且 mapping 必须是 Binance testnet
/// cancel 或 replace。该类型只保存 endpoint path 字面证据，不创建网络请求、不保存 credential。
public struct ReleaseV0140BinanceTestnetCancelReplaceRequestEvidence: Codable, Equatable, Sendable {
    public let requestID: Identifier
    public let operation: ExecutionContractOperation
    public let mappingID: Identifier
    public let intentID: Identifier
    public let localOrderID: Identifier
    public let productType: ProductType
    public let symbol: Symbol
    public let lifecycleState: OrderLifecycleState
    public let targetLifecycleState: OrderLifecycleState
    public let endpointHost: String
    public let endpointPath: String
    public let adapterApprovalID: Identifier
    public let existingLocalOMSOrderIdentityRequired: Bool
    public let testnetCancelReplaceEvidenceAllowed: Bool
    public let requestBodyRedacted: Bool
    public let credentialMaterialRedacted: Bool
    public let networkCancelReplacePerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        requestID: Identifier,
        mapping: ExecutionContractRequestMapping,
        localOrder: ReleaseV0140LocalOMSOrderIdentity,
        endpoint: ReleaseV0140BinanceTestnetEndpointReference,
        approval: ReleaseV0140BinanceTestnetCancelReplaceAdapterApproval,
        endpointPath: String? = nil,
        existingLocalOMSOrderIdentityRequired: Bool = true,
        testnetCancelReplaceEvidenceAllowed: Bool = true,
        requestBodyRedacted: Bool = true,
        credentialMaterialRedacted: Bool = true,
        networkCancelReplacePerformed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard localOrder.boundaryHeld, approval.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetCancelReplace.unheldIdentityOrApproval")
        }
        guard mapping.boundaryHeld,
              mapping.mode == .binanceTestnet,
              Self.allowedOperations.contains(mapping.operation),
              mapping.intentID == localOrder.intentID,
              mapping.lifecycleState == localOrder.lifecycleState else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetCancelReplace.mapping",
                expected: "Binance testnet cancel/replace mapping for existing local OMS order",
                actual: "\(mapping.operation.rawValue):\(mapping.mode.rawValue):\(mapping.lifecycleState.rawValue)"
            )
        }
        guard mapping.targetLifecycleState == Self.targetState(for: mapping.operation) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetCancelReplace.targetLifecycleState",
                expected: Self.targetState(for: mapping.operation).rawValue,
                actual: mapping.targetLifecycleState.rawValue
            )
        }
        guard endpoint.boundaryHeld,
              endpoint.productType == localOrder.productType,
              approval.localOrderID == localOrder.localOrderID,
              approval.productType == endpoint.productType else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetCancelReplace.endpointApproval",
                expected: "matching local order, product and testnet endpoint",
                actual: "\(endpoint.productType.rawValue):\(approval.productType.rawValue)"
            )
        }
        guard existingLocalOMSOrderIdentityRequired, testnetCancelReplaceEvidenceAllowed else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetCancelReplace.identitylessOrNonTestnetRequest")
        }
        guard requestBodyRedacted, credentialMaterialRedacted else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetCancelReplace.unredactedRequest")
        }
        try Self.forbid(networkCancelReplacePerformed, "networkCancelReplacePerformed")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        let resolvedEndpointPath = endpointPath ?? Self.orderEndpointPath(
            operation: mapping.operation,
            productType: endpoint.productType
        )
        guard resolvedEndpointPath == Self.orderEndpointPath(operation: mapping.operation, productType: endpoint.productType) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetCancelReplace.endpointPath",
                expected: Self.orderEndpointPath(operation: mapping.operation, productType: endpoint.productType),
                actual: resolvedEndpointPath
            )
        }
        guard requestID == Self.deterministicID(
            mappingID: mapping.mappingID,
            operation: mapping.operation,
            localOrderID: localOrder.localOrderID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetCancelReplace.requestID",
                expected: Self.deterministicID(
                    mappingID: mapping.mappingID,
                    operation: mapping.operation,
                    localOrderID: localOrder.localOrderID
                ).rawValue,
                actual: requestID.rawValue
            )
        }

        self.requestID = requestID
        self.operation = mapping.operation
        self.mappingID = mapping.mappingID
        self.intentID = mapping.intentID
        self.localOrderID = localOrder.localOrderID
        self.productType = localOrder.productType
        self.symbol = localOrder.symbol
        self.lifecycleState = mapping.lifecycleState
        self.targetLifecycleState = mapping.targetLifecycleState
        self.endpointHost = endpoint.baseURL.host?.lowercased() ?? ""
        self.endpointPath = resolvedEndpointPath
        self.adapterApprovalID = approval.approvalID
        self.existingLocalOMSOrderIdentityRequired = existingLocalOMSOrderIdentityRequired
        self.testnetCancelReplaceEvidenceAllowed = testnetCancelReplaceEvidenceAllowed
        self.requestBodyRedacted = requestBodyRedacted
        self.credentialMaterialRedacted = credentialMaterialRedacted
        self.networkCancelReplacePerformed = networkCancelReplacePerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        Self.allowedOperations.contains(operation)
            && existingLocalOMSOrderIdentityRequired
            && testnetCancelReplaceEvidenceAllowed
            && requestBodyRedacted
            && credentialMaterialRedacted
            && networkCancelReplacePerformed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
            && endpointHost == ReleaseV0140BinanceTestnetEndpointReference.expectedHost(for: productType)
            && endpointPath == Self.orderEndpointPath(operation: operation, productType: productType)
    }

    public static let allowedOperations: Set<ExecutionContractOperation> = [
        .cancel,
        .replace
    ]

    public static func targetState(for operation: ExecutionContractOperation) -> OrderLifecycleState {
        switch operation {
        case .cancel:
            .cancelRequested
        case .replace:
            .replaceRequested
        case .submit:
            .failedClosed
        }
    }

    public static func orderEndpointPath(
        operation: ExecutionContractOperation,
        productType: ProductType
    ) -> String {
        switch (operation, productType) {
        case (.cancel, .spot):
            "/api/v3/order"
        case (.cancel, .usdsPerpetual):
            "/fapi/v1/order"
        case (.replace, .spot):
            "/api/v3/order/cancelReplace"
        case (.replace, .usdsPerpetual):
            "/fapi/v1/order"
        case (.submit, _):
            "unsupported-submit"
        }
    }

    public static func deterministicID(
        mappingID: Identifier,
        operation: ExecutionContractOperation,
        localOrderID: Identifier
    ) -> Identifier {
        .constant(
            "gh-1030-binance-testnet-\(operation.rawValue)-request:\(mappingID.rawValue):\(localOrderID.rawValue)",
            field: "releaseV0140BinanceTestnetCancelReplace.requestID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetCancelReplace.request.\(field)")
        }
    }
}

/// ReleaseV0140BinanceTestnetCancelReplaceActionEvidence 记录 cancel / replace adapter action 的脱敏响应证据。
///
/// 该证据只承接 `ExecutionContractCancel` 或 `ExecutionContractReplace`，并要求交易所 order id
/// 与响应 payload 均为 redacted。它不是 broker fill，也不推进 reconciliation。
public struct ReleaseV0140BinanceTestnetCancelReplaceActionEvidence: Codable, Equatable, Sendable {
    public let actionID: Identifier
    public let requestID: Identifier
    public let mappingID: Identifier
    public let operation: ExecutionContractOperation
    public let lifecycleState: OrderLifecycleState
    public let contractActionID: Identifier
    public let acceptedByAdapter: Bool
    public let exchangeOrderIDRedacted: Bool
    public let responseBodyRedacted: Bool
    public let networkCancelReplacePerformed: Bool
    public let brokerFillIncluded: Bool
    public let reconciliationIncluded: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        actionID: Identifier,
        request: ReleaseV0140BinanceTestnetCancelReplaceRequestEvidence,
        cancel: ExecutionContractCancel? = nil,
        replace: ExecutionContractReplace? = nil,
        acceptedByAdapter: Bool = true,
        exchangeOrderIDRedacted: Bool = true,
        responseBodyRedacted: Bool = true,
        networkCancelReplacePerformed: Bool = false,
        brokerFillIncluded: Bool = false,
        reconciliationIncluded: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard request.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetCancelReplace.unheldRequest")
        }
        let contractActionID: Identifier
        let lifecycleState: OrderLifecycleState
        switch (request.operation, cancel, replace) {
        case let (.cancel, .some(cancelEvidence), .none):
            guard cancelEvidence.mappingID == request.mappingID,
                  cancelEvidence.lifecycleState == .cancelRequested,
                  cancelEvidence.authorizesProductionTrading == false,
                  cancelEvidence.touchesProductionEndpoint == false else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140BinanceTestnetCancelReplace.cancelEvidence",
                    expected: "cancelRequested evidence for request mapping",
                    actual: cancelEvidence.lifecycleState.rawValue
                )
            }
            contractActionID = cancelEvidence.cancelID
            lifecycleState = cancelEvidence.lifecycleState
        case let (.replace, .none, .some(replaceEvidence)):
            guard replaceEvidence.mappingID == request.mappingID,
                  replaceEvidence.lifecycleState == .replaceRequested,
                  replaceEvidence.authorizesProductionTrading == false,
                  replaceEvidence.touchesProductionEndpoint == false else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0140BinanceTestnetCancelReplace.replaceEvidence",
                    expected: "replaceRequested evidence for request mapping",
                    actual: replaceEvidence.lifecycleState.rawValue
                )
            }
            contractActionID = replaceEvidence.replaceID
            lifecycleState = replaceEvidence.lifecycleState
        default:
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetCancelReplace.actionEvidence",
                expected: "exactly one matching cancel or replace evidence",
                actual: request.operation.rawValue
            )
        }
        guard acceptedByAdapter, exchangeOrderIDRedacted, responseBodyRedacted else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetCancelReplace.unredactedOrRejectedAction")
        }
        try Self.forbid(networkCancelReplacePerformed, "networkCancelReplacePerformed")
        try Self.forbid(brokerFillIncluded, "brokerFillIncluded")
        try Self.forbid(reconciliationIncluded, "reconciliationIncluded")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard actionID == Self.deterministicID(
            requestID: request.requestID,
            contractActionID: contractActionID,
            operation: request.operation
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetCancelReplace.actionID",
                expected: Self.deterministicID(
                    requestID: request.requestID,
                    contractActionID: contractActionID,
                    operation: request.operation
                ).rawValue,
                actual: actionID.rawValue
            )
        }

        self.actionID = actionID
        self.requestID = request.requestID
        self.mappingID = request.mappingID
        self.operation = request.operation
        self.lifecycleState = lifecycleState
        self.contractActionID = contractActionID
        self.acceptedByAdapter = acceptedByAdapter
        self.exchangeOrderIDRedacted = exchangeOrderIDRedacted
        self.responseBodyRedacted = responseBodyRedacted
        self.networkCancelReplacePerformed = networkCancelReplacePerformed
        self.brokerFillIncluded = brokerFillIncluded
        self.reconciliationIncluded = reconciliationIncluded
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        ReleaseV0140BinanceTestnetCancelReplaceRequestEvidence.allowedOperations.contains(operation)
            && acceptedByAdapter
            && exchangeOrderIDRedacted
            && responseBodyRedacted
            && networkCancelReplacePerformed == false
            && brokerFillIncluded == false
            && reconciliationIncluded == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
    }

    public static func deterministicID(
        requestID: Identifier,
        contractActionID: Identifier,
        operation: ExecutionContractOperation
    ) -> Identifier {
        .constant(
            "gh-1030-binance-testnet-\(operation.rawValue)-action:\(requestID.rawValue):\(contractActionID.rawValue)",
            field: "releaseV0140BinanceTestnetCancelReplace.actionID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetCancelReplace.action.\(field)")
        }
    }
}

/// ReleaseV0140BinanceTestnetCancelReplacePath 汇总 GH-1030 cancel / replace evidence chain。
///
/// 该 path 只证明 local OMS identity、testnet adapter approval、ExecutionContract cancel/replace
/// request 与 redacted action evidence 的链接关系；它不发送网络 cancel / replace。
public struct ReleaseV0140BinanceTestnetCancelReplacePath: Codable, Equatable, Sendable {
    public let pathID: Identifier
    public let boundaryID: Identifier
    public let localOrderID: Identifier
    public let adapterApprovalID: Identifier
    public let cancelRequestID: Identifier
    public let cancelActionID: Identifier
    public let replaceRequestID: Identifier
    public let replaceActionID: Identifier
    public let existingLocalOMSOrderIdentityRequired: Bool
    public let testnetCancelReplaceEvidenceOnly: Bool
    public let networkCancelReplacePerformed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        pathID: Identifier,
        boundary: ReleaseV0140BinanceTestnetAdapterBoundary,
        localOrder: ReleaseV0140LocalOMSOrderIdentity,
        approval: ReleaseV0140BinanceTestnetCancelReplaceAdapterApproval,
        cancelRequest: ReleaseV0140BinanceTestnetCancelReplaceRequestEvidence,
        cancelAction: ReleaseV0140BinanceTestnetCancelReplaceActionEvidence,
        replaceRequest: ReleaseV0140BinanceTestnetCancelReplaceRequestEvidence,
        replaceAction: ReleaseV0140BinanceTestnetCancelReplaceActionEvidence,
        existingLocalOMSOrderIdentityRequired: Bool = true,
        testnetCancelReplaceEvidenceOnly: Bool = true,
        networkCancelReplacePerformed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard boundary.boundaryHeld,
              localOrder.boundaryHeld,
              approval.boundaryHeld,
              cancelRequest.boundaryHeld,
              cancelAction.boundaryHeld,
              replaceRequest.boundaryHeld,
              replaceAction.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetCancelReplace.unheldPathEvidence")
        }
        guard cancelRequest.operation == .cancel,
              cancelAction.operation == .cancel,
              replaceRequest.operation == .replace,
              replaceAction.operation == .replace else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetCancelReplace.pathOperations",
                expected: "cancel request/action and replace request/action",
                actual: "\(cancelRequest.operation.rawValue):\(replaceRequest.operation.rawValue)"
            )
        }
        guard approval.localOrderID == localOrder.localOrderID,
              cancelRequest.localOrderID == localOrder.localOrderID,
              replaceRequest.localOrderID == localOrder.localOrderID,
              cancelAction.requestID == cancelRequest.requestID,
              replaceAction.requestID == replaceRequest.requestID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetCancelReplace.evidenceLinks",
                expected: "linked identity / approval / request / action evidence",
                actual: "unlinked cancel replace evidence"
            )
        }
        guard existingLocalOMSOrderIdentityRequired, testnetCancelReplaceEvidenceOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetCancelReplace.nonEvidencePath")
        }
        try Self.forbid(networkCancelReplacePerformed, "networkCancelReplacePerformed")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetCancelReplace.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard pathID == Self.deterministicID(
            localOrderID: localOrder.localOrderID,
            cancelActionID: cancelAction.actionID,
            replaceActionID: replaceAction.actionID
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0140BinanceTestnetCancelReplace.pathID",
                expected: Self.deterministicID(
                    localOrderID: localOrder.localOrderID,
                    cancelActionID: cancelAction.actionID,
                    replaceActionID: replaceAction.actionID
                ).rawValue,
                actual: pathID.rawValue
            )
        }

        self.pathID = pathID
        self.boundaryID = boundary.boundaryID
        self.localOrderID = localOrder.localOrderID
        self.adapterApprovalID = approval.approvalID
        self.cancelRequestID = cancelRequest.requestID
        self.cancelActionID = cancelAction.actionID
        self.replaceRequestID = replaceRequest.requestID
        self.replaceActionID = replaceAction.actionID
        self.existingLocalOMSOrderIdentityRequired = existingLocalOMSOrderIdentityRequired
        self.testnetCancelReplaceEvidenceOnly = testnetCancelReplaceEvidenceOnly
        self.networkCancelReplacePerformed = networkCancelReplacePerformed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        existingLocalOMSOrderIdentityRequired
            && testnetCancelReplaceEvidenceOnly
            && networkCancelReplacePerformed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredValidationAnchors = [
        "GH-1030-BINANCE-TESTNET-CANCEL-REPLACE-PATH",
        "GH-1030-LOCAL-OMS-ORDER-IDENTITY-REQUIRED",
        "GH-1030-TESTNET-ADAPTER-APPROVAL-REDACTED",
        "TVM-RELEASE-V0140-BINANCE-TESTNET-CANCEL-REPLACE"
    ]

    public static func deterministicID(
        localOrderID: Identifier,
        cancelActionID: Identifier,
        replaceActionID: Identifier
    ) -> Identifier {
        .constant(
            "gh-1030-binance-testnet-cancel-replace-path:\(localOrderID.rawValue):\(cancelActionID.rawValue):\(replaceActionID.rawValue)",
            field: "releaseV0140BinanceTestnetCancelReplace.pathID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0140BinanceTestnetCancelReplace.path.\(field)")
        }
    }
}
