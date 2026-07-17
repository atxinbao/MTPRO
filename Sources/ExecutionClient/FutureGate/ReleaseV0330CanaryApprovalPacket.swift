import Foundation

// GH-1543-PREPARE-V0330-HUMAN-APPROVED-CANARY-PACKET
// TVM-RELEASE-V0330-HUMAN-APPROVAL-PACKET
// V0330-002-HUMAN-APPROVED-CANARY-PACKET

public enum ReleaseV0330CanaryProduct: String, CaseIterable, Codable, Sendable {
    case spot
    case usdsPerpetual
}

public enum ReleaseV0330ApprovalEvidenceOrigin: String, Codable, Sendable {
    case humanRecorded = "human-recorded"
    case deterministicFixture = "deterministic-fixture"
}

public struct ReleaseV0330HumanApprovalRecord: Codable, Equatable, Sendable {
    public let recordID: String
    public let approverIdentity: String
    public let approvedAtEpochSeconds: Int64
    public let sourceCommit: String
    public let attestationSHA256: String
    public let evidenceOrigin: ReleaseV0330ApprovalEvidenceOrigin

    public init(
        recordID: String,
        approverIdentity: String,
        approvedAtEpochSeconds: Int64,
        sourceCommit: String,
        attestationSHA256: String,
        evidenceOrigin: ReleaseV0330ApprovalEvidenceOrigin
    ) {
        self.recordID = recordID
        self.approverIdentity = approverIdentity
        self.approvedAtEpochSeconds = approvedAtEpochSeconds
        self.sourceCommit = sourceCommit
        self.attestationSHA256 = attestationSHA256
        self.evidenceOrigin = evidenceOrigin
    }
}

public struct ReleaseV0330CanaryProductScope: Codable, Equatable, Sendable {
    public let product: ReleaseV0330CanaryProduct
    public let symbolAllowlist: [String]
    public let maximumNotionalMinorUnits: Int64
    public let allowedOrderTypes: [String]
    public let maximumLeverageBasisPoints: Int

    public init(
        product: ReleaseV0330CanaryProduct,
        symbolAllowlist: [String],
        maximumNotionalMinorUnits: Int64,
        allowedOrderTypes: [String],
        maximumLeverageBasisPoints: Int
    ) {
        self.product = product
        self.symbolAllowlist = symbolAllowlist
        self.maximumNotionalMinorUnits = maximumNotionalMinorUnits
        self.allowedOrderTypes = allowedOrderTypes
        self.maximumLeverageBasisPoints = maximumLeverageBasisPoints
    }
}

public struct ReleaseV0330CanaryApprovalPacket: Codable, Equatable, Sendable {
    public let packetID: String
    public let operatorIdentity: String
    public let sourceCommit: String
    public let createdAtEpochSeconds: Int64
    public let expiresAtEpochSeconds: Int64
    public let productScopes: [ReleaseV0330CanaryProductScope]
    public let killSwitchEvidenceReference: String
    public let noTradeEvidenceReference: String
    public let rollbackOwnerIdentity: String
    public let humanApproval: ReleaseV0330HumanApprovalRecord?
    public let productionCutoverAuthorized: Bool
    public let defaultProductionTradingEnabled: Bool

    public init(
        packetID: String,
        operatorIdentity: String,
        sourceCommit: String,
        createdAtEpochSeconds: Int64,
        expiresAtEpochSeconds: Int64,
        productScopes: [ReleaseV0330CanaryProductScope],
        killSwitchEvidenceReference: String,
        noTradeEvidenceReference: String,
        rollbackOwnerIdentity: String,
        humanApproval: ReleaseV0330HumanApprovalRecord? = nil,
        productionCutoverAuthorized: Bool = false,
        defaultProductionTradingEnabled: Bool = false
    ) {
        self.packetID = packetID
        self.operatorIdentity = operatorIdentity
        self.sourceCommit = sourceCommit
        self.createdAtEpochSeconds = createdAtEpochSeconds
        self.expiresAtEpochSeconds = expiresAtEpochSeconds
        self.productScopes = productScopes
        self.killSwitchEvidenceReference = killSwitchEvidenceReference
        self.noTradeEvidenceReference = noTradeEvidenceReference
        self.rollbackOwnerIdentity = rollbackOwnerIdentity
        self.humanApproval = humanApproval
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.defaultProductionTradingEnabled = defaultProductionTradingEnabled
    }

    public func canonicalJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }
}

public enum ReleaseV0330ApprovalPacketFailure: String, Codable, Sendable {
    case invalidPacketIdentity = "invalid-packet-identity"
    case invalidOperatorIdentity = "invalid-operator-identity"
    case invalidSourceCommit = "invalid-source-commit"
    case sourceCommitMismatch = "source-commit-mismatch"
    case invalidValidityWindow = "invalid-validity-window"
    case approvalExpired = "approval-expired"
    case approvalNotYetValid = "approval-not-yet-valid"
    case productScopeMismatch = "product-scope-mismatch"
    case invalidSymbolAllowlist = "invalid-symbol-allowlist"
    case invalidNotionalCap = "invalid-notional-cap"
    case invalidOrderTypeScope = "invalid-order-type-scope"
    case invalidLeverageCap = "invalid-leverage-cap"
    case missingKillSwitchEvidence = "missing-kill-switch-evidence"
    case missingNoTradeEvidence = "missing-no-trade-evidence"
    case missingRollbackOwner = "missing-rollback-owner"
    case missingHumanApproval = "missing-human-approval"
    case fixtureApprovalEvidence = "fixture-approval-evidence"
    case invalidHumanApprovalIdentity = "invalid-human-approval-identity"
    case approvalSourceCommitMismatch = "approval-source-commit-mismatch"
    case invalidApprovalAttestation = "invalid-approval-attestation"
    case productionCutoverAlreadyAuthorized = "production-cutover-already-authorized"
    case productionTradingDefaultEnabled = "production-trading-default-enabled"
}

