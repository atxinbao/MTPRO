import Crypto
import DomainModel
import Foundation

// GH-1073 static contract boundary:
// cliCommand=testnet-execution
// explicitTestnetModeRequired=true
// operatorConfirmationRequired=true
// redactedOutputPrinted=true
// noProductionFallback=true
// appendOnlyChecksummedEvidenceRequired=true
// existingGuardedRuntimeRequired=true
// rawSecretPrinted=false
// rawCredentialPrinted=false
// rawOrderIdentityPrinted=false
// rawBrokerPayloadPrinted=false
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false

/// ReleaseV0150BinanceSpotTestnetCLIOperatorAction 固定 v0.15.0 CLI 可请求的 testnet 操作集合。
///
/// 该枚举只描述 Binance Spot Testnet submit / cancel / cancel-replace operator flow。
/// 它不引入 Futures、production endpoint、broker adapter 或真实生产订单语义。
public enum ReleaseV0150BinanceSpotTestnetCLIOperatorAction: String, CaseIterable, Codable, Sendable {
    case submit
    case cancel
    case cancelReplace = "cancel-replace"
}

/// ReleaseV0150BinanceSpotTestnetCLIOperatorInput 是 `mtpro testnet-execution` 的已验证输入。
///
/// CLI 必须显式传入 `--testnet` 和 operator confirmation phrase。该输入只保存
/// intent / append-only log reference 等脱敏 evidence handle，不保存 secret、API key、
/// order identity material 或 raw broker payload。
public struct ReleaseV0150BinanceSpotTestnetCLIOperatorInput: Codable, Equatable, Sendable {
    public let inputID: Identifier
    public let action: ReleaseV0150BinanceSpotTestnetCLIOperatorAction
    public let intentID: Identifier
    public let networkEventLogID: Identifier
    public let operatorConfirmationDigest: String
    public let explicitTestnetMode: Bool
    public let operatorConfirmationRequired: Bool
    public let operatorConfirmationAccepted: Bool
    public let redactedOutputRequested: Bool
    public let noProductionFallback: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        inputID: Identifier,
        action: ReleaseV0150BinanceSpotTestnetCLIOperatorAction,
        intentID: Identifier,
        networkEventLogID: Identifier,
        operatorConfirmationPhrase: String,
        explicitTestnetMode: Bool,
        operatorConfirmationRequired: Bool = true,
        redactedOutputRequested: Bool = true,
        noProductionFallback: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        let confirmationDigest = Self.operatorConfirmationDigest(operatorConfirmationPhrase)
        let confirmationAccepted = operatorConfirmationPhrase == Self.requiredOperatorConfirmationPhrase
        guard inputID == Self.deterministicID(
            action: action,
            intentID: intentID,
            networkEventLogID: networkEventLogID,
            operatorConfirmationDigest: confirmationDigest
        ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150CLIOperatorFlow.inputID",
                expected: Self.deterministicID(
                    action: action,
                    intentID: intentID,
                    networkEventLogID: networkEventLogID,
                    operatorConfirmationDigest: confirmationDigest
                ).rawValue,
                actual: inputID.rawValue
            )
        }
        guard explicitTestnetMode else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150CLIOperatorFlow.missingExplicitTestnetMode")
        }
        guard operatorConfirmationRequired, confirmationAccepted else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150CLIOperatorFlow.operatorConfirmation")
        }
        guard redactedOutputRequested, noProductionFallback else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150CLIOperatorFlow.unredactedOrFallbackOutput")
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.inputID = inputID
        self.action = action
        self.intentID = intentID
        self.networkEventLogID = networkEventLogID
        self.operatorConfirmationDigest = confirmationDigest
        self.explicitTestnetMode = explicitTestnetMode
        self.operatorConfirmationRequired = operatorConfirmationRequired
        self.operatorConfirmationAccepted = confirmationAccepted
        self.redactedOutputRequested = redactedOutputRequested
        self.noProductionFallback = noProductionFallback
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public var boundaryHeld: Bool {
        explicitTestnetMode
            && operatorConfirmationRequired
            && operatorConfirmationAccepted
            && redactedOutputRequested
            && noProductionFallback
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public static let requiredOperatorConfirmationPhrase = "CONFIRM_BINANCE_SPOT_TESTNET_EXECUTION"

    public static func deterministicID(
        action: ReleaseV0150BinanceSpotTestnetCLIOperatorAction,
        intentID: Identifier,
        networkEventLogID: Identifier,
        operatorConfirmationDigest: String
    ) -> Identifier {
        .constant(
            [
                "gh-1073-v0150-cli-operator-input",
                action.rawValue,
                intentID.rawValue,
                networkEventLogID.rawValue,
                operatorConfirmationDigest
            ].joined(separator: ":"),
            field: "releaseV0150CLIOperatorFlow.inputID"
        )
    }

    public static func operatorConfirmationDigest(_ phrase: String) -> String {
        stableSHA256(["gh-1073-operator-confirmation", phrase])
    }

    fileprivate static func stableSHA256(_ components: [String]) -> String {
        let data = components.joined(separator: "\u{1f}").data(using: .utf8) ?? Data()
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150CLIOperatorFlow.input.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetCLIOperatorEvidence 是 CLI 打印的脱敏执行 evidence 摘要。
///
/// 它证明 operator 已显式选择 Spot Testnet、确认没有 production trading fallback，并且
/// CLI 输出只包含 checksummed / redacted evidence handle。真实网络动作仍必须通过既有
/// v0.15.0 guarded runtime 产生 append-only network execution event log。
public struct ReleaseV0150BinanceSpotTestnetCLIOperatorEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let input: ReleaseV0150BinanceSpotTestnetCLIOperatorInput
    public let cliCommand: String
    public let venueName: String
    public let executionProductScope: String
    public let explicitTestnetModeRequired: Bool
    public let operatorConfirmationRequired: Bool
    public let operatorConfirmationAccepted: Bool
    public let redactedOutputPrinted: Bool
    public let appendOnlyChecksummedEvidenceRequired: Bool
    public let noProductionFallback: Bool
    public let existingGuardedRuntimeRequired: Bool
    public let rawSecretPrinted: Bool
    public let rawCredentialPrinted: Bool
    public let rawOrderIdentityPrinted: Bool
    public let rawBrokerPayloadPrinted: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        evidenceID: Identifier,
        input: ReleaseV0150BinanceSpotTestnetCLIOperatorInput,
        cliCommand: String = ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.cliCommand,
        venueName: String = "Binance",
        executionProductScope: String = "Binance Spot Testnet",
        explicitTestnetModeRequired: Bool = true,
        operatorConfirmationRequired: Bool = true,
        redactedOutputPrinted: Bool = true,
        appendOnlyChecksummedEvidenceRequired: Bool = true,
        noProductionFallback: Bool = true,
        existingGuardedRuntimeRequired: Bool = true,
        rawSecretPrinted: Bool = false,
        rawCredentialPrinted: Bool = false,
        rawOrderIdentityPrinted: Bool = false,
        rawBrokerPayloadPrinted: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard input.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150CLIOperatorFlow.evidence.input")
        }
        guard evidenceID == Self.deterministicID(inputID: input.inputID) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150CLIOperatorFlow.evidenceID",
                expected: Self.deterministicID(inputID: input.inputID).rawValue,
                actual: evidenceID.rawValue
            )
        }
        guard cliCommand == ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.cliCommand,
              venueName == "Binance",
              executionProductScope == "Binance Spot Testnet",
              explicitTestnetModeRequired,
              operatorConfirmationRequired,
              input.operatorConfirmationAccepted,
              redactedOutputPrinted,
              appendOnlyChecksummedEvidenceRequired,
              noProductionFallback,
              existingGuardedRuntimeRequired else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150CLIOperatorFlow.evidence.unheldOperatorGate")
        }
        try Self.forbid(rawSecretPrinted, "rawSecretPrinted")
        try Self.forbid(rawCredentialPrinted, "rawCredentialPrinted")
        try Self.forbid(rawOrderIdentityPrinted, "rawOrderIdentityPrinted")
        try Self.forbid(rawBrokerPayloadPrinted, "rawBrokerPayloadPrinted")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150CLIOperatorFlow.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.evidenceID = evidenceID
        self.input = input
        self.cliCommand = cliCommand
        self.venueName = venueName
        self.executionProductScope = executionProductScope
        self.explicitTestnetModeRequired = explicitTestnetModeRequired
        self.operatorConfirmationRequired = operatorConfirmationRequired
        self.operatorConfirmationAccepted = input.operatorConfirmationAccepted
        self.redactedOutputPrinted = redactedOutputPrinted
        self.appendOnlyChecksummedEvidenceRequired = appendOnlyChecksummedEvidenceRequired
        self.noProductionFallback = noProductionFallback
        self.existingGuardedRuntimeRequired = existingGuardedRuntimeRequired
        self.rawSecretPrinted = rawSecretPrinted
        self.rawCredentialPrinted = rawCredentialPrinted
        self.rawOrderIdentityPrinted = rawOrderIdentityPrinted
        self.rawBrokerPayloadPrinted = rawBrokerPayloadPrinted
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        input.boundaryHeld
            && cliCommand == ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.cliCommand
            && venueName == "Binance"
            && executionProductScope == "Binance Spot Testnet"
            && explicitTestnetModeRequired
            && operatorConfirmationRequired
            && operatorConfirmationAccepted
            && redactedOutputPrinted
            && appendOnlyChecksummedEvidenceRequired
            && noProductionFallback
            && existingGuardedRuntimeRequired
            && rawSecretPrinted == false
            && rawCredentialPrinted == false
            && rawOrderIdentityPrinted == false
            && rawBrokerPayloadPrinted == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public var redactedOutputLines: [String] {
        [
            "mtpro \(cliCommand)",
            "issue=GH-1073",
            "verificationAnchor=GH-1073-VERIFY-V0150-CLI-OPERATOR-FLOW",
            "validationAnchor=TVM-RELEASE-V0150-CLI-OPERATOR-FLOW",
            "requiredAnchors=\(validationAnchors.joined(separator: ","))",
            "action=\(input.action.rawValue)",
            "venueName=\(venueName)",
            "executionProductScope=\(executionProductScope)",
            "explicitTestnetModeRequired=\(explicitTestnetModeRequired)",
            "explicitTestnetMode=true",
            "operatorConfirmationRequired=\(operatorConfirmationRequired)",
            "operatorConfirmationAccepted=\(operatorConfirmationAccepted)",
            "operatorConfirmationDigest=\(input.operatorConfirmationDigest)",
            "intentID=\(input.intentID.rawValue)",
            "networkEventLogID=\(input.networkEventLogID.rawValue)",
            "evidenceID=\(evidenceID.rawValue)",
            "appendOnlyChecksummedEvidenceRequired=\(appendOnlyChecksummedEvidenceRequired)",
            "existingGuardedRuntimeRequired=\(existingGuardedRuntimeRequired)",
            "redactedOutputPrinted=\(redactedOutputPrinted)",
            "credentialReference=<redacted>",
            "orderIdentity=<redacted>",
            "rawSecretPrinted=\(rawSecretPrinted)",
            "rawCredentialPrinted=\(rawCredentialPrinted)",
            "rawOrderIdentityPrinted=\(rawOrderIdentityPrinted)",
            "rawBrokerPayloadPrinted=\(rawBrokerPayloadPrinted)",
            "noProductionFallback=\(noProductionFallback)",
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "productionSecretAutoRead=\(productionSecretAutoRead)",
            "productionEndpointConnected=\(productionEndpointConnected)",
            "brokerEndpointConnected=\(brokerEndpointConnected)",
            "productionOrderSubmitted=\(productionOrderSubmitted)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "boundaryHeld=\(boundaryHeld)"
        ]
    }

    public static let requiredValidationAnchors = [
        "GH-1073-VERIFY-V0150-CLI-OPERATOR-FLOW",
        "TVM-RELEASE-V0150-CLI-OPERATOR-FLOW",
        "V0150-008-EXPLICIT-TESTNET-MODE",
        "V0150-008-OPERATOR-CONFIRMATION-REQUIRED",
        "V0150-008-REDACTED-OUTPUT",
        "V0150-008-NO-PRODUCTION-FALLBACK",
        "V0150-008-APPEND-ONLY-EVIDENCE-REFERENCE",
        "V0150-008-NO-PRODUCTION-CUTOVER"
    ]

    public static func deterministicID(inputID: Identifier) -> Identifier {
        .constant(
            "gh-1073-v0150-cli-operator-evidence:\(inputID.rawValue)",
            field: "releaseV0150CLIOperatorFlow.evidenceID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150CLIOperatorFlow.evidence.\(field)")
        }
    }
}

