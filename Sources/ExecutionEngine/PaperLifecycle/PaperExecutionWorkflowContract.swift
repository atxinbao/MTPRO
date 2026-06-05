import DomainModel
import Foundation

/// Paper execution workflow contract 定义 MTP-38 的本地 paper-only 执行链路边界。
///
/// 该文件只描述 proposal、risk decision、paper execution decision、paper order、
/// simulated fill 和 portfolio projection 之间的阶段顺序、event stream 和禁止能力。
/// 它不是订单生命周期、撮合器、OMS、broker adapter 或 Live execution 入口；后续 issue
/// 只能在这些边界内补充本地 paper-only 模型，不能引入 signed endpoint、account endpoint、
/// 真实订单提交 / 取消 / 替换或 broker action。

/// PaperExecutionWorkflowStage 是 paper-only workflow 的阶段顺序合同。
///
/// 阶段名只表示本地 evidence chain 的逻辑位置，不代表真实交易系统状态或 broker order state。
public enum PaperExecutionWorkflowStage: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case proposal
    case riskDecision
    case paperExecutionDecision
    case paperOrder
    case simulatedFill
    case portfolioProjection
}

/// PaperExecutionWorkflowEvidenceKind 标记每个阶段允许使用的 evidence 类型。
///
/// 已存在的类型可以直接指向 Core 模型；后续 issue 的类型先作为合同占位，确保实现前已有
/// 明确事件边界和交易能力禁区。
public enum PaperExecutionWorkflowEvidenceKind: String, Codable, Equatable, Sendable {
    case paperActionProposal
    case paperActionProposalRiskDecision
    case paperExecutionDecision
    case paperOrder
    case simulatedFill
    case paperPortfolioProjectionUpdate
}

/// PaperExecutionWorkflowStageBoundary 描述单个阶段的输入、输出、event stream 和能力禁区。
///
/// `implementedInCurrentCode` 只说明当前仓库是否已有可复用 Core evidence 模型；为 `false`
/// 的阶段只能由后续 Linear issue 在本合同内补充。所有 capability flag 必须为 `false`，
/// Codable 解码也会拒绝任何试图恢复真实交易、broker、signed endpoint 或真实订单语义的 payload。
public struct PaperExecutionWorkflowStageBoundary: Codable, Equatable, Sendable {
    public let stage: PaperExecutionWorkflowStage
    public let consumes: PaperExecutionWorkflowStage?
    public let produces: PaperExecutionWorkflowStage?
    public let eventStream: EventStreamID
    public let evidenceKind: PaperExecutionWorkflowEvidenceKind
    public let implementedInCurrentCode: Bool
    public let futureIssueID: Identifier?
    public let authorizesTradingExecution: Bool
    public let authorizesLiveTrading: Bool
    public let touchesSignedEndpoint: Bool
    public let touchesBrokerAction: Bool
    public let representsRealOrder: Bool

    public var paperOnlyBoundaryHeld: Bool {
        authorizesTradingExecution == false
            && authorizesLiveTrading == false
            && touchesSignedEndpoint == false
            && touchesBrokerAction == false
            && representsRealOrder == false
    }

