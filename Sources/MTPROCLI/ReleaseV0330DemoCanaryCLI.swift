import ExecutionClient
import Foundation

public struct ReleaseV0330DemoCanaryCLIConfiguration: Codable, Equatable, Sendable {
    public let runID: String
    public let ownerID: String
    public let nonce: String
    public let sourceCommit: String
    public let approvalPacket: ReleaseV0330CanaryApprovalPacket
    public let executionAuthorization: ReleaseV0330ObservedCanaryExecutionAuthorization
    public let orderPlan: ReleaseV0330ObservedCanaryOrderPlan
    public let artifactRootPath: String
    public let riskGatePassed: Bool
    public let killSwitchClear: Bool
    public let noTradeClear: Bool
    public let rollbackEvidenceReference: String
    public let evaluationEpochSeconds: Int64
}

public enum ReleaseV0330DemoCanaryCLIError: Error, Equatable, Sendable {
    case invalidArguments
    case confirmationRejected
    case invalidConfiguration
    case missingCredentialEnvironment
    case unsafeArtifactRoot
    case runEvidenceAlreadyExists
}

public enum ReleaseV0330DemoCanaryCLI {
    public static let cliCommand = "v0.33-demo-canary"
    public static let prepareCommand = "v0.33-demo-canary-prepare"
    public static let confirmationPhrase = "CONFIRM_BINANCE_DEMO_ONLY"
    public static let apiKeyEnvironmentName = "MTPRO_BINANCE_DEMO_API_KEY"
    public static let secretKeyEnvironmentName = "MTPRO_BINANCE_DEMO_SECRET_KEY"

