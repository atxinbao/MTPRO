import Foundation
import Core

/// LiveReadOnlyDashboardBoundaryReadModel 是 MTP-131 的 App 层只读输入。
///
/// 输入只能来自 Core `LiveReadOnlyDashboardReadModelBoundary` deterministic fixture 或等价只读模型。
/// App 层只保留 source contract、边界枚举和禁止能力 flags，不读取 secret、不调用 signed / account
/// endpoint、不连接 broker，也不触碰 Runtime、Persistence schema 或真实交易系统。
public struct LiveReadOnlyDashboardBoundaryReadModel: Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let boundary: Core.LiveReadOnlyDashboardReadModelBoundary
    public let lastAppliedSequence: Int?

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        boundary: Core.LiveReadOnlyDashboardReadModelBoundary = .dashboardDeterministicFixture,
        lastAppliedSequence: Int? = nil
    ) {
        self.source = source
        self.boundary = boundary
        self.lastAppliedSequence = lastAppliedSequence
    }

    public var readModelOnlyBoundaryHeld: Bool {
        source.isReadModelOnly
            && boundary.dashboardReadModelOnlyBoundaryHeld
    }
}

/// LiveReadOnlyDashboardBoundaryViewModel 是 Dashboard / Report / Event Timeline 的 MTP-131 快照。
///
/// ViewModel 只输出 boundary surfaces、ReadModel / ViewModel 输入来源、detail / audit route 和
/// forbidden UI flags。它不提供 API key 输入、连接按钮、Live PRO Console、交易按钮、order form、
/// live command、adapter、Runtime、schema、signed/account endpoint 或真实订单授权。
public struct LiveReadOnlyDashboardBoundaryViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let contractID: String
    public let issueID: String
    public let matrixID: String
    public let boundarySurfaceLabels: [String]
    public let inputBoundaryLabels: [String]
    public let forbiddenUISurfaceLabels: [String]
    public let detailAuditRouteLabels: [String]
    public let handoffTargetLabels: [String]
    public let evidenceKindLabels: [String]
    public let sourceAnchors: [String]
    public let validationAnchors: [String]
    public let boundarySurfaceCount: Int
    public let inputBoundaryCount: Int
    public let forbiddenUISurfaceCount: Int
    public let detailAuditRouteCount: Int
    public let handoffTargetCount: Int
    public let consumesOnlyReadModelViewModel: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let exposesAPIKeyInput: Bool
    public let storesSecret: Bool
    public let providesBrokerConnect: Bool
    public let providesAccountConnect: Bool
    public let exposesLivePROConsole: Bool
    public let providesTradingButton: Bool
    public let providesLiveCommand: Bool
    public let exposesOrderForm: Bool
    public let exposesRealAccountBalance: Bool
    public let exposesBrokerPosition: Bool
    public let exposesRuntimeObject: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesAdapterSurface: Bool
    public let providesCommandSurface: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let instantiatesBrokerAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderLifecycle: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let authorizesLiveTrading: Bool
    public let authorizesTradingExecution: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let lastAppliedSequence: Int?

    public init(readModel: LiveReadOnlyDashboardBoundaryReadModel) {
        let source = readModel.source
        let boundary = readModel.boundary
        let exposesRuntimeObject = source.exposesRuntimeObjects
            || boundary.exposesRuntimeObject
        let exposesDatabaseSchema = source.exposesDatabaseTables
            || source.exposesORMModels
            || boundary.exposesDatabaseSchema
        let exposesAdapterSurface = source.callsBinanceAdapter
            || boundary.instantiatesBrokerAdapter
            || boundary.providesBrokerConnect
        let providesCommandSurface = source.providesLiveOrderAction
            || boundary.providesBrokerConnect
            || boundary.providesAccountConnect
            || boundary.providesLiveCommand
            || boundary.exposesOrderForm
            || boundary.providesTradingButton
            || boundary.submitsRealOrder
            || boundary.cancelsRealOrder
            || boundary.replacesRealOrder
        let authorizesLiveTrading = source.providesLiveOrderAction
            || providesCommandSurface
            || boundary.implementsRealOrderLifecycle
        let authorizesTradingExecution = authorizesLiveTrading
            || boundary.submitsRealOrder
            || boundary.cancelsRealOrder
            || boundary.replacesRealOrder

        self.source = source
        self.contractID = boundary.contractID.rawValue
        self.issueID = boundary.issueID.rawValue
        self.matrixID = boundary.matrixID
        self.boundarySurfaceLabels = boundary.boundarySurfaces.map(\.rawValue)
        self.inputBoundaryLabels = boundary.inputBoundaries.map(\.rawValue)
        self.forbiddenUISurfaceLabels = boundary.forbiddenUISurfaces.map(\.rawValue)
        self.detailAuditRouteLabels = boundary.detailAuditRoutes.map(\.rawValue)
        self.handoffTargetLabels = boundary.handoffTargets.map(\.rawValue)
        self.evidenceKindLabels = boundary.allowedEvidenceKinds.map(\.rawValue)
        self.sourceAnchors = boundary.sourceAnchors
        self.validationAnchors = boundary.validationAnchors
        self.boundarySurfaceCount = boundary.boundarySurfaces.count
        self.inputBoundaryCount = boundary.inputBoundaries.count
        self.forbiddenUISurfaceCount = boundary.forbiddenUISurfaces.count
        self.detailAuditRouteCount = boundary.detailAuditRoutes.count
        self.handoffTargetCount = boundary.handoffTargets.count
        self.consumesOnlyReadModelViewModel = boundary.consumesOnlyReadModelViewModel
        self.exposesAPIKeyInput = boundary.exposesAPIKeyInput
        self.storesSecret = boundary.storesSecret
        self.providesBrokerConnect = boundary.providesBrokerConnect
        self.providesAccountConnect = boundary.providesAccountConnect
        self.exposesLivePROConsole = boundary.exposesLivePROConsole
        self.providesTradingButton = boundary.providesTradingButton
        self.providesLiveCommand = boundary.providesLiveCommand
        self.exposesOrderForm = boundary.exposesOrderForm
        self.exposesRealAccountBalance = boundary.exposesRealAccountBalance
        self.exposesBrokerPosition = boundary.exposesBrokerPosition
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.exposesAdapterSurface = exposesAdapterSurface
        self.providesCommandSurface = providesCommandSurface
        self.callsSignedEndpoint = boundary.callsSignedEndpoint
        self.callsAccountEndpoint = boundary.callsAccountEndpoint
        self.createsListenKey = boundary.createsListenKey
        self.instantiatesBrokerAdapter = boundary.instantiatesBrokerAdapter
        self.implementsLiveExecutionAdapter = boundary.implementsLiveExecutionAdapter
        self.implementsOMS = boundary.implementsOMS
        self.implementsRealOrderLifecycle = boundary.implementsRealOrderLifecycle
        self.submitsRealOrder = boundary.submitsRealOrder
        self.cancelsRealOrder = boundary.cancelsRealOrder
        self.replacesRealOrder = boundary.replacesRealOrder
        self.authorizesLiveTrading = authorizesLiveTrading
        self.authorizesTradingExecution = authorizesTradingExecution
        self.requiredValidationDependsOnNetwork = boundary.requiredValidationDependsOnNetwork
        self.readModelOnlyBoundaryHeld = readModel.readModelOnlyBoundaryHeld
            && consumesOnlyReadModelViewModel
            && exposesAPIKeyInput == false
            && storesSecret == false
            && providesBrokerConnect == false
            && providesAccountConnect == false
            && exposesLivePROConsole == false
            && providesTradingButton == false
            && providesLiveCommand == false
            && exposesOrderForm == false
            && exposesRealAccountBalance == false
            && exposesBrokerPosition == false
            && exposesRuntimeObject == false
            && exposesDatabaseSchema == false
            && exposesAdapterSurface == false
            && providesCommandSurface == false
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && instantiatesBrokerAdapter == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderLifecycle == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && authorizesLiveTrading == false
            && authorizesTradingExecution == false
            && requiredValidationDependsOnNetwork == false
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}