    public init(
        stage: PaperExecutionWorkflowStage,
        consumes: PaperExecutionWorkflowStage?,
        produces: PaperExecutionWorkflowStage?,
        eventStream: EventStreamID,
        evidenceKind: PaperExecutionWorkflowEvidenceKind,
        implementedInCurrentCode: Bool,
        futureIssueID: Identifier? = nil,
        authorizesTradingExecution: Bool = false,
        authorizesLiveTrading: Bool = false,
        touchesSignedEndpoint: Bool = false,
        touchesBrokerAction: Bool = false,
        representsRealOrder: Bool = false
    ) throws {
        guard authorizesTradingExecution == false else {
            throw CoreError.paperExecutionWorkflowForbiddenCapability("authorizesTradingExecution")
        }
        guard authorizesLiveTrading == false else {
            throw CoreError.paperExecutionWorkflowForbiddenCapability("authorizesLiveTrading")
        }
        guard touchesSignedEndpoint == false else {
            throw CoreError.paperExecutionWorkflowForbiddenCapability("touchesSignedEndpoint")
        }
        guard touchesBrokerAction == false else {
            throw CoreError.paperExecutionWorkflowForbiddenCapability("touchesBrokerAction")
        }
        guard representsRealOrder == false else {
            throw CoreError.paperExecutionWorkflowForbiddenCapability("representsRealOrder")
        }
        if implementedInCurrentCode == false, futureIssueID == nil {
            throw CoreError.paperExecutionWorkflowContractMismatch(
                field: "\(stage.rawValue).futureIssueID",
                expected: "future issue id for unimplemented stage",
                actual: "nil"
            )
        }

        self.stage = stage
        self.consumes = consumes
        self.produces = produces
        self.eventStream = eventStream
        self.evidenceKind = evidenceKind
        self.implementedInCurrentCode = implementedInCurrentCode
        self.futureIssueID = futureIssueID
        self.authorizesTradingExecution = authorizesTradingExecution
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesSignedEndpoint = touchesSignedEndpoint
        self.touchesBrokerAction = touchesBrokerAction
        self.representsRealOrder = representsRealOrder
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            stage: try container.decode(PaperExecutionWorkflowStage.self, forKey: .stage),
            consumes: try container.decodeIfPresent(PaperExecutionWorkflowStage.self, forKey: .consumes),
            produces: try container.decodeIfPresent(PaperExecutionWorkflowStage.self, forKey: .produces),
            eventStream: try container.decode(EventStreamID.self, forKey: .eventStream),
            evidenceKind: try container.decode(PaperExecutionWorkflowEvidenceKind.self, forKey: .evidenceKind),
            implementedInCurrentCode: try container.decode(Bool.self, forKey: .implementedInCurrentCode),
            futureIssueID: try container.decodeIfPresent(Identifier.self, forKey: .futureIssueID),
            authorizesTradingExecution: try container.decode(
                Bool.self,
                forKey: .authorizesTradingExecution
            ),
            authorizesLiveTrading: try container.decode(Bool.self, forKey: .authorizesLiveTrading),
            touchesSignedEndpoint: try container.decode(Bool.self, forKey: .touchesSignedEndpoint),
            touchesBrokerAction: try container.decode(Bool.self, forKey: .touchesBrokerAction),
            representsRealOrder: try container.decode(Bool.self, forKey: .representsRealOrder)
        )
    }
}

