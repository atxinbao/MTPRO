import Crypto
import Foundation

// GH-1546-BUILD-IMMUTABLE-DEMO-VALIDATION-EVIDENCE-BUNDLE
// TVM-RELEASE-V0330-DEMO-VALIDATION-EVIDENCE
// V0330-005-TRUSTED-PROVENANCE-AND-INDEPENDENT-BUNDLE

public struct ReleaseV0330DemoValidationProvenance: Codable, Equatable, Sendable {
    public let repository: String
    public let workflowName: String
    public let runID: Int
    public let runURL: String
    public let artifactName: String
    public let artifactSHA256: String
    public let sourceCommit: String
    public let environment: String
    public let retrievedAtEpochSeconds: Int64

    public init(
        repository: String,
        workflowName: String,
        runID: Int,
        runURL: String,
        artifactName: String,
        artifactSHA256: String,
        sourceCommit: String,
        environment: String = "github-actions",
        retrievedAtEpochSeconds: Int64
    ) throws {
        guard repository == "atxinbao/MTPRO",
              workflowName == "MTPRO v0.33.0 Binance Demo Canary Validation",
              runID > 0,
              runURL == "https://github.com/atxinbao/MTPRO/actions/runs/\(runID)",
              artifactName.contains("demo-evidence-"),
              artifactSHA256.hasPrefix("sha256:"),
              sourceCommit.count == 40,
              sourceCommit.allSatisfy({ $0.isASCII && $0.isHexDigit }),
              environment == "github-actions"
        else {
            throw ReleaseV0330DemoValidationEvidenceBundleError.invalidProvenance
        }
        self.repository = repository
        self.workflowName = workflowName
        self.runID = runID
        self.runURL = runURL
        self.artifactName = artifactName
        self.artifactSHA256 = artifactSHA256
        self.sourceCommit = sourceCommit
        self.environment = environment
        self.retrievedAtEpochSeconds = retrievedAtEpochSeconds
    }
}

public struct ReleaseV0330DemoValidationProductEvidence: Codable, Equatable, Sendable {
    public let product: ReleaseV0330CanaryProduct
    public let runEvidence: ReleaseV0330ObservedCanaryRunEvidence
    public let provenance: ReleaseV0330DemoValidationProvenance

    public init(
        product: ReleaseV0330CanaryProduct,
        runEvidence: ReleaseV0330ObservedCanaryRunEvidence,
        provenance: ReleaseV0330DemoValidationProvenance
    ) throws {
        guard runEvidence.product == product,
              runEvidence.environment == .demo,
              runEvidence.sourceCommit == provenance.sourceCommit,
              runEvidence.observations.map(\.action) == [.submit, .status, .cancel]
        else {
            throw ReleaseV0330DemoValidationEvidenceBundleError.invalidProductEvidence
        }
        self.product = product
        self.runEvidence = runEvidence
        self.provenance = provenance
    }
}

public struct ReleaseV0330DemoValidationEvidenceBundle: Codable, Equatable, Sendable {
    public static let schemaVersion = "v0330-demo-validation-bundle-v1"
    public static let requiredProducts: Set<ReleaseV0330CanaryProduct> = [.spot, .usdsPerpetual]

    public let schemaVersion: String
    public let release: String
    public let environment: ReleaseV0330CanaryEnvironment
    public let sourceCommit: String
    public let products: [ReleaseV0330DemoValidationProductEvidence]
    public let createdAtEpochSeconds: Int64
    public let productionCutoverAuthorized: Bool
    public let defaultProductionTradingEnabled: Bool

    public init(
        sourceCommit: String,
        products: [ReleaseV0330DemoValidationProductEvidence],
        createdAtEpochSeconds: Int64,
        productionCutoverAuthorized: Bool = false,
        defaultProductionTradingEnabled: Bool = false
    ) throws {
        guard sourceCommit.count == 40,
              products.count == Self.requiredProducts.count,
              Set(products.map(\.product)) == Self.requiredProducts,
              products.allSatisfy({ $0.provenance.sourceCommit == sourceCommit })
        else {
            throw ReleaseV0330DemoValidationEvidenceBundleError.invalidBundle
        }
        self.schemaVersion = Self.schemaVersion
        self.release = "v0.33.0"
        self.environment = .demo
        self.sourceCommit = sourceCommit
        self.products = products
        self.createdAtEpochSeconds = createdAtEpochSeconds
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.defaultProductionTradingEnabled = defaultProductionTradingEnabled
    }

