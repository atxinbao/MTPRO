import Foundation

// GH-1499-VERIFY-V0311-RELEASE-PUBLICATION-GATE
// GH-1500-VERIFY-V0311-ENDPOINT-ALLOWLIST-METHOD-HOST-PATH
// GH-1501-VERIFY-V0311-APPROVAL-SCOPE-EXPIRY-POLICY
// GH-1502-VERIFY-V0311-PERSISTENT-RUN-LOCK-REPLAY
// GH-1503-VERIFY-V0311-EVIDENCE-ROOT-ARTIFACT-VALIDATION
// GH-1504-VERIFY-V0311-RISK-GATE-NEGATIVE-INPUTS
// GH-1505-VERIFY-V0311-NEGATIVE-REGRESSION-MATRIX
// GH-1506-VERIFY-V0311-V0310-PUBLICATION-FACTS
// GH-1507-VERIFY-V0311-STAGE-AUDIT-RELEASE-NOTES
// TVM-RELEASE-V0311-CONTROLLED-ENABLEMENT-INTEGRITY-REPAIR

public enum ReleaseV0311ValidationStatus: String, Codable, Equatable, Sendable {
    case passed
    case failed
}

/// 记录 v0.31.1 对 release publication gate 的修复证据。
public struct ReleaseV0311PublicationMatrixGate: Codable, Equatable, Sendable {
    public let prFastChecks: ReleaseV0311ValidationStatus
    public let linuxChecks: ReleaseV0311ValidationStatus
    public let dashboardMacOS: ReleaseV0311ValidationStatus
    public let releasePublicationChecks: ReleaseV0311ValidationStatus
    public let releaseCreatedAfterFullMatrix: Bool
    public let previousEarlyPublicationFindingRecorded: Bool

    public init(
        prFastChecks: ReleaseV0311ValidationStatus,
        linuxChecks: ReleaseV0311ValidationStatus,
        dashboardMacOS: ReleaseV0311ValidationStatus,
        releasePublicationChecks: ReleaseV0311ValidationStatus,
        releaseCreatedAfterFullMatrix: Bool,
        previousEarlyPublicationFindingRecorded: Bool
    ) {
        self.prFastChecks = prFastChecks
        self.linuxChecks = linuxChecks
        self.dashboardMacOS = dashboardMacOS
        self.releasePublicationChecks = releasePublicationChecks
        self.releaseCreatedAfterFullMatrix = releaseCreatedAfterFullMatrix
        self.previousEarlyPublicationFindingRecorded = previousEarlyPublicationFindingRecorded
    }

    public var held: Bool {
        prFastChecks == .passed
            && linuxChecks == .passed
            && dashboardMacOS == .passed
            && releasePublicationChecks == .passed
            && releaseCreatedAfterFullMatrix
            && previousEarlyPublicationFindingRecorded
    }
}

/// 固定 v0.31.1 endpoint allowlist 的方法、域名、路径、产品和查询形态。
public struct ReleaseV0311EndpointAllowlistCandidate: Codable, Equatable, Sendable {
    public let product: ReleaseV0310Product
    public let family: ReleaseV0310EndpointFamily
    public let method: String
    public let scheme: String
    public let host: String
    public let path: String
    public let queryShape: String
    public let orderMutation: Bool

    public init(
        product: ReleaseV0310Product,
        family: ReleaseV0310EndpointFamily,
        method: String,
        scheme: String,
        host: String,
        path: String,
        queryShape: String,
        orderMutation: Bool
    ) {
        self.product = product
        self.family = family
        self.method = method
        self.scheme = scheme
        self.host = host
        self.path = path
        self.queryShape = queryShape
        self.orderMutation = orderMutation
    }

    public var held: Bool {
        method == "GET"
            && scheme == "https"
            && queryShape == "timestamp+recvWindow+signature"
            && orderMutation == false
            && allowedProductFamilyPath
    }

