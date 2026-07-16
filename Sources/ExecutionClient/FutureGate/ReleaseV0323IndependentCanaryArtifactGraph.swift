import Crypto
import Foundation

// GH-1540-ADD-COMPLETE-V0323-NEGATIVE-MATRIX
// TVM-RELEASE-V0323-COMPLETE-EVIDENCE-INTEGRITY-NEGATIVE-MATRIX
// V0323-006-COMPLETE-EVIDENCE-INTEGRITY-NEGATIVE-MATRIX

// GH-1538-ADD-INDEPENDENT-CANARY-ARTIFACT-GRAPH
// TVM-RELEASE-V0323-INDEPENDENT-CANARY-ARTIFACT-GRAPH
// V0323-004-INDEPENDENT-CANARY-ARTIFACT-GRAPH

public enum ReleaseV0323LinkedArtifactKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case oms
    case reconciliation
    case rollback
    case incident
}

public struct ReleaseV0323OperationSemanticPayload: Codable, Equatable, Sendable {
    public let runID: String
    public let product: ReleaseV0310Product
    public let action: ReleaseV0320CanaryAction
    public let sequence: Int
    public let eventID: String
    public let idempotencyKey: String
    public let sourceCommit: String
    public let createdAtEpochSeconds: Int

    public init(
        runID: String,
        product: ReleaseV0310Product,
        action: ReleaseV0320CanaryAction,
        sequence: Int,
        eventID: String,
        idempotencyKey: String,
        sourceCommit: String,
        createdAtEpochSeconds: Int
    ) {
        self.runID = runID
        self.product = product
        self.action = action
        self.sequence = sequence
        self.eventID = eventID
        self.idempotencyKey = idempotencyKey
        self.sourceCommit = sourceCommit
        self.createdAtEpochSeconds = createdAtEpochSeconds
    }
}

public struct ReleaseV0323LinkedArtifactReference: Codable, Equatable, Sendable {
    public let kind: ReleaseV0323LinkedArtifactKind
    public let artifactID: String
    public let relativePath: String
    public let sha256: String

    public init(
        kind: ReleaseV0323LinkedArtifactKind,
        artifactID: String,
        relativePath: String,
        sha256: String
    ) {
        self.kind = kind
        self.artifactID = artifactID
        self.relativePath = relativePath
        self.sha256 = sha256
    }
}

public struct ReleaseV0323OperationArtifact: Codable, Equatable, Sendable {
    public let schemaVersion: String
    public let semantic: ReleaseV0323OperationSemanticPayload
    public let semanticSHA256: String
    public let linkedArtifacts: [ReleaseV0323LinkedArtifactReference]

    public init(
        schemaVersion: String = "v0323-operation-artifact-v1",
        semantic: ReleaseV0323OperationSemanticPayload,
        semanticSHA256: String,
        linkedArtifacts: [ReleaseV0323LinkedArtifactReference]
    ) {
        self.schemaVersion = schemaVersion
        self.semantic = semantic
        self.semanticSHA256 = semanticSHA256
        self.linkedArtifacts = linkedArtifacts
    }
}

public struct ReleaseV0323IndependentLinkedArtifact: Codable, Equatable, Sendable {
    public let schemaVersion: String
    public let artifactID: String
    public let kind: ReleaseV0323LinkedArtifactKind
    public let runID: String
    public let product: ReleaseV0310Product
    public let action: ReleaseV0320CanaryAction
    public let operationEventID: String
    public let operationRelativePath: String
    public let operationSemanticSHA256: String
    public let sourceCommit: String
    public let createdAtEpochSeconds: Int
    public let status: String

    public init(
        schemaVersion: String = "v0323-independent-linked-artifact-v1",
        artifactID: String,
        kind: ReleaseV0323LinkedArtifactKind,
        runID: String,
        product: ReleaseV0310Product,
        action: ReleaseV0320CanaryAction,
        operationEventID: String,
        operationRelativePath: String,
        operationSemanticSHA256: String,
        sourceCommit: String,
        createdAtEpochSeconds: Int,
        status: String
    ) {
        self.schemaVersion = schemaVersion
        self.artifactID = artifactID
        self.kind = kind
        self.runID = runID
        self.product = product
        self.action = action
        self.operationEventID = operationEventID
        self.operationRelativePath = operationRelativePath
        self.operationSemanticSHA256 = operationSemanticSHA256
        self.sourceCommit = sourceCommit
        self.createdAtEpochSeconds = createdAtEpochSeconds
        self.status = status
    }
}

