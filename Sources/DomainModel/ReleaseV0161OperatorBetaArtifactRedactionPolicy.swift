import Foundation

/// ReleaseV0161OperatorBetaArtifactRedactionPolicy 是 v0.16 operator beta artifact 的唯一脱敏策略来源。
///
/// 该策略只定义本地 evidence artifact、manual workflow validator 和 Dashboard read model 可复用的
/// forbidden marker / validation anchor。它不读取 credential value，不连接 testnet 或 production endpoint，
/// 不提交订单，也不授权 production cutover。
public struct ReleaseV0161OperatorBetaArtifactRedactionPolicy:
    Codable,
    Equatable,
    Hashable,
    Sendable
{
    public let policyID: String
    public let issueID: String
    public let releaseVersion: String
    public let sourceReleaseVersion: String
    public let forbiddenMarkers: [String]
    public let validationAnchors: [String]
    public let noSecretGuardFields: [String]
    public let noProductionGuardFields: [String]

    public var policyHeld: Bool {
        policyID == Self.requiredPolicyID
            && issueID == "GH-1135"
            && releaseVersion == "v0.16.1"
            && sourceReleaseVersion == "v0.16.0"
            && forbiddenMarkers == Self.requiredForbiddenMarkers
            && validationAnchors == Self.requiredValidationAnchors
            && noSecretGuardFields == Self.requiredNoSecretGuardFields
            && noProductionGuardFields == Self.requiredNoProductionGuardFields
    }

    public init(
        policyID: String = Self.requiredPolicyID,
        issueID: String = "GH-1135",
        releaseVersion: String = "v0.16.1",
        sourceReleaseVersion: String = "v0.16.0",
        forbiddenMarkers: [String] = Self.requiredForbiddenMarkers,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        noSecretGuardFields: [String] = Self.requiredNoSecretGuardFields,
        noProductionGuardFields: [String] = Self.requiredNoProductionGuardFields
    ) {
        self.policyID = policyID
        self.issueID = issueID
        self.releaseVersion = releaseVersion
        self.sourceReleaseVersion = sourceReleaseVersion
        self.forbiddenMarkers = Self.sortedUnique(forbiddenMarkers)
        self.validationAnchors = validationAnchors
        self.noSecretGuardFields = Self.sortedUnique(noSecretGuardFields)
        self.noProductionGuardFields = Self.sortedUnique(noProductionGuardFields)
    }

    public func forbiddenMarkers(in text: String) -> [String] {
        let lowered = text.lowercased()
        return forbiddenMarkers.filter { lowered.contains($0) }
    }

    public static func forbiddenMarkers(in text: String) -> [String] {
        current.forbiddenMarkers(in: text)
    }

    public static let current = ReleaseV0161OperatorBetaArtifactRedactionPolicy()

    public static let requiredPolicyID =
        "release-v0.16.1-operator-beta-artifact-redaction-policy.v1"

    public static let requiredValidationAnchors = [
        "GH-1135-VERIFY-V0161-CENTRAL-ARTIFACT-REDACTION-POLICY",
        "TVM-RELEASE-V0161-CENTRAL-ARTIFACT-REDACTION-POLICY",
        "V0161-003-SHARED-REDACTION-POLICY-SOURCE",
        "V0161-003-ARTIFACT-STORE-POLICY-USES-SHARED-SOURCE",
        "V0161-003-WORKFLOW-BUNDLE-POLICY-USES-SHARED-SOURCE",
        "V0161-003-DASHBOARD-READ-MODEL-POLICY-USES-SHARED-SOURCE",
        "V0161-003-NO-SECRET-NO-PRODUCTION-MARKERS",
        "V0161-003-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredForbiddenMarkers = [
        "api key:",
        "api.binance.com",
        "api_key",
        "apikey",
        "broker-endpoint",
        "listen_key",
        "listenkey",
        "production cutover authorized",
        "production endpoint",
        "raw broker",
        "raw order",
        "raw_order_id",
        "secret key:",
        "secret_key",
        "secretkey",
        "signature\"",
        "signature:",
        "signature=",
        "submit / cancel / replace authorized"
    ]

    public static let requiredNoSecretGuardFields = [
        "containsCredentialValue=false",
        "containsRawBrokerPayload=false",
        "containsRawOrderIdentity=false",
        "redactedEvidenceOnly=true"
    ]

    public static let requiredNoProductionGuardFields = [
        "brokerEndpointConnected=false",
        "productionCutoverAuthorized=false",
        "productionEndpointConnected=false",
        "productionOrderSubmitted=false",
        "productionSecretAutoRead=false",
        "productionTradingEnabledByDefault=false"
    ]

    private static func sortedUnique(_ values: [String]) -> [String] {
        Array(Set(values)).sorted()
    }
}