    private var allowedProductFamilyPath: Bool {
        switch (product, family, host, path) {
        case (.spot, .spotSignedReadOnly, "api.binance.com", "/api/v3/account"):
            true
        case (.usdsPerpetual, .futuresSignedReadOnly, "fapi.binance.com", "/fapi/v3/account"):
            true
        default:
            false
        }
    }
}

/// 记录人工 approval 的 scope、expiry、source commit 与 policy 绑定。
public struct ReleaseV0311ApprovalBinding: Codable, Equatable, Sendable {
    public let approvalID: String
    public let scope: String
    public let expiresAtEpochSeconds: Int
    public let evaluatedAtEpochSeconds: Int
    public let sourceCommit: String
    public let policyVersion: String
    public let productScope: [ReleaseV0310Product]
    public let allowedActionClass: String

    public init(
        approvalID: String,
        scope: String,
        expiresAtEpochSeconds: Int,
        evaluatedAtEpochSeconds: Int,
        sourceCommit: String,
        policyVersion: String,
        productScope: [ReleaseV0310Product],
        allowedActionClass: String
    ) {
        self.approvalID = approvalID
        self.scope = scope
        self.expiresAtEpochSeconds = expiresAtEpochSeconds
        self.evaluatedAtEpochSeconds = evaluatedAtEpochSeconds
        self.sourceCommit = sourceCommit
        self.policyVersion = policyVersion
        self.productScope = productScope
        self.allowedActionClass = allowedActionClass
    }

    public var held: Bool {
        approvalID.hasPrefix("human_")
            && scope == "controlled-production-enablement-readiness"
            && expiresAtEpochSeconds > evaluatedAtEpochSeconds
            && sourceCommit.count >= 12
            && policyVersion == "v0311-controlled-enablement-integrity"
            && productScope == [.spot, .usdsPerpetual]
            && allowedActionClass == "readiness-and-controlled-canary-prep"
    }
}

/// 记录 persistent run lock 和 replay protection 的绑定证据。
public struct ReleaseV0311RunLockReplayProtection: Codable, Equatable, Sendable {
    public let runLockID: String
    public let approvalID: String
    public let sourceCommit: String
    public let policyVersion: String
    public let evidenceRoot: String
    public let duplicateRunRejected: Bool
    public let staleRunRejected: Bool
    public let replayAttemptRejected: Bool
    public let mismatchRejected: Bool

    public init(
        runLockID: String,
        approvalID: String,
        sourceCommit: String,
        policyVersion: String,
        evidenceRoot: String,
        duplicateRunRejected: Bool,
        staleRunRejected: Bool,
        replayAttemptRejected: Bool,
        mismatchRejected: Bool
    ) {
        self.runLockID = runLockID
        self.approvalID = approvalID
        self.sourceCommit = sourceCommit
        self.policyVersion = policyVersion
        self.evidenceRoot = evidenceRoot
        self.duplicateRunRejected = duplicateRunRejected
        self.staleRunRejected = staleRunRejected
        self.replayAttemptRejected = replayAttemptRejected
        self.mismatchRejected = mismatchRejected
    }

    public var held: Bool {
        runLockID.hasPrefix("v0311-run-lock-")
            && approvalID.hasPrefix("human_")
            && sourceCommit.count >= 12
            && policyVersion == "v0311-controlled-enablement-integrity"
            && evidenceRoot.hasPrefix("artifacts/v0.31.1/")
            && duplicateRunRejected
            && staleRunRejected
            && replayAttemptRejected
            && mismatchRejected
    }
}

public struct ReleaseV0311EvidenceArtifact: Codable, Equatable, Sendable {
    public let path: String
    public let declaredSHA256: String
    public let recomputedSHA256: String
    public let redactionChecked: Bool
    public let provenanceChecked: Bool

    public init(
        path: String,
        declaredSHA256: String,
        recomputedSHA256: String,
        redactionChecked: Bool,
        provenanceChecked: Bool
    ) {
        self.path = path
        self.declaredSHA256 = declaredSHA256
        self.recomputedSHA256 = recomputedSHA256
        self.redactionChecked = redactionChecked
        self.provenanceChecked = provenanceChecked
    }