public struct ReleaseV0323OperationArtifactRecord: Codable, Equatable, Sendable {
    public let relativePath: String
    public let sha256: String
    public let byteCount: Int

    public init(relativePath: String, sha256: String, byteCount: Int) {
        self.relativePath = relativePath
        self.sha256 = sha256
        self.byteCount = byteCount
    }
}

public struct ReleaseV0323IndependentArtifactGraphReport: Codable, Equatable, Sendable {
    public let operationCount: Int
    public let linkedArtifactCount: Int
    public let products: [ReleaseV0310Product]
    public let actions: [ReleaseV0320CanaryAction]
    public let checksumsVerified: Bool
    public let reverseReferencesVerified: Bool
    public let completeArtifactKindsVerified: Bool
    public let productionCutoverAuthorized: Bool

    public var boundaryHeld: Bool {
        operationCount == 6
            && linkedArtifactCount == 24
            && products == [.spot, .usdsPerpetual]
            && actions == [.submit, .status, .cancel]
            && checksumsVerified
            && reverseReferencesVerified
            && completeArtifactKindsVerified
            && productionCutoverAuthorized == false
    }
}

public enum ReleaseV0323IndependentArtifactGraphError: Error, Equatable, Sendable {
    case unsafePath(String)
    case missingArtifact(String)
    case byteCountMismatch(String)
    case checksumMismatch(String)
    case invalidOperation(String)
    case invalidSemanticChecksum(String)
    case incompleteOperationSet
    case missingRequiredKinds(String)
    case duplicateArtifactID(String)
    case invalidLinkedArtifact(String)
    case reverseReferenceMismatch(String)
    case staleArtifact(String)
}

public enum ReleaseV0323IndependentCanaryArtifactGraphValidator {
    public static let validationAnchor = "TVM-RELEASE-V0323-INDEPENDENT-CANARY-ARTIFACT-GRAPH"
    public static let requiredKinds = Set(ReleaseV0323LinkedArtifactKind.allCases)

    public static func sha256Hex(for data: Data) -> String {
        "sha256:" + SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
    }