/// ReleaseV0150BinanceSpotTestnetCLIOperatorFlow 解析并执行 v0.15.0 operator CLI surface。
///
/// 该 flow 不直接创建 foundation networking request/session，也不读取任何 secret。它把 operator 命令压缩成
/// 脱敏 evidence 输出，并要求后续真实 testnet network action 继续走 #1068 / #1069 / #1070
/// guarded runtime 与 #1071 append-only event log。
public enum ReleaseV0150BinanceSpotTestnetCLIOperatorFlow {
    public static let cliCommand = "testnet-execution"
    public static let actionFlag = "--action"
    public static let testnetFlag = "--testnet"
    public static let operatorConfirmFlag = "--operator-confirm"
    public static let intentIDFlag = "--intent-id"
    public static let networkEventLogIDFlag = "--network-event-log-id"
    public static let outputFlag = "--output"
    public static let redactedOutput = "redacted"

    public static func commandLineOutput(arguments: [String]) throws -> String {
        try evidence(arguments: arguments).redactedOutputLines.joined(separator: "\n")
    }

    public static func evidence(arguments: [String]) throws -> ReleaseV0150BinanceSpotTestnetCLIOperatorEvidence {
        let input = try parse(arguments: arguments)
        return try ReleaseV0150BinanceSpotTestnetCLIOperatorEvidence(
            evidenceID: ReleaseV0150BinanceSpotTestnetCLIOperatorEvidence.deterministicID(inputID: input.inputID),
            input: input
        )
    }