    public static func prepareConfigurationOutput(
        arguments: [String],
        environment: [String: String] = ProcessInfo.processInfo.environment,
        nowEpochSeconds: Int64 = Int64(Date().timeIntervalSince1970)
    ) throws -> String {
        guard arguments.count == 13, arguments[0] == prepareCommand,
              let product = ReleaseV0330CanaryProduct(rawValue: arguments[1]),
              ["BUY", "SELL"].contains(arguments[3]),
              let priceMinorUnits = Int64(arguments[4]), priceMinorUnits > 0,
              let quantityAtomicUnits = Int64(arguments[5]), quantityAtomicUnits > 0,
              let baseAssetScale = Int(arguments[6]), (1...12).contains(baseAssetScale),
              let notionalCapMinorUnits = Int64(arguments[7]), notionalCapMinorUnits > 0,
              let leverageBasisPoints = Int(arguments[8]),
              arguments[12] == confirmationPhrase,
              Self.validSourceCommit(arguments[11])
        else {
            throw ReleaseV0330DemoCanaryCLIError.invalidArguments
        }
        let symbol = arguments[2]
        guard symbol.isEmpty == false, symbol == symbol.uppercased(),
              let notionalMinorUnits = Self.notionalMinorUnits(
                  priceMinorUnits: priceMinorUnits,
                  quantityAtomicUnits: quantityAtomicUnits,
                  baseAssetScale: baseAssetScale
              ),
              notionalMinorUnits > 0,
              notionalMinorUnits <= notionalCapMinorUnits,
              (product == .spot && leverageBasisPoints == 10_000)
                || (product == .usdsPerpetual
                    && (10_000...20_000).contains(leverageBasisPoints))
        else {
            throw ReleaseV0330DemoCanaryCLIError.invalidConfiguration
        }

        let sourceCommit = arguments[11]
        let operatorIdentity = environment["GITHUB_ACTOR"]
            ?? environment["USER"]
            ?? "local-operator"
        let issueNumber = product == .spot ? 1544 : 1545
        let shortDigest = String(sourceCommit.suffix(8))
            + "-"
            + String(nowEpochSeconds)
        let packetID = "v0330-demo-packet-\(shortDigest)"
        let planID = "v0330-demo-plan-\(shortDigest)"
        let plan = ReleaseV0330ObservedCanaryOrderPlan(
            planID: planID,
            approvalPacketID: packetID,
            sourceCommit: sourceCommit,
            product: product,
            issueNumber: issueNumber,
            symbol: symbol,
            side: arguments[3],
            orderType: "LIMIT",
            timeInForce: "GTC",
            priceQuoteMinorUnits: priceMinorUnits,
            quantityBaseAtomicUnits: quantityAtomicUnits,
            baseAssetScale: baseAssetScale,
            notionalMinorUnits: notionalMinorUnits,
            leverageBasisPoints: leverageBasisPoints,
            clientOrderID: ReleaseV0330ObservedCanaryOrderPlan.deterministicClientOrderID(
                planID: planID,
                sourceCommit: sourceCommit,
                product: product,
                symbol: symbol,
                issueNumber: issueNumber
            )
        )
        let planSHA256 = try plan.canonicalSHA256()
        let approval = ReleaseV0330HumanApprovalRecord(
            recordID: "v0330-demo-approval-\(shortDigest)",
            approverIdentity: operatorIdentity,
            approvedAtEpochSeconds: nowEpochSeconds,
            sourceCommit: sourceCommit,
            attestationSHA256: planSHA256,
            evidenceOrigin: .humanRecorded
        )
        let packet = ReleaseV0330CanaryApprovalPacket(
            packetID: packetID,
            operatorIdentity: operatorIdentity,
            sourceCommit: sourceCommit,
            createdAtEpochSeconds: nowEpochSeconds - 1,
            expiresAtEpochSeconds: nowEpochSeconds + 900,
            productScopes: [
                ReleaseV0330CanaryProductScope(
                    product: .spot,
                    symbolAllowlist: [symbol],
                    maximumNotionalMinorUnits: notionalCapMinorUnits,
                    allowedOrderTypes: ["LIMIT"],
                    maximumLeverageBasisPoints: 10_000
                ),
                ReleaseV0330CanaryProductScope(
                    product: .usdsPerpetual,
                    symbolAllowlist: [symbol],
                    maximumNotionalMinorUnits: notionalCapMinorUnits,
                    allowedOrderTypes: ["LIMIT"],
                    maximumLeverageBasisPoints: max(10_000, leverageBasisPoints)
                ),
            ],
            killSwitchEvidenceReference: "operator-confirmed-demo-kill-switch-clear",
            noTradeEvidenceReference: "operator-confirmed-demo-no-trade-clear",
            rollbackOwnerIdentity: operatorIdentity,
            humanApproval: approval,
            productionCutoverAuthorized: false,
            defaultProductionTradingEnabled: false
        )
        let authorization = ReleaseV0330ObservedCanaryExecutionAuthorization(
            recordID: "v0330-demo-authorization-\(shortDigest)",
            approvalPacketID: packetID,
            approverIdentity: operatorIdentity,
            sourceCommit: sourceCommit,
            product: product,
            symbol: symbol,
            issueNumber: issueNumber,
            authorizedAtEpochSeconds: nowEpochSeconds,
            expiresAtEpochSeconds: nowEpochSeconds + 900,
            attestationSHA256: planSHA256,
            orderPlanSHA256: planSHA256,
            evidenceOrigin: .humanRecorded,
            oneShot: true
        )
        let configuration = ReleaseV0330DemoCanaryCLIConfiguration(
            runID: "v0330-demo-\(product.rawValue)-\(shortDigest)",
            ownerID: operatorIdentity.replacingOccurrences(of: "/", with: "-"),
            nonce: "nonce-\(shortDigest)",
            sourceCommit: sourceCommit,
            approvalPacket: packet,
            executionAuthorization: authorization,
            orderPlan: plan,
            artifactRootPath: arguments[9],
            riskGatePassed: true,
            killSwitchClear: true,
            noTradeClear: true,
            rollbackEvidenceReference: "operator-confirmed-demo-cancel-rollback",
            evaluationEpochSeconds: nowEpochSeconds
        )
        let destination = URL(fileURLWithPath: arguments[10]).standardizedFileURL
        guard destination.isFileURL,
              FileManager.default.fileExists(atPath: destination.path) == false
        else {
            throw ReleaseV0330DemoCanaryCLIError.invalidConfiguration
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        try encoder.encode(configuration).write(to: destination, options: .withoutOverwriting)
        return [
            "v0.33-demo-canary-prepare",
            "configuration=\(destination.path)",
            "environment=demo",
            "product=\(product.rawValue)",
            "symbol=\(symbol)",
            "notionalMinorUnits=\(notionalMinorUnits)",
            "expiresAtEpochSeconds=\(nowEpochSeconds + 900)",
            "productionCutoverAuthorized=false",
        ].joined(separator: "\n")
    }

    public static func commandLineOutput(
        arguments: [String],
        environment: [String: String] = ProcessInfo.processInfo.environment,
        networkLoader: any ReleaseV0330CanaryNetworkLoading =
            ReleaseV0330URLSessionCanaryNetworkLoader()
    ) async throws -> String {
        guard arguments.count == 3, arguments[0] == cliCommand else {
            throw ReleaseV0330DemoCanaryCLIError.invalidArguments
        }
        guard arguments[2] == confirmationPhrase else {
            throw ReleaseV0330DemoCanaryCLIError.confirmationRejected
        }

        let configurationURL = URL(fileURLWithPath: arguments[1]).standardizedFileURL
        guard configurationURL.isFileURL,
              let data = try? Data(contentsOf: configurationURL),
              let configuration = try? JSONDecoder().decode(
                  ReleaseV0330DemoCanaryCLIConfiguration.self,
                  from: data
              )
        else {
            throw ReleaseV0330DemoCanaryCLIError.invalidConfiguration
        }

        guard let apiKey = environment[apiKeyEnvironmentName]?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              apiKey.isEmpty == false,
              let secretKey = environment[secretKeyEnvironmentName]?
                .trimmingCharacters(in: .whitespacesAndNewlines),
              secretKey.isEmpty == false
        else {
            throw ReleaseV0330DemoCanaryCLIError.missingCredentialEnvironment
        }

        let artifactRoot = URL(fileURLWithPath: configuration.artifactRootPath)
            .standardizedFileURL
        guard artifactRoot.isFileURL else {
            throw ReleaseV0330DemoCanaryCLIError.unsafeArtifactRoot
        }
        let operationRoot = artifactRoot.appendingPathComponent(
            "operations",
            isDirectory: true
        )
        let lockRoot = artifactRoot.appendingPathComponent("locks", isDirectory: true)
        let artifactSink = try ReleaseV0330FilesystemCanaryArtifactSink(
            rootURL: operationRoot
        )
        let credentialProvider = ReleaseV0330InjectedCanaryCredentialProvider { reference in
            guard reference == "environment:\(apiKeyEnvironmentName)+\(secretKeyEnvironmentName)" else {
                throw ReleaseV0330DemoCanaryCLIError.missingCredentialEnvironment
            }
            return try ReleaseV0330EphemeralCanaryCredentialMaterial(
                apiKey: apiKey,
                signingSecret: secretKey
            )
        }
        let transport = ReleaseV0330ExternallyActivatedCanaryTransport(
            credentialProvider: credentialProvider,
            networkLoader: networkLoader,
            artifactSink: artifactSink
        )
        let runner = ReleaseV0330ObservedCanaryRunner(
            lockStore: ReleaseV0323PersistentRunLockStore(storageRoot: lockRoot),
            transport: transport
        )
        let request = ReleaseV0330ObservedCanaryRunRequest(
            runID: configuration.runID,
            ownerID: configuration.ownerID,
            nonce: configuration.nonce,
            sourceCommit: configuration.sourceCommit,
            approvalPacket: configuration.approvalPacket,
            executionAuthorization: configuration.executionAuthorization,
            orderPlan: configuration.orderPlan,
            environment: .demo,
            baseURL: ReleaseV0330CanaryEnvironment.demo.endpointBaseURL(
                for: configuration.orderPlan.product
            ),
            credentialReference:
                "environment:\(apiKeyEnvironmentName)+\(secretKeyEnvironmentName)",
            riskGatePassed: configuration.riskGatePassed,
            killSwitchClear: configuration.killSwitchClear,
            noTradeClear: configuration.noTradeClear,
            rollbackEvidenceReference: configuration.rollbackEvidenceReference,
            evaluationEpochSeconds: configuration.evaluationEpochSeconds
        )
        let evidence = try await runner.run(request)
        try persistRunEvidence(evidence, under: artifactRoot)

        return [
            "v0.33-demo-canary",
            "runID=\(evidence.runID)",
            "environment=\(evidence.environment.rawValue)",
            "product=\(evidence.product.rawValue)",
            "symbol=\(evidence.symbol)",
            "actions=\(evidence.observations.map(\.action.rawValue).joined(separator: ","))",
            "artifactCount=\(evidence.observations.count + 1)",
            "rawSecretPersisted=false",
            "rawResponsePersisted=false",
            "productionCutoverAuthorized=false",
            "defaultProductionTradingEnabled=false",
        ].joined(separator: "\n")
    }

    private static func persistRunEvidence(
        _ evidence: ReleaseV0330ObservedCanaryRunEvidence,
        under artifactRoot: URL
    ) throws {
        try FileManager.default.createDirectory(
            at: artifactRoot,
            withIntermediateDirectories: true
        )
        let resolvedRoot = artifactRoot.resolvingSymlinksInPath()
        guard resolvedRoot == artifactRoot else {
            throw ReleaseV0330DemoCanaryCLIError.unsafeArtifactRoot
        }
        let evidenceURL = resolvedRoot.appendingPathComponent(
            "\(evidence.runID)-run-evidence.json"
        )
        guard FileManager.default.fileExists(atPath: evidenceURL.path) == false else {
            throw ReleaseV0330DemoCanaryCLIError.runEvidenceAlreadyExists
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        try encoder.encode(evidence).write(
            to: evidenceURL,
            options: .withoutOverwriting
        )
    }

    private static func notionalMinorUnits(
        priceMinorUnits: Int64,
        quantityAtomicUnits: Int64,
        baseAssetScale: Int
    ) -> Int64? {
        let product = priceMinorUnits.multipliedReportingOverflow(by: quantityAtomicUnits)
        guard product.overflow == false else { return nil }
        var divisor: Int64 = 1
        for _ in 0..<baseAssetScale {
            let next = divisor.multipliedReportingOverflow(by: 10)
            guard next.overflow == false else { return nil }
            divisor = next.partialValue
        }
        guard product.partialValue % divisor == 0 else { return nil }
        return product.partialValue / divisor
    }

    private static func validSourceCommit(_ value: String) -> Bool {
        value.count == 40 && value.allSatisfy { $0.isASCII && $0.isHexDigit }
    }

}
