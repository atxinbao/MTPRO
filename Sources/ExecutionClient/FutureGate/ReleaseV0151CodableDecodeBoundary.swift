import DomainModel
import Foundation

// GH-1100-VERIFY-V0151-CODABLE-DECODE-CLOSEOUT
// TVM-RELEASE-V0151-CODABLE-DECODE-CLOSEOUT
// V0151-007-CODABLE-DECODE-VALIDATION
// V0151-007-CORRUPTED-JSON-FAILS-CLOSED
// V0151-007-CHECKSUM-MISMATCH-FAILS-CLOSED
// V0151-007-PRODUCTION-HOST-MUTATION-REJECTED
// V0151-007-NO-PRODUCTION-CUTOVER

/// Release v0.15.1 的 Codable decode 统一边界辅助。
///
/// v0.15/v0.15.1 的执行证据构造器已经包含生产禁区、checksum 和 deterministic id 校验。
/// 但外部 JSON artifact 进入系统时会走 `Decodable`，因此每个 decode 入口必须重新执行同等边界校验，
/// 防止损坏 JSON、production host mutation 或 checksum mismatch 被解码成可信证据。
enum ReleaseV0151CodableDecodeBoundary {
    static func require(_ condition: Bool, field: String, expected: String, actual: String) throws {
        guard condition else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: field,
                expected: expected,
                actual: actual
            )
        }
    }

    static func requireHeld(_ condition: Bool, field: String) throws {
        try require(condition, field: field, expected: "decode-time boundary held", actual: "mutated artifact")
    }
}