    public static func parse(arguments: [String]) throws -> ReleaseV0150BinanceSpotTestnetCLIOperatorInput {
        guard arguments.first == cliCommand else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150CLIOperatorFlow.command",
                expected: cliCommand,
                actual: arguments.first ?? "missing"
            )
        }

        var explicitTestnetMode = false
        var action: ReleaseV0150BinanceSpotTestnetCLIOperatorAction?
        var confirmationPhrase: String?
        var intentID: Identifier?
        var networkEventLogID: Identifier?
        var redactedOutputRequested = true

        var index = 1
        while index < arguments.count {
            switch arguments[index] {
            case testnetFlag:
                explicitTestnetMode = true
                index += 1
            case actionFlag:
                let rawAction = try value(after: actionFlag, arguments: arguments, index: index)
                guard let parsedAction = ReleaseV0150BinanceSpotTestnetCLIOperatorAction(rawValue: rawAction) else {
                    throw CoreError.liveTradingBoundaryContractMismatch(
                        field: "releaseV0150CLIOperatorFlow.action",
                        expected: ReleaseV0150BinanceSpotTestnetCLIOperatorAction.allCases.map(\.rawValue).joined(separator: ","),
                        actual: rawAction
                    )
                }
                action = parsedAction
                index += 2
            case operatorConfirmFlag:
                confirmationPhrase = try value(after: operatorConfirmFlag, arguments: arguments, index: index)
                index += 2
            case intentIDFlag:
                intentID = .constant(try value(after: intentIDFlag, arguments: arguments, index: index))
                index += 2
            case networkEventLogIDFlag:
                networkEventLogID = .constant(try value(after: networkEventLogIDFlag, arguments: arguments, index: index))
                index += 2
            case outputFlag:
                let output = try value(after: outputFlag, arguments: arguments, index: index)
                guard output == redactedOutput else {
                    throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150CLIOperatorFlow.output.\(output)")
                }
                redactedOutputRequested = true
                index += 2
            case "--production", "--prod", "--production-endpoint", "--broker-endpoint":
                throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0150CLIOperatorFlow.productionFallback.\(arguments[index])")
            default:
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "releaseV0150CLIOperatorFlow.arguments",
                    expected: "\(cliCommand) --testnet --action submit|cancel|cancel-replace --operator-confirm <phrase> --intent-id <id> --network-event-log-id <id> [--output redacted]",
                    actual: arguments.joined(separator: " ")
                )
            }
        }

        guard let action, let confirmationPhrase, let intentID, let networkEventLogID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150CLIOperatorFlow.requiredArguments",
                expected: "--testnet --action --operator-confirm --intent-id --network-event-log-id",
                actual: arguments.joined(separator: " ")
            )
        }

        let confirmationDigest = ReleaseV0150BinanceSpotTestnetCLIOperatorInput.operatorConfirmationDigest(
            confirmationPhrase
        )
        return try ReleaseV0150BinanceSpotTestnetCLIOperatorInput(
            inputID: ReleaseV0150BinanceSpotTestnetCLIOperatorInput.deterministicID(
                action: action,
                intentID: intentID,
                networkEventLogID: networkEventLogID,
                operatorConfirmationDigest: confirmationDigest
            ),
            action: action,
            intentID: intentID,
            networkEventLogID: networkEventLogID,
            operatorConfirmationPhrase: confirmationPhrase,
            explicitTestnetMode: explicitTestnetMode,
            redactedOutputRequested: redactedOutputRequested
        )
    }

    private static func value(after flag: String, arguments: [String], index: Int) throws -> String {
        guard index + 1 < arguments.count, arguments[index + 1].hasPrefix("--") == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0150CLIOperatorFlow.\(flag)",
                expected: "value",
                actual: "missing"
            )
        }
        return arguments[index + 1]
    }
}