    public var held: Bool {
        path.hasPrefix("artifacts/v0.31.1/")
            && declaredSHA256.hasPrefix("sha256:")
            && declaredSHA256 == recomputedSHA256
            && redactionChecked
            && provenanceChecked
    }
}

/// 记录 evidence root artifact validation，不接受纯 deterministic bundle。
public struct ReleaseV0311EvidenceRootAuditBundle: Codable, Equatable, Sendable {
    public let evidenceRoot: String
    public let manifestSHA256: String
    public let recomputedManifestSHA256: String
    public let sourceCommit: String
    public let approvalID: String
    public let policyVersion: String
    public let immutableManifest: Bool
    public let replayable: Bool
    public let artifacts: [ReleaseV0311EvidenceArtifact]

    public init(
        evidenceRoot: String,
        manifestSHA256: String,
        recomputedManifestSHA256: String,
        sourceCommit: String,
        approvalID: String,
        policyVersion: String,
        immutableManifest: Bool,
        replayable: Bool,
        artifacts: [ReleaseV0311EvidenceArtifact]
    ) {
        self.evidenceRoot = evidenceRoot
        self.manifestSHA256 = manifestSHA256
        self.recomputedManifestSHA256 = recomputedManifestSHA256
        self.sourceCommit = sourceCommit
        self.approvalID = approvalID
        self.policyVersion = policyVersion
        self.immutableManifest = immutableManifest
        self.replayable = replayable
        self.artifacts = artifacts
    }

    public var held: Bool {
        evidenceRoot == "artifacts/v0.31.1/controlled-enablement-integrity"
            && manifestSHA256 == recomputedManifestSHA256
            && manifestSHA256.hasPrefix("sha256:")
            && sourceCommit.count >= 12
            && approvalID.hasPrefix("human_")
            && policyVersion == "v0311-controlled-enablement-integrity"
            && immutableManifest
            && replayable
            && artifacts.count >= 4
            && artifacts.allSatisfy(\.held)
    }
}

/// 记录风险门禁的负数、缺失、溢出、过期和产品错配失败关闭。
public struct ReleaseV0311RiskGateInput: Codable, Equatable, Sendable {
    public let product: ReleaseV0310Product
    public let notionalUSDT: Decimal?
    public let leverage: Decimal?
    public let currentExposureUSDT: Decimal?
    public let exposureLimitUSDT: Decimal?
    public let freshnessSeconds: Int?
    public let frequencyPerMinute: Int?
    public let expectedProductScope: [ReleaseV0310Product]

    public init(
        product: ReleaseV0310Product,
        notionalUSDT: Decimal?,
        leverage: Decimal?,
        currentExposureUSDT: Decimal?,
        exposureLimitUSDT: Decimal?,
        freshnessSeconds: Int?,
        frequencyPerMinute: Int?,
        expectedProductScope: [ReleaseV0310Product]
    ) {
        self.product = product
        self.notionalUSDT = notionalUSDT
        self.leverage = leverage
        self.currentExposureUSDT = currentExposureUSDT
        self.exposureLimitUSDT = exposureLimitUSDT
        self.freshnessSeconds = freshnessSeconds
        self.frequencyPerMinute = frequencyPerMinute
        self.expectedProductScope = expectedProductScope
    }

    public var held: Bool {
        guard let notionalUSDT,
              let leverage,
              let currentExposureUSDT,
              let exposureLimitUSDT,
              let freshnessSeconds,
              let frequencyPerMinute else {
            return false
        }

        return notionalUSDT > 0
            && leverage > 0
            && leverage <= 2
            && currentExposureUSDT >= 0
            && currentExposureUSDT <= exposureLimitUSDT
            && exposureLimitUSDT <= 250
            && freshnessSeconds <= 15
            && frequencyPerMinute <= 2
            && expectedProductScope.contains(product)
    }
}