    public var boundaryHeld: Bool {
        release == "v0.33.0"
            && schemaVersion == Self.schemaVersion
            && environment == .demo
            && products.count == 2
            && Set(products.map(\.product)) == Self.requiredProducts
            && products.allSatisfy { productEvidence in
                let evidence = productEvidence.runEvidence
                let expectedHost = environment.endpointHost(for: productEvidence.product)
                return evidence.sourceCommit == sourceCommit
                    && evidence.environment == .demo
                    && evidence.observations.map(\.action) == [.submit, .status, .cancel]
                    && evidence.observations.allSatisfy {
                        $0.endpointHost == expectedHost
                            && $0.rawSecretPersisted == false
                            && $0.rawResponsePersisted == false
                    }
                    && evidence.runLockReleased
                    && evidence.productionCutoverAuthorized == false
                    && evidence.defaultProductionTradingEnabled == false
                    && productEvidence.provenance.sourceCommit == sourceCommit
            }
            && productionCutoverAuthorized == false
            && defaultProductionTradingEnabled == false
    }

    public func canonicalSHA256() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return "sha256:" + SHA256.hash(data: try encoder.encode(self))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}

public enum ReleaseV0330DemoValidationEvidenceBundleError: Error, Equatable, Sendable {
    case invalidProvenance
    case invalidProductEvidence
    case invalidBundle
}

// GH-1547-ADD-DEMO-VALIDATION-DECISION-ENGINE
// TVM-RELEASE-V0330-DEMO-VALIDATION-DECISION
// V0330-006-FAIL-CLOSED-DEMO-DECISION
public enum ReleaseV0330DemoValidationDecision: String, Codable, Sendable {
    case accepted
    case blocked
}

public struct ReleaseV0330DemoValidationDecisionReport: Codable, Equatable, Sendable {
    /// Human 已确认 Binance Demo Network 与生产网络共享订单传输语义时，
    /// Demo 双产品证据可以关闭后端功能建设，但不会转换成生产切换授权。
    public static let acceptedDemoNetworkParityBackendClosure =
        "accepted-demo-network-parity"
    /// 缺失或无效证据必须继续阻断后端收口，避免把不完整夹具解释为已验收结果。
    public static let blockedBackendClosure = "blocked"

    public let decision: ReleaseV0330DemoValidationDecision
    public let reasons: [String]
    public let bundleSHA256: String?
    public let backendClosureDecision: String
    public let productionCutoverAuthorized: Bool
    public let defaultProductionTradingEnabled: Bool

    /// 同时校验验收结论和生产安全边界，保证后端收口不会隐式打开生产交易。
    public var boundaryHeld: Bool {
        backendClosureDecision
            == (
                decision == .accepted
                    ? Self.acceptedDemoNetworkParityBackendClosure
                    : Self.blockedBackendClosure
            )
            && productionCutoverAuthorized == false
            && defaultProductionTradingEnabled == false
            && (decision == .accepted ? reasons.isEmpty : reasons.isEmpty == false)
    }
}

public enum ReleaseV0330DemoValidationDecisionEngine {
    public static func evaluate(
        bundle: ReleaseV0330DemoValidationEvidenceBundle?
    ) -> ReleaseV0330DemoValidationDecisionReport {
        guard let bundle else {
            return blocked(["missing-demo-validation-bundle"])
        }
        guard bundle.boundaryHeld else {
            return blocked(["demo-validation-bundle-boundary-failed"])
        }
        let checksum = try? bundle.canonicalSHA256()
        return ReleaseV0330DemoValidationDecisionReport(
            decision: .accepted,
            reasons: [],
            bundleSHA256: checksum,
            backendClosureDecision:
                ReleaseV0330DemoValidationDecisionReport
                    .acceptedDemoNetworkParityBackendClosure,
            productionCutoverAuthorized: false,
            defaultProductionTradingEnabled: false
        )
    }

    private static func blocked(_ reasons: [String]) -> ReleaseV0330DemoValidationDecisionReport {
        ReleaseV0330DemoValidationDecisionReport(
            decision: .blocked,
            reasons: reasons,
            bundleSHA256: nil,
            backendClosureDecision:
                ReleaseV0330DemoValidationDecisionReport.blockedBackendClosure,
            productionCutoverAuthorized: false,
            defaultProductionTradingEnabled: false
        )
    }
}