    public static func semanticSHA256(
        for semantic: ReleaseV0323OperationSemanticPayload
    ) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return sha256Hex(for: try encoder.encode(semantic))
    }

    public static func validate(
        evidenceRoot: URL,
        operationRecords: [ReleaseV0323OperationArtifactRecord],
        expectedRunID: String,
        expectedSourceCommit: String,
        trustedEvaluationEpochSeconds: Int,
        maxArtifactAgeSeconds: Int
    ) throws -> ReleaseV0323IndependentArtifactGraphReport {
        let containment: ReleaseV0323EvidenceRootContainment
        do {
            containment = try ReleaseV0323EvidenceRootContainment(evidenceRoot: evidenceRoot)
        } catch {
            throw ReleaseV0323IndependentArtifactGraphError.unsafePath(evidenceRoot.path)
        }
        var observedOperations = Set<ReleaseV0323ObservedOperation>()
        var artifactIDs = Set<String>()
        var linkedArtifactCount = 0

        for record in operationRecords {
            let operationData = try read(
                relativePath: record.relativePath,
                containment: containment
            )
            guard operationData.count == record.byteCount else {
                throw ReleaseV0323IndependentArtifactGraphError.byteCountMismatch(record.relativePath)
            }
            guard record.sha256.hasPrefix("sha256:"), sha256Hex(for: operationData) == record.sha256 else {
                throw ReleaseV0323IndependentArtifactGraphError.checksumMismatch(record.relativePath)
            }

            let operation: ReleaseV0323OperationArtifact
            do {
                operation = try JSONDecoder().decode(ReleaseV0323OperationArtifact.self, from: operationData)
            } catch {
                throw ReleaseV0323IndependentArtifactGraphError.invalidOperation(record.relativePath)
            }
            guard operation.schemaVersion == "v0323-operation-artifact-v1",
                  operation.semantic.runID == expectedRunID,
                  operation.semantic.sourceCommit == expectedSourceCommit,
                  operation.semanticSHA256 == (try semanticSHA256(for: operation.semantic))
            else {
                throw ReleaseV0323IndependentArtifactGraphError.invalidSemanticChecksum(record.relativePath)
            }
            guard Set(operation.linkedArtifacts.map(\.kind)) == requiredKinds,
                  operation.linkedArtifacts.count == requiredKinds.count
            else {
                throw ReleaseV0323IndependentArtifactGraphError.missingRequiredKinds(record.relativePath)
            }

            observedOperations.insert(
                ReleaseV0323ObservedOperation(
                    product: operation.semantic.product,
                    action: operation.semantic.action
                )
            )

            for reference in operation.linkedArtifacts {
                guard reference.artifactID.isEmpty == false,
                      artifactIDs.insert(reference.artifactID).inserted
                else {
                    throw ReleaseV0323IndependentArtifactGraphError.duplicateArtifactID(reference.artifactID)
                }
                let linkedData = try read(
                    relativePath: reference.relativePath,
                    containment: containment
                )
                guard reference.sha256.hasPrefix("sha256:"), sha256Hex(for: linkedData) == reference.sha256 else {
                    throw ReleaseV0323IndependentArtifactGraphError.checksumMismatch(reference.relativePath)
                }

                let linked: ReleaseV0323IndependentLinkedArtifact
                do {
                    linked = try JSONDecoder().decode(ReleaseV0323IndependentLinkedArtifact.self, from: linkedData)
                } catch {
                    throw ReleaseV0323IndependentArtifactGraphError.invalidLinkedArtifact(reference.relativePath)
                }
                guard linked.schemaVersion == "v0323-independent-linked-artifact-v1",
                      linked.artifactID == reference.artifactID,
                      linked.kind == reference.kind,
                      linked.runID == operation.semantic.runID,
                      linked.product == operation.semantic.product,
                      linked.action == operation.semantic.action,
                      linked.operationEventID == operation.semantic.eventID,
                      linked.operationRelativePath == record.relativePath,
                      linked.operationSemanticSHA256 == operation.semanticSHA256,
                      linked.sourceCommit == operation.semantic.sourceCommit,
                      linked.status.isEmpty == false
                else {
                    throw ReleaseV0323IndependentArtifactGraphError.reverseReferenceMismatch(reference.relativePath)
                }
                guard linked.createdAtEpochSeconds <= trustedEvaluationEpochSeconds,
                      maxArtifactAgeSeconds >= 0,
                      trustedEvaluationEpochSeconds - linked.createdAtEpochSeconds <= maxArtifactAgeSeconds
                else {
                    throw ReleaseV0323IndependentArtifactGraphError.staleArtifact(reference.relativePath)
                }
                linkedArtifactCount += 1
            }
        }

        guard observedOperations == ReleaseV0323TrustedGitHubProvenanceLoader.requiredOperations,
              operationRecords.count == observedOperations.count
        else {
            throw ReleaseV0323IndependentArtifactGraphError.incompleteOperationSet
        }

        return ReleaseV0323IndependentArtifactGraphReport(
            operationCount: operationRecords.count,
            linkedArtifactCount: linkedArtifactCount,
            products: [.spot, .usdsPerpetual],
            actions: [.submit, .status, .cancel],
            checksumsVerified: true,
            reverseReferencesVerified: true,
            completeArtifactKindsVerified: true,
            productionCutoverAuthorized: false
        )
    }

    private static func read(
        relativePath: String,
        containment: ReleaseV0323EvidenceRootContainment
    ) throws -> Data {
        do {
            return try containment.readArtifact(relativePath: relativePath)
        } catch ReleaseV0323EvidenceRootContainmentError.missingArtifact {
            throw ReleaseV0323IndependentArtifactGraphError.missingArtifact(relativePath)
        } catch {
            throw ReleaseV0323IndependentArtifactGraphError.unsafePath(relativePath)
        }
    }
}