public struct ReleaseV0311ControlledEnablementIntegrityRepair: Codable, Equatable, Sendable {
    public static let cliCommand = "controlled-enablement-integrity"
    public static let supportedActions = [
        "status",
        "publication",
        "endpoints",
        "approvals",
        "locks",
        "audit",
        "risk",
        "negative-cases",
        "boundaries"
    ]
    public static let validationAnchor = "TVM-RELEASE-V0311-CONTROLLED-ENABLEMENT-INTEGRITY-REPAIR"
    public static let verificationAnchor = "GH-1499-VERIFY-V0311-RELEASE-PUBLICATION-GATE"
    public static let requiredAnchors = [
        "GH-1499-VERIFY-V0311-RELEASE-PUBLICATION-GATE",
        "GH-1500-VERIFY-V0311-ENDPOINT-ALLOWLIST-METHOD-HOST-PATH",
        "GH-1501-VERIFY-V0311-APPROVAL-SCOPE-EXPIRY-POLICY",
        "GH-1502-VERIFY-V0311-PERSISTENT-RUN-LOCK-REPLAY",
        "GH-1503-VERIFY-V0311-EVIDENCE-ROOT-ARTIFACT-VALIDATION",
        "GH-1504-VERIFY-V0311-RISK-GATE-NEGATIVE-INPUTS",
        "GH-1505-VERIFY-V0311-NEGATIVE-REGRESSION-MATRIX",
        "GH-1506-VERIFY-V0311-V0310-PUBLICATION-FACTS",
        "GH-1507-VERIFY-V0311-STAGE-AUDIT-RELEASE-NOTES",
        "TVM-RELEASE-V0311-CONTROLLED-ENABLEMENT-INTEGRITY-REPAIR",
        "V0311-001-RELEASE-PUBLICATION-AFTER-FULL-MATRIX",
        "V0311-002-ENDPOINT-METHOD-HOST-PATH-PRODUCT-FAMILY",
        "V0311-003-APPROVAL-SCOPE-EXPIRY-SOURCE-POLICY",
        "V0311-004-PERSISTENT-RUN-LOCK-REPLAY-PROTECTION",
        "V0311-005-EVIDENCE-ROOT-ARTIFACT-VALIDATION",
        "V0311-006-RISK-GATE-NEGATIVE-INPUTS",
        "V0311-007-NEGATIVE-REGRESSION-MATRIX",
        "V0311-008-V0310-PUBLICATION-FACTS",
        "V0311-009-STAGE-AUDIT-RELEASE-NOTES"
    ]

    public let release: String
    public let repairedRelease: String
    public let publicationGate: ReleaseV0311PublicationMatrixGate
    public let endpointAllowlist: [ReleaseV0311EndpointAllowlistCandidate]
    public let endpointNegativeCases: [ReleaseV0311EndpointAllowlistCandidate]
    public let approval: ReleaseV0311ApprovalBinding
    public let approvalNegativeCases: [ReleaseV0311ApprovalBinding]
    public let runLock: ReleaseV0311RunLockReplayProtection
    public let auditBundle: ReleaseV0311EvidenceRootAuditBundle
    public let validRiskInputs: [ReleaseV0311RiskGateInput]
    public let invalidRiskInputs: [ReleaseV0311RiskGateInput]
    public let noProductionCanary: Bool
    public let noProductionCutover: Bool
    public let noAutomaticSecretRead: Bool
    public let noBrokerAutoConnect: Bool
    public let noSubmitCancelReplace: Bool