/// PaperExecutionWorkflowContract 汇总 MTP-38 的完整阶段顺序和 event boundary。
///
/// 合同要求阶段顺序必须与 `PaperExecutionWorkflowStage.allCases` 完全一致，避免后续 issue
/// 越过 proposal / risk decision / paper execution decision 的边界直接生成 order、fill 或
/// portfolio projection。该合同不写 event log、不运行 workflow，只提供 deterministic validation
/// fixture 和文档化的 Core 边界。
public struct PaperExecutionWorkflowContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let stageBoundaries: [PaperExecutionWorkflowStageBoundary]

    public var stageOrder: [PaperExecutionWorkflowStage] {
        stageBoundaries.map(\.stage)
    }

    public var paperOnlyBoundaryHeld: Bool {
        stageBoundaries.allSatisfy(\.paperOnlyBoundaryHeld)
    }

    public init(
        contractID: Identifier,
        issueID: Identifier,
        stageBoundaries: [PaperExecutionWorkflowStageBoundary]
    ) throws {
        try Self.validateStageOrder(stageBoundaries)

        self.contractID = contractID
        self.issueID = issueID
        self.stageBoundaries = stageBoundaries
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            stageBoundaries: try container.decode(
                [PaperExecutionWorkflowStageBoundary].self,
                forKey: .stageBoundaries
            )
        )
    }

    public func boundary(for stage: PaperExecutionWorkflowStage) -> PaperExecutionWorkflowStageBoundary? {
        stageBoundaries.first { $0.stage == stage }
    }

    /// MTP-38 deterministic fixture 固定 stage order、stream、future issue 和 paper-only 禁区。
    public static let deterministicFixture: PaperExecutionWorkflowContract = {
        do {
            return try PaperExecutionWorkflowContract(
                contractID: try Identifier("mtp-38-paper-execution-workflow-contract"),
                issueID: try Identifier("MTP-38"),
                stageBoundaries: [
                    PaperExecutionWorkflowStageBoundary(
                        stage: .proposal,
                        consumes: nil,
                        produces: .riskDecision,
                        eventStream: .paper,
                        evidenceKind: .paperActionProposal,
                        implementedInCurrentCode: true
                    ),
                    PaperExecutionWorkflowStageBoundary(
                        stage: .riskDecision,
                        consumes: .proposal,
                        produces: .paperExecutionDecision,
                        eventStream: .risk,
                        evidenceKind: .paperActionProposalRiskDecision,
                        implementedInCurrentCode: true
                    ),
                    PaperExecutionWorkflowStageBoundary(
                        stage: .paperExecutionDecision,
                        consumes: .riskDecision,
                        produces: .paperOrder,
                        eventStream: .paper,
                        evidenceKind: .paperExecutionDecision,
                        implementedInCurrentCode: true
                    ),
                    PaperExecutionWorkflowStageBoundary(
                        stage: .paperOrder,
                        consumes: .paperExecutionDecision,
                        produces: .simulatedFill,
                        eventStream: .paper,
                        evidenceKind: .paperOrder,
                        implementedInCurrentCode: true
                    ),
                    PaperExecutionWorkflowStageBoundary(
                        stage: .simulatedFill,
                        consumes: .paperOrder,
                        produces: .portfolioProjection,
                        eventStream: .paper,
                        evidenceKind: .simulatedFill,
                        implementedInCurrentCode: true
                    ),
                    PaperExecutionWorkflowStageBoundary(
                        stage: .portfolioProjection,
                        consumes: .simulatedFill,
                        produces: nil,
                        eventStream: .portfolio,
                        evidenceKind: .paperPortfolioProjectionUpdate,
                        implementedInCurrentCode: true
                    )
                ]
            )
        } catch {
            preconditionFailure("Invalid deterministic paper execution workflow fixture: \(error)")
        }
    }()

    private static func validateStageOrder(_ stageBoundaries: [PaperExecutionWorkflowStageBoundary]) throws {
        let expected = PaperExecutionWorkflowStage.allCases
        let actual = stageBoundaries.map(\.stage)
        guard actual == expected else {
            throw CoreError.paperExecutionWorkflowContractMismatch(
                field: "stageOrder",
                expected: expected.map(\.rawValue).joined(separator: ","),
                actual: actual.map(\.rawValue).joined(separator: ",")
            )
        }
        try validateStageTransitions(stageBoundaries)
    }

    private static func validateStageTransitions(_ stageBoundaries: [PaperExecutionWorkflowStageBoundary]) throws {
        let stages = PaperExecutionWorkflowStage.allCases
        for (index, boundary) in stageBoundaries.enumerated() {
            let expectedConsumes: PaperExecutionWorkflowStage? = index == 0 ? nil : stages[index - 1]
            let expectedProduces: PaperExecutionWorkflowStage? = index == stages.count - 1 ? nil : stages[index + 1]
            guard boundary.consumes == expectedConsumes else {
                throw CoreError.paperExecutionWorkflowContractMismatch(
                    field: "\(boundary.stage.rawValue).consumes",
                    expected: expectedConsumes?.rawValue ?? "nil",
                    actual: boundary.consumes?.rawValue ?? "nil"
                )
            }
            guard boundary.produces == expectedProduces else {
                throw CoreError.paperExecutionWorkflowContractMismatch(
                    field: "\(boundary.stage.rawValue).produces",
                    expected: expectedProduces?.rawValue ?? "nil",
                    actual: boundary.produces?.rawValue ?? "nil"
                )
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case contractID
        case issueID
        case stageBoundaries
    }
}