public struct ReleaseV0330ApprovalPacketValidationReport: Codable, Equatable, Sendable {
    public let failures: [ReleaseV0330ApprovalPacketFailure]

    public var approvalPacketRecorded: Bool { failures.isEmpty }
    public var observedCanaryExecutionAuthorized: Bool { false }
    public var productionCutoverAuthorized: Bool { false }
}

public enum ReleaseV0330CanaryApprovalPacketValidator {
    public static func validate(
        _ packet: ReleaseV0330CanaryApprovalPacket,
        expectedSourceCommit: String,
        nowEpochSeconds: Int64
    ) -> ReleaseV0330ApprovalPacketValidationReport {
        var failures: [ReleaseV0330ApprovalPacketFailure] = []

        if packet.packetID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append(.invalidPacketIdentity)
        }
        if packet.operatorIdentity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append(.invalidOperatorIdentity)
        }
        if isCommit(packet.sourceCommit) == false || isCommit(expectedSourceCommit) == false {
            failures.append(.invalidSourceCommit)
        } else if packet.sourceCommit != expectedSourceCommit {
            failures.append(.sourceCommitMismatch)
        }
        if packet.createdAtEpochSeconds >= packet.expiresAtEpochSeconds {
            failures.append(.invalidValidityWindow)
        }
        if nowEpochSeconds < packet.createdAtEpochSeconds {
            failures.append(.approvalNotYetValid)
        }
        if nowEpochSeconds >= packet.expiresAtEpochSeconds {
            failures.append(.approvalExpired)
        }

        let scopes = Dictionary(grouping: packet.productScopes, by: \.product)
        if Set(scopes.keys) != Set(ReleaseV0330CanaryProduct.allCases)
            || packet.productScopes.count != ReleaseV0330CanaryProduct.allCases.count
        {
            failures.append(.productScopeMismatch)
        }
        for scope in packet.productScopes {
            let symbols = scope.symbolAllowlist.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if symbols.isEmpty || symbols.contains(where: { $0.isEmpty || $0 != $0.uppercased() })
                || Set(symbols).count != symbols.count
            {
                failures.append(.invalidSymbolAllowlist)
            }
            if scope.maximumNotionalMinorUnits <= 0 {
                failures.append(.invalidNotionalCap)
            }
            let orderTypes = scope.allowedOrderTypes.map { $0.uppercased() }
            if orderTypes.isEmpty || Set(orderTypes).count != orderTypes.count
                || orderTypes.contains(where: { $0 != "LIMIT" })
            {
                failures.append(.invalidOrderTypeScope)
            }
            switch scope.product {
            case .spot where scope.maximumLeverageBasisPoints != 10_000:
                failures.append(.invalidLeverageCap)
            case .usdsPerpetual where !(10_000...20_000).contains(scope.maximumLeverageBasisPoints):
                failures.append(.invalidLeverageCap)
            default:
                break
            }
        }

        if packet.killSwitchEvidenceReference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append(.missingKillSwitchEvidence)
        }
        if packet.noTradeEvidenceReference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append(.missingNoTradeEvidence)
        }
        if packet.rollbackOwnerIdentity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append(.missingRollbackOwner)
        }

        guard let approval = packet.humanApproval else {
            failures.append(.missingHumanApproval)
            return report(failures, packet: packet)
        }
        if approval.evidenceOrigin != .humanRecorded {
            failures.append(.fixtureApprovalEvidence)
        }
        if approval.recordID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || approval.approverIdentity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        {
            failures.append(.invalidHumanApprovalIdentity)
        }
        if approval.sourceCommit != packet.sourceCommit {
            failures.append(.approvalSourceCommitMismatch)
        }
        if approval.approvedAtEpochSeconds < packet.createdAtEpochSeconds
            || approval.approvedAtEpochSeconds >= packet.expiresAtEpochSeconds
        {
            failures.append(.invalidValidityWindow)
        }
        if isSHA256(approval.attestationSHA256) == false {
            failures.append(.invalidApprovalAttestation)
        }

        return report(failures, packet: packet)
    }

    private static func report(
        _ failures: [ReleaseV0330ApprovalPacketFailure],
        packet: ReleaseV0330CanaryApprovalPacket
    ) -> ReleaseV0330ApprovalPacketValidationReport {
        var result = failures
        if packet.productionCutoverAuthorized {
            result.append(.productionCutoverAlreadyAuthorized)
        }
        if packet.defaultProductionTradingEnabled {
            result.append(.productionTradingDefaultEnabled)
        }
        return ReleaseV0330ApprovalPacketValidationReport(failures: Array(Set(result)).sorted { $0.rawValue < $1.rawValue })
    }

    private static func isCommit(_ value: String) -> Bool {
        value.count == 40 && value.allSatisfy { $0.isHexDigit && $0.isASCII }
    }

    private static func isSHA256(_ value: String) -> Bool {
        guard value.hasPrefix("sha256:") else { return false }
        let digest = value.dropFirst("sha256:".count)
        return digest.count == 64 && digest.allSatisfy { $0.isHexDigit && $0.isASCII }
    }
}