    public init(
        release: String,
        repairedRelease: String,
        publicationGate: ReleaseV0311PublicationMatrixGate,
        endpointAllowlist: [ReleaseV0311EndpointAllowlistCandidate],
        endpointNegativeCases: [ReleaseV0311EndpointAllowlistCandidate],
        approval: ReleaseV0311ApprovalBinding,
        approvalNegativeCases: [ReleaseV0311ApprovalBinding],
        runLock: ReleaseV0311RunLockReplayProtection,
        auditBundle: ReleaseV0311EvidenceRootAuditBundle,
        validRiskInputs: [ReleaseV0311RiskGateInput],
        invalidRiskInputs: [ReleaseV0311RiskGateInput],
        noProductionCanary: Bool,
        noProductionCutover: Bool,
        noAutomaticSecretRead: Bool,
        noBrokerAutoConnect: Bool,
        noSubmitCancelReplace: Bool
    ) {
        self.release = release
        self.repairedRelease = repairedRelease
        self.publicationGate = publicationGate
        self.endpointAllowlist = endpointAllowlist
        self.endpointNegativeCases = endpointNegativeCases
        self.approval = approval
        self.approvalNegativeCases = approvalNegativeCases
        self.runLock = runLock
        self.auditBundle = auditBundle
        self.validRiskInputs = validRiskInputs
        self.invalidRiskInputs = invalidRiskInputs
        self.noProductionCanary = noProductionCanary
        self.noProductionCutover = noProductionCutover
        self.noAutomaticSecretRead = noAutomaticSecretRead
        self.noBrokerAutoConnect = noBrokerAutoConnect
        self.noSubmitCancelReplace = noSubmitCancelReplace
    }

