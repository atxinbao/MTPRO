import Foundation

// GH-1539-BLOCK-SYMLINK-REALPATH-ESCAPE
// TVM-RELEASE-V0323-EVIDENCE-ROOT-REALPATH-CONTAINMENT
// V0323-005-EVIDENCE-ROOT-REALPATH-CONTAINMENT

public enum ReleaseV0323EvidenceRootContainmentError: Error, Equatable, Sendable {
    case invalidRoot(String)
    case unsafeRelativePath(String)
    case symbolicLinkComponent(String)
    case resolvedPathOutsideRoot(String)
    case canonicalPathMismatch(String)
    case missingArtifact(String)
}

public struct ReleaseV0323EvidenceRootContainment: Sendable {
    public static let validationAnchor = "TVM-RELEASE-V0323-EVIDENCE-ROOT-REALPATH-CONTAINMENT"

    public let evidenceRoot: URL
    public let canonicalEvidenceRoot: URL

    public init(evidenceRoot: URL) throws {
        let fileManager = FileManager.default
        let root = evidenceRoot.standardizedFileURL
        var isDirectory: ObjCBool = false
        guard root.isFileURL,
              root.path.hasPrefix("/"),
              fileManager.fileExists(atPath: root.path, isDirectory: &isDirectory),
              isDirectory.boolValue
        else {
            throw ReleaseV0323EvidenceRootContainmentError.invalidRoot(evidenceRoot.path)
        }
        guard Self.isSymbolicLink(root, fileManager: fileManager) == false else {
            throw ReleaseV0323EvidenceRootContainmentError.invalidRoot(evidenceRoot.path)
        }

        self.evidenceRoot = root
        canonicalEvidenceRoot = root.resolvingSymlinksInPath().standardizedFileURL
    }

    public func readArtifact(relativePath: String) throws -> Data {
        let beforeRead = try resolvedArtifactURL(relativePath: relativePath)
        let data: Data
        do {
            data = try Data(contentsOf: beforeRead)
        } catch {
            throw ReleaseV0323EvidenceRootContainmentError.missingArtifact(relativePath)
        }
        let afterRead = try resolvedArtifactURL(relativePath: relativePath)
        guard beforeRead.path == afterRead.path else {
            throw ReleaseV0323EvidenceRootContainmentError.canonicalPathMismatch(relativePath)
        }
        return data
    }

    public func resolvedArtifactURL(relativePath: String) throws -> URL {
        let components = try validatedComponents(relativePath: relativePath)
        let fileManager = FileManager.default
        var candidate = evidenceRoot

        for component in components {
            candidate.appendPathComponent(component)
            guard Self.isSymbolicLink(candidate, fileManager: fileManager) == false else {
                throw ReleaseV0323EvidenceRootContainmentError.symbolicLinkComponent(relativePath)
            }
        }

        guard fileManager.fileExists(atPath: candidate.path) else {
            throw ReleaseV0323EvidenceRootContainmentError.missingArtifact(relativePath)
        }

        let resolved = candidate.resolvingSymlinksInPath().standardizedFileURL
        guard Self.path(resolved.path, isInside: canonicalEvidenceRoot.path) else {
            throw ReleaseV0323EvidenceRootContainmentError.resolvedPathOutsideRoot(relativePath)
        }

        let expectedCanonical = components.reduce(canonicalEvidenceRoot) {
            $0.appendingPathComponent($1)
        }.standardizedFileURL
        guard resolved.path == expectedCanonical.path else {
            throw ReleaseV0323EvidenceRootContainmentError.canonicalPathMismatch(relativePath)
        }
        return resolved
    }

    private func validatedComponents(relativePath: String) throws -> [String] {
        guard relativePath.isEmpty == false,
              relativePath.hasPrefix("/") == false,
              relativePath.hasPrefix("~") == false,
              relativePath.contains("\\") == false
        else {
            throw ReleaseV0323EvidenceRootContainmentError.unsafeRelativePath(relativePath)
        }

        let rawComponents = relativePath.split(separator: "/", omittingEmptySubsequences: false)
        guard rawComponents.isEmpty == false,
              rawComponents.allSatisfy({ $0.isEmpty == false && $0 != "." && $0 != ".." })
        else {
            throw ReleaseV0323EvidenceRootContainmentError.unsafeRelativePath(relativePath)
        }
        return rawComponents.map(String.init)
    }

    private static func isSymbolicLink(_ url: URL, fileManager: FileManager) -> Bool {
        (try? fileManager.destinationOfSymbolicLink(atPath: url.path)) != nil
    }

    private static func path(_ path: String, isInside root: String) -> Bool {
        path == root || path.hasPrefix(root.hasSuffix("/") ? root : root + "/")
    }
}