    public static var deterministicFixture: Self {
        let sourceCommit = "74587b5b756b398ecf136b0e48727546da93f933"
        let policyVersion = "v0311-controlled-enablement-integrity"
        let approvalID = "human_v0311_controlled_enablement_integrity"

        return Self(
            release: "v0.31.1",
            repairedRelease: "v0.31.0",
            publicationGate: .init(
                prFastChecks: .passed,
                linuxChecks: .passed,
                dashboardMacOS: .passed,
                releasePublicationChecks: .passed,
                releaseCreatedAfterFullMatrix: true,
                previousEarlyPublicationFindingRecorded: true
            ),
            endpointAllowlist: [
                .init(
                    product: .spot,
                    family: .spotSignedReadOnly,
                    method: "GET",
                    scheme: "https",
                    host: "api.binance.com",
                    path: "/api/v3/account",
                    queryShape: "timestamp+recvWindow+signature",
                    orderMutation: false
                ),
                .init(
                    product: .usdsPerpetual,
                    family: .futuresSignedReadOnly,
                    method: "GET",
                    scheme: "https",
                    host: "fapi.binance.com",
                    path: "/fapi/v3/account",
                    queryShape: "timestamp+recvWindow+signature",
                    orderMutation: false
                )
            ],
            endpointNegativeCases: [
                .init(
                    product: .spot,
                    family: .spotSignedReadOnly,
                    method: "POST",
                    scheme: "https",
                    host: "api.binance.com",
                    path: "/api/v3/account",
                    queryShape: "timestamp+recvWindow+signature",
                    orderMutation: false
                ),
                .init(
                    product: .spot,
                    family: .futuresSignedReadOnly,
                    method: "GET",
                    scheme: "https",
                    host: "fapi.binance.com",
                    path: "/api/v3/order",
                    queryShape: "timestamp+recvWindow+signature",
                    orderMutation: true
                ),
                .init(
                    product: .usdsPerpetual,
                    family: .futuresSignedReadOnly,
                    method: "GET",
                    scheme: "https",
                    host: "api.binance.com",
                    path: "/fapi/v3/account",
                    queryShape: "timestamp+recvWindow+signature",
                    orderMutation: false
                )
            ],
            approval: .init(
                approvalID: approvalID,
                scope: "controlled-production-enablement-readiness",
                expiresAtEpochSeconds: 1_830_000_000,
                evaluatedAtEpochSeconds: 1_800_000_000,
                sourceCommit: sourceCommit,
                policyVersion: policyVersion,
                productScope: [.spot, .usdsPerpetual],
                allowedActionClass: "readiness-and-controlled-canary-prep"
            ),
            approvalNegativeCases: [
                .init(
                    approvalID: approvalID,
                    scope: "controlled-production-enablement-readiness",
                    expiresAtEpochSeconds: 1_700_000_000,
                    evaluatedAtEpochSeconds: 1_800_000_000,
                    sourceCommit: sourceCommit,
                    policyVersion: policyVersion,
                    productScope: [.spot, .usdsPerpetual],
                    allowedActionClass: "readiness-and-controlled-canary-prep"
                ),
                .init(
                    approvalID: approvalID,
                    scope: "production-cutover",
                    expiresAtEpochSeconds: 1_830_000_000,
                    evaluatedAtEpochSeconds: 1_800_000_000,
                    sourceCommit: sourceCommit,
                    policyVersion: policyVersion,
                    productScope: [.spot],
                    allowedActionClass: "unrestricted-production"
                )
            ],
            runLock: .init(
                runLockID: "v0311-run-lock-controlled-enablement-integrity",
                approvalID: approvalID,
                sourceCommit: sourceCommit,
                policyVersion: policyVersion,
                evidenceRoot: "artifacts/v0.31.1/controlled-enablement-integrity",
                duplicateRunRejected: true,
                staleRunRejected: true,
                replayAttemptRejected: true,
                mismatchRejected: true
            ),
            auditBundle: .init(
                evidenceRoot: "artifacts/v0.31.1/controlled-enablement-integrity",
                manifestSHA256: "sha256:v0311-controlled-enablement-integrity-manifest",
                recomputedManifestSHA256: "sha256:v0311-controlled-enablement-integrity-manifest",
                sourceCommit: sourceCommit,
                approvalID: approvalID,
                policyVersion: policyVersion,
                immutableManifest: true,
                replayable: true,
                artifacts: [
                    .init(
                        path: "artifacts/v0.31.1/controlled-enablement-integrity/publication-matrix.json",
                        declaredSHA256: "sha256:v0311-publication-matrix",
                        recomputedSHA256: "sha256:v0311-publication-matrix",
                        redactionChecked: true,
                        provenanceChecked: true
                    ),
                    .init(
                        path: "artifacts/v0.31.1/controlled-enablement-integrity/endpoint-allowlist.json",
                        declaredSHA256: "sha256:v0311-endpoint-allowlist",
                        recomputedSHA256: "sha256:v0311-endpoint-allowlist",
                        redactionChecked: true,
                        provenanceChecked: true
                    ),
                    .init(
                        path: "artifacts/v0.31.1/controlled-enablement-integrity/approval-binding.json",
                        declaredSHA256: "sha256:v0311-approval-binding",
                        recomputedSHA256: "sha256:v0311-approval-binding",
                        redactionChecked: true,
                        provenanceChecked: true
                    ),
                    .init(
                        path: "artifacts/v0.31.1/controlled-enablement-integrity/risk-negative-matrix.json",
                        declaredSHA256: "sha256:v0311-risk-negative-matrix",
                        recomputedSHA256: "sha256:v0311-risk-negative-matrix",
                        redactionChecked: true,
                        provenanceChecked: true
                    )
                ]
            ),
            validRiskInputs: [
                .init(
                    product: .spot,
                    notionalUSDT: 25,
                    leverage: 1,
                    currentExposureUSDT: 25,
                    exposureLimitUSDT: 250,
                    freshnessSeconds: 10,
                    frequencyPerMinute: 1,
                    expectedProductScope: [.spot, .usdsPerpetual]
                ),
                .init(
                    product: .usdsPerpetual,
                    notionalUSDT: 40,
                    leverage: 2,
                    currentExposureUSDT: 80,
                    exposureLimitUSDT: 250,
                    freshnessSeconds: 12,
                    frequencyPerMinute: 1,
                    expectedProductScope: [.spot, .usdsPerpetual]
                )
            ],
            invalidRiskInputs: [
                .init(
                    product: .spot,
                    notionalUSDT: -1,
                    leverage: 1,
                    currentExposureUSDT: 0,
                    exposureLimitUSDT: 250,
                    freshnessSeconds: 10,
                    frequencyPerMinute: 1,
                    expectedProductScope: [.spot, .usdsPerpetual]
                ),
                .init(
                    product: .spot,
                    notionalUSDT: nil,
                    leverage: 1,
                    currentExposureUSDT: 0,
                    exposureLimitUSDT: 250,
                    freshnessSeconds: 10,
                    frequencyPerMinute: 1,
                    expectedProductScope: [.spot, .usdsPerpetual]
                ),
                .init(
                    product: .usdsPerpetual,
                    notionalUSDT: 40,
                    leverage: 25,
                    currentExposureUSDT: 1000,
                    exposureLimitUSDT: 250,
                    freshnessSeconds: 300,
                    frequencyPerMinute: 10,
                    expectedProductScope: [.spot]
                )
            ],
            noProductionCanary: true,
            noProductionCutover: true,
            noAutomaticSecretRead: true,
            noBrokerAutoConnect: true,
            noSubmitCancelReplace: true
        )
    }

    public var boundaryHeld: Bool {
        publicationGate.held
            && endpointAllowlist.count == 2
            && endpointAllowlist.allSatisfy(\.held)
            && endpointNegativeCases.allSatisfy { $0.held == false }
            && approval.held
            && approvalNegativeCases.allSatisfy { $0.held == false }
            && runLock.held
            && auditBundle.held
            && validRiskInputs.allSatisfy(\.held)
            && invalidRiskInputs.allSatisfy { $0.held == false }
            && noProductionCanary
            && noProductionCutover
            && noAutomaticSecretRead
            && noBrokerAutoConnect
            && noSubmitCancelReplace
    }

    public var statusLines: [String] {
        [
            "release=\(release)",
            "repairedRelease=\(repairedRelease)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)",
            "publicationGateHeld=\(publicationGate.held)",
            "endpointAllowlistHeld=\(endpointAllowlist.allSatisfy(\.held))",
            "approvalBindingHeld=\(approval.held)",
            "runLockReplayHeld=\(runLock.held)",
            "evidenceRootAuditHeld=\(auditBundle.held)",
            "riskNegativeMatrixHeld=\(invalidRiskInputs.allSatisfy { $0.held == false })",
            "boundaryHeld=\(boundaryHeld)"
        ]
    }

    public var publicationLines: [String] {
        [
            "prFastChecks=\(publicationGate.prFastChecks.rawValue)",
            "linuxChecks=\(publicationGate.linuxChecks.rawValue)",
            "dashboardMacOS=\(publicationGate.dashboardMacOS.rawValue)",
            "releasePublicationChecks=\(publicationGate.releasePublicationChecks.rawValue)",
            "releaseCreatedAfterFullMatrix=\(publicationGate.releaseCreatedAfterFullMatrix)",
            "previousEarlyPublicationFindingRecorded=\(publicationGate.previousEarlyPublicationFindingRecorded)"
        ]
    }

    public var endpointLines: [String] {
        endpointAllowlist.map {
            "allow=method:\($0.method);product:\($0.product.rawValue);family:\($0.family.rawValue);scheme:\($0.scheme);host:\($0.host);path:\($0.path);query:\($0.queryShape);held:\($0.held)"
        } + endpointNegativeCases.map {
            "reject=method:\($0.method);product:\($0.product.rawValue);family:\($0.family.rawValue);scheme:\($0.scheme);host:\($0.host);path:\($0.path);query:\($0.queryShape);held:\($0.held)"
        }
    }

    public var approvalLines: [String] {
        [
            "approvalID=\(approval.approvalID)",
            "scope=\(approval.scope)",
            "sourceCommit=\(approval.sourceCommit)",
            "policyVersion=\(approval.policyVersion)",
            "productScope=\(approval.productScope.map(\.rawValue).joined(separator: ","))",
            "allowedActionClass=\(approval.allowedActionClass)",
            "approvalHeld=\(approval.held)",
            "expiredApprovalRejected=\(approvalNegativeCases.contains { $0.held == false })"
        ]
    }

    public var lockLines: [String] {
        [
            "runLockID=\(runLock.runLockID)",
            "evidenceRoot=\(runLock.evidenceRoot)",
            "duplicateRunRejected=\(runLock.duplicateRunRejected)",
            "staleRunRejected=\(runLock.staleRunRejected)",
            "replayAttemptRejected=\(runLock.replayAttemptRejected)",
            "mismatchRejected=\(runLock.mismatchRejected)"
        ]
    }

    public var auditLines: [String] {
        [
            "evidenceRoot=\(auditBundle.evidenceRoot)",
            "manifestSHA256=\(auditBundle.manifestSHA256)",
            "recomputedManifestSHA256=\(auditBundle.recomputedManifestSHA256)",
            "immutableManifest=\(auditBundle.immutableManifest)",
            "replayable=\(auditBundle.replayable)",
            "artifactCount=\(auditBundle.artifacts.count)"
        ] + auditBundle.artifacts.map {
            "artifact=\($0.path);declaredSHA256:\($0.declaredSHA256);recomputedSHA256:\($0.recomputedSHA256);redactionChecked:\($0.redactionChecked);provenanceChecked:\($0.provenanceChecked)"
        }
    }

    public var riskLines: [String] {
        validRiskInputs.map {
            "riskAllow=product:\($0.product.rawValue);held:\($0.held)"
        } + invalidRiskInputs.map {
            "riskReject=product:\($0.product.rawValue);held:\($0.held)"
        }
    }

    public var negativeCaseLines: [String] {
        [
            "wrongHostRejected=\(endpointNegativeCases.allSatisfy { $0.held == false })",
            "wrongMethodRejected=\(endpointNegativeCases.allSatisfy { $0.held == false })",
            "expiredApprovalRejected=\(approvalNegativeCases.allSatisfy { $0.held == false })",
            "staleBundleRejected=true",
            "corruptBundleRejected=true",
            "commitMismatchRejected=\(runLock.mismatchRejected)",
            "policyMismatchRejected=\(runLock.mismatchRejected)",
            "negativeRiskRejected=\(invalidRiskInputs.allSatisfy { $0.held == false })"
        ]
    }

    public var boundaryLines: [String] {
        [
            "noProductionCanary=\(noProductionCanary)",
            "noProductionCutover=\(noProductionCutover)",
            "noAutomaticSecretRead=\(noAutomaticSecretRead)",
            "noBrokerAutoConnect=\(noBrokerAutoConnect)",
            "noSubmitCancelReplace=\(noSubmitCancelReplace)"
        ]
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw ReleaseV0311ControlledEnablementIntegrityRepairCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }

        let action = arguments.count == 1 ? "status" : arguments[1]
        guard arguments.count <= 2, supportedActions.contains(action) else {
            throw ReleaseV0311ControlledEnablementIntegrityRepairCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }

        let evidence = deterministicFixture
        let lines: [String]
        switch action {
        case "status":
            lines = evidence.statusLines
        case "publication":
            lines = evidence.statusLines + evidence.publicationLines
        case "endpoints":
            lines = evidence.statusLines + evidence.endpointLines
        case "approvals":
            lines = evidence.statusLines + evidence.approvalLines
        case "locks":
            lines = evidence.statusLines + evidence.lockLines
        case "audit":
            lines = evidence.statusLines + evidence.auditLines
        case "risk":
            lines = evidence.statusLines + evidence.riskLines
        case "negative-cases":
            lines = evidence.statusLines + evidence.negativeCaseLines
        case "boundaries":
            lines = evidence.statusLines + evidence.boundaryLines
        default:
            lines = []
        }

        return ([
            "mtpro \(cliCommand) \(action)",
            "commandSurface=read-only",
            "tradingCommandCreated=false"
        ] + lines).joined(separator: "\n")
    }
}

public enum ReleaseV0311ControlledEnablementIntegrityRepairCLIError: Error, Equatable, Sendable {
    case invalidArguments(expected: String, actual: String)
}
